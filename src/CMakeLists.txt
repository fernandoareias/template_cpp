add_library(CppTemplate
    CppTemplate.cpp
)

target_include_directories(CppTemplate
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

target_link_libraries(CppTemplate
    PRIVATE $<BUILD_INTERFACE:ProjectOptions>
)

include(GNUInstallDirs)

install(
    TARGETS CppTemplate
    EXPORT  CppTemplateExportSet
)

install(
    EXPORT      CppTemplateExportSet
    FILE        ${PROJECT_NAME}Targets.cmake
    NAMESPACE   ${PROJECT_NAME}::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
)

install(
    DIRECTORY   include/
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)
