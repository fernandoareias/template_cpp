# CppTemplate

Modern C++ project template with CMake, Google Test, clang-tidy, and cppcheck.

## Initialising this template

```bash
bash init.sh --init MyProjectName
```

Replaces all `CppTemplate` references with your project name and renames stub files accordingly.

## Building

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build
```

## Testing

```bash
cd build && ctest --output-on-failure
```

## Requirements

- CMake >= 3.21
- C++20-capable compiler (GCC 10+, Clang 12+, MSVC 2019+)
- Google Test

## Optional tools (auto-detected)

- **ccache** — compiler caching
- **clang-tidy** — static analysis
- **cppcheck** — static analysis

---

Based on https://gregorykelleher.com/modern_cpp_project_structuring
