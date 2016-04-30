# setup
default.chopped.nginx.package = 'nginx'
default.chopped.nginx.nginx_home = '/etc/nginx'

# base config that could be os-specific
# values here are lifted from ubuntu 14.04
default.chopped.nginx.user = 'www-data'
default.chopped.nginx.worker_processes = 4
default.chopped.nginx.pid_file = '/run/nginx.pid'
default.chopped.nginx.access_log = '/var/log/nginx/access.log'
default.chopped.nginx.error_log = '/var/log/nginx/error.log'
