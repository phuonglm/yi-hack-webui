#!/bin/bash

# Disable Strict Host checking for non interactive git clones
mkdir -p -m 0700 /root/.ssh
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

# Tweak nginx to match the workers to cpu's
procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $procs/" /etc/nginx/nginx.conf


# If an htpasswd file is provided, download and configure nginx
if [[ ${ENABLE_BASIC_AUTH} == 'yes' || ${ENABLE_BASIC_AUTH} == 'true' ]]; then
  echo "Enabling basic auth..."
   sed -i "s/#auth_basic/auth_basic/g;" /etc/nginx/conf.d/default.conf
fi

# Push current environment variables into PHP-FPM
STAGE=${STAGE:-dev}
printenv | grep -v affinity:container | xargs -I{} echo {} | awk 'BEGIN { FS = "=" }; { print "env ["$1"] = \""$2"\"" }' >> /etc/php5/php-fpm.conf

# Run Phing if present in the container
if [ -f /var/www/app/phing ]; then
  cd /var/www/app
  /var/www/app/phing ${STAGE}
fi 

chown -R nginx:nginx /var/www/app

# Run specific config script for a particular container
if [ -f /usr/local/bin/nginx_env.sh ]; then
  /usr/local/bin/nginx_env.sh
fi

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf
