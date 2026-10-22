# Slim Hermes gateway for Render free (512 MB). No Chromium/Node/browser tools.
# hermes-agent blocks wheel/sdist builds outside Nix (setup.py guard), so we
# use a source checkout + editable install, which keeps bundled assets in place.
FROM python:3.14-slim
ARG HERMES_REF=3d7e687462ca8edfa52142a4dafad12def723bd7
ENV PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1 HERMES_HOME=/opt/data
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates tini \
 && rm -rf /var/lib/apt/lists/* \
 && git init -q /opt/hermes && cd /opt/hermes \
 && git remote add origin https://github.com/NousResearch/hermes-agent \
 && git fetch -q --depth 1 origin "$HERMES_REF" && git checkout -q FETCH_HEAD \
 && rm -rf .git tests website evals \
 && pip install -e "/opt/hermes[messaging]" \
 && useradd -m -u 10000 hermes && mkdir -p /opt/data && chown hermes /opt/data
COPY start.sh /start.sh
RUN chmod +x /start.sh
USER hermes
ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/start.sh"]
