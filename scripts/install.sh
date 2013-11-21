#!/bin/bash

# Configure directory names
HIDDEN_MASTER_DIRECTORY=".coreos-devenv"
HIDDEN_DATABASE_DIRECTORY=".coreos-databases"

runChecks() {

	# Check dependencies
	hash git 2>&- || {
		echo -e >&2 "\033[0;31mGit is required but is either not installed or not in your PATH.  Aborting.\033[0m"
		exit 1
	}

	# Check we haven't already installed
	if [ -d "$HIDDEN_MASTER_DIRECTORY" ]; then
		echo -e >&2 "\033[0;31mYou already have an instance of '$HIDDEN_MASTER_DIRECTORY' in this folder. If you need to continue, remove it first.\033[0m"
		exit 2
	fi

	# Don't want to run this if they have
	# a pre-existing vagrantfile.
	if [ -f "Vagrantfile" ]; then
		echo -e >&2 "\033[0;31mYou have a Vagrantfile in this directory, either run 'vagrant destroy' and move the file out of the way or choose another directory.\033[0m"
		exit 3
	fi

}

createMasterDirectory() {

	echo -e "\033[0;32m:: Cloning to hidden directory at '$HIDDEN_MASTER_DIRECTORY'.\033[0m"
	git clone https://github.com/EpocSquadron/coreos-devenv.git "$HIDDEN_MASTER_DIRECTORY"

}

copyVagrantfile() {

	echo -e "\033[0;32m:: Copying the Vagrantfile to the current directory.\033[0m"
	cp "$HIDDEN_MASTER_DIRECTORY/Vagrantfile" .

}

bootstrapDatabaseDirectory() {

	if [ -d "$HIDDEN_DATABASE_DIRECTORY" ]; then
		echo -n -e "\033[0;33m:: You already have an instance of '$HIDDEN_DATABASE_DIRECTORY' in this folder. Would you like to overwrite the data? [y/N]\033[0m "
		read RESPONSE

		if [[ "$RESPONSE" == 'y' || "$RESPONSE" == 'Y' || "$RESPONSE" == 'yes' ]]; then
			clearDatabases
			copyBlankDatabases
		fi

	else
		copyBlankDatabases
	fi

}

clearDatabases() {

	local TIMESTAMP=`date +"%Y-%m-%d-%H%M%S"`

	if [ -d "$HIDDEN_DATABASE_DIRECTORY/mysql" ]; then
		mv "$HIDDEN_DATABASE_DIRECTORY/mysql" "$HIDDEN_DATABASE_DIRECTORY/mysql.old-$TIMESTAMP"
	fi

}

copyBlankDatabases() {

	echo -e "\033[0;32m:: Creating hidden directory at '$HIDDEN_DATABASE_DIRECTORY' and populating it with blank databases.\033[0m"
	mkdir -p "$HIDDEN_DATABASE_DIRECTORY" && \
	cp -r "$HIDDEN_MASTER_DIRECTORY/database/mysql" "$HIDDEN_DATABASE_DIRECTORY/"

}

offerDnsmasq() {

	if [[ "$OSTYPE" =~ "darwin" ]]; then

		echo -n -e "\033[0;33m:: Would you like to install dnsmasq for wildcard DNS to the development environment? [Y/n]\033[0m "
		read RESPONSE

		if [[ "$RESPONSE" == "" || "$RESPONSE" == 'y' || "$RESPONSE" == 'Y' || "$RESPONSE" == 'yes' ]]; then
			source "$HIDDEN_MASTER_DIRECTORY/scripts/osx/install-dnsmasq.sh"
		fi

	fi

}

main() {

	runChecks && \
	createMasterDirectory && \
	copyVagrantfile && \
	bootstrapDatabaseDirectory && \
	offerDnsmasq

	echo -e "\033[0;32m:: Done installing.\033[0m"

}

main

