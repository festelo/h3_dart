cmake_minimum_required(VERSION 3.4.1)
project(h3)

option(BuildForTests "BuildForTests" OFF)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

FILE(GLOB CSources *.c)
FILE(GLOB HSources *.h)

add_library( h3

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
            ${CSources}
            ${HSources})

if (BuildForTests OR NOT WIN32 AND NOT ANDROID) 
    set_target_properties(h3 PROPERTIES PREFIX "")
    set_target_properties(h3 PROPERTIES SUFFIX ".so")
endif()

IF ( WIN32 )
    target_compile_definitions(h3 PUBLIC DART_SHARED_LIB)
endif()