CREATE OR REPLACE FUNCTION colocated_shard_placements(left_table REGCLASS, right_table REGCLASS)
RETURNS TABLE (left_shard TEXT, right_shard TEXT, nodename TEXT, nodeport BIGINT) AS $$
  SELECT
    a.logicalrelid::regclass||'_'||a.shardid,
    b.logicalrelid::regclass||'_'||b.shardid,
    nodename, nodeport
  FROM pg_dist_shard a
  JOIN pg_dist_shard b USING (shardminvalue)
  JOIN pg_dist_shard_placement p ON (a.shardid = p.shardid)
  WHERE a.logicalrelid = left_table AND b.logicalrelid = right_table;
$$ LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION expire_old_request_data() RETURNS void
AS $$
  SET LOCAL citus.all_modification_commutative TO TRUE;
  -- If we didn't set all_modifications_commutative master_modify_multiple_shards would
  -- take out an exclusive lock on each of the shard placements (the metadata on the
  -- master, not the actual placement), preventing any simultaneous queries while the
  -- delete runs. The only other modification we run against these tables is inserts,
  -- which are commutative with these deletions, so it's safe to make this optimization

  SELECT master_modify_multiple_shards(
    'DELETE FROM http_request WHERE ingest_time < now() - interval ''1 hour'';');

  SELECT master_modify_multiple_shards(
    'DELETE FROM http_request_1min WHERE ingest_time < now() - interval ''1 day'';');

  SELECT NULL::void;
$$ LANGUAGE 'sql';
