FBC := fbc

libname := Dict

libfile := lib$(libname).a
rootdir := $(dir $(MAKEFILE_LIST))
srcdir := $(rootdir)src
objdir := $(rootdir)obj
libdir := $(rootdir)../dist
exampledir := $(rootdir)examples

LIB_BI  := $(wildcard *.bi) $(wildcard $(srcdir)/*.bi)
LIB_BAS := $(sort $(wildcard $(srcdir)/*.bas))
LIB_OBJ := $(patsubst $(srcdir)/%.bas,$(objdir)/%.o,$(LIB_BAS))
LIB_LIB := $(libdir)/$(libfile)

EXAMPLES_BI  := $(wildcard $(exampledir)/*.bi)
EXAMPLES_BAS := $(sort $(wildcard $(exampledir)/*.bas))
EXAMPLES_OBJ := $(patsubst $(exampledir)/%.bas,$(exampledir)/obj/%.o,$(EXAMPLES_BAS))
EXAMPLES_EXE := $(patsubst $(exampledir)/%.bas,$(exampledir)/bin/%.exe,$(EXAMPLES_BAS))

EXAMPLES_FLAGS := -x $(EXAMPLES_EXE)
OBJ_FLAGS := -O 3

.PHONY: examples 

examples: $(EXAMPLES_EXE)

$(EXAMPLES_EXE): $(LIB_LIB) $(EXAMPLES_OBJ)
	$(FBC) $(EXAMPLES_FLAGS) $(EXAMPLES_OBJ) -p $(dir $(LIB_LIB))

$(EXAMPLES_OBJ): $(exampledir)/obj/%.o: $(exampledir)/%.bas $(EXAMPLES_BI) $(LIB_BI) | $(exampledir)/obj
	$(FBC) $(OBJ_FLAGS) -m $(notdir $(basename $<)) -c $< -o $@

$(LIB_OBJ): $(objdir)/%.o: $(srcdir)/%.bas $(LIB_BI) | $(objdir)
	$(FBC) $(OBJ_FLAGS) -c $< -o $@

$(LIB_LIB): $(LIB_OBJ)
	$(FBC) -lib $(LIB_OBJ)
	move "$(subst /,\,$(objdir)/$(libfile))" "$(subst /,\,$(libdir))"