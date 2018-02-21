FROM composer
RUN apk --update add nodejs nodejs-npm
RUN mkdir -p /app/
WORKDIR /app
ADD . ./
RUN composer install
RUN cd /app/scripts/ && npm install
CMD php -S 0.0.0.0:80 -t /app/