
FROM grafana/loki:3.1.0 as loki
FROM grafana/tempo:2.5.0 as tempo
FROM prom/prometheus:v2.53.1 as prometheus
FROM otel/opentelemetry-collector-contrib:0.106.0 as otel

#using grafana as runtime
FROM grafana/grafana:11.1.3 as grafana 

ENV GF_PATHS_DATA=/data/grafana/data \
    GF_PATHS_PLUGINS=/data/grafana/plugins \
    GF_AUTH_ANONYMOUS_ENABLED=true \
    GF_AUTH_ANONYMOUS_ORG_NAME="Main Org." \
    GF_AUTH_ANONYMOUS_ORG_ROLE="Viewer" \
    GF_AUTH_BASIC_ENABLED="false" \
    GF_AUTH_DISABLE_LOGIN_FORM="true" \
    GF_AUTH_DISABLE_SIGNOUT_MENU="true" \
    GF_AUTH_PROXY_ENABLED="true" \
    GF_USERS_ALLOW_SIGN_UP=false \
    GF_SERVER_HTTP_ADDR="0.0.0.0" \
    GF_SERVER_HTTP_PORT=8080 \
    GF_INSTALL_PLUGINS=grafana-piechart-panel \
    GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH="/var/lib/grafana/dashboards/dashboard.json"

USER root
RUN apk add --no-cache --update supervisor && rm  -rf /tmp/* /var/cache/apk/*

COPY --from=prometheus /bin/prometheus /bin/prometheus
COPY --from=prometheus /usr/share/prometheus /usr/share/prometheus

COPY config/prometheus/ /etc/prometheus/

# grafana
COPY config/grafana/grafana.ini /etc/grafana/grafana.ini
COPY config/grafana/provisioning/ /etc/grafana/provisioning/

# LOKI 
COPY --from=loki /usr/bin/loki /bin/loki
COPY config/loki-config.yml /etc/loki/loki-config.yml

COPY --from=tempo /tempo /tempo
COPY config/tempo-config.yml /etc/tempo/tempo-config.yml

COPY --from=otel /otelcol-contrib /otelcol-contrib
COPY config/otelcol-config.yml /etc/otelcol/otelcol-config.yml

# supervisord 
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080 9090 4317 4318 13133 3100