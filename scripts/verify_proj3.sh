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
cat > evidence/control.vec <<'VEC'
Instruction[32] BrEq BrLt PCSel RegWEn ImmSel[3] BrUn ASel BSel ALUSel[4] MemRW WBSel[2]
0x00100293 1 0 0 1 0 0 0 1 0 0 0
VEC
xvfb-run -a java -jar tools/logisim-evolution.jar -test-vector control_logic evidence/control.vec cpu/control-logic.circ 2>&1 | tee evidence/control-vector.log
python3 - <<'PY'
from pathlib import Path
text=Path('evidence/control-vector.log').read_text()
assert 'Passed: 1, Failed: 0' in text,text
PY
timeout 600 python3 tools/run_test.py --pipelined tests/integration-*/ 2>&1 | tee evidence/integration.log
python3 - <<'PY'
from pathlib import Path
import re
text=Path('evidence/integration.log').read_text()
assert re.findall(r'Passed (\d+)/(\d+) tests',text)==[('15','15')],text
PY
curl -fL --retry 3 --max-time 180 https://inst.eecs.berkeley.edu/~cs61c/fa24/tools/venus-latest.jar -o tools/venus.jar
echo "69e48a8ffecb155d1227d171ae6888be0d3e103975d04b19762a08fc9463e1cc  tools/venus.jar" | sha256sum --check
sha256sum tools/venus.jar | tee evidence/venus.sha256
timeout 180 bash test.sh create_custom 2>&1 | tee evidence/create-custom.log
timeout 300 bash test.sh run_custom --pipelined 2>&1 | tee evidence/custom.log
python3 - <<'PY'
from pathlib import Path
import re
text=Path('evidence/custom.log').read_text()
assert re.findall(r'Passed (\d+)/(\d+) tests',text)==[('1','1')],text
PY
python3 - <<'PY'
from pathlib import Path
import csv,json
folder=Path('tests/integration-custom/out')
actual=list(csv.reader((folder/'isa-boundaries.out').open()))
reference=list(csv.reader((folder/'isa-boundaries.piperef').open()))
assert actual[:len(reference)]==reference,'Raw trace differs from Venus'
assert len(actual)==len(reference)+1,(len(actual),len(reference))
last=[int(x,2) for x in actual[-2]]
tail=[int(x,2) for x in actual[-1]]
assert tail[:8]==last[:8] and tail[8]==last[8]+4 and tail[9]==0 and tail[10]==last[10]+1,(last,tail)
result={'reference_cycles':len(reference)-1,'actual_cycles':len(actual)-1,'exact_reference_prefix':True,'extra_halt_row':'registers unchanged, PC+4, instruction0, step+1'}
Path('evidence/raw-trace.json').write_text(json.dumps(result,indent=2)+'\n')
print(result)
PY
