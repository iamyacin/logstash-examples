# 01 — CSV to Elasticsearch

Parse a CSV file with the `csv` filter, fix field types, and use a Unix
timestamp from the file as `@timestamp`.

| | |
|---|---|
| **Input** | `data/tags.csv` (MovieLens-style tags: `userId,movieId,tag,timestamp`) |
| **Filters** | `csv`, `mutate` (convert + strip), `date` |
| **Output index** | `demo-csv-tags` |
| **Documents** | 3,683 (header skipped) |

## Run it

```bash
make up
make run EXAMPLE=01-csv-to-elasticsearch
make count
```

The file input runs in `read` mode with `exit_after_read => true`, so the
container stops on its own after the file has been indexed. `sincedb_path`
points to `/dev/null` so every run starts from the beginning.

## What to look at

- `skip_header => true` ignores the CSV header.
- `convert` turns `userId` and `movieId` into numbers, which makes them
  aggregatable in Kibana.
- `date { match => ["timestamp", "UNIX"] }` creates a real `@timestamp`.
- The raw `timestamp` field is removed after it has been applied.

## Kibana queries

```text
tag: "will ferrell"
userId: 18
```

A useful visualization is a **Terms** aggregation on `tag.keyword` (top 10
tags) or an **Average** of `movieId` per `userId`.
