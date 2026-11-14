#!/usr/bin/env bash
set -euo pipefail
mkdir -p evidence
curl -fL --retry 3 --max-time 180 https://inst.eecs.berkeley.edu/~cs61c/fa24/tools/logisim-evolution-latest.jar -o tools/logisim-evolution.jar
sha256sum tools/logisim-evolution.jar | tee evidence/tools.sha256
git rev-parse HEAD > evidence/commit.txt
timeout 300 bash test.sh test_branch_comp 2>&1 | tee evidence/branch-comp.log
python3 - <<'PY'
from pathlib import Path
import re
text=Path('evidence/branch-comp.log').read_text()
rows=re.findall(r'Passed (\d+)/(\d+) tests',text)
assert rows == [('3','3')], rows
PY
