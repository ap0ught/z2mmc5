.PHONY: all clean dir

SRCDIR := $(CURDIR)
STEM := $(notdir $(CURDIR))
BUILDDIR := build/$(TGT_NAME)
BUILD_INC_PATH := "$(BUILDDIR)/build.inc"
CFG_NAME := $(STEM).cfg
ROM_NAME := $(TGT_NAME).nes
DBG_NAME := $(TGT_NAME).dbg
DELTA_NAME := $(TGT_NAME).xdelta
IPS_NAME := $(TGT_NAME).ips
BPS_NAME := $(TGT_NAME).bps

# Assembler files, for building out the banks
ASM_FILES := $(wildcard $(SRCDIR)/*.s)
O_FILES := $(patsubst $(SRCDIR)/%.s,$(BUILDDIR)/%.o,$(ASM_FILES))

all: dir $(ROM_NAME) $(DELTA_NAME) $(IPS_NAME) $(BPS_NAME)

dir:
	-@mkdir -p build
	-@mkdir -p "$(BUILDDIR)"

clean:
	-@rm -rf build
	-@rm -f $(ROM_NAME)
	-@rm -f $(DBG_NAME)
	-@rm -f $(DELTA_NAME)
	-@rm -f $(IPS_NAME)
	-@rm -f $(BPS_NAME)

$(DELTA_NAME): $(ROM_NAME)
#	Requires xdelta3 from https://www.romhacking.net/utilities/928/ renamed to xdelta3.exe
	xdelta3 -e -9 -I 0 -f -s "$(SRC_ROM)" $< $@
	
$(IPS_NAME): $(ROM_NAME)
#	Requires Lunar IPS 1.03 from https://fusoya.eludevisibility.org/lips/index.html
	"Lunar IPS.exe" -CreateIPS $@ "$(SRC_ROM)" $<
	
$(BPS_NAME): $(ROM_NAME)
#	Requires flips from https://www.romhacking.net/utilities/1040/
	flips --create --bps-delta-moremem --exact "$(SRC_ROM)" $< $@
	
$(ROM_NAME): $(CFG_NAME) $(O_FILES)
	ld65 -vm -m $(BUILDDIR)/map.txt -Ln $(BUILDDIR)/labels.txt --dbgfile $(DBG_NAME) -o $@ -C $^

$(BUILDDIR)/%.o: $(SRCDIR)/%.s
	echo '.define SRC_ROM "$(value SRC_ROM)"' > $(BUILD_INC_PATH)
	
	ca65 -g -I "$(BUILDDIR)" -o $@ $<
