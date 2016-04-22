class Factorio
  class ServerService < BaseService
    def sv_command(command)
      factorio.run("sudo sv #{command} factorio")
    end

    def stop
      sv_command('stop')
    end

    def start
      sv_command('start')
    end

    def restart
      sv_command('restart')
    end

    def status
      sv_command('status')
    end

    def while_stopped
      stop
      begin
        yield
      ensure
        start
      end
    end

    def log_file
      Pathname.new('/var/log/factorio/current')
    end

    def log
      log_file.read
    end

    def to_json(state = nil)
      { :status => status }.to_json(state)
    end
  end # end class
end
