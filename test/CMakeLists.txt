find_package(GTest REQUIRED)
include(GoogleTest)

set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}")
file(GLOB _test_dirs RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*")

foreach(_dir ${_test_dirs})
    if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${_dir}"
       AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_dir}/CMakeLists.txt")
        message(STATUS "Found test module: ${_dir}")
        add_subdirectory(${_dir})
    endif()
endforeach()
