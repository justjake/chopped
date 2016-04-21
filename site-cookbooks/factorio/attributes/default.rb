default.factorio.debug = false

# installation settings
default.factorio.version = '0.12.29'
# HTTPS doesn't work for some reason
default.factorio.download_uri = 'http://www.factorio.com/get-download/%{version}/headless/linux64'
default.factorio.tmp_location = '/tmp/factorio-install-process'


default.factorio.install_location = '/opt/factorio/app'
default.factorio.save_location = '/opt/factorio/storage'
default.factorio.config_location = '/opt/factorio/config'
default.factorio.binary = '%{install_location}/bin/x64/factorio'

# network
default.factorio.port = 34197
default.factorio.latency = 250

# save settings
default.factorio.autosave_interval = 10
default.factorio.autosave_slots = 10
default.factorio.save_name = 'chef-default-save'

# Add extra arguments when we run the factorio server
# example: '--disallow-commands --peer-to-peer'
default.factorio.extra_bin_args = ''

# TODO: handle config of factorio via attributes, or via template?
