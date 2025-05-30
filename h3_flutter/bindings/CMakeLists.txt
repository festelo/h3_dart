cmake_minimum_required(VERSION 3.20)
project(h3 C)

# Set standard C version
set(CMAKE_C_STANDARD 11)

# Detect platform and delegate to the right cmake file
if(ANDROID)
    message(STATUS "Configuring for Android")
    include(cmake/android.cmake)

elseif(APPLE)
    message(STATUS "Configuring for iOS/macOS")
    include(cmake/darwin.cmake)

elseif(WIN32)
    message(STATUS "Configuring for Windows")
    include(cmake/windows.cmake)

elseif(UNIX)
    message(STATUS "Configuring for Linux")
    include(cmake/linux.cmake)

else()
    message(FATAL_ERROR "Unsupported platform")
endif()