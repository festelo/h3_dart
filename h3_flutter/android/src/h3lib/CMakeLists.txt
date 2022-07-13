cmake_minimum_required(VERSION 3.4.1)
set(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE INTERNAL "" FORCE)
project(h3lib)

FILE(GLOB CSources *.c)
FILE(GLOB HSources *.h)

add_library( h3lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
            ${CSources}
            ${HSources})

if ( NOT ANDROID ) 
    set_target_properties(h3lib PROPERTIES SUFFIX ".lib")
endif()
