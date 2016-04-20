default.packages = %w(
  git
  vim
  zsh
)

# openssh hardening
default.openssh.server.permit_root_login = 'no'
default.openssh.server.password_authentication = 'no'
default.openssh.server.allow_groups = 'sysadmin'
default.openssh.server.port = '2222'
default.openssh.server.login_grace_time = '30'
default.openssh.server.use_p_a_m = 'no'

# allow using sudo LWRP
default.authorization.sudo.include_sudoers_d = true
