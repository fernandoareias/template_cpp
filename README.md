# CppTemplate

Modern C++ umbrella project template with CMake, Google Test, clang-tidy, and cppcheck.

## Getting started

Rename the project (replaces `CppTemplate` throughout):

```bash
bash init.sh --init MyProject
```

Add your first module:

```bash
bash init.sh --add-module my-module
```

## `run` commands

All day-to-day operations go through the `run` script.

### Build

```bash
./run build my-module   # build only my-module
./run build all         # build all modules
```

### Run

```bash
./run run my-module     # run my-module
./run run all           # run all modules
```

### Test

```bash
./run test my-module    # run tests for my-module
./run test all          # run all tests
```

### Clean

```bash
./run clean             # remove the build directory
```

## Module layout

Each module lives under `src/<name>/` and follows this structure:

```
src/my-module/
  CMakeLists.txt        # defines my-module-lib (static) + my-module (executable)
  main.cpp
  my-module.cpp
  include/
    my-module.h

test/my-module/
  CMakeLists.txt        # links against my-module-lib
  my-module_test.cpp
```

New modules are auto-discovered — no manual wiring needed in CMake.

## Requirements

- CMake >= 3.21
- C++20-capable compiler (GCC 10+, Clang 12+, MSVC 2019+)
- Google Test

## Optional tools (auto-detected)

- **ccache** — compiler caching
- **clang-tidy** — static analysis
- **cppcheck** — static analysis
