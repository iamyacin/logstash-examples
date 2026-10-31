# 02 — Apache access log to Elasticsearch

Turn Combined Log Format lines into structured fields with the built-in
`COMBINEDAPACHELOG` grok pattern, then map the Apache timestamp to
`@timestamp`.

| | |
|---|---|
| **Input** | `data/access.log` (Apache combined format) |
| **Filters** | `grok`, `date`, `mutate` |
| **Output index** | `demo-apache-logs` |
| **Documents** | 102,977 |

## Run it

```bash
make up
make run EXAMPLE=02-apache-log-to-elasticsearch
make count
```

The large file uses the `dots` stdout codec, so the terminal shows progress
without printing 100k JSON documents.

## What to look at

Logstash 8 and 9 run in ECS compatibility mode by default, so
`%{COMBINEDAPACHELOG}` emits ECS field names:

| Source | ECS field |
|--------|-----------|
| Client IP | `source.address` |
| HTTP method | `http.request.method` |
| HTTP version | `http.version` |
| Status code | `http.response.status_code` |
| Response bytes | `http.response.body.bytes` |
| Request path | `url.original` |
| Referrer | `http.request.referrer` |
| User agent | `user_agent.original` |
| Raw line | `event.original` |

A `-` byte count is omitted rather than indexed as a string. The `log.file.path`
field is added by the file input and is useful for multi-file pipelines.

The original config used `dd/MM/yyyy:HH:mm:ss Z`, which does not match
`30/Apr/2017:04:28:11 +0000`. The correct pattern uses `MMM`:

```text
dd/MMM/yyyy:HH:mm:ss Z
```

If you need the classic field names (`clientip`, `verb`, `response`, `bytes`,
`agent`), set `ecs_compatibility => disabled` on the grok filter — but prefer
ECS for new pipelines.

## Kibana queries

```text
http.response.status_code >= 400
user_agent.original: *bot*
url.original: /wp-login.php
```

Good dashboard candidates: requests over time, top URLs, response-code pie,
top user agents.
