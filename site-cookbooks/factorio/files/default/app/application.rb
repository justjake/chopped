require 'json'
require 'yaml'
require 'pathname'
require 'open3'
require 'sinatra'

APP_DIR = File.dirname(__FILE__)
CONFIG = YAML::load(File.read(File.join(APP_DIR, 'config.yml')))

class Factorio

  class Save
    attr_accessor :factorio, :name
    def initialize(factorio, name)
      @name = name
      @factorio = factorio
    end

    def exist?
      location.exist?
    end

    def location
      Pathname.new(factorio.save_dirs.join(name))
    end

    def create
      location.mkdir
    end

    def write(data)
      save_path = location.join(factorio.config['save_name'] + '.zip')
      save_path.open('w') do |file|
        file.write(data)
      end
    end

    def ==(other)
      if other.class == self.class
        other.factorio == self.factorio && other.name == self.name
      else
        false
      end
    end
  end

  attr_accessor :config

  def initialize(config)
    @config = config
  end

  ### saves
  def current_save
    name = storage_location.join('saves').readlink.basename
    Save.new(self, name)
  end

  def set_current_save(save)
    with_stopped_service do
      storage_location.join('saves').unlink.symlink(save.location)
    end
  end

  def saves
    save_dirs.entries.map { |e| Save.new(self, e.to_s) }.reject { |save| save.name == '.' || save.name == '..' }
  end

  ### service
  def stop_service
    run('sudo sv stop factorio')
  end

  def start_service
    run('sudo sv start factorio')
  end

  def status_service
    run('sudo sv status factorio')
  end

  def with_stopped_service
    stop_service
    begin
      yield
    ensure
      start_service
    end
  end

  ### locations
  def storage_location
    @sl ||= Pathname.new(config['save_location'])
  end

  def save_dirs
    storage_location.join('save_dirs')
  end

  def run(command)
    result, status = Open3.capture2e(command)
    return result
  end
end

factorio = Factorio.new(CONFIG)

get '/' do
  content_type :json

  {
    :saves => factorio.saves.map(&:name),
    :current => factorio.current_save.name,
    :status => factorio.status_service,
  }.to_json
end

get '/current_save' do
  content_type :json
  { :save => factorio.current_save.name }.to_json
end

post '/current_save' do
  content_type :json
  target = Factorio::Save.new(factorio, params['name'])

  if !target.exist?
    halt 404, { :error => :not_found, :save => target.name, :action => :no_op }.to_json
  end

  if target == factorio.current_save
    halt 302, { :save => target.name, :action => :no_op }.to_json
  end

  old_save = factorio.current_save
  factorio.set_current_save(target)
  { :save => target.name, :action => :set_current_save, :prev_save => old_save.name }.to_json
end

post '/save' do
  content_type :json

  save = Factorio::Save.new(factorio, params['name'])
  created = false
  begin
    save.create
    created = true
  rescue Errno::EEXIST
  end
  # TODO: write save data, if given, and if the save data is a zip
  # if the save is the current save, do this in a with_stopped_service block

  # TODO: if params[make_current] or soemthing, also make the newley modified
  # save the current save.

  { :created => created, :save => save.name, :uploaded => false, :current => factorio.current_save.name }.to_json
end

get '/save/:name' do
  content_type :json

  # TODO: download the save zip file
end

get '/log' do
  # TODO: download the log file from /var/log/factorio
end

get '/log/api' do
  # TODO: download the log file from /var/log/factorio-api
end
