# GCC x86_64 Linux OpenLook / XView development toolchain (Ubuntu 22.04)
ARG BASE_IMAGE=wischner/gcc-x86_64-linux-x11:1.0.0
FROM ${BASE_IMAGE}

ARG IMG_VERSION=1.0.0
ARG XVIEW_BASE_URL=https://sourceforge.net/projects/openlook/files/XView-base/STABLE-1.0/xview-base.tar.gz/download
ARG XVIEW_EXTRAS_URL=https://sourceforge.net/projects/openlook/files/XView-lib-extras/STABLE-1.0/xview-lib-extras.tar.gz/download

LABEL org.opencontainers.image.title="gcc-x86_64-linux-openlook" \
      org.opencontainers.image.description="GCC x86_64 Linux OpenLook and XView development toolchain layered on the Linux X11 base image." \
      org.opencontainers.image.vendor="Wischner Ltd." \
      org.opencontainers.image.licenses="GPL-2.0-or-later; see component licenses" \
      org.opencontainers.image.source="https://github.com/wischner/docker-toolchains" \
      org.opencontainers.image.version="${IMG_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive
ENV OPENWINHOME=/usr/openwin
ENV PATH=/usr/openwin/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/openwin/lib

# XView / OpenLook are built from source because Ubuntu 22.04 does not ship
# XView development packages. xutils-dev provides the imake-era build tools.
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    libtirpc-dev \
    perl \
    xutils-dev \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    tmpdir="$(mktemp -d)"; \
    curl -L --max-time 60 -fsSL -o "$tmpdir/xview-base.tar.gz" "$XVIEW_BASE_URL"; \
    tar -xzf "$tmpdir/xview-base.tar.gz" -C "$tmpdir"; \
    cd "$tmpdir/xview-base"; \
    perl -0pi -e 's/INCLUDES      := -I`pwd`\/build\/include \$IMAKE_EXTRA_INCLUDES -I\$OWDEST\/include \\\$\(INCLUDES\)/INCLUDES      := -I`pwd`\/build\/include \$IMAKE_EXTRA_INCLUDES -I\/usr\/include\/tirpc -I\$OWDEST\/include \\\$\(INCLUDES\)/' Build-LinuxXView.bash; \
    perl -0pi -e 's/LOCAL_LDFLAGS := -L`pwd`\/lib\/libolgx -L`pwd`\/lib\/libxview \$IMAKE_EXTRA_LOCAL_LDFLAGS -L\$OWDEST\/lib \\\$\(LOCAL_LDFLAGS\) -lutil/LOCAL_LDFLAGS := -L`pwd`\/lib\/libolgx -L`pwd`\/lib\/libxview \$IMAKE_EXTRA_LOCAL_LDFLAGS -L\$OWDEST\/lib \\\$\(LOCAL_LDFLAGS\) -lutil -ltirpc/' Build-LinuxXView.bash; \
    perl -0pi -e 's/#include <xview\/attr.h>\n/#include <xview\/attr.h>\n\nstatic int copy_1_attr(Attr_attribute attr, Attr_avlist *source, Attr_avlist *dest);\nstatic int copy_counted_list(Attr_avlist *source, Attr_avlist *dest);\nstatic int copy_singleton(Attr_attribute attr, Attr_avlist *source, Attr_avlist *dest);\nstatic int copy_null_list(Attr_attribute attr, Attr_avlist *source, Attr_avlist *dest);\n/' lib/libxview/attr/attr_copy.c; \
    perl -0pi -e 's/#if defined\(__linux__\) && defined\(__GLIBC__\)\n\/\* martin\.buck\@bigfoot\.com \*\/\n#include <errno\.h>\n#else\n\/\* Unix system error variables \*\/\nextern int      sys_nerr;\nextern char    \*sys_errlist\[\];\nextern int      errno;\n#endif/#include <errno.h>\n#include <string.h>/' lib/libxview/base/xv_error.c; \
    perl -0pi -e 's/if \(\(int\) errno < sys_nerr\)\n\s*sprintf\(layer_msg, "%s", sys_errlist\[\(int\) errno\]\);\n\s*else\n\s*sprintf\(layer_msg, XV_MSG\("unix error %d"\), \n\s*\(int\) errno\);/if ((int) errno > 0)\n\t    snprintf(layer_msg, LMSGSIZE, "%s", strerror(errno));\n\telse\n\t    sprintf(layer_msg, XV_MSG("unix error %d"), \n\t\t(int) errno);/' lib/libxview/base/xv_error.c; \
    perl -0pi -e 's/#if defined\(__linux__\) && defined\(__GLIBC__\)\n\/\* martin\.buck\@bigfoot\.com \*\/\n#include <errno\.h>\n#else\nextern int      errno, sys_nerr;\nextern char    \*sys_errlist\[\];\n#endif/#include <errno.h>\n#include <string.h>/' lib/libxview/textsw/es_file.c; \
    perl -0pi -e 's/if \(errno <= 0 \|\| errno >= sys_nerr\)\n\t\tgoto Default;\n\t    \(void\) sprintf\(first_free_in_buf, \n#ifdef OW_I18N\n\t\t\tXV_MSG\("file '\''%ws'\'': %s"\),\n#else\n\t\t\tXV_MSG\("file '\''%s'\'': %s"\),\n#endif\n\t\t\t   file_name, sys_errlist\[errno\]\);/if (errno <= 0)\n\t\tgoto Default;\n\t    (void) sprintf(first_free_in_buf, \n#ifdef OW_I18N\n\t\t\tXV_MSG("file '\''%ws'\'': %s"),\n#else\n\t\t\tXV_MSG("file '\''%s'\'': %s"),\n#endif\n\t\t\t   file_name, strerror(errno));/' lib/libxview/textsw/es_file.c; \
    perl -0pi -e 's/#if defined\(__linux__\) && defined\(__GLIBC__\)\n\/\* martin\.buck\@bigfoot\.com \*\/\n#include <errno\.h>\n#else\nextern int      errno, sys_nerr;\nextern char    \*sys_errlist\[\];\n#endif/#include <string.h>/' lib/libxview/textsw/txt_file.c; \
    perl -0pi -e 's/sys_msg = \(errno > 0 && errno < sys_nerr\) \? sys_errlist\[errno\] : NULL;/sys_msg = (errno > 0) ? strerror(errno) : "";/' lib/libxview/textsw/txt_file.c; \
    perl -0pi -e 's/static Window FindLeafWindow\(\);/static Window FindLeafWindow();\nstatic int IsV2App();\nstatic int SendTrigger();\nstatic int SendOldDndEvent();\nstatic int WaitForAck();/' lib/libxview/dnd/dnd.c; \
    printf 'static void ReplyProc();\n' | cat - lib/libxview/dnd/dnd_dsdm.c > lib/libxview/dnd/dnd_dsdm.c.new; \
    mv lib/libxview/dnd/dnd_dsdm.c.new lib/libxview/dnd/dnd_dsdm.c; \
    perl -0pi -e 's/^[ \t]+static void\s+ReplyProc\(\);\s*$//mg' lib/libxview/dnd/dnd_dsdm.c; \
    perl -0pi -e 's/static notice_buttons_handle\s+notice_get_prev_button\(\);\n/static notice_buttons_handle\tnotice_get_prev_button();\nstatic int notice_quadrant(Rect notice_screen_rect, int x, int y);\n/' lib/libxview/notice/notice_pt.c; \
    perl -0pi -e 's/static void\s+flist_error\(\);\n#endif\n\n\s*/static void\tflist_error();\n#endif\n\nstatic int flist_match_regex(char *s, File_list_private *private);\n\n/' lib/libxview/file_chooser/file_list.c; \
    perl -0pi -e 's/#ifdef __linux\b/#ifdef __linux__/g; s/#ifndef __linux\b/#ifndef __linux__/g; s/#else \/\* __linux \*\//#else \/\* __linux__ \*\//g; s/#endif \/\* __linux \*\//#endif \/\* __linux__ \*\//g;' lib/libxview/file_chooser/file_list.c lib/libxview/file_chooser/flist_impl.h; \
    perl -0pi -e 's/->translate\b/->__REPB_PREFIX(translate)/g; s/->allocated\b/->__REPB_PREFIX(allocated)/g; s/->buffer\b/->__REPB_PREFIX(buffer)/g;' lib/libxview/file_chooser/file_list.c; \
    perl -0pi -e 's/#include <xview_private\/io_stream.h>\n/#include <xview_private\/io_stream.h>\n\nstatic struct CharAction digits();\nstatic enum CharClass breakProc();\nstatic int any_shell_meta();\n/' lib/libxview/filter/filter.c; \
    perl -0pi -e 's/#include <xview\/server.h>\n/#include <xview\/server.h>\n\nstatic int update_default_pin_state(Frame_cmd_info *frame, Xv_opaque server_public);\n/' lib/libxview/frame/fmcmd_set.c; \
    perl -0pi -e 's/\n\s*int\s+update_default_pin_state\(\);\n/\n/' lib/libxview/frame/fmcmd_set.c; \
    perl -0pi -e 's/^char\t\*stream_getstring\(\);$/static char\t*stream_getstring();/m' lib/libxview/io_stream/input.c; \
    perl -0pi -e 's/^char \*_gettext\(\);$/static char *_gettext();/m' lib/libxview/misc/gettext.c; \
    perl -0pi -e 's/^Xv_opaque resource_type_conv\(\);$/static Xv_opaque resource_type_conv();/m' lib/libxview/misc/quark.c; \
    perl -0pi -e 's/#ifdef SYSV_WAIT\nEXTERN_FUNCTION \(Notify_value\s+notify_default_wait3, \(Notify_client nclient, int pid, int  \*status, struct rusage \*rusage\)\);\n#define notify_default_waitpid notify_default_wait3\n#else\nEXTERN_FUNCTION \(Notify_value \tnotify_default_wait3, \(Notify_client nclient, int pid, union wait \*status, struct rusage \*rusage\)\);\n#endif/#if defined(SYSV_WAIT) || defined(__linux__)\nEXTERN_FUNCTION (Notify_value   notify_default_wait3, (Notify_client nclient, int pid, int  *status, struct rusage *rusage));\n#define notify_default_waitpid notify_default_wait3\n#else\nEXTERN_FUNCTION (Notify_value \tnotify_default_wait3, (Notify_client nclient, int pid, union wait *status, struct rusage *rusage));\n#endif/g; s/#ifdef SYSV_WAIT\nEXTERN_FUNCTION \(Notify_value \tnotify_next_wait3_func, \(Notify_client nclient, int pid, int  \*status, struct rusage \*rusage\)\);\n#define notify_next_waitpid_func notify_next_wait3_func\n#else\nEXTERN_FUNCTION \(Notify_value \tnotify_next_wait3_func, \(Notify_client nclient, int pid, union wait \*status, struct rusage \*rusage\)\);\n#endif/#if defined(SYSV_WAIT) || defined(__linux__)\nEXTERN_FUNCTION (Notify_value \tnotify_next_wait3_func, (Notify_client nclient, int pid, int  *status, struct rusage *rusage));\n#define notify_next_waitpid_func notify_next_wait3_func\n#else\nEXTERN_FUNCTION (Notify_value \tnotify_next_wait3_func, (Notify_client nclient, int pid, union wait *status, struct rusage *rusage));\n#endif/g;' lib/libxview/notify/notify.h; \
    perl -0pi -e 's/#ifndef SVR4\n    union wait     \*status;\n#else \/\* SVR4 \*\//#if !defined(SVR4) \&\& !defined(__linux__)\n    union wait     *status;\n#else \/\* SVR4 \*\//g;' lib/libxview/notify/ndisd_wait.c lib/libxview/notify/nintn_wait.c; \
    perl -0pi -e 's/static int      openwin_unlink_view\(\);\n/static int      openwin_unlink_view();\nstatic int      openwin_check_view();\n/' lib/libxview/openwin/ow_view.c; \
    perl -0pi -e 's/#include <sys\/types.h>\n/#include <sys\/types.h>\n#include <string.h>\n/' lib/libxview/font/font.c; \
    perl -0pi -e 's/extern char    \*strcpy\(\);\n//' lib/libxview/font/font.c; \
    perl -0pi -e 's/(\n\s*NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL\n};\n)/$1\nstatic int font_setup_defaults(Font_locale_info\t*linfo);\nstatic int font_construct_name(Font_return_attrs font_attrs);\nstatic int font_init_create_attrs(Font_return_attrs font_attrs);\n/' lib/libxview/font/font.c; \
    chmod a+rx imake Build-LinuxXView.bash; \
    DESTDIR=; BUILDPREFIX=; export DESTDIR BUILDPREFIX; \
    OPENWINHOME="$OPENWINHOME" X11DIR=/usr CDEBUGFLAGS='-g -O2 -fno-strict-aliasing -std=gnu89' \
      bash ./Build-LinuxXView.bash libs clients contrib olvwm instlibs instclients instcontrib instolvwm instfinish; \
    mkdir -p "$OPENWINHOME/share/doc/xview"; \
    cp -a README README.LinuxELF README.X11R6 xview.man "$OPENWINHOME/share/doc/xview/"; \
    rm -rf "$tmpdir"

RUN set -eux; \
    tmpdir="$(mktemp -d)"; \
    curl -L --max-time 60 -fsSL -o "$tmpdir/xview-extras.tar.gz" "$XVIEW_EXTRAS_URL"; \
    tar -xzf "$tmpdir/xview-extras.tar.gz" -C "$tmpdir"; \
    cd "$tmpdir/xview-lib-extras/SlingShot"; \
    make -j"$(nproc)"; \
    make install INSTALL_DIR="$OPENWINHOME"; \
    mkdir -p "$OPENWINHOME/share/doc/xview/SlingShot"; \
    cp -a README doc "$OPENWINHOME/share/doc/xview/SlingShot/"; \
    rm -rf "$tmpdir"

WORKDIR /work

# Sanity checks
RUN set -eux; \
    echo "=== Compiler ==="; gcc --version; g++ --version; \
    echo "=== CMake ==="; cmake --version; \
    echo "=== pkg-config ==="; pkg-config --version; \
    echo "=== GDB ==="; gdb --version | head -1; \
    echo "=== Base X11 ==="; pkg-config --modversion x11; \
    echo "=== OpenLook headers ==="; test -f /usr/openwin/include/xview/xview.h; \
    echo "=== XView libraries ==="; test -f /usr/openwin/lib/libxview.so; test -f /usr/openwin/lib/libolgx.so; \
    echo "=== SlingShot library ==="; ls /usr/openwin/lib/libsspkg.*; \
    echo "=== OpenLook window managers ==="; command -v olwm; command -v olvwm; \
    echo "--- Compile tests ---"; \
    printf '#include <xview/xview.h>\nint main(int argc, char **argv){xv_init(XV_INIT_ARGC_PTR_ARGV, &argc, argv, 0); return 0;}\n' > /tmp/test-xview.c; \
    gcc -o /tmp/test-xview /tmp/test-xview.c -I/usr/openwin/include -I/usr/include/tirpc -L/usr/openwin/lib -Wl,-rpath,/usr/openwin/lib -lxview -lolgx -lX11 -lXext -lXmu -lXt -lXpm -ltirpc -lm -lutil; \
    printf '#include <sspkg/rectobj.h>\nint main(void){return 0;}\n' > /tmp/test-sspkg.c; \
    gcc -c -o /tmp/test-sspkg.o /tmp/test-sspkg.c -I/usr/openwin/include; \
    rm -f /tmp/test-xview /tmp/test-xview.c /tmp/test-sspkg.o /tmp/test-sspkg.c; \
    echo "All checks passed."
