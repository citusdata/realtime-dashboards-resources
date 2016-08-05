#!/usr/bin/env bash

QUERY=$(cat <<END
  SELECT * FROM colocated_shard_placements(
    'http_request'::regclass, 'http_request_1min'::regclass
  );
END
)

COMMAND="bin/psql -h \$2 -p \$3 -c \"SELECT rollup_1min('\$0', '\$1')\""

bin/psql -tA -F" " -c "$QUERY" | xargs -P32 -n4 sh -c "$COMMAND"
