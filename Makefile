#
# Makefile -- compiling/copying/install/uninstall the module
#

PREFIX = $(setu)

# Program and Data files and directories.
DEST_PROG_DIR = $(PREFIX)/src/sl_tl/transfergrammar-
DEST_DATA_DIR = $(PREFIX)/data_bin/sl_tl/transfergrammar-
VER = 2.4.5
CPFR = cp -fr

# make all -- make programs, data, library, documentation, etc.

all:install-src install-data

install-src:
	mkdir -p $(DEST_PROG_DIR)$(VER)
	cp -fr common src tests README transfergrammar.pl doc API ChangeLog $(DEST_PROG_DIR)$(VER)
	$(CPFR) transfergrammar_run.sh transfergrammar.sh transfergrammar.spec data_bin/* $(DEST_PROG_DIR)$(VER)
	cp Makefile.stage2 $(DEST_PROG_DIR)$(VER)/Makefile

install-data:
	mkdir -p $(DEST_DATA_DIR)$(VER)
	$(CPFR)  data_bin/* $(DEST_DATA_DIR)$(VER)

# make compile -- Compiles the source code as well as the data
# compile: compile-exec compile-data

# make install -- Install what all needs to be installed, copying the files from the packages tree to systemwide directories.# it installs the engine and the corpus, dictionary, etc.


# remove the module files from sampark
clean:uninstall
uninstall:
	$(MAKE) -C  $(DEST_PROG_DIR)$(VER) clean
	rm -fr $(DEST_PROG_DIR)$(VER) $(DEST_DATA_DIR)$(VER)

.PHONY: all clean install uninstall install-src install-data

