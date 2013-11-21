# Create remote user with remote login and full access.
GRANT ALL ON *.* TO remote@'%' IDENTIFIED BY 'blahblahblah' WITH GRANT OPTION;

# Remove anonymous user, and root's @% user.
DELETE FROM mysql.user WHERE User='' OR User='debian-sys-maint';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

FLUSH PRIVILEGES;
