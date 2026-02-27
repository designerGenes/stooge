# ─────────────────────────────────────────────────────────────────────────────
# Stooge CI — Makefile
#
# Convenience wrapper around the Docker + Jenkins workflow.
# All targets are PHONY (not tied to real files).
#
# Usage
#   make jenkins-start            # build image and start controller
#   make jenkins-password         # print initial admin password (first run only)
#   make connect-agent JENKINS_SECRET=<secret>
#   make jenkins-stop
#   make check-prereqs            # verify the Mac agent toolchain
# ─────────────────────────────────────────────────────────────────────────────

JENKINS_URL    ?= http://localhost:8080
JENKINS_SECRET ?=
NODE_NAME      ?= mac

.PHONY: jenkins-start jenkins-stop jenkins-restart jenkins-logs jenkins-password \
        connect-agent check-prereqs clean-simulators help

# ── Jenkins controller ───────────────────────────────────────────────────────

## Start the Jenkins controller (builds the image if needed)
jenkins-start:
	docker compose up -d --build
	@echo ""
	@echo "  Jenkins is starting …"
	@echo "  ➜  Web UI  : $(JENKINS_URL)"
	@echo "  ➜  Run 'make jenkins-password' to get the initial admin password."
	@echo "  ➜  Run 'make connect-agent JENKINS_SECRET=<secret>' once the node is created."

## Stop the Jenkins controller
jenkins-stop:
	docker compose down

## Restart the Jenkins controller
jenkins-restart:
	docker compose restart jenkins

## Tail the Jenkins controller logs
jenkins-logs:
	docker compose logs -f jenkins

## Print the initial one-time admin password (only needed on first boot)
jenkins-password:
	@docker compose exec jenkins \
	    cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null \
	    || echo "Container not running — run 'make jenkins-start' first."

# ── Mac agent ────────────────────────────────────────────────────────────────

## Connect this Mac to the Jenkins controller as a build agent.
## Requires JENKINS_SECRET (copy from Jenkins → Manage Nodes → mac → Agent).
connect-agent:
	@[ -n "$(JENKINS_SECRET)" ] || { \
	    echo "ERROR: JENKINS_SECRET is required."; \
	    echo "  1. Open $(JENKINS_URL) → Manage Jenkins → Nodes → mac"; \
	    echo "  2. Copy the secret from the 'Connect agent' page"; \
	    echo "  3. Re-run: make connect-agent JENKINS_SECRET=<secret>"; \
	    exit 1; \
	}
	JENKINS_URL=$(JENKINS_URL) JENKINS_SECRET=$(JENKINS_SECRET) NODE_NAME=$(NODE_NAME) \
	    bash scripts/connect-mac-agent.sh

# ── Toolchain check ──────────────────────────────────────────────────────────

## Check that all tools required by the Mac agent are installed
check-prereqs:
	@echo "Checking Mac agent prerequisites …"
	@which xcodebuild  > /dev/null 2>&1 && echo "  ✓  xcodebuild"  || echo "  ✗  xcodebuild  — install Xcode from the Mac App Store"
	@which xcrun       > /dev/null 2>&1 && echo "  ✓  xcrun"       || echo "  ✗  xcrun       — install Xcode Command Line Tools"
	@which tuist       > /dev/null 2>&1 && echo "  ✓  tuist"       || echo "  ✗  tuist       — curl -Ls https://install.tuist.io | bash"
	@which xcbeautify  > /dev/null 2>&1 && echo "  ✓  xcbeautify"  || echo "  ✗  xcbeautify  — brew install xcbeautify"
	@which java        > /dev/null 2>&1 && echo "  ✓  java"        || echo "  ✗  java        — brew install --cask temurin"
	@which python3     > /dev/null 2>&1 && echo "  ✓  python3"     || echo "  ✗  python3     — brew install python3"
	@which git         > /dev/null 2>&1 && echo "  ✓  git"         || echo "  ✗  git         — xcode-select --install"
	@echo "Done."

# ── Simulator housekeeping ────────────────────────────────────────────────────

## Delete all StoogeCI-* simulators left over from interrupted builds
clean-simulators:
	@echo "Removing stale StoogeCI simulators …"
	@xcrun simctl list devices -j | python3 -c "\
import sys, json; \
devs = json.load(sys.stdin).get('devices', {}); \
udids = [d['udid'] for dl in devs.values() for d in dl if d.get('name','').startswith('StoogeCI-')]; \
[print(u) for u in udids]" \
	| xargs -I{} sh -c 'xcrun simctl shutdown {} 2>/dev/null; xcrun simctl delete {}'
	@echo "Done."

# ── Help ─────────────────────────────────────────────────────────────────────

help:
	@echo ""
	@echo "Stooge CI — available targets"
	@echo "──────────────────────────────────────────────────────────────────────"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/^## /  /'
	@echo ""
