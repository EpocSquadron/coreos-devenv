# CoreOS DevEnv

## What is it?

This is a ready to go developement environment utilizing [Docker](http://docker.io) containers on a [CoreOS](http://coreos.com) virtual machine set up with [Vagrant](http://vagrantup.com). It provides a standard LAMP environment, that is Apache 2.2 with PHP 5.3 and mod_php, and a separate container for Mysql, both running in Ubuntu 12.10 environments.

## Advantages

### The old way

I used to use [Chef](http://www.opscode.com/chef/) to configure multiple virtual machines through Vagrant. This had several weaknesses.

- The base virtual machine had to be kept up to date with virtualbox guest additions and OS updates, which meant regenerating the base image constantly.
- Chef cookbooks require a certain learning curve to be able to modify and distribute.
- Dependence on other's cookbooks meant that if something broke, you either needed to fork their cookbook repository or wait for them to fix the issue.
- Setting up my own chef cookbooks (for the aforementioned forks and for custom functionality) presented its own challenges, some of which were solved by [Berkshelf](http://berkshelf.com/).
- Having more than one virtual machine for a development environment quickly slows down the host machine, eating up ram, disk and cpu.

The combination of the above resulted in a large number of dependencies on the system of a would-be contributor. The workflow for a contributor would be like this:

- They would need to set up rbenv or rvm for berkshelf
- Then install berkshelf
- Then clone the repositories and init berkshelf
- Then possibly fork dependent cookbooks
- Then learn how to write or modify recipes
- Then iterate with vagrant up and destroy over and over again

This old way of doing things has proven to be a huge barrier to adoption as well as introducing enough moving parts to make things break fairly often. So I went searching for a replacement technology. Then came Docker and CoreOS.

### The new way

CoreOS is essentially a barebones linux with the following properties:

- It updates itself automatically
- Does not use virtualbox guest additions (and so doesn't need to update it)
- Cannot be modified by the user (doesn't have a package manager of it's own to modify the system, and has read-only system files)
- Has Docker already completely set up and ready to use

Thanks to the above, I no longer need to maintain a working development environment once it has been set up. Now only the server stack itself receives updates. That server stack is introduced via Docker images. Docker images have the following advantages:

- They are [LXC containers](http://linuxcontainers.org/), which are like a chroot on steroids, or a really lightweight virtual machine
- Files that are the same across containers don't get replicated for each container, but rather reused, saving disk space
- Each container shares the host's kernel and so need not initialize it's own and hog additional memory for it
- They are easily published and updated with `docker push` and `docker pull`

So with containers I can simply attach a shell, install and modify what I need, then commit and push the changes up to the Docker repository. Later other developers can simply pull the changes down inside their vm (or destroy and up), instead of modifying their vagrantfiles to pull a new tar of cookbooks.

Furthermore, additional dockerfiles can be introduced by each developer to set up a custom stack for a project involving a different server setup (ngninx, php-fpm, php5.5, varnish, etc.).

### Dynamic Virtual Hosts

We are able to share the hosts directory with CoreOS using NFS, and from there we can share the directory with the apache-php docker container. This allows developers to use their host machine to manage all of the development (git, uglify, etc), while immediately having their modifications appear in the apache server.

Using apache's mod_vhost_alias we can route wildcard hostnames to their matching folders. Thus, as long as a folder exists in the shared directory with a name appearing in the hostname used to access it, we can simply serve it, bypassing the need to generate it's own virtualhost configuration.

> This introduces a weakness, where `$_SERVER['DOCUMENT_ROOT']` does not get set. Fortunately, we take care of this by simply prepending all php scripts with a small php script that sets this variable manually.

## How to use it

### Installation

This virtual machine is meant to be run in the same directory as where you store your web projects. For many this is `~/Sites` or `~/Projects` or some variation thereof. Create and navigate (`cd` into) the folder you wish to use, then choose one of the following options for installing.

#### The Really Easy Way

You can run the installer in much the way you might for [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh):

	$ curl -sLS https://github.com/EpocSquadron/coreos-devenv/raw/master/scripts/install.sh -o tmp.sh && bash tmp.sh; rm tmp.sh

or

	$ wget -q --no-check-certificate https://github.com/EpocSquadron/coreos-devenv/raw/master/scripts/install.sh -O tmp.sh && bash tmp.sh; rm tmp.sh

#### The Manual Way

1. Clone this repository

	$ git clone https://github.com/EpocSquadron/coreos-devenv .coreos-devenv

2. Copy the Vagrantfile into the current directory

	$ cp .coreos-devenv/Vagrantfile .

3. If you have a raw mysql data directory you would like to use from a previous development environment, copy it to `.coreos-databases/mysql`.
4. If you have no data directory to start from, you must provide a bare-bones (no databases) data directory, provided with the project.

	$ cp -r .coreos-devenv/database/mysql .coreos-databases/


#### Optional

You may also install dnsmasq via the included script at `.coreos-devenv/scripts/osx/install-dnsmasq.sh`, which requires OSX and [homebrew](http://brew.sh/).

> **Linux Users:** You can install dnsmasq from your distro's repository and add the line `address=/dsdev/33.33.33.77` to the `/etc/dnsmasq.conf` file. Then ensure that your dnsmasq installation is (re)loaded to allow the configuration to take effect, and optionally enable it on startup. For systemd users this means running `sudo systemctl reload dnsmasq.service && sudo systemctl enable dnsmasq.service`. Finally ensure dnsmasq is your default nameserver for your network connection, usually by adding `nameserver 127.0.0.1` as the first line in your `/etc/resolv.conf` file.

### Starting the virtual machine

From your master project directory, run `vagrant up`. The first time it runs it may take some time to pull down the required virtual machine and container images. Subsequent runs should be much faster.

> Note: [Bugs](https://github.com/coreos/coreos-vagrant/issues/23) are still being worked on with regards to starting docker from within the virtual machine. In the meantime, if the development server doesn't resopnd you may need to use the `--provision` flag on subsequent runs. If this results in a failed provisioning run `vagrant provision` separately.

### Setting up a project

The standard LAMP setup that comes packaged utilizes apache's mod_vhost_alias to provide true dynamic virtualhosts. Combined with dnsmasq on the host machine, one can set up a new project by doing the following:

Clone or create the project in the directory the vagrant virtual machine is running. Ensure that the project has a public_html directory for its document root. This looks like the following

	~/Sites
	├── Vagrantfile
	└── test
	    └── public_html
	        ├── index.html
	        └── phpinfo.php

Then [set up your database](#setting-up-a-database-for-a-project) for that project if it has one. All that remains from here then is to visit `http(s)://<project-directory-name>.dsdev`. In the above example that is `http://test.dsdev`.

And that's it! No more mucking around with `/etc/hosts` and `a2ensite` and custom virtual host files every time you set up a new project.

### Setting up a database for a project

On every start the mysql server docker container ensures that the user `remote` exists and has full grants on all databases. You can therefore use a tool like [Mysql Workbench](http://www.mysql.com/products/workbench/), [SequelPro](http://www.sequelpro.com/), or the host machine's mysql cli client to connect to the server with these details:

- Username: remote
- Password: blahblahblah
- Host: 33.33.33.77
- Port: 3306

Continue as you normally would for creating the required database and loading the required data. Once that is complete, you will need to configure your application to connect to the mysql server. In php you can do this with the following:

	$env_db['hostname'] = getenv('DB_PORT_3306_TCP_ADDR');
	$env_db['port']     = getenv('DB_PORT_3306_TCP_PORT');
	$env_db['username'] = getenv('DB_ENV_USERNAME');
	$env_db['password'] = getenv('DB_ENV_PASSWORD');

Note that the data files for mysql are actually stored on your computer (the host), so that you can destroy and up your virtual machine at will. A base data folder is provided to prevent mysql from failing to start on first load, but if you have a data directory from a previous install, you can simply overwrite `.coreos-devenv/mysql-data/` with it and you should be up and running with your databases.

## Development

The dockerfiles and additional assets for the two core containers are located in `.coreos-devenv/containers`, where you can modify them as you wish and generate new docker images. Read more about docker development at the [docker.io docs](http://docs.docker.io/en/latest/).
