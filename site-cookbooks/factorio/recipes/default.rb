#
# Cookbook Name:: factorio
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# we need runit later. install deps now.
include_recipe 'runit'

# create a service user. We do not want to run Factorio as root.
user 'factorio' do
  password '*'
  system true
  home '/dev/null'
end

exec_file = node.factorio.binary % {install_location: node.factorio.install_location}
is_installed = -> { ::File.exist?(exec_file) }

### make sure everything has the right permissions
directory '/opt' do
  not_if { File.exist?('/opt') }
  owner 'root'
  group 'root'
  mode '0755'
end

directory node.factorio.install_location do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  not_if(&is_installed)
end

### DO INSTALL
# can we put a big if around all this checking if we need to perform an install?
directory 'tmp' do
  path node.factorio.tmp_location
  recursive true
  not_if(&is_installed)
end

download_uri = node.factorio.download_uri % {version: node.factorio.version}

remote_file 'download' do
  source download_uri
  path File.join(node.factorio.tmp_location, 'factorio.tar.gz')
  not_if(&is_installed)
end

bash 'install' do
  user 'root'
  cwd node.factorio.tmp_location
  creates 'maybe'
  code <<-EOH
    ERROR=0
    tar xzf factorio.tar.gz || ERROR=1
    rmdir #{node.factorio.install_location} || ERROR=1
    mv factorio #{node.factorio.install_location} || ERROR=1
    exit $ERROR
  EOH
  not_if(&is_installed)
end
### END INSTALL

directory node.factorio.save_location do
  owner 'factorio'
  group 'factorio'
  recursive true
  mode '0755'
end

default_save_dir = ::File.join(node.factorio.save_location, 'save_dirs', 'default-save')
factorio_save_target = ::File.join(node.factorio.save_location, 'saves')

directory 'default_save' do
  owner 'factorio'
  group 'factorio'
  recursive true
  mode '0755'
  path default_save_dir
end

link 'enable_default_save' do
  to factorio_save_target
  target_file default_save_dir
  not_if { ::File.exist?(factorio_save_target) }
end

directory node.factorio.config_location do
  owner 'factorio'
  group 'factorio'
  recursive true
  mode '0755'
end

### make sure factorio goes looking for the config file in the right spot
template 'config-path' do
  owner 'root'
  group 'root'
  mode '0755'
  source 'config-path.cfg.erb'
  path ::File.join(node.factorio.install_location, 'config-path.cfg')
  # TODO: notifies runit_service[factorio] ?
end

template 'config' do
  owner 'factorio'
  group 'factorio'
  mode '0755'
  source 'config.ini.erb'
  path ::File.join(node.factorio.config_location, 'config.ini')
  # TODO: notifies runit_service[factorio] ?
end

### set up runit service
runit_service "factorio" do
  default_logger true
end
