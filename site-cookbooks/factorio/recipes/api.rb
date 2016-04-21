# Installs an HTTP API alongside your factorio game service
require 'yaml'

gem_package 'bundler'

remote_directory node.factorio.api.install_location do
  source 'app'
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, "runit_service[factorio-api]"
end

file 'config' do
  path ::File.join(node.factorio.api.install_location, 'config.yml')
  content node.factorio.to_h.merge("api" => node.factorio.api.to_h).to_yaml
end

execute 'bundle_install' do
  command 'bundle install --deployment'
  cwd node.factorio.api.install_location
end

# allow factorio user to control service status
sudo 'factorio' do
  user 'factorio'
  runas 'root'
  nopasswd true
  commands [
    '/usr/bin/sv restart factorio',
    '/usr/bin/sv status factorio',
    '/usr/bin/sv stop factorio',
    '/usr/bin/sv start factorio'
  ]
end

runit_service 'factorio-api' do
  default_logger true
end
