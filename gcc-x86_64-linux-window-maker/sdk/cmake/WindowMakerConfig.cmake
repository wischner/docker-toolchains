include(CMakeFindDependencyMacro)

find_dependency(X11 REQUIRED)
find_dependency(PNG REQUIRED)
find_dependency(JPEG REQUIRED)
find_dependency(TIFF REQUIRED)
find_dependency(GIF REQUIRED)
find_dependency(PkgConfig REQUIRED)

pkg_check_modules(WindowMaker_XFT REQUIRED IMPORTED_TARGET xft)
pkg_check_modules(WindowMaker_FONTCONFIG REQUIRED IMPORTED_TARGET fontconfig)
pkg_check_modules(WindowMaker_PANGOXFT REQUIRED IMPORTED_TARGET pangoxft)
pkg_check_modules(WindowMaker_WEBP REQUIRED IMPORTED_TARGET libwebp)
pkg_check_modules(WindowMaker_MAGICKWAND REQUIRED IMPORTED_TARGET MagickWand)

get_filename_component(WindowMaker_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)
set(WindowMaker_INCLUDE_DIR "${WindowMaker_PREFIX}/include")
set(WindowMaker_LIBRARY_DIR "${WindowMaker_PREFIX}/lib")

foreach(_wmaker_dependency
        X11_Xext_LIB X11_Xinerama_LIB X11_Xrandr_LIB X11_XRes_LIB
        X11_Xmu_LIB X11_Xpm_LIB)
    if(NOT ${_wmaker_dependency})
        message(FATAL_ERROR "WindowMaker requires ${_wmaker_dependency}")
    endif()
endforeach()

if(NOT TARGET WindowMaker::WUtil)
    add_library(WindowMaker::WUtil SHARED IMPORTED)
    set_target_properties(WindowMaker::WUtil PROPERTIES
        IMPORTED_LOCATION "${WindowMaker_LIBRARY_DIR}/libWUtil.so"
        INTERFACE_INCLUDE_DIRECTORIES "${WindowMaker_INCLUDE_DIR}")
endif()

if(NOT TARGET WindowMaker::wraster)
    add_library(WindowMaker::wraster SHARED IMPORTED)
    set_target_properties(WindowMaker::wraster PROPERTIES
        IMPORTED_LOCATION "${WindowMaker_LIBRARY_DIR}/libwraster.so"
        INTERFACE_INCLUDE_DIRECTORIES "${WindowMaker_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "X11::X11")
endif()

if(NOT TARGET WindowMaker::WINGs)
    add_library(WindowMaker::WINGs SHARED IMPORTED)
    set_target_properties(WindowMaker::WINGs PROPERTIES
        IMPORTED_LOCATION "${WindowMaker_LIBRARY_DIR}/libWINGs.so"
        INTERFACE_INCLUDE_DIRECTORIES "${WindowMaker_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES
            "WindowMaker::WUtil;WindowMaker::wraster;PkgConfig::WindowMaker_PANGOXFT")
endif()

if(NOT TARGET WindowMaker::WMaker)
    add_library(WindowMaker::WMaker SHARED IMPORTED)
    set_target_properties(WindowMaker::WMaker PROPERTIES
        IMPORTED_LOCATION "${WindowMaker_LIBRARY_DIR}/libWMaker.so"
        INTERFACE_INCLUDE_DIRECTORIES "${WindowMaker_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "X11::X11")
endif()

if(NOT TARGET WindowMaker::WUtil_static)
    add_library(WindowMaker::WUtil_static STATIC IMPORTED)
    set_target_properties(WindowMaker::WUtil_static PROPERTIES
        IMPORTED_LOCATION "${WindowMaker_LIBRARY_DIR}/libWUtil.a"
        INTERFACE_INCLUDE_DIRECTORIES "${WindowMaker_INCLUDE_DIR}")
endif()

if(NOT TARGET WindowMaker::wraster_static)
    add_library(WindowMaker::wraster_static STATIC IMPORTED)
    set_target_properties(WindowMaker::wraster_static PROPERTIES
        IMPORTED_LOCATION "${WindowMaker_LIBRARY_DIR}/libwraster.a"
        INTERFACE_INCLUDE_DIRECTORIES "${WindowMaker_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES
            "X11::X11;${X11_Xext_LIB};${X11_Xinerama_LIB};${X11_Xrandr_LIB};${X11_XRes_LIB};${X11_Xmu_LIB};${X11_Xpm_LIB};PNG::PNG;JPEG::JPEG;TIFF::TIFF;GIF::GIF;PkgConfig::WindowMaker_WEBP;PkgConfig::WindowMaker_MAGICKWAND;m")
endif()

if(NOT TARGET WindowMaker::WINGs_static)
    add_library(WindowMaker::WINGs_static STATIC IMPORTED)
    set_target_properties(WindowMaker::WINGs_static PROPERTIES
        IMPORTED_LOCATION "${WindowMaker_LIBRARY_DIR}/libWINGs.a"
        INTERFACE_INCLUDE_DIRECTORIES "${WindowMaker_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES
            "WindowMaker::WUtil_static;WindowMaker::wraster_static;PkgConfig::WindowMaker_XFT;PkgConfig::WindowMaker_FONTCONFIG;PkgConfig::WindowMaker_PANGOXFT;${X11_Xext_LIB};${X11_Xinerama_LIB};${X11_Xrandr_LIB};${X11_XRes_LIB};X11::X11;m")
endif()

if(NOT TARGET WindowMaker::WMaker_static)
    add_library(WindowMaker::WMaker_static STATIC IMPORTED)
    set_target_properties(WindowMaker::WMaker_static PROPERTIES
        IMPORTED_LOCATION "${WindowMaker_LIBRARY_DIR}/libWMaker.a"
        INTERFACE_INCLUDE_DIRECTORIES "${WindowMaker_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "X11::X11")
endif()

set(WindowMaker_INCLUDE_DIRS "${WindowMaker_INCLUDE_DIR}")
set(WindowMaker_LIBRARIES WindowMaker::WINGs WindowMaker::WUtil WindowMaker::wraster WindowMaker::WMaker)
set(WindowMaker_VERSION 0.96.0)
set(WindowMaker_FOUND TRUE)

