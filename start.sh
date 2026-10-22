#!/bin/sh
# Render has no persistent disk: rebuild config.yaml from env on every boot.
set -e
mkdir -p "$HERMES_HOME"
cat > "$HERMES_HOME/config.yaml" <<YAML
model:
  provider: nous-api
  default: ${HERMES_MODEL_DEFAULT:-stepfun/step-3.7-flash:free}
security:
  allow_lazy_installs: false
YAML
# API server only serves the public /health for Render + UptimeRobot.
export API_SERVER_ENABLED=true API_SERVER_HOST=0.0.0.0 API_SERVER_PORT="${PORT:-8642}"
exec hermes gateway run
