# Generate headers from .h.in files
file(GLOB H3_TEMPLATE_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/h3lib/include/*.in")
foreach(infile ${H3_TEMPLATE_HEADERS})
    get_filename_component(filename ${infile} NAME_WE)
    configure_file(${infile} ${CMAKE_CURRENT_BINARY_DIR}/generated/${filename}.h)
endforeach()

# Include directories
include_directories(${CMAKE_CURRENT_BINARY_DIR}/generated)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/h3lib/include)

# Gather source files
file(GLOB CSources "${CMAKE_CURRENT_SOURCE_DIR}/h3lib/lib/*.c")

if(BUILD_SHARED_LIBS)
    # Dynamic h3.framework (iOS). Its exported symbols stay visible to
    # DynamicLibrary.process() however the app links its pods.
    if(NOT DEFINED H3_VERSION)
        set(H3_VERSION "1.0.0")
    endif()
    if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
        set(H3_MINIMUM_OS_KEY "MinimumOSVersion")
    else()
        set(H3_MINIMUM_OS_KEY "LSMinimumSystemVersion")
    endif()

    add_library(h3 SHARED ${CSources})
    set_target_properties(h3 PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION A
        MACOSX_FRAMEWORK_IDENTIFIER "dev.festelo.h3"
        MACOSX_FRAMEWORK_BUNDLE_VERSION "${H3_VERSION}"
        MACOSX_FRAMEWORK_SHORT_VERSION_STRING "${H3_VERSION}"
        MACOSX_FRAMEWORK_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/cmake/darwin-framework-Info.plist.in"
        PUBLIC_HEADER "${CMAKE_CURRENT_BINARY_DIR}/generated/h3api.h"
        INSTALL_NAME_DIR "@rpath"
        BUILD_WITH_INSTALL_NAME_DIR TRUE
    )

    install(TARGETS h3 FRAMEWORK DESTINATION .)
else()
    # Static libh3.a (macOS)
    add_library(h3 STATIC ${CSources})

    # Install library and headers
    install(TARGETS h3 ARCHIVE DESTINATION lib)
    install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/generated/ DESTINATION include)
    install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/h3lib/include/ DESTINATION include)
endif()
