# use [mingw32-]make to build & run 

# build & run system on Linux: make [linux]
.PHONY: linux
linux: log.log
# build & run system on Windows: mingw32-make [win32]
.PHONY: win32
win32: log.log

# run sample system in hosted mode
log.log: src.src ./exe.exe
	./exe.exe < $< > $@ && tail $(TAIL) $@
C = c.c
H = h.h
./exe.exe: $(C) $(H)
	$(CC) $(CFLAGS) -o $@ $(C)
	
# github pull
.PHONY: pull
pull:
	git pull &
	cd wiki ; git pull &

# build GNU toolchain from sources (some cryptic makefile part, see wiki)

CPU_CORES ?= $(shell grep processor /proc/cpuinfo |wc -l)
MAKE = make -j$(CPU_CORES)

## default TARGET
TARGET ?= i386-elf

## versions
BINUTILS_VER = 2.29.1
GMP_VER = 6.1.2
MPFR_VER = 3.1.6
MPC_VER = 1.0.3
CLOOG_VER = 0.18.1
ISL_VER = 0.18

## packages
BINUTILS = binutils-$(BINUTILS_VER)
GMP = gmp-$(GMP_VER)
MPFR = mpfr-$(MPFR_VER)
MPC = mpc-$(MPC_VER)
CLOOG = cloog-$(CLOOG_VER)
ISL = isl-$(ISL_VER)

## archives
BINUTILS_GZ = $(BINUTILS).tar.bz2
GMP_GZ = $(GMP).tar.xz
MPFR_GZ = $(MPFR).tar.xz
MPC_GZ = $(MPC).tar.gz
CLOOG_GZ = $(CLOOG).tar.gz
ISL_GZ = $(ISL).tar.bz2

## create directory structure
CWD = $(CURDIR)
GZ = $(CWD)/gz
SRC = $(CWD)/src
TMP = $(CWD)/tmp
TC = $(CWD)/$(TARGET)
DIRS = $(GZ) $(SRC) $(TMP) $(TC)
.PHONY: dirs
dirs:
	mkdir -p $(DIRS)

## download sources
.PHONY: gz
gz: $(GZ)/$(BINUTILS_GZ) $(GZ)/$(GMP_GZ) $(GZ)/$(MPFR_GZ) $(GZ)/$(MPC_GZ) $(GZ)/$(CLOOG_GZ) $(GZ)/$(ISL_GZ)
WGET = wget -c -P $(GZ)
$(GZ)/$(BINUTILS_GZ):
	$(WGET) http://ftp.gnu.org/gnu/binutils/$(BINUTILS_GZ) && touch $@
$(GZ)/$(GMP_GZ):
	$(WGET) ftp://ftp.gmplib.org/pub/gmp/$(GMP_GZ) && touch $@
$(GZ)/$(MPFR_GZ):
	$(WGET) http://www.mpfr.org/mpfr-current/$(MPFR_GZ) && touch $@	
$(GZ)/$(MPC_GZ):
	$(WGET) http://www.multiprecision.org/mpc/download/$(MPC_GZ) && touch $@	
$(GZ)/$(CLOOG_GZ):	
	$(WGET) ftp://gcc.gnu.org/pub/gcc/infrastructure/$(CLOOG_GZ) && touch $@
$(GZ)/$(ISL_GZ):
	$(WGET) ftp://gcc.gnu.org/pub/gcc/infrastructure/$(ISL_GZ) && touch $@

## build
.PHONY: cross
cross: cclibs binutils

## toolchain libs required

.PHONY: cclibs
cclibs: gmp mpfr mpc isl cloog

CFG_LIBCC = --with-gmp=$(TC) --with-mpfr=$(TC) --with-mpc=$(TC) \
			--with-isl=$(TC) --with-cloog=$(TC) 

CFG_LIBS0 =	--disable-shared --prefix=$(TC)
CFG_LIBS  = $(CFG_LIBS0) $(CFG_LIBCC)

gmp: $(TC)/lib/libgmp.a
$(TC)/lib/libgmp.a: $(SRC)/$(GMP)/README
	rm -rf $(TMP)/$(GMP) ; mkdir $(TMP)/$(GMP) ; cd $(TMP)/$(GMP) ;\
	$(SRC)/$(GMP)/configure $(CFG_LIBS) && $(MAKE) install-strip
mpfr: $(TC)/lib/libmpfr.a
$(TC)/lib/libmpfr.a: $(SRC)/$(MPFR)/README $(TC)/lib/libgmp.a
	rm -rf $(TMP)/$(MPFR) ; mkdir $(TMP)/$(MPFR) ; cd $(TMP)/$(MPFR) ;\
	$(SRC)/$(MPFR)/configure $(CFG_LIBS) && $(MAKE) install-strip
mpc: $(TC)/lib/libmpc.a
$(TC)/lib/libmpc.a: $(SRC)/$(MPC)/README $(TC)/lib/libmpfr.a
	rm -rf $(TMP)/$(MPC) ; mkdir $(TMP)/$(MPC) ; cd $(TMP)/$(MPC) ;\
	$(SRC)/$(MPC)/configure $(CFG_LIBS) && $(MAKE) install-strip

CFG_ISL = $(CFG_LIBS0) --with-gmp-prefix=$(TC)
	
cloog: $(TC)/lib/libcloog-isl.a
$(TC)/lib/libcloog-isl.a: $(SRC)/$(CLOOG)/README $(TC)/lib/libmpc.a
	rm -rf $(TMP)/$(CLOOG) ; mkdir $(TMP)/$(CLOOG) ; cd $(TMP)/$(CLOOG) ;\
	$(SRC)/$(CLOOG)/configure $(CFG_ISL) && $(MAKE) install-strip
isl: $(TC)/lib/libisl.a
$(TC)/lib/libisl.a: $(SRC)/$(ISL)/README $(TC)/lib/libcloog-isl.a
	rm -rf $(TMP)/$(ISL) ; mkdir $(TMP)/$(ISL) ; cd $(TMP)/$(ISL) ;\
	$(SRC)/$(ISL)/configure $(CFG_ISL) && $(MAKE) install-strip

## bintuils

CFG_BINUTILS = $(CFG_LIBCC) --prefix=$(TC) --target=$(TARGET)
binutils: $(TC)/bin/$(TARGET)-as
$(TC)/bin/$(TARGET)-as: $(SRC)/$(BINUTILS)/README $(TC)/lib/libisl.a
	rm -rf $(TMP)/$(BINUTILS) ; mkdir $(TMP)/$(BINUTILS) ; cd $(TMP)/$(BINUTILS) ;\
	$(SRC)/$(BINUTILS)/configure $(CFG_BINUTILS)

## template rules for unpacking
$(SRC)/%/README: $(GZ)/%.tar.gz
	cd $(SRC) &&  zcat $< | tar x && touch $@
$(SRC)/%/README: $(GZ)/%.tar.bz2
	cd $(SRC) && bzcat $< | tar x && touch $@
$(SRC)/%/README: $(GZ)/%.tar.xz
	cd $(SRC) && xzcat $< | tar x && touch $@
