require 'yaml'
require_relative './lib/factorio'

APP_DIR = File.dirname(__FILE__)
CONFIG_PATH = ENV['CONFIG'] || File.join(APP_DIR, 'config.yml')
CONFIG = YAML::load(File.read(CONFIG_PATH))
factorio = Factorio.new(CONFIG)

LOG_FILE = '/var/log/factorio/current'
factorio.players.tail_file(LOG_FILE)
