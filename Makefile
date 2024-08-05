# Copyright (C) 2022, ATA Engineering, Inc.
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

all: $(MODULE_NAME)_m.so

GITCHECK = $(shell git status | head -n 1)
TEST = $(findstring fatal,$(GITCHECK))
VERSTRING = unknown
ifeq (branch,$(TEST))
	VERSTRING = unknown
	$(info This is NOT a git repository)
else
	VERSTRING = $(shell git describe --tags)
endif

version: 
	$(info Creating version string)
	@echo '#ifndef MODULEVERSION' >> version.hpp
	@echo -n '#define MODULEVERSION "' >> version.hpp
	$(info version is ${VERSTRING})
	@echo -n $(VERSTRING) >> version.hpp
	@echo '"' >> version.hpp
	@echo '#endif' >> version.hpp
	$(info done with versioning)

$(MODULE_NAME)_m.so: $(LIB_OBJS) $(OBJS) version
	$(SHARED_LD) $(SHARED_LD_FLAGS) $(MODULE_NAME)_m.so $(LIB_FLAGS) $(LIB_OBJS) $(OBJS)

FRC : 

clean:
	rm -fr $(LOCI_OBJS) $(OBJS) $(LIB_OBJS) $(MODULE_NAME)_m.so $(JUNK)

install: $(MODULE_NAME)_m.so
	cp $(MODULE_NAME)_m.so $(CHEM_BASE)/lib

LOCI_FILES = $(wildcard *.loci)
LOCI_LPP_FILES = $(LOCI_FILES:.loci=.cc)

distclean: 
	rm $(DEPEND_FILES) version.hpp
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
endif
