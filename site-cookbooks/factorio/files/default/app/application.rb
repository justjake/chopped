require 'yaml'
require 'sinatra'

require_relative './lib/factorio'

# TODO: create a logger

APP_DIR = File.dirname(__FILE__)
CONFIG = YAML::load(File.read(File.join(APP_DIR, 'config.yml')))
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
    halt 404, { :error => :not_found, :save => target.name, :action => :none }.to_json
  end

  if target == factorio.saves.current
    # TODO: is this the correct error code?
    halt 302, { :current => target, :action => :none }.to_json
  end

  prev = factorio.saves.set_current(target)
  { :prev => prev, :current => target, :action => :set_current }.to_json
end

get '/saves/:name' do
  content_type :json

  # TODO: download the save zip file
end

post '/saves/:name' do
  content_type :json

  save = factorio.saves.create(params['name'])
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

  { :created => created, :save => save, :uploaded => false, :current => factorio.saves.current }.to_json
end

get '/log' do
  # TODO: download the log file from /var/log/factorio
end

get '/log/api' do
  # TODO: download the log file from /var/log/factorio-api
end
