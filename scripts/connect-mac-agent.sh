#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# connect-mac-agent.sh
#
# Downloads the Jenkins agent JAR from the controller and starts an inbound
# (JNLP) agent that runs on this Mac.  All iOS/Xcode pipeline work is
# dispatched here — nothing Xcode-related runs inside Docker.
#
# Usage (via Makefile):
#   make connect-agent JENKINS_SECRET=<secret>
#
# Or directly:
#   JENKINS_URL=http://localhost:8080 \
#   JENKINS_SECRET=<secret>          \
#   NODE_NAME=mac                    \
#   bash scripts/connect-mac-agent.sh
#
# Prerequisites:
#   • Java 17+   (brew install --cask temurin)
#   • The "mac" node must already exist in Jenkins and have the label "mac".
#     Create it at:  Manage Jenkins → Nodes → New Node
#     Type: Permanent Agent  |  Label: mac  |  Launch: via inbound JNLP
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Config (override via environment) ────────────────────────────────────────
JENKINS_URL="${JENKINS_URL:-http://localhost:8080}"
NODE_NAME="${NODE_NAME:-mac}"
AGENT_WORKDIR="${AGENT_WORKDIR:-$HOME/jenkins-agent}"
JENKINS_SECRET="${JENKINS_SECRET:?'ERROR: JENKINS_SECRET must be set.  Copy it from Jenkins → Nodes → mac → Agent page.'}"

# ── Sanity checks ─────────────────────────────────────────────────────────────
if ! which java > /dev/null 2>&1; then
    echo "ERROR: java not found.  Install with: brew install --cask temurin"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d. -f1)
if [ "${JAVA_VERSION:-0}" -lt 17 ] 2>/dev/null; then
    echo "WARNING: Java ${JAVA_VERSION} detected — Jenkins agent requires Java 17+."
fi

# ── Wait for Jenkins to be ready ──────────────────────────────────────────────
echo "Waiting for Jenkins at ${JENKINS_URL} …"
for i in $(seq 1 30); do
    if curl -sf "${JENKINS_URL}/login" > /dev/null 2>&1; then
        echo "Jenkins is up."
        break
    fi
    [ "$i" -eq 30 ] && { echo "ERROR: Jenkins did not become ready."; exit 1; }
    sleep 2
done

# ── Download the agent JAR ────────────────────────────────────────────────────
mkdir -p "${AGENT_WORKDIR}"
cd "${AGENT_WORKDIR}"

echo "Downloading agent.jar from ${JENKINS_URL} …"
curl -fsSL -o agent.jar "${JENKINS_URL}/jnlpJars/agent.jar"
echo "agent.jar downloaded ($(du -sh agent.jar | cut -f1))."

# ── Connect ────────────────────────────────────────────────────────────────────
echo ""
echo "Connecting agent '${NODE_NAME}' to ${JENKINS_URL}"
echo "Work directory: ${AGENT_WORKDIR}"
echo "Press Ctrl-C to disconnect."
echo ""

exec java -jar agent.jar \
    -url       "${JENKINS_URL}" \
    -secret    "${JENKINS_SECRET}" \
    -name      "${NODE_NAME}" \
    -workDir   "${AGENT_WORKDIR}"
