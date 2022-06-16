cmake_minimum_required(VERSION 3.4.1)

FILE(GLOB CSources ../ios/Classes/h3lib/*.c)
FILE(GLOB HSources ../ios/Classes/h3lib/*.h)

add_library( h3lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
            ${CSources}
            ${HSources})