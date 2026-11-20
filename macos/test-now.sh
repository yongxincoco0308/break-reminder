#!/bin/bash
# Show one break right now, then exit. / 马上弹一次休息页面然后退出 / Muestra un descanso ahora.
#   bash test-now.sh --language en
. "$(dirname "$0")/_common.sh"
need_python
exec "$PY" "$SCRIPT" --test-now "$@"
