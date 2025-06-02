# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.20 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.20)

# Project-level configuration.
set(PROJECT_NAME "h3_flutter")
project(${PROJECT_NAME} LANGUAGES CXX)

# Include FFI library
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../bindings" "${CMAKE_CURRENT_BINARY_DIR}/shared")

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(h3_flutter_bundled_libraries
  $<TARGET_FILE:h3>
  PARENT_SCOPE
)