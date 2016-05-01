require 'time'
require 'slack-notifier'
require 'file-tail'

class Factorio
  class PlayerService < BaseService
    class LogLine < Struct.new("LogLone", :logged_at, :factorio_time, :words)
      TIME_FORMAT = '%a %b %d at %I:%M:%S.%6N %P'.freeze
      FACTORIO_ZERO = '0.000'.freeze
      INFO = 'Info'.freeze

      # connection events
      # 1. adding peer(ID) address(IP) sending connectionAttempt(true)
      # 2. networkTick(SOME_INT) adding peer(ID) success(true)
      # 3. lists the peerInfo for each connected peer
      # -> Received peer info for peer(ID) username(UNSERNAME)
      # -> at this point we can emit the notification for the newly added peer(ID)

      # disconnect events
      # 1. networkTick(SOME_INT) mapTick(SOME_INT) removing peer(ID) dropout(BOOLEAN)
      # -> we can look up the name for peer(ID)

      def self.parens(name)
        name = name.to_s
        "#{name}\\((?<#{name}>\\w+)\\)"
      end

      EVENTS = {
        :adding_peer => /#{parens(:networkTick)} adding #{parens(:peer)} #{parens(:success)}/,
        :peer_info => /Received peer info for #{parens(:peer)} #{parens(:username)}/,
        :removing_peer => /#{parens(:networkTick)} #{parens(:mapTick)} removing #{parens(:peer)} #{parens(:dropout)}/,
      }.freeze

      def self.from_line(line)
        exact_time, factorio_time, *words = line.split(/\s+/)
        self.new(exact_time, factorio_time, words)
      rescue ArgumentError
        # TODO: log error?
        return nil
      end

      def self.load_file(path)
        log_lines = []
        File.readlines(path).each do |line|
          event = from_line(line)
          if event.is_info?
            if event.info_event
              log_lines << event
            end
          end
        end
        log_lines
      end

      def initialize(logged_at, factorio_time, words)
        super(logged_at, factorio_time, words)
        time()
      end

      def is_factorio?
        factorio_time.to_f != 0.0 || factorio_time == FACTORIO_ZERO
      end

      def is_info?
        is_factorio? && words[0] == INFO
      end

      def info_event
        info_text = words[2..-1].join(' ')
        EVENTS.each do |name, regex|
          capture = regex.match(info_text)
          return name, capture if capture
        end
        nil
      end

      # the CPP source file in factorio where the log message was emitted
      def log_source
        if is_info?
          file, line = words[1].split(':')
          return [file, line.to_i]
        else
          nil
        end
      end

      def time
        @time ||= Time.parse(logged_at)
      rescue
        nil
      end

      def to_s
        body = words.join(' ')
        if is_info?
          event, data = info_event
          if event
            hsh = {}
            data.names.each { |n| hsh[n.to_sym] = data[n] }
            body = "event #{event.inspect} >> #{hsh.inspect}"
          end
        end
        "[ #{time.strftime(TIME_FORMAT)} ] #{factorio_time} - #{body}"
      end
    end # end class LogLine

    class Peer
      attr_accessor :username, :connected, :notified_connect, :notified_disconnect
      def initialize
        @connected = nil
        @username = nil
      end
    end

    attr_reader :peers

    def initialize(factorio)
      super(factorio)
      @peers = Hash.new { |h, k| h[k] = Peer.new }
      if factorio.config && factorio.config['api']['slack_webhook']
        @webhook = Slack::Notifier.new(factorio.config['api']['slack_webhook'])
      end
    end

    def handle_event(log_line)
      event, data = log_line.info_event
      peer_id = data[:peer]
      case event
      when :peer_info
        peers[peer_id].username = data[:username]
      when :adding_peer
        peers[peer_id].connected = true
      when :removing_peer
        peers[peer_id].connected = false
      end
      send_notifications
    end

    def send_notifications
      peers.each do |peer_id, peer|
        # connect
        if peer.connected == true && peer.username && !peer.notified_connect
          peer.notified_connect = true
          notify("user #{peer.username} connected")
        end

        # disconnect
        if peer.connected == false && peer.username && !peer.notified_disconnect
          peer.notified_disconnect = true
          notify("user #{peer.username} disconnected")
        end
      end
    end

    def notify(string)
      # this goes in our log
      puts "NOTIFY: #{string}"
      # post to slack
      if @webhook
        @webhook.ping(string)
      end
    end

    def events_in_file(filename)
      log_events = LogLine.load_file(filename)
      log_events.each do |event|
        handle_event(event)
      end
    end

    def tail_file(filename)
      File::Tail::Logfile.open(filename) do |log|
        # be responsive
        log.interval = 1
        # go to end of file
        log.backward(0)
        log.tail do |line|
          event = LogLine.from_line(line)
          if event.is_info? && event.info_event
            puts "EVENT #{event}"
            handle_event(event)
          end
        end
      end
    end

    # depends on the server service
    def log_file
      factorio.server.log_file
    end
  end
end
