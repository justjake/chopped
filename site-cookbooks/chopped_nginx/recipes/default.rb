#
# Cookbook Name:: chopped_nginx
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

require 'pathname'

# install and enable the service
package node.chopped.nginx.package
service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

# make sure config directories exist
helper = Chopped::Nginx::Helper.new(node)
[helper.home, helper.http_d, helper.bare_d].map(&:to_s).each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode 00755
  end
end

# our default configuration - just requires our other config di
chopped_nginx_config_file 'nginx.conf' do
  path helper.home.join('nginx.conf').to_s
  # are you ready for this magic?
  config_proc(proc do
    comment 'this base file just includes other files'
    comment 'create nginx_bare resources to access the main nginx context'
    # the config just handles sourcing the other configs
    include helper.bare_d.join('*').to_s

    http do
      comment 'create nginx_http resources to access the http context'
      include helper.http_d.join('*').to_s
    end

    comment 'this section is required to be in the NGINX config'
    comment 'initial converge will fail unless this is defined in root config'
    events do
      # is this needed?
      worker_connections 768
    end
  end)
end

# provides absolute essentials like pids
chopped_nginx_bare '00_defaults' do
  config do
    comment 'these defaults pulled from ubuntu 14.04'
    user node.chopped.nginx.user
    worker_processes node.chopped.nginx.worker_processes
    pid node.chopped.nginx.pid_file
  end
end

chopped_nginx_http '00_defaults' do
  config do
    comment 'these defaults pulled from ubuntu 14.04'
    comment ''
    comment 'basic settings'
    sendfile :on
    tcp_nopush :on
    tcp_nodelay :on
    keepalive_timeout 65
    types_hash_max_size 2048

    comment 'mime types'
    include helper.home.join('mime.types').to_s
    default_type 'application/octet-stream'

    comment 'loggng settings'
    access_log node.chopped.nginx.access_log
    error_log node.chopped.nginx.error_log

    comment 'gzip settings'
    gzip :on
    gzip_disable '"msie6"'
  end
end
