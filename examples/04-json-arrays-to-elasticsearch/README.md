# 04 — Nested JSON arrays to Elasticsearch

A single JSON document can contain a list of child records. The `split`
filter turns each array element into its own event, and a deterministic
`document_id` makes the load idempotent.

| | |
|---|---|
| **Input** | `data/sample-json-split.log` (6 lines: 5 unique parents + 1 duplicate) |
| **Filters** | `json`, `split`, `mutate`, `date` |
| **Output index** | `demo-json-array-events` |
| **Documents** | 10 after de-duplication (12 events before writing) |

## Run it

```bash
make up
make run EXAMPLE=04-json-arrays-to-elasticsearch
make count
```

Run it twice: the document count stays at 10.

## What to look at

```text
split {
  field => "pastEvents"
}
```

Each `pastEvents` element becomes a separate event that still has the parent's
`id`, `name`, `country`, etc. The pipeline then copies `eventId` and
`transactionId` to the top level and drops the `pastEvents` object.

```text
document_id => "%{id}-%{eventId}"
```

Without a document ID, Elasticsearch generates a random ID and reruns create
duplicates. The sample file deliberately contains a repeated parent event, so
you can see the difference.

## Kibana queries

```text
eventId >= 8
country: Brazil and age < 45
```

A **Terms** aggregation on `transactionId.keyword` shows one bucket per past
transaction.
