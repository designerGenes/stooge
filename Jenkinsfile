// ─────────────────────────────────────────────────────────────────────────────
// Stooge iOS — CI Pipeline
//
// Topology
//   • Jenkins controller : Docker container (docker-compose.yml)
//   • Build agent        : The Mac that hosts Docker  ← all Xcode work runs here
//
// Prerequisites on the Mac agent (run `make check-prereqs` to verify):
//   • Xcode + Command Line Tools
//   • tuist          (curl -Ls https://install.tuist.io | bash)
//   • xcbeautify     (brew install xcbeautify)
//   • java           (brew install --cask temurin)   ← needed to run the agent JAR
//
// Agent registration:
//   1. Start Jenkins:              make jenkins-start
//   2. Open http://localhost:8080  → finish setup wizard → install suggested plugins
//   3. Manage Jenkins → Nodes → New Node → Permanent Agent
//      Label: mac  |  Remote root: ~/jenkins-agent  |  Launch: via JNLP
//   4. Copy the node secret, then:  make connect-agent JENKINS_SECRET=<secret>
// ─────────────────────────────────────────────────────────────────────────────

pipeline {

    // Every stage runs on the Mac — Xcode and the iOS Simulator cannot live in Docker.
    agent { label 'mac' }

    // ── Build parameters ────────────────────────────────────────────────────
    parameters {
        string(
            name:         'IOS_VERSION',
            defaultValue: '17.2',
            description:  'iOS Simulator runtime version (must be installed in Xcode → Platforms)'
        )
        string(
            name:         'DEVICE_TYPE',
            defaultValue: 'iPhone 15',
            description:  'Simulator device type'
        )
        booleanParam(
            name:         'KEEP_SIMULATOR',
            defaultValue: false,
            description:  'Skip teardown — useful for post-build inspection'
        )
    }

    // ── Pipeline-wide env vars ───────────────────────────────────────────────
    environment {
        // Paths
        DERIVED_DATA  = "${WORKSPACE}/DerivedData"
        RESULTS_DIR   = "${WORKSPACE}/test-results"
        XCRESULT_PATH = "${WORKSPACE}/test-results/ShadowTests.xcresult"

        // Simulator name is unique per build so parallel runs never collide
        SIM_NAME      = "StoogeCI-${BUILD_NUMBER}"

        // xcodebuild flags shared across build stages
        XCODE_FLAGS   = "CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=NO"
    }

    options {
        timestamps()
        ansiColor('xterm')
        timeout(time: 45, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '30'))
        // Prevent concurrent runs on the same agent from colliding on the simulator
        disableConcurrentBuilds()
    }

    // ════════════════════════════════════════════════════════════════════════
    stages {

        // ── 1. Prerequisites ─────────────────────────────────────────────────
        stage('Prerequisites') {
            steps {
                sh '''
                    set -euo pipefail
                    echo "──────────────────────────────────────────────"
                    echo " Checking Mac agent toolchain"
                    echo "──────────────────────────────────────────────"

                    fail=0
                    check() {
                        if which "$1" > /dev/null 2>&1; then
                            echo "  ✓  $1"
                        else
                            echo "  ✗  $1  — $2"
                            fail=1
                        fi
                    }

                    check xcodebuild "install Xcode from the Mac App Store"
                    check xcrun      "install Xcode Command Line Tools"
                    check tuist      "curl -Ls https://install.tuist.io | bash"
                    check xcbeautify "brew install xcbeautify"
                    check python3    "brew install python3"

                    [ $fail -eq 0 ] || { echo "ERROR: missing tools above"; exit 1; }

                    echo ""
                    xcodebuild -version
                    echo "tuist   $(tuist version)"
                    echo "xcbeautify $(xcbeautify --version 2>/dev/null || echo n/a)"
                    echo "──────────────────────────────────────────────"
                '''
            }
        }

        // ── 2. Generate Xcode project ────────────────────────────────────────
        stage('Generate Project') {
            steps {
                sh '''
                    set -euo pipefail
                    echo "=== tuist generate ==="
                    tuist generate --no-open
                    ls Stooge.xcodeproj/project.pbxproj > /dev/null
                    echo "project.pbxproj generated."
                '''
            }
        }

        // ── 3. Build Stooge (app under test) ─────────────────────────────────
        stage('Build — Stooge') {
            steps {
                sh """
                    set -euo pipefail
                    echo "=== xcodebuild build-for-testing  [Stooge] ==="
                    xcodebuild build-for-testing \\
                        -project  Stooge.xcodeproj \\
                        -scheme   Stooge \\
                        -destination 'platform=iOS Simulator,name=${params.DEVICE_TYPE},OS=${params.IOS_VERSION}' \\
                        -derivedDataPath '${DERIVED_DATA}' \\
                        -configuration Debug \\
                        ${XCODE_FLAGS} \\
                    | xcbeautify

                    # Verify the .app was produced
                    STOOGE_APP=\$(find '${DERIVED_DATA}/Build/Products' -maxdepth 3 -name 'Stooge.app' -type d | head -1)
                    [ -n "\$STOOGE_APP" ] || { echo "ERROR: Stooge.app not found after build"; exit 1; }
                    echo "Built → \$STOOGE_APP"
                """
            }
        }

        // ── 4. Build ShadowTests (external test bundle) ──────────────────────
        stage('Build — ShadowTests') {
            steps {
                sh """
                    set -euo pipefail
                    echo "=== xcodebuild build-for-testing  [ShadowTests] ==="
                    xcodebuild build-for-testing \\
                        -project  Stooge.xcodeproj \\
                        -scheme   ShadowTests \\
                        -destination 'platform=iOS Simulator,name=${params.DEVICE_TYPE},OS=${params.IOS_VERSION}' \\
                        -derivedDataPath '${DERIVED_DATA}' \\
                        -configuration Debug \\
                        ${XCODE_FLAGS} \\
                    | xcbeautify

                    # Verify the .xctestrun was produced
                    XCTESTRUN=\$(find '${DERIVED_DATA}/Build/Products' -maxdepth 2 -name 'ShadowTests*.xctestrun' | head -1)
                    [ -n "\$XCTESTRUN" ] || { echo "ERROR: ShadowTests.xctestrun not found after build"; exit 1; }
                    echo "xctestrun → \$XCTESTRUN"
                """
            }
        }

        // ── 5. Provision simulator ────────────────────────────────────────────
        stage('Provision Simulator') {
            steps {
                script {
                    def iosVersion  = params.IOS_VERSION
                    def deviceType  = params.DEVICE_TYPE
                    def simName     = env.SIM_NAME

                    // ── Resolve the exact runtime identifier ──────────────────
                    // `simctl list runtimes -j` returns structured JSON; filtering
                    // by version string is more robust than parsing plain text.
                    def runtime = sh(
                        script: """
                            xcrun simctl list runtimes available -j | python3 -c "
import sys, json
runtimes = json.load(sys.stdin).get('runtimes', [])
matches  = [r['identifier']
            for r in runtimes
            if r.get('isAvailable') and '${iosVersion}' in r.get('version', '')]
print(matches[0] if matches else '')
"
                        """,
                        returnStdout: true
                    ).trim()

                    if (!runtime) {
                        error(
                            "iOS ${iosVersion} runtime not found on this Mac. " +
                            "Install it via Xcode → Settings → Platforms."
                        )
                    }

                    echo "Resolved runtime: ${runtime}"

                    // ── Tear down any leftover simulator with the same name ────
                    sh """
                        STALE=\$(xcrun simctl list devices -j | python3 -c "
import sys, json
devs = json.load(sys.stdin).get('devices', {})
udids = [d['udid'] for devs_list in devs.values()
         for d in devs_list if d.get('name') == '${simName}']
print(udids[0] if udids else '')
")
                        if [ -n "\$STALE" ]; then
                            echo "Removing stale simulator \$STALE"
                            xcrun simctl shutdown "\$STALE" 2>/dev/null || true
                            xcrun simctl delete   "\$STALE"
                        fi
                    """

                    // ── Create a clean simulator for this build ────────────────
                    def udid = sh(
                        script: "xcrun simctl create '${simName}' '${deviceType}' '${runtime}'",
                        returnStdout: true
                    ).trim()

                    env.SIM_UDID = udid
                    echo "Provisioned ${simName}  udid=${udid}"

                    // ── Boot and wait ──────────────────────────────────────────
                    sh """
                        xcrun simctl boot '${udid}'
                        xcrun simctl bootstatus '${udid}' -b
                        echo "Simulator booted and ready."
                    """
                }
            }
        }

        // ── 6. Install Stooge onto the simulator ─────────────────────────────
        //
        // xcodebuild test-without-building would install the UITargetApp
        // automatically via the .xctestrun, but we do this explicitly so the
        // pipeline makes the two install steps visible and independently
        // verifiable (and so the app is warm before the test runner starts).
        stage('Install Stooge') {
            steps {
                sh '''
                    set -euo pipefail

                    STOOGE_APP=$(find "${DERIVED_DATA}/Build/Products" -maxdepth 3 -name "Stooge.app" -type d | head -1)
                    [ -n "$STOOGE_APP" ] || { echo "ERROR: Stooge.app not found"; exit 1; }

                    echo "Installing $STOOGE_APP → simulator ${SIM_UDID}"
                    xcrun simctl install "${SIM_UDID}" "$STOOGE_APP"

                    # Confirm the bundle is registered
                    xcrun simctl get_app_container "${SIM_UDID}" com.designerGenes.Stooge app \
                        && echo "Stooge installed successfully." \
                        || { echo "ERROR: Installation verification failed"; exit 1; }
                '''
            }
        }

        // ── 7. Install ShadowTests runner ────────────────────────────────────
        //
        // The test runner app (UITestRunner) built into the ShadowTests bundle
        // must also be present on the simulator before we call test-without-building.
        stage('Install ShadowTests Runner') {
            steps {
                sh '''
                    set -euo pipefail

                    # The UITestRunner .app lives alongside the xctestrun in Products/
                    RUNNER_APP=$(find "${DERIVED_DATA}/Build/Products" -maxdepth 3 \
                                      -name "ShadowTests-Runner.app" -type d | head -1)

                    if [ -n "$RUNNER_APP" ]; then
                        echo "Installing $RUNNER_APP → simulator ${SIM_UDID}"
                        xcrun simctl install "${SIM_UDID}" "$RUNNER_APP"
                        echo "ShadowTests runner installed."
                    else
                        echo "ShadowTests-Runner.app not found — xcodebuild will install it automatically."
                    fi
                '''
            }
        }

        // ── 8. Run Shadow Tests + emit JUnit XML ─────────────────────────────
        //
        // xcodebuild exits non-zero when tests fail.  We wrap the sh step in
        // catchError so Jenkins marks the build UNSTABLE (not FAILURE) and the
        // pipeline continues to the post-always block where results are published.
        stage('Run Shadow Tests') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                    sh '''
                        set -euo pipefail
                        mkdir -p "${RESULTS_DIR}"

                        XCTESTRUN=$(find "${DERIVED_DATA}/Build/Products" \
                                         -maxdepth 2 -name "ShadowTests*.xctestrun" | head -1)
                        [ -n "$XCTESTRUN" ] || { echo "ERROR: xctestrun not found"; exit 1; }

                        echo "──────────────────────────────────────────────"
                        echo " Running ShadowTests"
                        echo "  Simulator  : ${SIM_UDID}"
                        echo "  xctestrun  : $XCTESTRUN"
                        echo "  xcresult   : ${XCRESULT_PATH}"
                        echo "  JUnit XML  : ${RESULTS_DIR}/shadow-tests.xml"
                        echo "──────────────────────────────────────────────"

                        xcodebuild test-without-building \
                            -xctestrun        "$XCTESTRUN" \
                            -destination      "platform=iOS Simulator,id=${SIM_UDID}" \
                            -resultBundlePath "${XCRESULT_PATH}" \
                        | xcbeautify \
                              --report                 junit \
                              --report-path            "${RESULTS_DIR}" \
                              --junit-report-filename  shadow-tests.xml
                    '''
                }
            }
        }

    } // end stages

    // ════════════════════════════════════════════════════════════════════════
    post {

        always {
            // ── Publish JUnit results ─────────────────────────────────────────
            // Runs whether tests passed, failed, or the stage errored.
            junit(
                testResults:           'test-results/shadow-tests.xml',
                allowEmptyResults:     true,
                skipPublishingChecks:  false
            )

            // ── Archive the full .xcresult bundle ────────────────────────────
            // Lets you open it locally with `xcrun xcresulttool` or Xcode.
            archiveArtifacts(
                artifacts:         'test-results/ShadowTests.xcresult/**',
                allowEmptyArchive: true
            )

            // ── Tear down the simulator ───────────────────────────────────────
            script {
                if (!params.KEEP_SIMULATOR && env.SIM_UDID) {
                    sh """
                        echo "=== Tearing down simulator ${env.SIM_UDID} ==="
                        xcrun simctl shutdown '${env.SIM_UDID}' 2>/dev/null || true
                        xcrun simctl delete   '${env.SIM_UDID}' 2>/dev/null || true
                        echo "Simulator removed."
                    """
                } else if (params.KEEP_SIMULATOR) {
                    echo "KEEP_SIMULATOR=true — skipping teardown. Simulator ${env.SIM_UDID} is still running."
                }
            }

            // ── Clean workspace (keep test-results for the JUnit trend graph) ─
            cleanWs(
                patterns: [[pattern: 'test-results/**', type: 'EXCLUDE']]
            )
        }

        success  { echo "✅  All Shadow Tests passed." }
        unstable { echo "⚠️   Some Shadow Tests failed — see the Test Results tab." }
        failure  { echo "❌  Pipeline failed before tests could run — check the stage logs." }
    }
}
