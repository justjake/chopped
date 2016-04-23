# This resource should not be used directly.
# Instead, use chopped_nginx_bare or chopped_nginx_http resources

property :path, String, :name_property => true
property :config_proc, Proc

default_action :create

helper = Chopped::Nginx::Helper.new(node)

action :create do
  execute 'check_nginx_config' do
    command "nginx -t -c #{helper.conf}"
    action :nothing
  end

  file new_resource.path do
    content Chopped::Nginx.config(&new_resource.config_proc)
    action :create
    notifies :run, 'execute[check_nginx_config]', :immediately
    notifies :reload, 'service[nginx]', :immediately
  end
end

action :delete do
  execute 'check_nginx_config' do
    command "nginx -t -c #{helper.conf}"
    action :nothing
  end

  file new_resource.path do
    action :delete
    notifies :run, 'execute[check_nginx_config]', :immediately
    notifies :reload, 'service[nginx]', :immediately
  end
end
