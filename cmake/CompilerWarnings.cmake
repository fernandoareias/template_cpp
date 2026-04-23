function(set_project_warnings project_name)
    set(_gcc_warnings
        -Wall
        -Wextra
        -Wshadow
        -Wnon-virtual-dtor
        -Wold-style-cast
        -Wcast-align
        -Wunused
        -Woverloaded-virtual
        -Wpedantic
        -Wconversion
        -Wsign-conversion
        -Wnull-dereference
        -Wdouble-promotion
        -Wformat=2
        -Wimplicit-fallthrough
    )

    set(_clang_warnings
        ${_gcc_warnings}
        -Wno-gnu-zero-variadic-macro-arguments
    )

    set(_msvc_warnings
        /W4
        /w14640
        /w14265
        /w14826
        /permissive-
    )

    if(MSVC)
        set(_project_warnings ${_msvc_warnings})
    elseif(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
        set(_project_warnings ${_clang_warnings})
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set(_project_warnings ${_gcc_warnings})
    else()
        message(WARNING "Unknown compiler; no warnings configured")
        return()
    endif()

    target_compile_options(${project_name} INTERFACE ${_project_warnings})
endfunction()
