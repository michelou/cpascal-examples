##
## Copyright (c) 2018-2026 Stéphane Micheloud
##
## Licensed under the MIT License.
##
##############################################################################

DEBUG ?= 0

include ../Makefile.inc

MAIN_NAME  = TypeNames
MAIN_CLASS = CP.TypeNames.$(MAIN_NAME)
MAIN_ARGS  =

TARGET ?= net

SOURCE_DIR      = src
SOURCE_MAIN_DIR = $(SOURCE_DIR)/main/cp
TARGET_DIR      = target
CLASSES_DIR     = $(TARGET_DIR)/classes

## https://www.baeldung.com/linux/makefile-if-else-conditionals
ifeq ($(DEBUG),1)
VERBOSE_OPT = -verbose
else
VERBOSE_OPT = -quiet
endif
GPCP_OPTS = $(VERBOSE_OPT) -target:$(TARGET)

JARS_DIR = $(subst \,/,$(JROOT))/jars
SYMS_DIR = $(subst \,/,$(JROOT))/symfiles
CPATH    = $(JARS_DIR)/cprts.jar;$(CLASSES_DIR)
CPSYM    = .;$(SYMS_DIR);$(SYMS_DIR)/JvmSystem

##############################################################################
## main rules

SOURCE_MAIN_FILE = $(SOURCE_MAIN_DIR)/$(MAIN_NAME).cp

TARGET_NAME = $(MAIN_NAME)$(TARGET_EXT)
TARGET_FILE = $(TARGET_DIR)/$(TARGET_NAME)

all: build run

build: $(TARGET_FILE)

$(TARGET_FILE): $(SOURCE_MAIN_FILE)
ifeq ($(TARGET),jvm)
	[[ -d "$(CLASSES_DIR)" ]] || "$(MKDIR)" -p "$(CLASSES_DIR)"
	pushd $(CLASSES_DIR) 1>/dev/null; \
	"$(GPCP_JVM)" $(GPCP_OPTS) ../../$<
else
	[[ -d "$(TARGET_DIR)" ]] || "$(MKDIR)" -p "$(TARGET_DIR)"
	pushd $(TARGET_DIR) 1>/dev/null; \
	$(eval CPSYM := $(CPSYM)) "$(GPCP_NET)" $(GPCP_OPTS) ../$<
	$(eval RTS_FILE := $(subst \,/,$(GPCP_HOME))/bin/RTS.dll)
	@[[ -f "$(RTS_FILE)" ]] || ( $(ECHO) "Error: Runtime library not found " && exit 1 )
	cp "$(RTS_FILE)" "$(TARGET_DIR)"
endif

clean:
	"$(RM)" -rf "$(TARGET_DIR)"

run: build
ifeq ($(TARGET),jvm)
	"$(JAVA)" -cp "$(CPATH)" $(MAIN_CLASS) $(MAIN_ARGS)
else
	@[[ -f "$(TARGET_FILE)" ]] && "$(TARGET_FILE)"
endif
  
help:
	@$(ECHO) "Usage: make all|build|clean|help|run"
	@$(ECHO) ""
	@$(ECHO) "  Subcommands:"
	@$(ECHO) "    all      alias for build"
	@$(ECHO) "    build    compile Ada source files"
	@$(ECHO) "    clean    delete generated files"
	@$(ECHO) "    help     print this help message"
	@$(ECHO) "    run      execute main program \"$(TARGET_NAME)\""
	@$(ECHO) ""
	@$(ECHO) "  Variables:"
	@$(ECHO) "    DEBUG"
	@$(ECHO) "      1      enable debug mode"
	@$(ECHO) "    TARGET"
	@$(ECHO) "      jvm    generate JVM code"
	@$(ECHO) "      net    generate .Net code (default)"
	@$(ECHO) ""
	@$(ECHO) "  Example:"
	@$(ECHO) "    make TARGET=jvm clean run"

##############################################################################
## phony

.PHONY: all build clean help run

.SUFFIXES:
.SUFFIXES: .class .cp .exe
