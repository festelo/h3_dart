# Strip symbols in release
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -s")

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

# Build library
add_library(h3 SHARED ${CSources})

# Link math library
target_link_libraries(h3 m)