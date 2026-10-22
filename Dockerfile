# Slim Hermes gateway for Render free (512 MB). No Chromium/Node/browser tools.
FROM python:3.14-slim
ENV PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1 HERMES_HOME=/opt/data
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates tini \
 && rm -rf /var/lib/apt/lists/* \
 && pip install "hermes-agent[messaging] @ git+https://github.com/NousResearch/hermes-agent@main" \
 && useradd -m -u 10000 hermes && mkdir -p /opt/data && chown hermes /opt/data
COPY start.sh /start.sh
RUN chmod +x /start.sh
USER hermes
ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/start.sh"]
