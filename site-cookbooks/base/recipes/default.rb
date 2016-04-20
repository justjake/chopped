# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

node.packages.each do |pkg|
  package pkg
end

# provision users who have group `sysadmin` on every box
# see https://supermarket.chef.io/cookbooks/users#recipe-overview
include_recipe 'users::sysadmins'

# provision ssh
include_recipe 'openssh'

# set up sudo
include_recipe 'sudo'

sudo 'sysadmin' do
  group 'sysadmin'
  nopasswd true
end
