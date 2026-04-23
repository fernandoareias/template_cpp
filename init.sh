#!/usr/bin/env bash
set -euo pipefail

PLACEHOLDER="CppTemplate"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Usage ─────────────────────────────────────────────────────────
usage() {
    echo "Usage: $0 --init PROJECT_NAME"
    echo
    echo "  --init PROJECT_NAME   Replace '${PLACEHOLDER}' with PROJECT_NAME"
    echo "                        throughout the template and rename stub files."
    exit 1
}

# ── Argument parsing ──────────────────────────────────────────────
PROJECT_NAME=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --init)
            shift
            [[ $# -eq 0 ]] && { echo "Error: --init requires a PROJECT_NAME"; usage; }
            PROJECT_NAME="$1"
            shift
            ;;
        -h|--help) usage ;;
        *) echo "Unknown argument: $1"; usage ;;
    esac
done

[[ -z "$PROJECT_NAME" ]] && usage

# ── Validation ────────────────────────────────────────────────────
if [[ ! "$PROJECT_NAME" =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; then
    echo "Error: PROJECT_NAME must start with a letter and contain only"
    echo "       letters, digits, and underscores. Got: '${PROJECT_NAME}'"
    exit 1
fi

if [[ "$PROJECT_NAME" == "$PLACEHOLDER" ]]; then
    echo "Error: PROJECT_NAME cannot be the same as the placeholder ('${PLACEHOLDER}')"
    exit 1
fi

# ── Idempotency guard ─────────────────────────────────────────────
if ! grep -qF "$PLACEHOLDER" "${SCRIPT_DIR}/CMakeLists.txt" 2>/dev/null; then
    echo "Warning: placeholder '${PLACEHOLDER}' not found in root CMakeLists.txt."
    echo "         init.sh may have already been run. Nothing changed."
    exit 0
fi

echo "Initialising template: '${PLACEHOLDER}' → '${PROJECT_NAME}'"

# ── Helper: portable in-place sed ────────────────────────────────
sed_inplace() {
    local file="$1"
    local from="$2"
    local to="$3"
    if sed --version >/dev/null 2>&1; then
        sed -i "s/${from}/${to}/g" "$file"
    else
        sed -i '' "s/${from}/${to}/g" "$file"
    fi
}

# ── Step 1: Replace in CMake files ───────────────────────────────
echo "[1/5] Replacing '${PLACEHOLDER}' in CMake files..."

cmake_files=(
    "${SCRIPT_DIR}/CMakeLists.txt"
    "${SCRIPT_DIR}/src/CMakeLists.txt"
    "${SCRIPT_DIR}/test/CMakeLists.txt"
)

for f in "${cmake_files[@]}"; do
    if [[ -f "$f" ]]; then
        sed_inplace "$f" "$PLACEHOLDER" "$PROJECT_NAME"
        echo "      patched: ${f#"${SCRIPT_DIR}/"}"
    else
        echo "      Warning: not found: $f"
    fi
done

# ── Step 2: Replace in source/header/test files ───────────────────
echo "[2/5] Replacing '${PLACEHOLDER}' in source files..."

while IFS= read -r -d '' f; do
    sed_inplace "$f" "$PLACEHOLDER" "$PROJECT_NAME"
    echo "      patched: ${f#"${SCRIPT_DIR}/"}"
done < <(find "${SCRIPT_DIR}/src" "${SCRIPT_DIR}/test" \
              -type f \( -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) \
              -print0)

# ── Step 3: Rename .cmake.in config file ─────────────────────────
echo "[3/5] Renaming cmake config template..."

OLD_CONFIG="${SCRIPT_DIR}/cmake/${PLACEHOLDER}Config.cmake.in"
NEW_CONFIG="${SCRIPT_DIR}/cmake/${PROJECT_NAME}Config.cmake.in"

if [[ -f "$OLD_CONFIG" ]]; then
    mv "$OLD_CONFIG" "$NEW_CONFIG"
    echo "      renamed: cmake/${PLACEHOLDER}Config.cmake.in → cmake/${PROJECT_NAME}Config.cmake.in"
elif [[ -f "$NEW_CONFIG" ]]; then
    echo "      already renamed: cmake/${PROJECT_NAME}Config.cmake.in"
else
    echo "      Warning: config template not found at: $OLD_CONFIG"
fi

# ── Step 4: Rename stub source/test files ────────────────────────
echo "[4/5] Renaming stub files..."

rename_if_exists() {
    local old_path="$1"
    local new_path="$2"
    if [[ -f "$old_path" ]]; then
        mv "$old_path" "$new_path"
        echo "      renamed: ${old_path#"${SCRIPT_DIR}/"} → ${new_path#"${SCRIPT_DIR}/"}"
    elif [[ -f "$new_path" ]]; then
        echo "      already renamed: ${new_path#"${SCRIPT_DIR}/"}"
    fi
}

rename_if_exists \
    "${SCRIPT_DIR}/src/${PLACEHOLDER}.cpp" \
    "${SCRIPT_DIR}/src/${PROJECT_NAME}.cpp"

rename_if_exists \
    "${SCRIPT_DIR}/src/include/${PLACEHOLDER}.h" \
    "${SCRIPT_DIR}/src/include/${PROJECT_NAME}.h"

rename_if_exists \
    "${SCRIPT_DIR}/test/${PLACEHOLDER}Test.cpp" \
    "${SCRIPT_DIR}/test/${PROJECT_NAME}Test.cpp"

# ── Step 5: Patch README ──────────────────────────────────────────
echo "[5/5] Patching README.md..."

if [[ -f "${SCRIPT_DIR}/README.md" ]]; then
    sed_inplace "${SCRIPT_DIR}/README.md" "$PLACEHOLDER" "$PROJECT_NAME"
    echo "      patched: README.md"
fi

# ── Done ──────────────────────────────────────────────────────────
echo
echo "Done. Template initialised as '${PROJECT_NAME}'."
echo
echo "Next steps:"
echo "  cmake -B build -DCMAKE_BUILD_TYPE=Debug"
echo "  cmake --build build"
echo "  cd build && ctest --output-on-failure"
