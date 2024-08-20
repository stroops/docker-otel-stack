#!/bin/bash

set -e

mkdir -p /data/{prometheus,grafana,loki,tempo}
mkdir -p /data/grafana/{data,plugins} 

if [ ! -z "$GRAFANA_PASSWORD" ]; then
  export GF_AUTH_ANONYMOUS_ENABLED="false"
  export GF_AUTH_BASIC_ENABLED="true"
  export GF_AUTH_DISABLE_LOGIN_FORM=""
  export GF_AUTH_DISABLE_SIGNOUT_MENU=""

  export GF_SECURITY_ADMIN_PASSWORD="$GRAFANA_PASSWORD"

  cd /usr/share/grafana && grafana cli admin reset-admin-password "$GRAFANA_PASSWORD"
fi

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

while ! curl -sg 'http://localhost:9090/api/v1/query?query=up{job="opentelemetry-collector"}' | jq -r .data.result[0].value[1] | grep '1' > /dev/null ; do
    sleep 1
done

echo "The OpenTelemetry collector and the Grafana Monitoring stack are up and running."
echo "Open ports:"
echo " - 4317: OpenTelemetry GRPC endpoint"
echo " - 4318: OpenTelemetry HTTP endpoint"
echo " - 8080: Grafana. User: admin, password: $GRAFANA_PASSWORD"