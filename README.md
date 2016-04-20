# Chopped

knife-solo kitchen for deploying fun servers.

## Intended roles

- Factorio host. Would be best with an HTTP API to control the Factorio game
  instance. Should support generating new saves, listing saves, changing the
  active save, managing save backups (autosaves), etc. Ubuntu-based service
  descriptions exist in the wild for Factorio, but are shitty (eg using
  `screen` for persistance and daemonization)

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

I suggest creating a new RVM or rbenv context with ruby 2.x for use with this
project. I did `rbenv install 2.2.3` and then `rbenv local 2.2.3` to use ruby
2.2.3 for this.

Perform this one-time setup:

1. `bundle install`
1. `bundle exec berks install`
1. `vagrant up`

Then, you can provision your vagrant box using `knife solo` to test out this
chef repo. I haven't done this yet, but it looks like this in theory:

`bundle exec knife solo prepare vagrant@127.0.0.1 -p 2222 -i ./.vagrant/machines/default/virtualbox/private_key`
