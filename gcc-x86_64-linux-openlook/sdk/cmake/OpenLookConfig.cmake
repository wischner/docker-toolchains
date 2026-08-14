include(CMakeFindDependencyMacro)
find_dependency(X11 REQUIRED)

find_path(OpenLook_TIRPC_INCLUDE_DIR
    NAMES rpc/rpc.h
    PATH_SUFFIXES tirpc
    REQUIRED
)
find_library(OpenLook_TIRPC_LIBRARY
    NAMES tirpc
    REQUIRED
)

set(OpenLook_INCLUDE_DIR "/usr/openwin/include")
set(OpenLook_LIBRARY_DIR "/usr/openwin/lib")

if(NOT TARGET OpenLook::olgx)
    add_library(OpenLook::olgx SHARED IMPORTED)
    set_target_properties(OpenLook::olgx PROPERTIES
        IMPORTED_LOCATION "${OpenLook_LIBRARY_DIR}/libolgx.so"
        INTERFACE_INCLUDE_DIRECTORIES "${OpenLook_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "X11::X11"
    )
endif()

if(NOT TARGET OpenLook::olgx_static)
    add_library(OpenLook::olgx_static STATIC IMPORTED)
    set_target_properties(OpenLook::olgx_static PROPERTIES
        IMPORTED_LOCATION "${OpenLook_LIBRARY_DIR}/libolgx.a"
        INTERFACE_INCLUDE_DIRECTORIES "${OpenLook_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "X11::X11"
    )
endif()

if(NOT TARGET OpenLook::xview)
    add_library(OpenLook::xview SHARED IMPORTED)
    set_target_properties(OpenLook::xview PROPERTIES
        IMPORTED_LOCATION "${OpenLook_LIBRARY_DIR}/libxview.so"
        INTERFACE_INCLUDE_DIRECTORIES "${OpenLook_INCLUDE_DIR};${OpenLook_TIRPC_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "OpenLook::olgx;${OpenLook_TIRPC_LIBRARY};X11::X11"
    )
endif()

if(NOT TARGET OpenLook::xview_static)
    add_library(OpenLook::xview_static STATIC IMPORTED)
    set_target_properties(OpenLook::xview_static PROPERTIES
        IMPORTED_LOCATION "${OpenLook_LIBRARY_DIR}/libxview.a"
        INTERFACE_INCLUDE_DIRECTORIES "${OpenLook_INCLUDE_DIR};${OpenLook_TIRPC_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "OpenLook::olgx_static;${OpenLook_TIRPC_LIBRARY};X11::X11;m;util"
    )
endif()

set(OpenLook_LIBRARIES OpenLook::xview OpenLook::olgx)
set(OpenLook_FOUND TRUE)
