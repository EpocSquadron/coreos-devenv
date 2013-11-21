#!/bin/bash

checkDependencies() {

	# Check for existence/accessibility of mysql and sed
	echo "\033[0;32m:: Checking dependencies.\033[0m"
	hash brew 2>&- || {
		echo >&2-e  "\033[0;31mHomebrew is required but is either not installed or not in your PATH. Aborting install of dnsmasq.\033[0m";
		exit 1;
	}

}

installDnsmasq() {

	echo -e "\033[0;32m:: Installing dnsmasq with homebrew.\033[0m"

	if [ `brew list | grep -w dnsmasq` == "" ]; then
		brew update && brew install dnsmasq
	fi

}

configureDnsmasq() {

	echo -e "\033[0;32m:: Configuring dnsmasq.\033[0m"

	if [ -f "/usr/local/etc/dnsmasq.conf" ]; then

		echo -n -e "\033[0;33m:: Previous configuration found, append new address line? [Y/n] \033[0m"
		read RESPONSE

		if [[ "$RESPONSE" == "" || "$RESPONSE" == 'y' || "$RESPONSE" == 'Y' || "$RESPONSE" == 'yes' ]]; then
			echo "address=/.dsdev/33.33.33.77" >> /usr/local/etc/dnsmasq.conf
		fi

	else
		cp /usr/local/opt/dnsmasq/dnsmasq.conf.example /usr/local/etc/dnsmasq.conf
		echo "address=/.dsdev/33.33.33.77" >> /usr/local/etc/dnsmasq.conf
	fi

}


setNameserver() {

	echo -e "\033[0;32m:: Setting up resolver for dnsmasq on .dsdev domains.\033[0m"

	if [ ! -d "/etc/resolver" ]; then
		sudo mkdir /etc/resolver
	fi

	if [ ! -f "/etc/resolver/dsdev" ]; then
		sudo touch /etc/resolver/dsdev
		sudo echo "nameserver 127.0.0.1" > /etc/resolver/dsdev
	fi

}

registerDnsmasq() {

	# Make it load at start
	echo -e "\033[0;32m:: Registering dnsmasq as a startup daemon..\033[0m"

	# We will unload it, in case it was already installed and enabled.
	if [[ -f /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist ]]; then
		sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
	else
		sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons
	fi

	sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist

}

main() {

	checkDependencies && \
	installDnsmasq && \
	configureDnsmasq && \
	registerDnsmasq && \
	setNameserver

	echo -e "\033[0;32m:: dnsmasq installed!\033[0m

\033[0;34mhttp://*.dsdev will now point to your vagrant machine at 33.33.33.77.
Edit /usr/local/etc/dnsmasq.conf if you need to make configuration adjustments.\033[0m"

}

main
