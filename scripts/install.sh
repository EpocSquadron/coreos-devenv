#!/bin/bash

# Configure directory names
HIDDEN_MASTER_DIRECTORY=".coreos-devenv"
HIDDEN_DATABASE_DIRECTORY=".coreos-databases"

runChecks() {

	# Check dependencies
	hash git 2>&- || {
		echo >&2 ":: Git is required but is either not installed or not in your PATH.  Aborting."
		exit 1
	}

	# Check we haven't already installed
	if [ -d "$HIDDEN_MASTER_DIRECTORY" ]; then
		echo >&2 ":: You already have an instance of '$HIDDEN_MASTER_DIRECTORY' in this folder. If you need to continue, remove it first."
		exit 1
	fi

}

createMasterDirectory() {

	echo ":: Creating hidden directory at '$HIDDEN_MASTER_DIRECTORY'."
	git clone https://github.com/EpocSquadron/coreos-devenv.git "$HIDDEN_MASTER_DIRECTORY"

}

copyVagrantfile() {

	echo ":: Copying the Vagrantfile to the current directory."
	cp "$THIS_DIR/../Vagrantfile" .

}

bootstrapDatabaseDirectory() {

	if [ -d "$HIDDEN_DATABASE_DIRECTORY" ]; then
		echo ":: You already have an instance of '$HIDDEN_DATABASE_DIRECTORY' in this folder."
		echo -n "   Would you like to overwrite the data? [y/N] "
		read RESPONSE

		if [ "$RESPONSE" == 'y' || "$RESPONSE" == 'Y' || "$RESPONSE" == 'yes' ]; then
			clearDatabases
			copyBlankDatabases
		fi

	else
		copyBlankDatabases
	fi

}

clearDatabases() {

	mv "$HIDDEN_DATABASE_DIRECTORY/mysql" "$HIDDEN_DATABASE_DIRECTORY/mysql.old-"

}

copyBlankDatabases() {

	echo ":: Creating hidden directory at '$HIDDEN_DATABASE_DIRECTORY' and populating it with blank databases."
	mkdir "$HIDDEN_DATABASE_DIRECTORY" && \
	cp -r "$HIDDEN_MASTER_DIRECTORY/database/mysql" "$HIDDEN_DATABASE_DIRECTORY/"

}

offerDnsmasq() {

	if [[ "$OSTYPE" ~= "darwin" ]]; then

		echo -n ":: Would you like to install dnsmasq for wildcard DNS to the development environment? [Y/n] "
		read RESPONSE

		if [ "$RESPONSE" == "" || "$RESPONSE" == 'y' || "$RESPONSE" == 'Y' || "$RESPONSE" == 'yes' ]; then
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

}


