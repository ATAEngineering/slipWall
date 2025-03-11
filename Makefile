# Copyright (C) 2024, ATA Engineering, Inc.
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with this program; if not, see
# <https://www.gnu.org/licenses/lgpl-3.0.html>.

LOCI_BASE?=/usr/local/loci
CHEM_BASE?=/usr/local/chem

MODULE_NAME = slipWall

# Put objects in the module here
LOCI_OBJS = slipWall.o
OBJS =

include $(CHEM_BASE)/chem.conf
include $(LOCI_BASE)/Loci.conf

INCLUDES = -I$(CHEM_BASE)/include -I$(CHEM_BASE)/include/fluidPhysics
#uncomment this for a debugging compile
#COPT=-O0 -g 
CPP += -fPIC

LOCAL_LIBS = 

JUNK = *~  core ti_files ii_files rii_files

LIB_OBJS=$(LOCI_OBJS:.o=_lo.o)

.DEFAULT_GOAL: all

all: module

VERSION_FILE := version.hpp

$(VERSION_FILE): 
	$(info Checking for git)
	@echo "#ifndef MODULEVERSION" > $(VERSION_FILE)
	@if [ -d .git ]; then  \
	  echo "this is a git repository"; \
	  VERSTRING=$$(git describe --tags --always); \
	else \
	  echo "this is NOT a git repository"; \
	  VERSTRING="unknown"; \
	fi; \
	echo "version is $${VERSTRING}"; \
	echo "#define MODULEVERSION \"$${VERSTRING}\"" >> $(VERSION_FILE)
	@echo "#endif" >> $(VERSION_FILE)
	$(info done with versioning)

module: $(VERSION_FILE) $(LIB_OBJS) $(OBJS)
	$(SHARED_LD) $(SHARED_LD_FLAGS) $(MODULE_NAME)_m.so $(LIB_FLAGS) $(LIB_OBJS) $(OBJS)

FRC : 

clean:
	rm -fr $(LOCI_OBJS) $(OBJS) $(LIB_OBJS) $(MODULE_NAME)_m.so $(JUNK)

install: module
	cp $(MODULE_NAME)_m.so $(CHEM_BASE)/lib

LOCI_FILES = $(wildcard *.loci)
LOCI_LPP_FILES = $(LOCI_FILES:.loci=.cc)

distclean: 
	rm $(DEPEND_FILES) 
	rm -fr $(VERSION_FILE)
	rm -fr $(LOCI_OBJS) $(OBJS) $(LIB_OBJS) $(MODULE_NAME)_m.so $(JUNK) $(LOCI_LPP_FILES)

# dependencies
#
%.d: %.cpp
	set -e; $(CPP) -M $(COPT) $(EXCEPTIONS) $(DEFINES) $(INCLUDES) $< \
	| sed 's/\($*\)\.o[ :]*/\1.o \1_lo.o $@ : /g' > $@; \
		[ -s $@ ] || rm -f $@

DEPEND_FILES=$(subst .o,.d,$(LOCI_OBJS)) $(subst .o,.d,$(OBJS))
JUNK += $(subst .loci,.cc,$(LOCI_FILES))

#include automatically generated dependencies                                                                                                         
ifeq ($(filter $(MAKECMDGOALS),clean distclean),)
-include $(DEPEND_FILES)
-include $(VERSION_FILE)
endif
