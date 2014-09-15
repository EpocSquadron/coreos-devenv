# -*- mode: ruby -*-
# # vi: set ft=ruby :

Vagrant.configure("2") do |config|

	# Define the CoreOS box
	config.vm.box = "coreos-alpha"
	config.vm.box_url = "http://alpha.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json"

	# Define a static IP
	config.vm.network "private_network",
		ip: "33.33.33.77"

	# Share the current folder via NFS
	config.vm.synced_folder ".", "/home/core/sites",
		id: "core",
		:nfs => true,
		:mount_options => ['nolock,vers=3,udp,noatime']

	# Provision docker with shell
	# config.vm.provision
	config.vm.provision "shell",
		path: ".coreos-devenv/scripts/provision-docker.sh"

end
