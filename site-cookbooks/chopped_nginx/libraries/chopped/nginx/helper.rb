module Chopped
  module Nginx
    # path helper for NGINX config paths
    class Helper
      attr_reader :node
      def initialize(node)
        @node = node
      end

      # where all the nginx config
      def home
        Pathname.new(node.chopped.nginx.nginx_home)
      end

      # where configs that we include into the http {} context live
      def http_d
        home.join('http.conf.d')
      end

      # where configs that we include into the main context live
      def bare_d
        home.join('bare.conf.d')
      end

      # the core nginx conf file
      def conf
        home.join('nginx.conf')
      end

      # returns the name and path for base chopped_nginx_config_file resource
      def bare_resource(resource)
        inner_name = "bare_#{resource.name}"
        inner_path = bare_d.join("#{resource.name}.conf").to_s
        return inner_name, inner_path
      end

      def http_resource(resource)
        inner_name = "http_#{resource.name}"
        inner_path = http_d.join("#{resource.name}.conf").to_s
        return inner_name, inner_path
      end
    end # end Helper
  end # end Nginx
end
