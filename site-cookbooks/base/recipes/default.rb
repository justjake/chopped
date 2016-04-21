# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

# provision users who have group `sysadmin` on every box
# see https://supermarket.chef.io/cookbooks/users#recipe-overview

# get search working
include_recipe 'chef-solo-search'

include_recipe 'users::sysadmins'

# provision ssh
include_recipe 'openssh'

# set up sudo
include_recipe 'sudo'

sudo 'sysadmin' do
  group 'sysadmin'
  nopasswd true
end

# install site_packages
node.site_packages.each do |pkg|
  package pkg
end
