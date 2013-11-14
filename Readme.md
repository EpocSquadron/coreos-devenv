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

The combination of the above resulted in a large number of dependencies on the system of a would-be modifier.

- They would need to set up rbenv or rvm for berkshelf
- Then install berkshelf
- Then clone the repositories and init berkshelf
- Then possibly fork dependent cookbooks
- Then learn how to write or modify recipes
- Then iterate with vagrant up and destroy over and over again

### The new way

To fix the maintainance issues I settled on CoreOS, which:

- Updates itself automatically
- Does not use virtualbox guest additions (and so doesn't need to update it)
- Cannot be modified by the user (doesn't have a package manager of it's own to modify the system, and has read-only system files)
- Has Docker already completely set up and ready to use

Thanks to the above, I no longer need to maintain a working development environment once it has been set up. Now only the server stack itself receives updates. That server stack is introduced via Docker images. Docker images have the following advantages:

- They are LXC containers, which are like a chroot on steroids, or a really lightweight virtual machine
- Files that are the same accross containers don't get replicated for each container
- Each container shares the host's kernel and so need not initialize it's own and hog additional memory for it
- They are secure in that they are separated at the process level from eachother, and can only expose certain ports to the world (no need for a firewall on each container)
- They are easily published and updated with `docker push` and `docker pull`

So with containers I can simply attach a shell, install and modify what I need, then commit and push the changes up to the Docker repository. Later other developers can simply pull the changes down inside their vm (or destroy and up), instead of modifying their vagrantfiles to pull a new tar of cookbooks.

Furthermore, additional dockerfiles can be introduced by each developer to set up a custom stack for a project involving a different server setup (ngninx, php-fpm, php5.5, varnish, etc.).

### Dynamic Virtual Hosts

In addition to the advantages above, the standard LAMP setup included utilizes apache's mod_vhost_alias

## How to use it

### Installation

Simply clone or download this repo to the directory you will be storing your website projects. Typically this is `~/Sites` or `~/Projects`. Then in that directory run `vagrant up`. The first run will take a little bit of time to pull the coreos image, pull the relevant docker images and start them up, but subsequent runs will only need to start the docker instances (which btw is nearly instantaneous).

You may also install dnsmasq via the included script at `.scripts/install-dnsmasq.sh`, which requires OSX and [homebrew](http://brew.sh/).

> **Linux Users:** You can install dnsmasq from your distro's repository and add the line `address=/dsdev/33.33.33.77` to the `/etc/dnsmasq.conf` file. Then ensure that your dnsmasq installation is (re)loaded to allow the configuration to take effect, and optionally enable it on startup. For systemd users this means running `sudo systemctl reload dnsmasq.service && sudo systemctl enable dnsmasq.service`. Finally ensure dnsmasq is your default nameserver for your network connection, usually by adding `nameserver 127.0.0.1` as the first line in your `/etc/resolv.conf` file.

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

Continue as you normally would for creating the required database and loading the required data. Once that is complete, you will need to configure your application to connect to the mysql server with the following credentials:

- Username: remote
- Password: blahblahblah
- Host: ??
- Port: 3306

> If you want to change the password, open up `.containers/mysql-standard/grants.sql` and change the password in the SQL statement. This sql file is ran as the init-file for apache every time the mysql-standard container loads.


