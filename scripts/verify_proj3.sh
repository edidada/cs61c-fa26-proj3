#!/usr/bin/env bash
set -euo pipefail
mkdir -p evidence
curl -fL --retry 3 --max-time 180 https://inst.eecs.berkeley.edu/~cs61c/fa24/tools/logisim-evolution-latest.jar -o tools/logisim-evolution.jar
echo "8a963b4031c681f9945fb90f5a4c5506d6973dadb46844c44deca204258238df  tools/logisim-evolution.jar" | sha256sum --check
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
timeout 300 bash test.sh test_imm_gen 2>&1 | tee evidence/imm-gen.log
python3 - <<'PY'
from pathlib import Path
import re
text=Path('evidence/imm-gen.log').read_text()
assert re.findall(r'Passed (\d+)/(\d+) tests',text)==[('6','6')],text
PY
timeout 300 bash test.sh test_alu 2>&1 | tee evidence/alu.log
python3 - <<'PY'
from pathlib import Path
import re
text=Path('evidence/alu.log').read_text()
assert re.findall(r'Passed (\d+)/(\d+) tests',text)==[('6','6')],text
PY
timeout 300 bash test.sh test_regfile 2>&1 | tee evidence/regfile.log
python3 - <<'PY'
from pathlib import Path
import re
text=Path('evidence/regfile.log').read_text()
assert re.findall(r'Passed (\d+)/(\d+) tests',text)==[('4','4')],text
PY
timeout 300 bash test.sh test_partial_load 2>&1 | tee evidence/partial_load.log
python3 - <<'PY'
from pathlib import Path
import re
text=Path('evidence/partial_load.log').read_text()
assert re.findall(r'Passed (\d+)/(\d+) tests',text)==[('3','3')],text
PY
timeout 300 bash test.sh test_partial_store 2>&1 | tee evidence/partial_store.log
python3 - <<'PY'
from pathlib import Path
import re
text=Path('evidence/partial_store.log').read_text()
assert re.findall(r'Passed (\d+)/(\d+) tests',text)==[('4','4')],text
PY
