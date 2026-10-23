#!/bin/sh
# Render has no persistent disk: rebuild config.yaml from env on every boot.
set -e
mkdir -p "$HERMES_HOME"
# Provider: Google Gemini (native "gemini" provider, reads GEMINI_API_KEY) when its key is set,
# with OpenRouter as fallback if OPENROUTER_API_KEY is also set; otherwise OpenRouter only.
if [ -n "$GEMINI_API_KEY" ]; then
  PROVIDER=gemini; MODEL="${HERMES_MODEL_DEFAULT:-gemini-3.5-flash-lite}"
else
  PROVIDER=openrouter; MODEL="${HERMES_MODEL_DEFAULT:-openrouter/free}"
fi
cat > "$HERMES_HOME/config.yaml" <<YAML
model:
  provider: $PROVIDER
  default: $MODEL
security:
  allow_lazy_installs: false
YAML
if [ "$PROVIDER" = gemini ] && [ -n "$OPENROUTER_API_KEY" ]; then
  cat >> "$HERMES_HOME/config.yaml" <<YAML
fallback_providers:
  - provider: openrouter
    model: ${OPENROUTER_FALLBACK_MODEL:-openrouter/free}
YAML
fi
# Custom personas (/personality <name>) + matching skills (/<name>)
printf 'personalities: ' >> "$HERMES_HOME/config.yaml"
cat /opt/bots/personalities.json >> "$HERMES_HOME/config.yaml"
printf '\n' >> "$HERMES_HOME/config.yaml"
cat >> "$HERMES_HOME/config.yaml" <<'YAML'
platforms:
  telegram:
    extra:
      command_menu:
        max_commands: 100
        priority:
          - personality
          - code_forge
          - grok_bot
          - hustle_hawk
          - ivy_hollow
          - keys_and_deeds
          - lead_scout
          - lynx_lens
          - moon_wolf
          - nova_scout
          - reel_rocket
          - sars_practitioner
          - viral_vibe
          - vita_pulse
YAML
mkdir -p "$HERMES_HOME/skills" && cp -r /opt/bots/skills/. "$HERMES_HOME/skills/"
# API server only serves the public /health for Render + UptimeRobot.
export API_SERVER_ENABLED=true API_SERVER_HOST=0.0.0.0 API_SERVER_PORT="${PORT:-8642}"
exec hermes gateway run
