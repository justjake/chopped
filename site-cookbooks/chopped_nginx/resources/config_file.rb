# This resource should not be used directly.
# Instead, use chopped_nginx_bare or chopped_nginx_http resources

property :path, String, :name_property => true
property :config_proc, Proc

default_action :create

helper = Chopped::Nginx::Helper.new(node)

action :create do
  file new_resource.path do
    content Chopped::Nginx::Config.from_dsl(new_resource.config_proc)
    action :create
    notifies :run, 'execute[check_nginx_config]', :delayed
    notifies :reload, 'service[nginx]', :delayed
  end
end

action :delete do
  file new_resource.path do
    action :delete
    notifies :run, 'execute[check_nginx_config]', :delayed
    notifies :reload, 'service[nginx]', :delayed
  end
end
