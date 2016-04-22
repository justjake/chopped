require 'yaml'
require 'sinatra'
require 'base64'

require_relative './lib/factorio'

# TODO: create a logger

APP_DIR = File.dirname(__FILE__)
CONFIG_PATH = ENV['CONFIG'] || File.join(APP_DIR, 'config.yml')
CONFIG = YAML::load(File.read(CONFIG_PATH))
factorio = Factorio.new(CONFIG)

get '/' do
  content_type :json
  factorio.to_json
end

get '/current_save' do
  content_type :json
  factorio.saves.current.to_json
end

post '/current_save' do
  content_type :json
  target = factorio.saves.create(params['name'])

  if !target.exist?
    halt 404, { :error => :not_found, :save => target, :action => :none }.to_json
  end

  if target == factorio.saves.current
    # TODO: is this the correct error code?
    halt 302, { :current => target, :action => :none }.to_json
  end

  prev = factorio.saves.set_current(target)
  { :prev => prev, :current => target, :action => :set_current }.to_json
end

get '/saves/:name' do
  save = factorio.saves.create(params['name'])

  if !save.exist?
    halt 404, { :error => :not_found, :save => save }
  end

  result = { :save => save }

  if save.head.exist?
    data = save.head.read

    if params['download']
      content_type 'application/octet-stream'
      next data
    end

    result[:head] = Base64.encode64(data)
  end

  content_type :json
  next result.to_json
end

# param :file can be used to upload a file
post '/saves/:name' do
  content_type :json
  created = false
  uploaded = false
  save = factorio.saves.create(params['name'])

  begin
    save.create
    created = true
  rescue Errno::EEXIST
  end

  if file = params['file']
    # TODO: ensure uploaded file is a zip
    # TODO: ensure uploaded file is under a certain size
    data = file[:tempfile].read
    save.write(data)
    uploaded = true
  end

  { :created => created, :save => save, :uploaded => uploaded }.to_json
end

get '/log' do
  content_type :json
  { :log => factorio.server.log }.to_json
end

get '/log/api' do
  file = Pathname.new('/var/log/factorio-api/current')
  { :log => file.read }.to_json
end
