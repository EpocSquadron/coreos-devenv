echo ":: Ensuring that docker is running..."
sudo systemctl start docker

echo ":: Building docker containers..."

# Loop through the container definitions in .coreos-devenv/containers
# and build them or pull them if they exist.
REPOS=`find /home/core/sites/.coreos-devenv/containers/ -maxdepth 1 -type d -printf '%P '`

for REPO in $REPOS; do

	# Look in docker's public repository for an exact match, removing the
	# line describing the query used, which triggers a false positive.
	SEARCH_RESULT=`docker search epocsquadron/$REPO | sed 1d | grep -o epocsquadron/$REPO`

	if [[ -n $SEARCH_RESULT ]]; then
		echo "Found epocsquadron/$REPO, pulling latest..."
		docker pull "epocsquadron/$REPO"
	else
		echo "Didn't find epocsquadron/$REPO, building it ourselves..."
		docker build -t epocsquadron/$REPO /home/core/sites/.coreos-devenv/containers/$REPO/
	fi

done

echo ":: Starting mysql container..."

if [[ -n `docker ps | grep -o mysql-standard` ]]; then
	echo "Already running. Restarting..."
	docker restart mysql-standard
else
	docker run \
		-v /home/core/sites/.coreos-devenv/mysql-data:/var/lib/mysql \
		-p 3306:3306 \
		-e USERNAME="remote" \
		-e PASSWORD="blahblahblah" \
		-d \
		-name mysql-standard \
		epocsquadron/mysql-standard
fi

echo ":: Starting apache container..."

if [[ -n `docker ps | grep -o apache-php-dynamic` ]]; then
	echo "Already running. Restarting..."
	docker restart apache-php-dynamic
else
	docker run \
		-v /home/core/sites:/var/www \
		-p 80:80 \
		-p 443:443 \
		-d \
		-name apache-php-dynamic \
		-link /mysql-standard:db \
		epocsquadron/apache-php-dynamic
fi
