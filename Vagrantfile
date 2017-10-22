# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile for testing sqitch locally.
#
# This is intended to make it easier for people to spin up a fully working
# development environment to be able to test Postgresql features, or verify
# Postgresql-related functions using sqitch.

# How much RAM to assign to a vagrant box
ENV["VAGRANT_SQITCH_BOX_RAM"] = "2048"

# Optionally expose the Postgres port on the host. Defaults to 5454. (This is
# a non-standard Postgres port as developers will most likely have it installed
# and running on 5432.)
ENV["VAGRANT_SQITCH_POSTGRES_PORT"] = "5454"

Vagrant.configure(2) do |config|
  config.vm.box = "debian/contrib-jessie64"

  # Increase VM RAM
  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", ENV["VAGRANT_SQITCH_BOX_RAM"]]
  end

  if ENV.has_key? "VAGRANT_SQITCH_POSTGRES_PORT"
    config.vm.network "forwarded_port", guest: 5432, host: ENV["VAGRANT_SQITCH_POSTGRES_PORT"]
  end

  ## For masterless, mount salt file roots under default path /srv
  config.vm.synced_folder "saltstack/salt", "/srv/salt"
  config.vm.synced_folder "saltstack/pillar", "/srv/pillar"

  # See https://github.com/mitchellh/vagrant/pull/6073
  config.vm.provision :salt do |salt|
    salt.masterless = true
    salt.minion_config = "saltstack/etc/minion"
    salt.run_highstate = true

    # Logging output control
    salt.colorize = true
    salt.log_level = "info"
    salt.verbose = true
  end
end
