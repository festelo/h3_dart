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

# Define BUILD_SHARED_LIBS, BUILDING_H3 and disable secure warnings
target_compile_definitions(h3 PUBLIC 
    BUILD_SHARED_LIBS 
    BUILDING_H3 
    _CRT_SECURE_NO_WARNINGS
)
