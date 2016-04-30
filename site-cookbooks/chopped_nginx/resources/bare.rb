extend Chopped::BlockPropertySupport
block_property :config
default_action :create

helper = Chopped::Nginx::Helper.new(node)

action :create do
  inner_name, inner_path = helper.bare_resource(new_resource)
  chopped_nginx_config_file inner_name do
    action :create
    path inner_path
    config_proc new_resource.config
  end
end

action :delete do
  inner_name, inner_path = helper.bare_resource(new_resource)
  chopped_nginx_config_file inner_name do
    action :delete
    path inner_path
    config_proc proc { nil }
  end
end
