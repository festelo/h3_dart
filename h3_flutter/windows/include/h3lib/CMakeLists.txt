cmake_minimum_required(VERSION 3.4.1)
project(h3lib)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

FILE(GLOB CSources *.c)
FILE(GLOB HSources *.h)

add_library( h3lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
            ${CSources}
            ${HSources})

if ( NOT ANDROID AND NOT WIN32 ) 
    set_target_properties(h3lib PROPERTIES SUFFIX ".lib")
endif()

IF ( WIN32 )
    target_compile_definitions(h3lib PUBLIC DART_SHARED_LIB)
endif()