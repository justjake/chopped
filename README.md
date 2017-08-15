# Chopped

knife-solo kitchen for deploying fun servers.

## Intended roles

- Factorio host. Would be best with an HTTP API to control the Factorio game
  instance. Should support generating new saves, listing saves, changing the
  active save, managing save backups (autosaves), etc. Ubuntu-based service
  descriptions exist in the wild for Factorio, but are shitty (eg using
  `screen` for persistance and daemonization)
  - why not just use [the existing chef
    cookbook](https://github.com/sghar/factorio-cookbook/blob/master/recipes/default.rb)?
    Because it's running Factorio, an untrusted C++ binary network service, as
    root. Unacceptable if we are putting this server on the general internet.

- Minecraft host. ????. I don't care how it works, but it should be chef
  configurable :)

- Slackbots host. This will need `nodejs_service` definition so we can add a
  bunch of different slackbots or whatnot.

## Design

This is my first time chef-ing from scratch, and the ecosystem is baroque to
say the least. I'm vaguely following the approach in these articles:

- repo setup follows http://www.markjberger.com/an-introduction-to-chef-solo/
- vagrant configuration and philosophy follows
  http://www.talkingquickly.co.uk/2013/10/using-vagrant-to-test-chef-cookbooks/

I want to use `runit` for service definition and management -- I use it at home
and at work, and I appreciate its design.

## How to get going

### One-time setup:

I suggest creating a new RVM or rbenv context with ruby 2.x for use with this
project. I did `rbenv install 2.2.3` and then `rbenv local 2.2.3` to use ruby
2.2.3 for this.

Perform this one-time setup:
1. `bundle install`
1. `bundle exec berks install`
1. Start up a node in AWS. There are plugins to do this magically, but :meh:, you might have to
   create some keys & stuff, so just do this by hand.
   Confirm that you can login with `ssh ubuntu@12.34.56.78 -i ~/.ssh/leroy_jenkins.pem`.
1. While that is starting up, go into `data_bags/users/` and create yourself a file, because you'll
   want to be able to SSH into this box once it's provisioned. Probably.
1. `bundle exec knife solo prepare ubuntu@12.34.56.78 -i ~/.ssh/leroy_jenkins.pem` This will load
   all the chef stuff onto it, and give you a file `nodes/12.34.56.78.json`.

### B-b-b-but... Vagrant?

Instead of starting up a node on AWS, do this:

1. `vagrant up`
1. `bundle exec knife solo prepare vagrant@127.0.0.1 -p 2222 -i
   ./.vagrant/machines/default/virtualbox/private_key`
   prepares your Vagrant machine for knife-solo development by setting up chef on it.
1. Run `vagrant snapshot save chef`. If your VM ever becomes inaccessable due to
   bad chef changes, you can always run `vagrant snapshot restore chef` to reset
   it to this known-good state.

Your file created will be `nodes/127.0.0.1`.

### Creating a cookbook

Put cookbooks in the `site-cookbooks` folder. `cookbooks` folder is reserved
for upstream dependencies.

`knife cookbook create -o site-cookbooks/ YOUR_NEW_COOKBOOK`

### GO GO GADGET COOKBOOK.

1. `vi nodes/12.34.56.78.json` and add roles to the run_list. These are the recipes that your box
   will run, e.g.
   `["recipe[base]","recipe[factorio]","recipe[factorio::api","recipe[chopped_nginx"]`.
1. `bundle exec knife solo cook ubuntu@12.34.56.78 -i ~/.ssh/leroy_jenkins.pem` and chef will go off
   and run all of the cheffy stuff.

On future runs you should be using your own user account to cook and clean the
box, since the vagrant user may no longer be allowed to SSH.

### Testing chef in Vagrant

Then, you can provision your own box using `knife solo` to test out this
chef repo. I haven't done this yet.

## Upgrading Server

Goto `/opt/factorio/storage/saves` and save a copy of the map somewhere.

Goto `/opt` and rename the `factorio` server to something, idk like `factorio-0.15.31`. This
will make the `is_installed` variable in the `site-cookbooks/factorio/recipes/default.rb` come
up false, so it will reinstall.

Then do a cook command again (you'll prob have to use your own login now),
`bundle exec knife solo cook leroy_jenkins@12.34.56.78`, and it will install again. Resolve
any install problems, stuff breaks a lot. Check out `/var/log/factorio/current` for what's
going on.

Copy your save back into the server.

## Useful tips

Put `127.0.0.1 vagrant-box` to your /etc/hosts file, and a section like this to
your SSH config:
```
Host vagrant-box
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  Port 222
```
This makes later access via your user `ssh leroy_jenkins@vagrant-box` or `bundle exec
knife solo prepare leroy_jenkins@vagrant-box` instead of needing to manually specify
the port.
