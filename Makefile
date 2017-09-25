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

## packages
BINUTILS = binutils-$(BINUTILS_VER)

## archives
BINUTILS_GZ = $(BINUTILS).tar.xz

# create directory structure
CWD = $(CURDIR)
GZ = $(CWD)/gz
SRC = $(CWD)/src
TMP = $(CWD)/tmp
TC = $(CWD)/$(TARGET)
DIRS = $(GZ) $(SRC) $(TMP) $(TC)
.PHONY: dirs
dirs:
	mkdir -p $(DIRS)
	