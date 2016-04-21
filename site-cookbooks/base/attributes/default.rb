# install some basics
default.site_packages = [
  'git',
  'vim',
  'zsh',
]

### openssh
default.openssh.server.port = 22

# ubuntu defaults
default.openssh.server.protocol = 2
default.openssh.server.host_key = [
  '/etc/ssh/ssh_host_rsa_key',
  '/etc/ssh/ssh_host_dsa_key',
  '/etc/ssh/ssh_host_ecdsa_key',
  '/etc/ssh/ssh_host_ed25519_key',
]
default.openssh.server.ignore_rhosts = 'yes'
default.openssh.server.hostbased_authentication = 'no'
default.openssh.server.t_c_p_keep_alive = 'yes'
default.openssh.server.use_privilege_separation = 'yes'

# login settings
default.openssh.server.use_p_a_m = 'no'
default.openssh.server.r_s_a_authentication = 'yes'
default.openssh.server.pubkey_authentication = 'yes'
default.openssh.server.password_authentication = 'no'
default.openssh.server.permit_root_login = 'no'
default.openssh.server.login_grace_time = '60'
default.openssh.server.allow_groups = ['sysadmin', 'vagrant']


### sudo
# allow using sudo LWRP
default.authorization.sudo.include_sudoers_d = true
