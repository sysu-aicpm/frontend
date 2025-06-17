FROM ubuntu/nginx:latest
COPY ./build/web /var/www/html
