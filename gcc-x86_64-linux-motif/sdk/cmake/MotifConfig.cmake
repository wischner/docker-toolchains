set(Motif_VERSION "2.3.8")
set(Motif_INCLUDE_DIR "/usr/include")

find_library(Motif_Xm_LIBRARY NAMES Xm REQUIRED)
find_library(Motif_Mrm_LIBRARY NAMES Mrm REQUIRED)
find_library(Motif_Uil_LIBRARY NAMES Uil REQUIRED)
find_library(Motif_GLw_LIBRARY NAMES GLw REQUIRED)

find_file(Motif_Xm_STATIC_LIBRARY NAMES libXm.a
    PATHS /usr/lib/x86_64-linux-gnu REQUIRED)
find_file(Motif_Mrm_STATIC_LIBRARY NAMES libMrm.a
    PATHS /usr/lib/x86_64-linux-gnu REQUIRED)
find_file(Motif_Uil_STATIC_LIBRARY NAMES libUil.a
    PATHS /usr/lib/x86_64-linux-gnu REQUIRED)
find_file(Motif_GLw_STATIC_LIBRARY NAMES libGLw.a
    PATHS /usr/lib/x86_64-linux-gnu REQUIRED)

find_library(Motif_Xt_LIBRARY NAMES Xt REQUIRED)
find_library(Motif_X11_LIBRARY NAMES X11 REQUIRED)
find_library(Motif_Xext_LIBRARY NAMES Xext REQUIRED)
find_library(Motif_Xft_LIBRARY NAMES Xft REQUIRED)
find_library(Motif_Xmu_LIBRARY NAMES Xmu REQUIRED)
find_library(Motif_Xrender_LIBRARY NAMES Xrender REQUIRED)
find_library(Motif_Fontconfig_LIBRARY NAMES fontconfig REQUIRED)
find_library(Motif_Freetype_LIBRARY NAMES freetype REQUIRED)
find_library(Motif_JPEG_LIBRARY NAMES jpeg REQUIRED)
find_library(Motif_PNG_LIBRARY NAMES png16 png REQUIRED)
find_library(Motif_ZLIB_LIBRARY NAMES z REQUIRED)
find_library(Motif_MATH_LIBRARY NAMES m REQUIRED)
find_library(Motif_OPENGL_LIBRARY NAMES GL REQUIRED)

set(_Motif_Xm_shared_dependencies
    "${Motif_Xt_LIBRARY}"
    "${Motif_X11_LIBRARY}"
)
set(_Motif_Xm_static_dependencies
    "${Motif_Xt_LIBRARY}"
    "${Motif_X11_LIBRARY}"
    "${Motif_Xext_LIBRARY}"
    "${Motif_Xft_LIBRARY}"
    "${Motif_Fontconfig_LIBRARY}"
    "${Motif_Freetype_LIBRARY}"
    "${Motif_Xmu_LIBRARY}"
    "${Motif_Xrender_LIBRARY}"
    "${Motif_JPEG_LIBRARY}"
    "${Motif_PNG_LIBRARY}"
    "${Motif_ZLIB_LIBRARY}"
    "${Motif_MATH_LIBRARY}"
)

if(NOT TARGET Motif::Xm)
    add_library(Motif::Xm SHARED IMPORTED)
    set_target_properties(Motif::Xm PROPERTIES
        IMPORTED_LOCATION "${Motif_Xm_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Motif_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "${_Motif_Xm_shared_dependencies}"
    )
endif()

if(NOT TARGET Motif::Xm_static)
    add_library(Motif::Xm_static STATIC IMPORTED)
    set_target_properties(Motif::Xm_static PROPERTIES
        IMPORTED_LOCATION "${Motif_Xm_STATIC_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Motif_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "${_Motif_Xm_static_dependencies}"
    )
endif()

if(NOT TARGET Motif::Mrm)
    add_library(Motif::Mrm SHARED IMPORTED)
    set_target_properties(Motif::Mrm PROPERTIES
        IMPORTED_LOCATION "${Motif_Mrm_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Motif_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "Motif::Xm"
    )
endif()

if(NOT TARGET Motif::Mrm_static)
    add_library(Motif::Mrm_static STATIC IMPORTED)
    set_target_properties(Motif::Mrm_static PROPERTIES
        IMPORTED_LOCATION "${Motif_Mrm_STATIC_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Motif_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "Motif::Xm_static"
    )
endif()

if(NOT TARGET Motif::Uil)
    add_library(Motif::Uil SHARED IMPORTED)
    set_target_properties(Motif::Uil PROPERTIES
        IMPORTED_LOCATION "${Motif_Uil_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Motif_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "Motif::Mrm"
    )
endif()

if(NOT TARGET Motif::Uil_static)
    add_library(Motif::Uil_static STATIC IMPORTED)
    set_target_properties(Motif::Uil_static PROPERTIES
        IMPORTED_LOCATION "${Motif_Uil_STATIC_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Motif_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "Motif::Mrm_static"
    )
endif()

if(NOT TARGET Motif::GLw)
    add_library(Motif::GLw SHARED IMPORTED)
    set_target_properties(Motif::GLw PROPERTIES
        IMPORTED_LOCATION "${Motif_GLw_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Motif_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "Motif::Xm;${Motif_OPENGL_LIBRARY}"
    )
endif()

if(NOT TARGET Motif::GLw_static)
    add_library(Motif::GLw_static STATIC IMPORTED)
    set_target_properties(Motif::GLw_static PROPERTIES
        IMPORTED_LOCATION "${Motif_GLw_STATIC_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Motif_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "Motif::Xm_static;${Motif_OPENGL_LIBRARY}"
    )
endif()

if(NOT TARGET Motif::Motif)
    add_library(Motif::Motif INTERFACE IMPORTED)
    set_target_properties(Motif::Motif PROPERTIES
        INTERFACE_LINK_LIBRARIES "Motif::Uil;Motif::Mrm;Motif::GLw;Motif::Xm"
    )
endif()

if(NOT TARGET Motif::Motif_static)
    add_library(Motif::Motif_static INTERFACE IMPORTED)
    set_target_properties(Motif::Motif_static PROPERTIES
        INTERFACE_LINK_LIBRARIES "Motif::Uil_static;Motif::Mrm_static;Motif::GLw_static;Motif::Xm_static"
    )
endif()

# Compatibility variables for consumers that prefer variable-style packages.
set(MOTIF_FOUND TRUE)
set(MOTIF_INCLUDE_DIR "${Motif_INCLUDE_DIR}")
set(MOTIF_LIBRARIES Motif::Xm)
set(Motif_FOUND TRUE)
