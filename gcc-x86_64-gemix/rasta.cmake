# Keep the toolchain's Rasta dependency reproducible instead of following main.
include(ExternalProject)
set(GEM_RASTA_SOURCE_DIR "${CMAKE_BINARY_DIR}/deps/rasta-source")
ExternalProject_Add(rasta_viewer
    URL "https://codeload.github.com/tstih/rasta/tar.gz/${GEM_RASTA_REVISION}"
    URL_HASH "SHA256=${GEM_RASTA_SHA256}"
    TLS_VERIFY TRUE
    PREFIX "${CMAKE_BINARY_DIR}/deps/rasta"
    SOURCE_DIR "${GEM_RASTA_SOURCE_DIR}"
    BINARY_DIR "${CMAKE_BINARY_DIR}/deps/rasta-build"
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=gcc
        -DCMAKE_CXX_COMPILER=g++
    BUILD_ALWAYS TRUE
    BUILD_COMMAND ${CMAKE_COMMAND} -E env --unset=MAKEFLAGS --unset=MFLAGS
        --unset=GNUMAKEFLAGS ${CMAKE_COMMAND} --build <BINARY_DIR>
        --target rasta test_rasta --parallel 4
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory "${GEM_TOOLS_DIR}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            <SOURCE_DIR>/bin/rasta "${GEM_TOOLS_DIR}/rasta"
    BUILD_BYPRODUCTS "${GEM_TOOLS_DIR}/rasta")
