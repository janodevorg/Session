import ProjectDescription

let project = Project(
    name: "Session",
    packages: [
        .package(url: "git@github.com:SimplyDanny/SwiftLintPlugins.git", from: "0.59.1"),
        .package(url: "git@github.com:apple/swift-docc-plugin.git", from: "1.4.3")
    ],
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        "IPHONEOS_DEPLOYMENT_TARGET": "18.0",
        "ENABLE_MODULE_VERIFIER": "YES"
    ]),
    targets: [
        .target(
            name: "Session",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "dev.jano.session",
            sources: ["Sources/Main/**"],
            scripts: [
                swiftlintScript()
            ],
            dependencies: []
        ),
        .target(
            name: "SessionTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "dev.jano.session.test",
            sources: ["Sources/Tests/**"],
            dependencies: [
                .target(name: "Session")
            ]
        )
    ],
    schemes: [
       Scheme.scheme(
           name: "Session",
           shared: true,
           buildAction: BuildAction.buildAction(
               targets: [TargetReference.target("Session")]
           ),
           testAction: .targets(
               [TestableTarget.testableTarget(target: TargetReference.target("SessionTests"))],
               configuration: .debug,
               attachDebugger: true
           )
       )
    ]
)

func swiftlintScript() -> ProjectDescription.TargetScript {
    let script = """
    #!/bin/sh

    # Check swiftlint
    command -v /opt/homebrew/bin/swiftlint >/dev/null 2>&1 || { echo >&2 "swiftlint not found at /opt/homebrew/bin/swiftlint. Aborting."; exit 1; }

    # Create a temp file
    temp_file=$(mktemp)

    # Gather all modified and staged files within the Sources directory
    git ls-files -m Sources | grep ".swift$" > "${temp_file}"
    git diff --name-only --cached Sources | grep ".swift$" >> "${temp_file}"

    # Make list of unique and sorted files
    counter=0
    for f in $(sort "${temp_file}" | uniq)
    do
        eval "export SCRIPT_INPUT_FILE_$counter=$f"
        counter=$(expr $counter + 1)
    done

    # Lint
    if [ $counter -gt 0 ]; then
        export SCRIPT_INPUT_FILE_COUNT=${counter}
        /opt/homebrew/bin/swiftlint autocorrect --use-script-input-files
    fi
    """
    return .post(script: script, name: "Swiftlint", basedOnDependencyAnalysis: false, runForInstallBuildsOnly: false, shellPath: "/bin/zsh")
}