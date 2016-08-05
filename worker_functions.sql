CREATE OR REPLACE FUNCTION rollup_1min(p_source_shard text, p_dest_shard text) RETURNS void
AS $$
BEGIN
  -- the dest shard will have a name like: http_request_1min_204566, where 204566 is the
  -- shard id. We lock using that id, to make sure multiple instances of this function
  -- never simultaneously write to the same shard.
  IF pg_try_advisory_xact_lock(29999, split_part(p_dest_shard, '_', 4)::int) = false THEN
    -- N.B. make sure the int constant (29999) you use here is unique within your system
    RETURN;
  END IF;

  EXECUTE format($insert$
    INSERT INTO %2$I (
      site_id, ingest_time, request_count,
      error_count, success_count, average_response_time_msec
    ) SELECT
      site_id,
      date_trunc('minute', ingest_time) as minute,
      COUNT(1) as request_count,
      SUM(CASE WHEN (status_code between 200 and 299) THEN 1 ELSE 0 END) as success_count,
      SUM(CASE WHEN (status_code between 200 and 299) THEN 0 ELSE 1 END) as error_count,
      SUM(response_time_msec) / COUNT(1) AS average_response_time_msec
    FROM %1$I
    WHERE
      date_trunc('minute', ingest_time) > (
	SELECT COALESCE(max(ingest_time), timestamp '10-10-1901') FROM %2$I
      )
      AND date_trunc('minute', ingest_time) < date_trunc('minute', now())
    GROUP BY site_id, minute
    ORDER BY minute ASC;
  $insert$, p_source_shard, p_dest_shard);
END;
$$ LANGUAGE 'plpgsql';
