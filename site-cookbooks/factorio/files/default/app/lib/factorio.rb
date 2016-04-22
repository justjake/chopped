require 'json'
require 'pathname'
require 'open3'
require 'pry'

class Factorio
  attr_accessor :config

  def initialize(config)
    @config = config
    # initialize everything
    saves
    mods
    server
  end

  ### services
  def saves
    @saves ||= Factorio::SaveService.new(self)
  end

  def mods
    @mods ||= Factorio::ModService.new(self)
  end

  def server
    @server ||= Factorio::ServerService.new(self)
  end

  ### locations
  def storage_location
    @sl ||= Pathname.new(config['save_location'])
  end

  ### execute a command
  def run(command)
    result, status = Open3.capture2e(command)
    return result
  end

  def to_json(state = nil)
    {
      :saves => saves,
      :mods => mods,
      :server => server,
    }.to_json(state)
  end
end

require_relative './factorio/base_service'
require_relative './factorio/save_service'
require_relative './factorio/server_service'
require_relative './factorio/mod_service'
