#!/usr/bin/env bash
# Fetch the SingleStepTests/z80 conformance data into testdata/.
#
# The harness reads the upstream .json files directly, so no decode step is
# needed. Roughly 1.6 GB after clone; testdata/ is gitignored.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -d testdata/.git ]; then
    echo "updating testdata/"
    git -C testdata pull --ff-only
else
    echo "cloning SingleStepTests/z80 into testdata/ (this is large)"
    git clone --depth 1 https://github.com/SingleStepTests/z80.git testdata
fi

echo "$(find testdata/v1 -name '*.json' | wc -l) test files ready"
echo "run: zig build sst"
