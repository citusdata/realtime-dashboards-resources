-- If you're familar with postgres this function might seem a little strange,
-- however, in Citus operations on distributed transactions do not respect function
-- transactions, so this code works

DO $$
BEGIN
  LOOP
    INSERT INTO http_request (
        site_id, ingest_time, url, request_country,
        ip_address, status_code, response_time_msec
    ) VALUES (
        1, clock_timestamp(), 'http://example.com/path', 'USA',
        inet '88.250.10.123', 200, 10
    );
    PERFORM pg_sleep(random() * 2);
  END LOOP;
END $$;
