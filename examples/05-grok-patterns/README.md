# 05 — Multiple grok patterns

One file, two log formats: application logs and HTTP request lines. Grok
tries each pattern in order and stops at the first match.

| | |
|---|---|
| **Input** | `data/sample.log` (7 lines, mixed formats) |
| **Filters** | `grok` (two patterns), `date`, `mutate` |
| **Output index** | `demo-grok-patterns` |
| **Documents** | 7 |

## Run it

```bash
make up
make run EXAMPLE=05-grok-patterns
make count
```

## What to look at

```text
grok {
  match => {
    "message" => [
      "%{TIMESTAMP_ISO8601:time} %{LOGLEVEL:logLevel} %{GREEDYDATA:logMessage}",
      "%{IP:clientIP} %{WORD:httpMethod} %{URIPATH:requestPath}"
    ]
  }
}
```

- `TIMESTAMP_ISO8601`, `LOGLEVEL` and `IP` are built-in patterns.
- Named captures become fields: `time`, `logLevel`, `logMessage`, `clientIP`,
  `httpMethod`, `requestPath`. `requestPath` is a custom name deliberately
  kept separate from the ECS `url` object used by the Apache example.
- Order matters. The first pattern fails on IP lines, so the second one runs.
- Lines that match neither pattern get the `_grokparsefailure` tag. Use that
  tag to find parsing problems:

```text
tags: _grokparsefailure
```

## Kibana queries

```text
logLevel: ERROR
httpMethod: POST
requestPath: /user/*
```

A **Terms** aggregation on `logLevel.keyword` gives an immediate error-rate
view; a **Terms** aggregation on `httpMethod.keyword` shows the request mix.
