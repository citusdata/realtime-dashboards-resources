-- this gets run on the master

CREATE TABLE http_request (
	  site_id INT,
	  ingest_time TIMESTAMPTZ DEFAULT now(),

	  url TEXT,
	  request_country TEXT,
	  ip_address INET,

	  status_code INT,
	  response_time_msec INT
);
SELECT master_create_distributed_table('http_request', 'site_id', 'hash');
SELECT master_create_worker_shards('http_request', 16, 2);

CREATE TABLE http_request_1min (
      site_id INT,
      ingest_time TIMESTAMPTZ, -- which minute this row represents

      error_count INT,
      success_count INT,
      request_count INT,
      average_response_time_msec INT,
      CHECK (request_count = error_count + success_count),
      CHECK (ingest_time = date_trunc('minute', ingest_time))
);
SELECT master_create_distributed_table('http_request_1min', 'site_id', 'hash');
SELECT master_create_worker_shards('http_request_1min', 16, 2);

-- indexes aren't automatically created by Citus
-- this will create the index on all shards
CREATE INDEX http_request_1min_index ON http_request_1min (site_id, ingest_time);
