cmake_minimum_required(VERSION 3.21)

project(
    CppTemplate
    VERSION 0.1.0
    DESCRIPTION "A modern C++ project"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(cmake/StandardProjectSettings.cmake)
include(cmake/ProjectOptions.cmake)
include(cmake/StaticAnalysers.cmake)
include(cmake/GenerateAndInstallConfig.cmake)

add_subdirectory(src)

enable_testing()
add_subdirectory(test)
