echo ":: Building docker containers..."
docker build -t epocsquadron/apache-php-dynamic /home/core/sites/.containers/apache-php-dynamic/
docker build -t epocsquadron/mysql-standard /home/core/sites/.containers/mysql-standard/

echo ":: Starting mysql container..."
docker run -v /home/core/sites/.mysql-data:/var/lib/mysql -p 3306:3306 -d epocsquadron/mysql-standard

echo ":: Starting apache container..."
docker run -v /home/core/sites:/var/www -p 80:80 -p 443:443 -d epocsquadron/apache-php-dynamic
