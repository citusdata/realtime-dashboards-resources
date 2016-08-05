# Technical Solution: Real Time Aggregation

A collection of scripts meant to be used alongside the documentation [on our website](https://docs.citusdata.com/en/v5.1/tech_soln/real_time_analytics.html). If you didn't find your way here from those docs, start there :)

**Contents:**
* [A schema](master_schema.sql) and [functions](master_functions.sql) for the master node.
* [A schema](worker_schema.sql) and [functions](worker_functions.sql) for each of the worker nodes.
* [A bash script](run_rollups.sh) which is run on the master node, and triggers rollups on each of the workers.
* [A data injest script](ingest_example_data.sql) which will stream fake data into the master node.
