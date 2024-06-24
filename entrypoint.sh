#!/bin/bash
# Read the PORTS environment variable, default to 80 if not provided
PORTS=${PORTS:-80}

# Prepare dynamic Nginx location configurations
DYNAMIC_LOCATIONS=""
DYNAMIC_STREAMS=""

# Check and parse HOSTS_OVERRIDE
if [ -n "$HOSTS_OVERRIDE" ]; then
    # Split by comma
    OLD_IFS="$IFS"
    IFS=','
    set -f  # disable globbing
    for pair in $HOSTS_OVERRIDE; do
        # Split by equals
        key="${pair%%=*}"
        value="${pair#*=}"

        # Generate location block
        DYNAMIC_LOCATIONS="${DYNAMIC_LOCATIONS}
        location ^~ /${key} {

            set \$url http://${value}:${UPSTREAM_PORT};
            set \$attempted_url \$url;

            proxy_pass \$url;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            error_page 404 500 502 503 504 @custom_error;
        }
        "
    done
    IFS="$OLD_IFS"
    set +f  # re-enable globbing
fi

# Check and parse TCP_PORTS for TCP stream settings
if [ -n "$TCP_PORTS" ]; then
    OLD_IFS="$IFS"
    IFS=','
    set -f  # disable globbing
    for pair in $TCP_PORTS; do
        port="${pair%%=*}"
        target="${pair#*=}"

        DYNAMIC_STREAMS="${DYNAMIC_STREAMS}
        server {
            listen ${port};
            proxy_pass ${target}:${port};
        }
        "
    done
    IFS="$OLD_IFS"
    set +f  # re-enable globbing
fi

DYNAMIC_LOCATIONS=$(echo "$DYNAMIC_LOCATIONS" | sed ':a;N;$!ba;s/\n/\\n/g')
DYNAMIC_STREAMS=$(echo "$DYNAMIC_STREAMS" | sed ':a;N;$!ba;s/\n/\\n/g')

# Replace the placeholder in the Nginx config template with the actual ports
sed -i "s/\${PORTS}/$PORTS/g" /nginx-http.conf.template
sed -i "s/\${UPSTREAM_PORT}/$UPSTREAM_PORT/g" /nginx-http.conf.template
sed -i "s|#DYNAMIC_LOCATIONS#|$DYNAMIC_LOCATIONS|" /nginx-http.conf.template
sed -i "s|#DYNAMIC_STREAMS#|$DYNAMIC_STREAMS|" /nginx-stream.conf.template

# Move the modified template to the final config location
mv /nginx-http.conf.template /etc/nginx/conf.d/http.conf
mv /nginx-stream.conf.template /etc/nginx/conf.d/stream.conf

cat /etc/nginx/conf.d/http.conf
cat /etc/nginx/conf.d/stream.conf

# Execute the main container command (CMD)
exec "$@"