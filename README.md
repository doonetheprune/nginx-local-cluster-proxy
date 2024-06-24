
# Custom Nginx Docker Image

This Docker image is based on the official Nginx image and includes dynamic configuration capabilities to set up HTTP and TCP stream configurations via environment variables.

## Features

- **Custom Nginx Configuration**: Uses a custom Nginx configuration to better suit applications that require dynamic proxy settings.
- **Entrypoint Script**: Dynamically configures HTTP and TCP streams based on the environment variables provided at runtime.

## Dockerfile Explanation

- **Base Image**: Uses `nginx:latest` as the base image.
- **Configuration Removal**: Removes the default Nginx configuration.
- **Configuration Templates**: Copies custom configuration templates and an entrypoint script into the image.
- **Permissions**: Sets the entrypoint script as executable.
- **Entrypoint and CMD**: Uses the custom entrypoint script to configure and start Nginx.

## Entrypoint Script

The entrypoint script allows dynamic configuration of Nginx based on the following environment variables:
- `PORTS`: Specifies the HTTP port Nginx should listen on (default is 80).
- `UPSTREAM_PORT`: Specifies the default port for upstream services.
- `HOSTS_OVERRIDE`: Maps paths to service URLs for HTTP proxying.
- `TCP_PORTS`: Configures TCP ports for proxying to specific services.

Example:
```
UPSTREAM_PORT="8000"
HOSTS_OVERRIDE="other-service=auth-service"
TCP_PORTS="5432=db"
```

## Building the Image

To build this Docker image, run the following command:

```sh
docker build -t custom-nginx .
```

## Running the Container

You can run your Docker container using:

```sh
docker run -d -p 80:80 -e UPSTREAM_PORT=8000 -e HOSTS_OVERRIDE=other-service=auth-service -e TCP_PORTS="5432=db" custom-nginx
```

Replace the environment variable values as needed based on your configuration requirements.

## Contributing

Feel free to fork this project, submit pull requests, or send suggestions to improve the Docker image or its configuration handling.
