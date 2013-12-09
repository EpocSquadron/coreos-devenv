# -*- mode: ruby -*-
# # vi: set ft=ruby :

Vagrant.configure("2") do |config|

	# Define the CoreOS box
	config.vm.box = "coreos"
	config.vm.box_url = "http://storage.core-os.net/coreos/amd64-generic/dev-channel/coreos_production_vagrant.box"

	# Define a static IP
	config.vm.network "private_network",
		ip: "33.33.33.78"

	# Provision docker with shell
	# config.vm.provision
	config.vm.provision "shell",
		path: ".coreos-devenv/scripts/provision-docker.sh"

end
