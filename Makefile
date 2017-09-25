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

# build GNU toolchain from sources

## default TARGET
TARGET ?= i386-elf

## versions
BINUTILS_VER = 2.29.1
GMP_VER = 6.1.2
ISL_VER = 0.18

## packages
BINUTILS = binutils-$(BINUTILS_VER)
GMP = gmp-$(GMP_VER)
ISL = isl-$(ISL_VER)

## archives
BINUTILS_GZ = $(BINUTILS).tar.xz
GMP_GZ = $(GMP).tar.xz
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
gz: $(GZ)/$(BINUTILS_GZ) $(GZ)/$(GMP_GZ) $(GZ)/$(ISL_GZ)
WGET = wget -c -P $(GZ)
$(GZ)/$(BINUTILS_GZ):
	$(WGET) http://ftp.gnu.org/gnu/binutils/$(BINUTILS_GZ) && touch $@
$(GZ)/$(GMP_GZ):
	$(WGET) ftp://ftp.gmplib.org/pub/gmp/$(GMP_GZ) && touch $@
$(GZ)/$(ISL_GZ):
	$(WGET) ftp://gcc.gnu.org/pub/gcc/infrastructure/$(ISL_GZ) && touch $@

## build
.PHONY: cross
cross: binutils
binutils: $(TC)/bin/$(TARGET)-as
$(TC)/bin/$(TARGET)-as: $(SRC)/$(BINUTILS)/README $(TC)/lib/isl
	rm -rf $(TMP)/$(BINUTILS) ; mkdir $(TMP)/$(BINUTILS) ; cd $(TMP)/$(BINUTILS) ;\
	$(SRC)/$(BINUTILS)/configure --prefix=$(TC) --target=$(TARGET)
	
## toolchaing libs required
CFG_LIBS = --disable-shared --prefix=$(TC)

CFG_GMP = $(CFG_LIBS)
gmp: $(TC)/lib/gmp
$(TC)/lib/gmp: $(SRC)/$(GMP)/README
	rm -rf $(TMP)/$(GMP) ; mkdir $(TMP)/$(GMP) ; cd $(TMP)/$(GMP) ;\
	$(SRC)/$(GMP)/configure $(CFG_GMP)
	 
CFG_ISL = $(CFG_LIBS)
isl: $(TC)/lib/isl
$(TC)/lib/isl: $(SRC)/$(ISL)/README $(TC)/lib/gmp
	rm -rf $(TMP)/$(ISL) ; mkdir $(TMP)/$(ISL) ; cd $(TMP)/$(ISL) ;\
	$(SRC)/$(ISL)/configure $(CFG_ISL) --with-gmp-prefix=$(TC)
#	 && make install-strip

## template rules for unpacking
$(SRC)/%/README: $(GZ)/%.tar.gz
	cd $(SRC) &&  zcat $< | tar x && touch $@
$(SRC)/%/README: $(GZ)/%.tar.bz2
	cd $(SRC) && bzcat $< | tar x && touch $@
$(SRC)/%/README: $(GZ)/%.tar.xz
	cd $(SRC) && xzcat $< | tar x && touch $@
