# Use the official httpd (Apache) base image
FROM httpd:latest

# Copy the custom index.html to the Apache document root
COPY website/* /usr/local/apache2/htdocs/
