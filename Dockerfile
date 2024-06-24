# Use the official Nginx image as a parent image
FROM nginx:latest

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom Nginx config template and entrypoint script
COPY nginx.conf /etc/nginx/
COPY nginx-http.conf.template /nginx-http.conf.template
COPY nginx-stream.conf.template /nginx-stream.conf.template
COPY entrypoint.sh /usr/local/bin/

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint script to run on container start
ENTRYPOINT ["entrypoint.sh"]

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]
