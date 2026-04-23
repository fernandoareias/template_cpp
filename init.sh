#!/usr/bin/env bash
set -euo pipefail

PLACEHOLDER="CppTemplate"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: $0 <command> [args]"
    echo ""
    echo "Commands:"
    echo "  --init PROJECT_NAME        Rename the umbrella project"
    echo "  --add-module MODULE_NAME   Scaffold a new module under src/"
    echo ""
    echo "Examples:"
    echo "  $0 --init MyProject"
    echo "  $0 --add-module payment"
    exit 1
}

sed_inplace() {
    local file="$1" from="$2" to="$3"
    if sed --version >/dev/null 2>&1; then
        sed -i "s/${from}/${to}/g" "$file"
    else
        sed -i '' "s/${from}/${to}/g" "$file"
    fi
}

validate_name() {
    local name="$1" label="$2"
    if [[ ! "$name" =~ ^[A-Za-z][A-Za-z0-9_-]*$ ]]; then
        echo "Error: ${label} must start with a letter and contain only"
        echo "       letters, digits, hyphens, and underscores. Got: '${name}'"
        exit 1
    fi
}

cmd_init() {
    local project_name="$1"
    validate_name "$project_name" "PROJECT_NAME"

    if [[ "$project_name" == "$PLACEHOLDER" ]]; then
        echo "Error: PROJECT_NAME cannot be the same as the placeholder ('${PLACEHOLDER}')"
        exit 1
    fi

    if ! grep -qF "$PLACEHOLDER" "${SCRIPT_DIR}/CMakeLists.txt" 2>/dev/null; then
        echo "Warning: placeholder '${PLACEHOLDER}' not found — init may have already been run."
        exit 0
    fi

    echo "Initialising: '${PLACEHOLDER}' → '${project_name}'"

    sed_inplace "${SCRIPT_DIR}/CMakeLists.txt" "$PLACEHOLDER" "$project_name"
    echo "  patched: CMakeLists.txt"

    if [[ -f "${SCRIPT_DIR}/README.md" ]]; then
        sed_inplace "${SCRIPT_DIR}/README.md" "$PLACEHOLDER" "$project_name"
        echo "  patched: README.md"
    fi

    echo ""
    echo "Done. Next:"
    echo "  ./run build all"
    echo "  ./run test  all"
}

cmd_add_module() {
    local name="$1"
    validate_name "$name" "MODULE_NAME"

    local src_dir="${SCRIPT_DIR}/src/${name}"
    local test_dir="${SCRIPT_DIR}/test/${name}"
    local ns="${name//-/_}"   # namespace: hyphens → underscores

    if [[ -d "$src_dir" ]]; then
        echo "Error: module '${name}' already exists at src/${name}/"
        exit 1
    fi

    echo "Scaffolding module: ${name}"

    # src/
    mkdir -p "${src_dir}/include"

    cat > "${src_dir}/CMakeLists.txt" <<EOF
add_library(${name}-lib STATIC
    ${name}.cpp
)

target_include_directories(${name}-lib
    PUBLIC include
)

target_link_libraries(${name}-lib
    PRIVATE \$<BUILD_INTERFACE:ProjectOptions>
)

add_executable(${name}
    main.cpp
)

target_link_libraries(${name}
    PRIVATE
        ${name}-lib
        \$<BUILD_INTERFACE:ProjectOptions>
)
EOF

    cat > "${src_dir}/include/${name}.h" <<EOF
#pragma once

#include <string>

namespace ${ns} {

std::string hello();

} // namespace ${ns}
EOF

    cat > "${src_dir}/${name}.cpp" <<EOF
#include "${name}.h"

namespace ${ns} {

std::string hello()
{
    return "Hello from ${name}!";
}

} // namespace ${ns}
EOF

    cat > "${src_dir}/main.cpp" <<EOF
#include "${name}.h"
#include <iostream>

int main()
{
    std::cout << ${ns}::hello() << '\\n';
    return 0;
}
EOF

    echo "  created: src/${name}/"

    # test/
    mkdir -p "${test_dir}"

    cat > "${test_dir}/CMakeLists.txt" <<EOF
add_executable(${name}-tests
    ${name}_test.cpp
)

target_link_libraries(${name}-tests
    PRIVATE
        GTest::GTest
        GTest::Main
        ${name}-lib
)

gtest_discover_tests(${name}-tests)
EOF

    cat > "${test_dir}/${name}_test.cpp" <<EOF
#include "${name}.h"
#include <gtest/gtest.h>

TEST(${ns^}, HelloReturnsExpectedString)
{
    EXPECT_EQ(${ns}::hello(), "Hello from ${name}!");
}
EOF

    echo "  created: test/${name}/"
    echo ""
    echo "Done. Run:"
    echo "  ./run build ${name}"
    echo "  ./run run   ${name}"
    echo "  ./run test  ${name}"
}

[[ $# -lt 1 ]] && usage

case "$1" in
    --init)
        [[ $# -lt 2 ]] && { echo "Error: --init requires a PROJECT_NAME"; usage; }
        cmd_init "$2"
        ;;
    --add-module)
        [[ $# -lt 2 ]] && { echo "Error: --add-module requires a MODULE_NAME"; usage; }
        cmd_add_module "$2"
        ;;
    -h|--help) usage ;;
    *) echo "Unknown command: $1"; usage ;;
esac
