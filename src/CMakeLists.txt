set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}")
file(GLOB _module_dirs RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*")

foreach(_dir ${_module_dirs})
    if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${_dir}"
       AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_dir}/CMakeLists.txt")
        message(STATUS "Found module: ${_dir}")
        add_subdirectory(${_dir})
    endif()
endforeach()
