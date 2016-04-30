# Installs an HTTP API alongside your factorio game service
include_recipe 'chopped_nginx'

require 'yaml'

# (debian) package seems to be 1000x faster than gem_package
package 'bundler'

remote_directory node.factorio.api.install_location do
  source 'app'
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, "runit_service[factorio-api]", :delayed
end

file 'config' do
  path ::File.join(node.factorio.api.install_location, 'config.yml')
  content node.factorio.to_h.merge("api" => node.factorio.api.to_h).to_yaml
end

execute 'bundle_install' do
  command 'bundle install --deployment --without development'
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

the_location = "http://unix:#{node.factorio.api.socket_location}:"

# set up reverse proxy for our factorio server
chopped_nginx_http 'factorio-api-proxy' do
  config do
    comment 'proxy to a Thin server hosting our Sinatra app'
    server do
      listen 80

      location '/' do
        proxy_set_header :Host, '$host'
        proxy_pass the_location
      end
    end
  end
end
