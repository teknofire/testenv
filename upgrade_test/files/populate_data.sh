#!/usr/bin/env bash

set -xeuo pipefail

enddate=$(date -I -d "-30 day")
d=$(date -I)

while [ "$d" != $enddate ]; do
  echo $d

  d=$(date -I -d "$d - 1 day")
done
