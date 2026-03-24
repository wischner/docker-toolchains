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

COPY packages/ /opt/openlook-packages/

# XView / OpenLook are built from source because Ubuntu 22.04 does not ship
# XView development packages. xutils-dev provides the imake-era build tools.
RUN apt-get update && apt-get install -y \
    bison \
    ca-certificates \
    curl \
    flex \
    libncurses-dev \
    libtirpc-dev \
    perl \
    xutils-dev \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    tmpdir="$(mktemp -d)"; \
    if [ -f /opt/openlook-packages/xview-base.tar.gz ]; then \
      cp /opt/openlook-packages/xview-base.tar.gz "$tmpdir/xview-base.tar.gz"; \
    else \
      curl -L --max-time 60 -fsSL -o "$tmpdir/xview-base.tar.gz" "$XVIEW_BASE_URL"; \
    fi; \
    tar -xzf "$tmpdir/xview-base.tar.gz" -C "$tmpdir"; \
    cd "$tmpdir/xview-base"; \
    perl -0pi -e 's/INCLUDES      := -I`pwd`\/build\/include \$IMAKE_EXTRA_INCLUDES -I\$OWDEST\/include \\\$\(INCLUDES\)/INCLUDES      := -I`pwd`\/build\/include \$IMAKE_EXTRA_INCLUDES -I\/usr\/include\/tirpc -I\$OWDEST\/include \\\$\(INCLUDES\)/' Build-LinuxXView.bash; \
    perl -0pi -e 's/LOCAL_LDFLAGS := -L`pwd`\/lib\/libolgx -L`pwd`\/lib\/libxview \$IMAKE_EXTRA_LOCAL_LDFLAGS -L\$OWDEST\/lib \\\$\(LOCAL_LDFLAGS\) -lutil/LOCAL_LDFLAGS := -L`pwd`\/lib\/libolgx -L`pwd`\/lib\/libxview \$IMAKE_EXTRA_LOCAL_LDFLAGS -L\$OWDEST\/lib \\\$\(LOCAL_LDFLAGS\) -lutil -ltirpc/' Build-LinuxXView.bash; \
    perl -0pi -e 's/make World/make CC='"'"'gcc -std=gnu89 -fcommon'"'"' CDEBUGFLAGS='"'"'-g -O2 -fno-strict-aliasing -std=gnu89 -fcommon'"'"' World/' Build-LinuxXView.bash; \
    perl -0pi -e 's/make Clients/make CC='"'"'gcc -std=gnu89 -fcommon'"'"' CDEBUGFLAGS='"'"'-g -O2 -fno-strict-aliasing -std=gnu89 -fcommon'"'"' Clients/' Build-LinuxXView.bash; \
    perl -0pi -e 's/make Contrib/make CC='"'"'gcc -std=gnu89 -fcommon'"'"' CDEBUGFLAGS='"'"'-g -O2 -fno-strict-aliasing -std=gnu89 -fcommon'"'"' Contrib/' Build-LinuxXView.bash; \
    perl -0pi -e 's/make depend/make CC='"'"'gcc -std=gnu89 -fcommon'"'"' CDEBUGFLAGS='"'"'-g -O2 -fno-strict-aliasing -std=gnu89 -fcommon'"'"' depend/' Build-LinuxXView.bash; \
    perl -0pi -e 's/\n        make\n/\n        make CC='"'"'gcc -std=gnu89 -fcommon'"'"' CDEBUGFLAGS='"'"'-g -O2 -fno-strict-aliasing -std=gnu89 -fcommon'"'"'\n/' Build-LinuxXView.bash; \
    perl -0pi -e 's/XVIEW_DEPLIBS = \$\(LDPRELIBS\) \$\(XLIB\) -L\.\.\/\.\.\/libolgx -lolgx -lc/XVIEW_DEPLIBS = \$\(LDPRELIBS\) \$\(XLIB\) -L..\/..\/libolgx -lolgx -ltirpc -lutil -lc/' lib/libxview/Imakefile; \
    perl -0pi -e 's/#include <xview\/attr.h>\n/#include <xview\/attr.h>\n\nstatic int copy_1_attr(Attr_attribute attr, Attr_avlist *source, Attr_avlist *dest);\nstatic int copy_counted_list(Attr_avlist *source, Attr_avlist *dest);\nstatic int copy_singleton(Attr_attribute attr, Attr_avlist *source, Attr_avlist *dest);\nstatic int copy_null_list(Attr_attribute attr, Attr_avlist *source, Attr_avlist *dest);\n/' lib/libxview/attr/attr_copy.c; \
    perl -0pi -e 's/#if defined\(__linux__\) && defined\(__GLIBC__\)\n\/\* martin\.buck\@bigfoot\.com \*\/\n#include <errno\.h>\n#else\n\/\* Unix system error variables \*\/\nextern int      sys_nerr;\nextern char    \*sys_errlist\[\];\nextern int      errno;\n#endif/#include <errno.h>\n#include <string.h>/' lib/libxview/base/xv_error.c; \
    perl -0pi -e 's/if \(\(int\) errno < sys_nerr\)\n\s*sprintf\(layer_msg, "%s", sys_errlist\[\(int\) errno\]\);\n\s*else\n\s*sprintf\(layer_msg, XV_MSG\("unix error %d"\), \n\s*\(int\) errno\);/if ((int) errno > 0)\n\t    snprintf(layer_msg, LMSGSIZE, "%s", strerror(errno));\n\telse\n\t    sprintf(layer_msg, XV_MSG("unix error %d"), \n\t\t(int) errno);/' lib/libxview/base/xv_error.c; \
    perl -0pi -e 's/#if defined\(__linux__\) && defined\(__GLIBC__\)\n\/\* martin\.buck\@bigfoot\.com \*\/\n#include <errno\.h>\n#else\nextern int      errno, sys_nerr;\nextern char    \*sys_errlist\[\];\n#endif/#include <errno.h>\n#include <string.h>/' lib/libxview/textsw/es_file.c; \
    perl -0pi -e 's/if \(errno <= 0 \|\| errno >= sys_nerr\)\n\t\tgoto Default;\n\t    \(void\) sprintf\(first_free_in_buf, \n#ifdef OW_I18N\n\t\t\tXV_MSG\("file '\''%ws'\'': %s"\),\n#else\n\t\t\tXV_MSG\("file '\''%s'\'': %s"\),\n#endif\n\t\t\t   file_name, sys_errlist\[errno\]\);/if (errno <= 0)\n\t\tgoto Default;\n\t    (void) sprintf(first_free_in_buf, \n#ifdef OW_I18N\n\t\t\tXV_MSG("file '\''%ws'\'': %s"),\n#else\n\t\t\tXV_MSG("file '\''%s'\'': %s"),\n#endif\n\t\t\t   file_name, strerror(errno));/' lib/libxview/textsw/es_file.c; \
    perl -0pi -e 's/\/\* ARGSUSED \*\/\nstatic\s+caddr_t\n#ifdef ANSI_FUNC_PROTO\nes_file_get/\/\* ARGSUSED \*\/\ncaddr_t\n#ifdef ANSI_FUNC_PROTO\nes_file_get/' lib/libxview/textsw/es_file.c; \
    perl -0pi -e 's/\/\* ARGSUSED \*\/\nstatic\s+caddr_t\n#ifdef ANSI_FUNC_PROTO\nes_mem_get/\/\* ARGSUSED \*\/\ncaddr_t\n#ifdef ANSI_FUNC_PROTO\nes_mem_get/' lib/libxview/textsw/es_mem.c; \
    perl -0pi -e 's/static int      es_file_set\(\);/static int      es_file_set();\nstatic int      es_file_make_wchar_file();/' lib/libxview/textsw/es_file.c; \
    perl -0pi -e 's/Pkg_private Es_index textsw_do_pending_delete\(\);/Pkg_private Es_index textsw_do_pending_delete();\nstatic int textsw_string_min_free();/' lib/libxview/textsw/txt_again.c; \
    perl -0pi -e 's/static char\s+\*textsw_savestr\(\), \*textsw_save2str\(\);/static char    *textsw_savestr(), *textsw_save2str();\nstatic int      any_shell_meta();/' lib/libxview/textsw/txt_e_menu.c; \
    perl -0pi -e 's/static int      event_code_for_filter_rec\(\);/static int      event_code_for_filter_rec();\nstatic int      talk_to_filter();\nstatic int      start_filter();/' lib/libxview/textsw/txt_filter.c; \
    perl -0pi -e 's/\n[ \t]*static void[ \t]+textsw_get_match_symbol\(\);\n/\n/g' lib/libxview/textsw/txt_field.c; \
    perl -0pi -e 's/#include <xview_private\/txt_18impl.h>\n/#include <xview_private\/txt_18impl.h>\n\nstatic void     textsw_get_match_symbol();\n/' lib/libxview/textsw/txt_field.c; \
    perl -0pi -e 's/Pkg_private caddr_t  textsw_checkpoint_undo\(\);/Pkg_private caddr_t  textsw_checkpoint_undo();\nstatic int      textsw_do_put();/' lib/libxview/textsw/txt_putkey.c; \
    perl -0pi -e 's/Pkg_private     save_cmd_proc\(\);/Pkg_private     save_cmd_proc();\nstatic void     add_exten_item();\nstatic void     show_dot_files_proc();\nstatic int      fc_exten_func();/' lib/libxview/textsw/txt_popup.c; \
    perl -0pi -e 's/\n\s*void show_dot_files_proc\(\);\n\s*int  fc_exten_func\(\);\n/\n/' lib/libxview/textsw/txt_popup.c; \
    perl -0pi -e 's/static void\t\trecord_pos\(\);/static void\t\trecord_pos();\nstatic int\t\twclen_by_mblen();\nstatic int\t\tbytes_in_wcs();/' lib/libxview/textsw/convpos.c; \
    perl -0pi -e 's/static Es_index write_header_etc\(\);/static Es_index write_header_etc();\nstatic int copy_pieces();\nstatic int get_current_offset();/' lib/libxview/textsw/ps_impl.c; \
    perl -0pi -e 's/static\s+caddr_t\n#ifdef ANSI_FUNC_PROTO\nps_get/caddr_t\n#ifdef ANSI_FUNC_PROTO\nps_get/' lib/libxview/textsw/ps_impl.c; \
    perl -0pi -e 's/static void\s+ev_swap_line_table\(\);/void ev_swap_line_table();/' lib/libxview/textsw/ev_display.c; \
    perl -0pi -e 's/static Ev_finger_handle ev_insert_finger\(\);/static Ev_finger_handle ev_insert_finger();\nstatic int ev_find_finger_internal();\nstatic int ev_remove_finger_internal();/' lib/libxview/textsw/ev_op_bdry.c; \
    perl -0pi -e 's/static struct ei_process_result ei_plain_text_expand\(\);/static struct ei_process_result ei_plain_text_expand();\nstatic int paint_batch();/' lib/libxview/textsw/ei_text.c; \
    perl -0pi -e 's/int\s+textsw_file_do_menu_action\(\);/int             textsw_file_do_menu_action();\nstatic int textsw_edit_do_menu_action();\nstatic int textsw_view_do_menu_action();\nstatic int textsw_find_do_menu_action();/' lib/libxview/textsw/txt_menu.c; \
    perl -0pi -e 's/\n\s*static int\s+textsw_edit_do_menu_action\(\),\s*textsw_view_do_menu_action\(\),\s*textsw_find_do_menu_action\(\);\n/\n/' lib/libxview/textsw/txt_menu.c; \
    perl -0pi -e 's/static\s+void\s+textsw_do_undo\(\);\n/static\tvoid\ttextsw_do_undo();\nstatic int textsw_do_newline();\nstatic int textsw_scroll_event();\nstatic int textsw_function_key_event();\nstatic int textsw_mouse_event();\nstatic int textsw_edit_function_key_event();\nstatic int textsw_caret_motion_event();\nstatic int textsw_field_event();\nstatic int textsw_file_operation();\nstatic int textsw_erase_action();\n/' lib/libxview/textsw/txt_input.c; \
    perl -0pi -e 's/Pkg_private void\s+textsw_update_scrollbars\(\);\n\s*static int\s+textsw_scroll_event\(\);\n\s*static int\s+textsw_function_key_event\(\);\n\s*static int\s+textsw_mouse_event\(\);\n\s*static int\s+textsw_edit_function_key_event\(\);\n\s*static int\s+textsw_caret_motion_event\(\);\n\s*static int\s+textsw_field_event\(\);\n\s*static int\s+textsw_file_operation\(\);\n\s*static int\s+textsw_erase_action\(\);\n/Pkg_private void     textsw_update_scrollbars();\n/' lib/libxview/textsw/txt_input.c; \
    perl -0pi -e 's/VIEW_PRIVATE\(view_public\)\s*=\s*NULL;/((Xv_textsw_view *)view_public)->private_data = (Xv_opaque)0;/' lib/libxview/textsw/txt_once.c; \
    perl -0pi -e 's/static Seln_result textsw_seln_yield\(\);/static Seln_result textsw_seln_yield();\nstatic int textsw_should_ask_seln_svc();/' lib/libxview/textsw/txt_selsvc.c; \
    perl -0pi -e 's/#if defined\(__linux__\) && defined\(__GLIBC__\)\n\/\* martin\.buck\@bigfoot\.com \*\/\n#include <errno\.h>\n#else\nextern int      errno, sys_nerr;\nextern char    \*sys_errlist\[\];\n#endif/#include <string.h>/' lib/libxview/textsw/txt_file.c; \
    perl -0pi -e 's/sys_msg = \(errno > 0 && errno < sys_nerr\) \? sys_errlist\[errno\] : NULL;/sys_msg = (errno > 0) ? strerror(errno) : "";/g' lib/libxview/textsw/txt_file.c; \
    perl -0pi -e 's/static Window FindLeafWindow\(\);/static Window FindLeafWindow();\nstatic int IsV2App();\nstatic int SendTrigger();\nstatic int SendOldDndEvent();\nstatic int WaitForAck();/' lib/libxview/dnd/dnd.c; \
    printf 'static void ReplyProc();\n' | cat - lib/libxview/dnd/dnd_dsdm.c > lib/libxview/dnd/dnd_dsdm.c.new; \
    mv lib/libxview/dnd/dnd_dsdm.c.new lib/libxview/dnd/dnd_dsdm.c; \
    perl -0pi -e 's/^[ \t]+static void\s+ReplyProc\(\);\s*$//mg' lib/libxview/dnd/dnd_dsdm.c; \
    perl -0pi -e 's/static notice_buttons_handle\s+notice_get_prev_button\(\);\n/static notice_buttons_handle\tnotice_get_prev_button();\nstatic int notice_quadrant(Rect notice_screen_rect, int x, int y);\n/' lib/libxview/notice/notice_pt.c; \
    perl -0pi -e 's/static void\s+flist_error\(\);\n#endif\n\n\s*/static void\tflist_error();\n#endif\n\nstatic int flist_match_regex(char *s, File_list_private *private);\n\n/' lib/libxview/file_chooser/file_list.c; \
    perl -0pi -e 's/#ifdef __linux\b/#ifdef __linux__/g; s/#ifndef __linux\b/#ifndef __linux__/g; s/#else \/\* __linux \*\//#else \/\* __linux__ \*\//g; s/#endif \/\* __linux \*\//#endif \/\* __linux__ \*\//g;' lib/libxview/file_chooser/file_list.c lib/libxview/file_chooser/flist_impl.h; \
    perl -0pi -e 's/->translate\b/->__REPB_PREFIX(translate)/g; s/->allocated\b/->__REPB_PREFIX(allocated)/g; s/->buffer\b/->__REPB_PREFIX(buffer)/g;' lib/libxview/file_chooser/file_list.c; \
    perl -0pi -e 's/#include <xview_private\/io_stream.h>\n/#include <xview_private\/io_stream.h>\n\nstatic struct CharAction digits();\nstatic enum CharClass breakProc();\nstatic int any_shell_meta();\n/' lib/libxview/filter/filter.c; \
    perl -0pi -e 's/\bcfree\s*\(/free(/g' lib/libxview/filter/filter.c lib/libxview/ttysw/cim_size.c; \
    perl -0pi -e 's/^Xv_private_data\s+CONST char\s+\*xv_domain;/extern CONST char *xv_domain;/m' lib/libxview/misc/i18n_impl.h; \
    perl -0pi -e 's/static int      panel_layout\(\);/static int      panel_layout();\nstatic int      panel_unregister_view();/' lib/libxview/panel/panel.c; \
    perl -0pi -e 's/static void panel_set_fonts\(\);/static void panel_set_fonts();\nstatic int column_from_absolute_x();\nstatic int row_from_absolute_y();/' lib/libxview/panel/p_set.c; \
    perl -0pi -e 's/static int      shrink_to_fit\(\);/static int      shrink_to_fit();\nstatic int      panel_shrink_margin();/' lib/libxview/panel/p_get.c; \
    perl -0pi -e 's/static void item_adjust_label_size\(\);/static void item_adjust_label_size();\nstatic int fix_positions();\nint panel_fix_label_position();/' lib/libxview/panel/item_set.c; \
    perl -0pi -e 's/static Xv_opaque choice_do_menu_item\(\);/static Xv_opaque choice_do_menu_item();\nstatic int find_choice();\nstatic int modify_choice();\nstatic int move_specified();\nstatic int re_alloc_choices();/' lib/libxview/panel/p_choice.c; \
    perl -0pi -e 's/static void     update_rects\(\);/static void     update_rects();\nstatic int      etoi();\nstatic int      itoe();/' lib/libxview/panel/p_slider.c; \
    perl -0pi -e 's/static void     update_rects\(\);/static void     update_rects();\nstatic int      etoi();/' lib/libxview/panel/p_gauge.c; \
    perl -0pi -e 's/#include <xview\/rect.h>\n/#include <xview\/rect.h>\n\nstatic int rect_nearest_edge();\n/' lib/libxview/rect/rect_util.c; \
    perl -0pi -e 's/static int      is_blocking_over\(\);/static int      is_blocking_over();\nstatic int      waitforReadableTimeout();/' lib/libxview/sel/sel_agent.c; \
    perl -0pi -e 's/static void SendIncrMessage\(\);/static void SendIncrMessage();\nstatic int SendIncr();/' lib/libxview/selection/sel_own.c; \
    perl -0pi -e 's/Pkg_private XID SelGetOwnerXID\(\/\* selReq \*\/\);/static XID SelGetOwnerXID(\/\* selReq \*\/);/' lib/libxview/selection/sel_req.c; \
    perl -0pi -e 's/static Requestor \*SelGetReq\(\);/static Requestor *SelGetReq();\nstatic int XvGetRequestedValue();\nstatic int ProcessNonBlkIncr();\nstatic int ProcessReq();\nstatic int OldPkgIsOwner();/' lib/libxview/selection/sel_req.c; \
    perl -0pi -e 's/#include <xview_private\/sel_impl.h>\n/#include <xview_private\/sel_impl.h>\n\nstatic int SelFindReply();\n/' lib/libxview/selection/sel_util.c; \
    perl -0pi -e 's/#include <xview_private\/svr_kmdata.h>\n/#include <xview_private\/svr_kmdata.h>\n\nstatic int xv_set_scheduler();\n/' lib/libxview/server/server.c; \
    perl -0pi -e 's/\/\* Used by atom mgr \*\//\/\* Used by atom mgr \*\/\n    XID atom_mgr_ids[4];\n    XAllocIDs((Display *)server->xdisplay, atom_mgr_ids, 4);/' lib/libxview/server/server.c; \
    perl -0pi -e 's/server->atom_mgr\[ATOM\]\s*=\s*\(XID\)\s*XAllocID\(\(Display \*\)server->xdisplay\);/server->atom_mgr[ATOM] = atom_mgr_ids[0];/' lib/libxview/server/server.c; \
    perl -0pi -e 's/server->atom_mgr\[NAME\]\s*=\s*\(XID\)\s*XAllocID\(\(Display \*\)server->xdisplay\);/server->atom_mgr[NAME] = atom_mgr_ids[1];/' lib/libxview/server/server.c; \
    perl -0pi -e 's/server->atom_mgr\[TYPE\]\s*=\s*\(XID\)\s*XAllocID\(\(Display \*\)server->xdisplay\);/server->atom_mgr[TYPE] = atom_mgr_ids[2];/' lib/libxview/server/server.c; \
    perl -0pi -e 's/server->atom_mgr\[DATA\]\s*=\s*\(XID\)\s*XAllocID\(\(Display \*\)server->xdisplay\);/server->atom_mgr[DATA] = atom_mgr_ids[3];/' lib/libxview/server/server.c; \
    perl -0pi -e 's/#include <fcntl.h>\n/#include <fcntl.h>\n#include <unistd.h>\n/' lib/libxview/ttysw/tty_init.c; \
    perl -0pi -e 's/\/\* static \*\/ void ttysw_parseargs\(\);/\/\* static \*\/ void ttysw_parseargs();\nstatic int ttyinit();/' lib/libxview/ttysw/tty_init.c; \
    perl -0pi -e 's/^\s*extern char\s+\*ttyname\(\);\n//mg' lib/libxview/ttysw/tty_init.c; \
    perl -0pi -e 's/#ifndef SVR4\n\s*union wait\s+\*status;\n#else\n\s*int\s+\*status;\n#endif/#if !defined(SVR4) \&\& !defined(__linux__)\n    union wait     *status;\n#else\n    int     *status;\n#endif/g' lib/libxview/ttysw/tty.c; \
    perl -0pi -e 's/#include <xview\/sel_attrs.h>\n/#include <xview\/sel_attrs.h>\n\nstatic int send_input_to_textsw();\nstatic int ansi_lf();\nstatic int ansi_char();\n/' lib/libxview/ttysw/ttyansi.c; \
    perl -0pi -e 's/extern int\s+tty_has_new_bufmod;\n/extern int tty_has_new_bufmod;\n\nstatic int ttysw_process_point();\nstatic int ttysw_process_adjust();\nstatic int ttysw_process_motion();\nstatic int ttysw_process_keyboard();\n/' lib/libxview/ttysw/tty_main.c; \
    perl -0pi -e 's/^int\s+ttysw_waiting_for_pty_input;/extern int ttysw_waiting_for_pty_input;/m' lib/libxview/ttysw/tty_modes.c; \
    perl -0pi -e 's/static int      ttysel_insel\(\),\n                ttysel_eq\(\);/static int      ttysel_insel(),\n                ttysel_eq(),\n                ttysel_resynch();/' lib/libxview/ttysw/ttyselect.c; \
    perl -0pi -e 's/static int \ttranslate_key\(\);/static int \ttranslate_key();\nstatic int      xevent_to_event();/' lib/libxview/win/win_input.c; \
    perl -0pi -e 's/static\s+Xv_opaque\s+window_set_avlist_tier3\(\);/static     Xv_opaque \twindow_set_avlist_tier3();\nstatic     void      \twindow_set_softkey_labels();/' lib/libxview/window/window_set.c; \
    perl -0pi -e 's/(\n\s*register\s+Xv_Drawable_info\s+\*info;\n)\s*static\s+void\s+window_set_softkey_labels\(\);\n/$1/s' lib/libxview/window/window_set.c; \
    perl -0pi -e 's/#include <xview\/server.h>\n/#include <xview\/server.h>\n\nstatic int update_default_pin_state(Frame_cmd_info *frame, Xv_opaque server_public);\n/' lib/libxview/frame/fmcmd_set.c; \
    perl -0pi -e 's/\n\s*int\s+update_default_pin_state\(\);\n/\n/' lib/libxview/frame/fmcmd_set.c; \
    perl -0pi -e 's/^char\t\*stream_getstring\(\);$/static char\t*stream_getstring();/m' lib/libxview/io_stream/input.c; \
    perl -0pi -e 's/^char \*_gettext\(\);$/static char *_gettext();/m' lib/libxview/misc/gettext.c; \
    perl -0pi -e 's/^Xv_opaque resource_type_conv\(\);$/static Xv_opaque resource_type_conv();/m' lib/libxview/misc/quark.c; \
    perl -0pi -e 's/#include <sys\/resource.h>\n/#include <sys\/resource.h>\n#if defined(__linux__) \&\& !defined(SYSV_WAIT)\n#define SYSV_WAIT 1\n#endif\n/' lib/libxview/notify/notify.h; \
    perl -0pi -e 's/#ifndef SVR4/#if !defined(SVR4) \&\& !defined(__linux__)/g' lib/libxview/notify/ndisd_wait.c lib/libxview/notify/nintn_wait.c; \
    perl -0pi -e 's/union wait\s*\*status/int *status/g; s/status->w_termsig/WTERMSIG(*status)/g; s/status->w_retcode/WEXITSTATUS(*status)/g' lib/libxview/notify/ntfy_pipe.c lib/libxview/notify/ndisd_wait.c lib/libxview/notify/nintn_wait.c; \
    perl -0pi -e 's/#include <sys\/types.h>\n/#include <sys\/types.h>\n#include <sys\/wait.h>\n/' lib/libxview/notify/ntfy_pipe.c lib/libxview/notify/ndisd_wait.c lib/libxview/notify/nintn_wait.c; \
    perl -0pi -e 's/union wait\s*\*status/int *status/g; s/status->w_termsig/WTERMSIG(*status)/g; s/status->w_retcode/WEXITSTATUS(*status)/g' contrib/examples/notifier/ntfy_pipe.c; \
    perl -0pi -e 's/#include <sys\/types.h>\n/#include <sys\/types.h>\n#include <sys\/wait.h>\n/' contrib/examples/notifier/ntfy_pipe.c; \
    perl -0pi -e 's/static int      openwin_unlink_view\(\);\n/static int      openwin_unlink_view();\nstatic int      openwin_check_view();\n/' lib/libxview/openwin/ow_view.c; \
    perl -0pi -e 's/#include <sys\/types.h>\n/#include <sys\/types.h>\n#include <string.h>\n/' lib/libxview/font/font.c; \
    perl -0pi -e 's/extern char    \*strcpy\(\);\n//' lib/libxview/font/font.c; \
    perl -0pi -e 's/(\n\s*NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL\n};\n)/$1\nstatic int font_setup_defaults(Font_locale_info\t*linfo);\nstatic int font_construct_name(Font_return_attrs font_attrs);\nstatic int font_init_create_attrs(Font_return_attrs font_attrs);\n/' lib/libxview/font/font.c; \
    perl -0pi -e 's/static void enable_timer\(\);/static void enable_timer();\nstatic int min();\nstatic int armwidth();\nstatic int seconds_on();\nstatic int date_on();/' clients/clock/clock.c; \
    perl -0pi -e 's/static Bool isClick\(\);/static Bool isClick();\nstatic Bool isEnabled();/' clients/olwm/menu.c; \
    perl -0pi -e 's/#ifdef SYSV/#if defined(SYSV) || defined(__linux__)/g' clients/olwm/olwm.c clients/olvwm-4.1/olwm.c; \
    perl -0pi -e 's/\*-------------------------------------------------------------------------\*\/\n\n\/\*\n \* makeScreenQuarks/*-------------------------------------------------------------------------*\/\n\nstatic int updateScreenWorkspaceColor();\nstatic int updateScreenWindowColor();\nstatic int updateScreenForegroundColor();\nstatic int updateScreenBackgroundColor();\nstatic int updateScreenBorderColor();\nstatic int updateScreenInputFocusColor();\nstatic int updateScreenTitleFont();\nstatic int updateScreenTextFont();\nstatic int updateScreenButtonFont();\nstatic int updateScreenIconFont();\nstatic int updateScreenGlyphFont();\n\n\/\*\n \* makeScreenQuarks/' clients/olwm/screen.c clients/olvwm-4.1/screen.c; \
    perl -0pi -e 's/#include <stdio.h>\n/#include <stdio.h>\n#include <string.h>\n/' clients/olwm/cmdstream.c clients/olwmslave/cmdstream.c clients/olvwm-4.1/cmdstream.c; \
    perl -0pi -e 's/Command\s+\*MatchCommand\(\);\nCmdAttr\s+\*MatchAttr\(\);\nint\s+EncodeAttrValue\(\);\nint\s+DecodeAttrValue\(\);/static Command\t*MatchCommand();\nstatic CmdAttr\t*MatchAttr();\nstatic int\tEncodeAttrValue();\nstatic int\tDecodeAttrValue();/' clients/olwm/cmdstream.c clients/olwmslave/cmdstream.c; \
    perl -0pi -e 's/^void\s+SlaveFailure\(\);$/static void SlaveFailure();/m' clients/olwm/slave.c clients/olwmslave/slave.c clients/olvwm-4.1/slave.c; \
    perl -0pi -e 's/#include <stdio.h>\n/#include <stdio.h>\n#include <stdlib.h>\n/' clients/olwm/st.c clients/olwmslave/st.c clients/olvwm-4.1/st.c; \
    perl -0pi -e 's/#define alloc\(type\) \(type\*\) malloc\(sizeof\(type\)\)/#define alloc(type) (type*) malloc(sizeof(type))\n\nstatic int rehash();/' clients/olwm/st.c clients/olwmslave/st.c clients/olvwm-4.1/st.c; \
    perl -0pi -e 's/#include "st.h"\n/#include "st.h"\n\nstatic int rehash();\n/' clients/olwm/st.c clients/olwmslave/st.c clients/olvwm-4.1/st.c; \
    perl -0pi -e 's/#include <st.h>\n/#include <st.h>\n\nstatic int rehash();\n/' clients/olwm/st.c clients/olwmslave/st.c clients/olvwm-4.1/st.c; \
    perl -0pi -e 's/#include "olwm.h"\n/#include "olwm.h"\n\nstatic int headerHeight();\n/' clients/olwm/winframe.c clients/olwmslave/winframe.c clients/olvwm-4.1/winframe.c; \
    perl -0pi -e 's/\nstatic int\nheaderHeight\(/\nstatic int headerHeight();\n\nstatic int\nheaderHeight(/' clients/olwm/winframe.c clients/olwmslave/winframe.c clients/olvwm-4.1/winframe.c; \
    perl -0pi -e 's/^static int headerHeight\(\);$/int headerHeight();/m; s/\nstatic int\nheaderHeight\(/\nint\nheaderHeight(/g' clients/olwm/winframe.c clients/olwmslave/winframe.c clients/olvwm-4.1/winframe.c; \
    perl -0pi -e 's/^\s*int\s+headerHeight\(\);\s*$/static int headerHeight();/mg; s/\nint\nheaderHeight\(/\nstatic int\nheaderHeight(/g' clients/olwm/winframe.c clients/olwmslave/winframe.c clients/olvwm-4.1/winframe.c; \
    perl -0pi -e 's/\nstatic int\nheightTopIcon\(/\nint\nheightTopIcon(/g; s/\nstatic int\nheightBottomIcon\(/\nint\nheightBottomIcon(/g; s/\nstatic int\nwidthBothIcon\(/\nint\nwidthBothIcon(/g' clients/olwm/winicon.c clients/olwmslave/winicon.c clients/olvwm-4.1/winicon.c; \
    perl -0pi -e 's/^\s*void\s+ReceiveHelpCmd\(\);\s*$/static void ReceiveHelpCmd();/m' clients/olwm/helprecv.c clients/olwmslave/helprecv.c clients/olvwm-4.1/helprecv.c; \
    perl -0pi -e 's/^\s*void\s+ReceivePropsCmd\(\);\s*$/static void ReceivePropsCmd();/m' clients/olwm/propsrecv.c clients/olwmslave/propsrecv.c clients/olvwm-4.1/propsrecv.c; \
    perl -0pi -e 's/\nstatic\s*\n(InitHelpWindow|CreateHelpWindow|ResetHelpWindow|DestroyHelpWindow|TextHelpWindow|ImageHelpWindow|ConstrainMousePos|MoreHelp|ErrorNotice)\(/\n$1(/g; s/\nstatic\s+int\s*\n(InitHelpWindow|CreateHelpWindow|ResetHelpWindow|DestroyHelpWindow|TextHelpWindow|ImageHelpWindow|ConstrainMousePos|MoreHelp|ErrorNotice)\(/\nint\n$1(/g; s/\nstatic\s+void\s*\n(InitHelpWindow|CreateHelpWindow|ResetHelpWindow|DestroyHelpWindow|TextHelpWindow|ImageHelpWindow|ConstrainMousePos|MoreHelp|ErrorNotice)\(/\nvoid\n$1(/g' clients/olwm/helpwin.c clients/olwmslave/helpwin.c clients/olvwm-4.1/helpwin.c; \
    perl -0pi -e 's/^(\s*)(Bool|Notify_value|int|void)\s+(InitHelpWindow|CreateHelpWindow|ResetHelpWindow|DestroyHelpWindow|TextHelpWindow|ImageHelpWindow|ConstrainMousePos|MoreHelp|ErrorNotice)\(\);\s*$/$1static $2 $3();/mg' clients/olwm/helpwin.c clients/olwmslave/helpwin.c clients/olvwm-4.1/helpwin.c; \
    perl -0pi -e 's/^(\s*)(Bool|Notify_value|int|void)\s+(InitScreenInfo|ParseScreenArgs|InputReader)\(\);\s*$/$1static $2 $3();/mg' clients/olwm/olwmslave.c clients/olwmslave/olwmslave.c clients/olvwm-4.1/olwmslave.c; \
    perl -0pi -e 's/^(\s*)(Bool|Notify_value|int|void)\s+(InitWindowProps|CreateWindowProps|DestroyWindowProps)\(\);\s*$/$1static $2 $3();/mg' clients/olwm/propswin.c clients/olwmslave/propswin.c clients/olvwm-4.1/propswin.c; \
    perl -0pi -e 's/\nstatic\s*\ndie\(/\nstatic int die();\n\nstatic\ndie(/g' clients/olwm/textedit.c clients/olwmslave/textedit.c clients/olvwm-4.1/textedit.c; \
    perl -0pi -e 's/\n[ \t]*static[ \t]*\n([ \t]*die\()/\n$1/g; s/^[ \t]*static[ \t]+die\(/die(/mg' clients/olwm/textedit.c clients/olwmslave/textedit.c clients/olvwm-4.1/textedit.c; \
    perl -0pi -e 's/\n[ \t]*static[ \t]*\n([ \t]*die\()/\n$1/g; s/^[ \t]*static[ \t]+die\(/die(/mg' clients/textedit/textedit.c; \
    perl -0pi -e 's/\n[ \t]*static[ \t]*\n([ \t]*die\([ \t]*msg1[ \t]*,[ \t]*msg2[ \t]*,[ \t]*msg3[ \t]*\))/\n$1/g' clients/textedit/textedit.c; \
    perl -0pi -e 's/extern char\s+\*ExpandPath\(\);\n/extern char *ExpandPath();\n\nstatic int rexMatch();\nstatic int rexInit();\n/' clients/olvwm-4.1/virtual.c; \
    perl -0pi -e 's/#include <regexp.h>\n#ifdef REGEXP\nregexp \*expbuf;\n#endif/#include <regex.h>\n\nstatic regex_t expbuf;/' clients/olvwm-4.1/virtual.c; \
    perl -0pi -e 's/return regexec\(expbuf, string\);/return regexec(\&expbuf, string, 0, NULL, 0) == 0;/' clients/olvwm-4.1/virtual.c; \
    perl -0pi -e 's/return step\(string,expbuf\);/return regexec(\&expbuf, string, 0, NULL, 0) == 0;/' clients/olvwm-4.1/virtual.c; \
    perl -0pi -e 's/expbuf = regcomp\(newPattern\);/(void) regcomp(\&expbuf, newPattern, REG_NOSUB | REG_EXTENDED);/' clients/olvwm-4.1/virtual.c; \
    perl -0pi -e 's/compile\(newPattern, expbuf, \&expbuf\[256\], '\''\\0'\''\);/(void) regcomp(\&expbuf, newPattern, REG_NOSUB | REG_EXTENDED);/' clients/olvwm-4.1/virtual.c; \
    perl -0pi -e 's/\nstatic char expbuf\[256\];\n/\n/' clients/olvwm-4.1/virtual.c; \
    perl -0pi -e 's/^char\s+\*strexpand\(\);$/static char *strexpand();/m' clients/olvwm-4.1/olvwmrc.y; \
    perl -0pi -e 's/#include "mem.h"\n/#include "mem.h"\n#include <string.h>\n/' clients/olvwm-4.1/gif.c; \
    perl -0pi -e 's/^extern XImage\* ReadImage\(\);$/static XImage* ReadImage();\nstatic int ReadColorMap();\nstatic int DoExtension();\nstatic int GetDataBlock();/m' clients/olvwm-4.1/gif.c; \
    chmod a+rx imake Build-LinuxXView.bash; \
    DESTDIR=; BUILDPREFIX=; export DESTDIR BUILDPREFIX; \
    OPENWINHOME="$OPENWINHOME" X11DIR=/usr CDEBUGFLAGS='-g -O2 -fno-strict-aliasing -std=gnu89 -fcommon' \
      bash ./Build-LinuxXView.bash libs clients contrib olvwm instlibs instclients instcontrib instolvwm instfinish; \
    mkdir -p "$OPENWINHOME/share/doc/xview"; \
    cp -a README README.LinuxELF README.X11R6 xview.man "$OPENWINHOME/share/doc/xview/"; \
    rm -rf "$tmpdir"

RUN set -eux; \
    tmpdir="$(mktemp -d)"; \
    if [ -f /opt/openlook-packages/xview-lib-extras.tar.gz ]; then \
      cp /opt/openlook-packages/xview-lib-extras.tar.gz "$tmpdir/xview-extras.tar.gz"; \
    else \
      curl -L --max-time 60 -fsSL -o "$tmpdir/xview-extras.tar.gz" "$XVIEW_EXTRAS_URL"; \
    fi; \
    tar -xzf "$tmpdir/xview-extras.tar.gz" -C "$tmpdir"; \
    mkdir -p "$OPENWINHOME/share/src"; \
    cp -a "$tmpdir/xview-lib-extras/SlingShot" "$OPENWINHOME/share/src/"; \
    mkdir -p "$OPENWINHOME/share/doc/xview/SlingShot"; \
    cp -a "$tmpdir/xview-lib-extras/SlingShot/README" "$tmpdir/xview-lib-extras/SlingShot/doc" "$OPENWINHOME/share/doc/xview/SlingShot/"; \
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
    echo "=== OpenLook window managers ==="; command -v olwm; command -v olvwm; \
    echo "--- Compile tests ---"; \
    printf '#include <xview/xview.h>\nint main(int argc, char **argv){xv_init(XV_INIT_ARGC_PTR_ARGV, &argc, argv, 0); return 0;}\n' > /tmp/test-xview.c; \
    gcc -o /tmp/test-xview /tmp/test-xview.c -I/usr/openwin/include -I/usr/include/tirpc -L/usr/openwin/lib -Wl,-rpath,/usr/openwin/lib -lxview -lolgx -lX11 -lXext -lXmu -lXt -lXpm -ltirpc -lm -lutil; \
    rm -f /tmp/test-xview /tmp/test-xview.c; \
    echo "All checks passed."
