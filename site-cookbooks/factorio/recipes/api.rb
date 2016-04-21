# Installs an HTTP API alongside your factorio game service
require 'yaml'

gem_package 'bundler'

remote_directory node.factorio.api.install_location do
  source 'app'
  owner 'root'
  group 'root'
  mode '0755'
end

file 'config' do
  path ::File.join(node.factorio.api.install_location, 'config.yml')
  contents node.factorio.to_h.to_yaml
end

execute 'bundle_install' do
  command 'bundle install --deployment'
  cwd node.factorio.api.install_location
end

runit_service 'factorio-api' do
  default_logger true
end
