/* Handle shared libraries for GDB, the GNU Debugger.

   Copyright (C) 2024 Free Software Foundation, Inc.

   This file is part of GDB.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

#include "defs.h"

#include "exec.h"
#include "haiku-tdep.h"
#include "inferior.h"
#include "objfiles.h"
#include "solib.h"
#include "solib-haiku.h"
#include "solib-target.h"


/* solib_ops for Haiku systems.  */

struct haiku_solib_ops : public target_solib_ops
{
  using target_solib_ops::target_solib_ops;

  void relocate_section_addresses (solib &so, target_section *) const override;
  void clear_solib (program_space *pspace) const override;
  void create_inferior_hook (int from_tty) const override;
  owning_intrusive_list<solib> current_sos () const override;
  bool open_symbol_file_object (int from_tty) const override;
  bool in_dynsym_resolve_code (CORE_ADDR pc) const override;
  gdb_bfd_ref_ptr bfd_open (const char *pathname) const override;
};

/* See solib-haiku.h.  */

solib_ops_up
make_haiku_solib_ops (program_space *pspace)
{
  return std::make_unique<haiku_solib_ops> (pspace);
}


/* For other targets, the solib implementation usually reads hints from the
   dynamic linker in the active address space, which could be anything from a
   core file to a live inferior.

   Haiku's runtime_loader does not export such information. The nearest
   we have is the static variable sLoadedImages. We therefore have to rely on
   what the target reports.

   This is basically a wrapper around solib-target.c.  */

void
haiku_solib_ops::relocate_section_addresses (solib &so, struct target_section *sec) const
{
  if (so.name == "commpage")
  {
    CORE_ADDR commpage_address = haiku_get_commpage_address ();
    sec->addr = commpage_address;
    sec->endaddr = commpage_address + HAIKU_COMMPAGE_SIZE;

    so.addr_low = commpage_address;
    so.addr_high = commpage_address + HAIKU_COMMPAGE_SIZE;
  }
  /*else
  {
    solib_target_so_ops::relocate_section_addresses (so, sec);
  }*/
}

/*static void
haiku_clear_so (const solib &so)
{
  if (solib_target_so_ops.clear_so != nullptr)
    solib_target_so_ops.clear_so (so);
}*/

void
haiku_solib_ops::clear_solib (program_space *pspace) const
{
  target_solib_ops::clear_solib (pspace);
}

void
haiku_solib_ops::create_inferior_hook (int from_tty) const
{
  target_solib_ops::create_inferior_hook (from_tty);
}

owning_intrusive_list<solib>
haiku_solib_ops::current_sos () const
{
  return target_solib_ops::current_sos ();
}

bool
haiku_solib_ops::open_symbol_file_object (int from_tty) const
{
  return target_solib_ops::open_symbol_file_object (from_tty);
}

bool
haiku_solib_ops::in_dynsym_resolve_code (CORE_ADDR pc) const
{
  /* No dynamic resolving implemented in Haiku yet.
     Return what the generic code has to say.  */
  return target_solib_ops::in_dynsym_resolve_code (pc);
}

gdb_bfd_ref_ptr
haiku_solib_ops::bfd_open (const char *pathname) const
{
  if (strcmp (pathname, "commpage") == 0)
    return haiku_bfd_open_commpage ();
  return target_solib_ops::bfd_open (pathname);
}
