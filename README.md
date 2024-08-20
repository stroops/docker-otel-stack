# `docker-otel-stack`
Observability for the project, using Prometheus/Grafana/Loki

It is inspired by [docker-otel-lgtm](https://github.com/grafana/docker-otel-lgtm)

## Getting started

To run the collector locally using Docker Compose:

### Create secrets

Create an `.env` file:

```
cp .env.example .env
```

Run docker Local development

```sh
   docker compose up -d
```

### Access the grafana dashboard
Visit [localhost:8000](https://localhost:8000) and login with the credentials:

- Username: `admin`
- Password: [the password in your `.env` file]

| Port              | Description                   | Server                                |
| ----------------- | ------------------------      | --------------------------------------|
| 8080              | Grafana                       | http://localhost:8080                 |
| 4317              | OpenTelemetry GRPC endpoint   |
| 4318              | OpenTelemetry HTTP endpoint   |

## Todo
- Alert management

## Credits
This stack is heavily inspired by https://github.com/grafana/docker-otel-lgtm
