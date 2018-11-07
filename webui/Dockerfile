FROM composer
RUN apk --update add nodejs nodejs-npm
RUN mkdir -p /app/
WORKDIR /app
ADD composer.json composer.lock ./
RUN composer install
ADD index.php ./
ADD libs ./libs
ADD templates ./templates
ADD scripts ./scripts
RUN cd /app/scripts/ && npm install
CMD php -S 0.0.0.0:80 -t /app/