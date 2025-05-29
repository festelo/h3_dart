set(CMAKE_C_STANDARD 99)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fembed-bitcode")

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

# Build static library
add_library(h3 STATIC ${CSources})

# Install library and headers
install(TARGETS h3 ARCHIVE DESTINATION lib)
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/generated/ DESTINATION include)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/h3lib/include/ DESTINATION include)