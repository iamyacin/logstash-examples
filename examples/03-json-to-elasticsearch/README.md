# 03 — JSON lines to Elasticsearch

Expand a JSON object on each line into independent fields, filter events with
a conditional, and use the event's own ISO-8601 timestamp.

| | |
|---|---|
| **Input** | `data/sample-json.log` (5 JSON lines) |
| **Filters** | `json`, conditional `drop`, `date`, `mutate` |
| **Output index** | `demo-json-payments` |
| **Documents** | 3 (2 Mastercard events are dropped) |

## Run it

```bash
make up
make run EXAMPLE=03-json-to-elasticsearch
make count
```

## What to look at

```text
if [paymentType] == "Mastercard" {
  drop {}
}
```

This is the Logstash equivalent of a `WHERE` clause: matching events are
removed before they reach the output. Removing the condition indexes all five
events instead of three.

The JSON already contains `timestamp`, but Elasticsearch and Kibana expect
`@timestamp` — the `date` filter maps one to the other.

## Kibana queries

```text
paymentType: Visa
age >= 40
country: Brazil
```

Try a **Terms** aggregation on `purpose.keyword` or an **Average** of `age`
grouped by `gender`.
