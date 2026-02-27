# ─────────────────────────────────────────────────────────────────────────────
# Stooge CI — Jenkins controller image
#
# Extends the official LTS image with:
#   • Required plugins pre-installed at build time (faster first boot)
#   • git + curl for SCM polling
#
# The controller itself never runs Xcode.  It delegates all iOS builds to the
# Mac agent that connects via JNLP on port 50000.
# ─────────────────────────────────────────────────────────────────────────────

FROM jenkins/jenkins:lts-jdk21

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
 && rm -rf /var/lib/apt/lists/*

USER jenkins

# Pre-install plugins at image-build time so the container is immediately
# usable without waiting for the plugin download on first boot.
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli \
        --plugin-file /usr/share/jenkins/ref/plugins.txt \
        --verbose
