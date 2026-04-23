find_package(GTest REQUIRED)
include(GoogleTest)

add_executable(CppTemplateTests
    CppTemplateTest.cpp
)

target_link_libraries(CppTemplateTests
    PRIVATE
        GTest::GTest
        GTest::Main
        CppTemplate
)

target_include_directories(CppTemplateTests
    PRIVATE
        "${CMAKE_SOURCE_DIR}/src/include"
)

gtest_discover_tests(CppTemplateTests)
