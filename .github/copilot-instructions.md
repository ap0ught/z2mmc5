# z2mmc5 - Zelda II MMC5 ROM Hack

z2mmc5 is a ROM hack project that converts "Zelda II - The Adventure of Link (USA)" from its original mapper to use the MMC5 (Memory Management Controller 5) mapper. This project uses the cc65 assembler toolchain to patch and rebuild the game ROM.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Required Dependencies
NEVER CANCEL: Installing dependencies takes 2-3 minutes. Set timeout to 5+ minutes.
```bash
sudo apt update && sudo apt install -y cc65 xdelta3
```

### Build Process
The build process requires:
1. The original "Zelda II - The Adventure of Link (USA).nes" ROM file (not included in repository)
2. cc65 assembler toolchain (ca65, ld65)
3. xdelta3 for patch creation

### Basic Build Commands
NEVER CANCEL: Build completes in under 0.1 seconds. Set timeout to 30 seconds for safety.
```bash
# Clean build artifacts
make clean

# Build the modified ROM (requires source ROM file)
make SRC_ROM="Zelda II - The Adventure of Link (USA).nes" TGT_NAME=z2mmc5

# Build only specific targets
make SRC_ROM="Zelda II - The Adventure of Link (USA).nes" TGT_NAME=z2mmc5 dir z2mmc5.nes z2mmc5.xdelta
```

### Alternative Build Method
Use the provided batch file (requires Wine for Linux):
```bash
# Windows-style build (requires Wine)
wine cmd /c compile.bat
```

## Validation

### Build Validation
- The build succeeds if it produces `z2mmc5.nes` without errors
- Warning about missing segment 'BANK_F_FREE_SPACE_1' is expected and harmless
- Linux build fails at patch creation stage due to missing Windows tools ("Lunar IPS.exe", flips) - this is expected
- xdelta3 patches (.xdelta files) can be created successfully on Linux

### Manual Testing Scenarios
Since this is a ROM hack project, manual testing requires:
1. A NES emulator (fceux, nestopia, etc.)
2. The generated z2mmc5.nes file
3. Test basic game functionality: title screen, game start, basic movement

### Basic ROM Validation
Verify the ROM was properly patched by checking the header:
```bash
# Check ROM header - should show MMC5 mapper (0x52) and 16 banks
hexdump -C z2mmc5.nes | head -2
```
Expected output shows mapper byte 0x52 at offset 6, indicating successful MMC5 conversion.

### Testing Without Source ROM
The build fails without the original ROM file with "Cannot open include file" errors. This is expected behavior.

## Build System Details

### File Structure
- `z2mmc5.s` - Main assembly source file with MMC5 patches
- `mmc5regs.inc` - MMC5 register definitions
- `z2mmc5.cfg` - Linker configuration for memory layout
- `Makefile` - Build system
- `compile.bat` - Windows batch build script

### Build Timing
NEVER CANCEL: All build operations complete very quickly:
- Clean: ~0.01 seconds
- ROM assembly and linking: ~0.05 seconds  
- Patch creation: ~0.01 seconds
- Complete build: under 0.1 seconds total

### Generated Files
Successful build creates:
- `z2mmc5.nes` - Modified ROM file
- `z2mmc5.dbg` - Debug symbols
- `z2mmc5.xdelta` - Binary patch file (Linux compatible)
- `z2mmc5.ips` - IPS patch (requires Windows tools)
- `z2mmc5.bps` - BPS patch (requires Windows tools)
- `build/z2mmc5/` - Build artifacts directory

## Common Issues and Solutions

### "Cannot open include file" errors
This indicates the source ROM file is missing or incorrectly specified. The error will show:
```
Error: Cannot open include file 'Zelda II - The Adventure of Link (USA).nes': No such file or directory
```
Ensure the ROM filename exactly matches the SRC_ROM parameter and the file exists in the project directory.

### "Lunar IPS.exe: not found"
This is expected on Linux. The IPS and BPS patch creation requires Windows tools. Use xdelta3 patches instead, which work fine on Linux.

### "Directory nonexistent" errors
Run the build with the `dir` target first, or use the complete target list:
```bash
make SRC_ROM="ROM_FILE.nes" TGT_NAME=z2mmc5 dir z2mmc5.nes
```

### Missing cc65 tools
Install the complete cc65 package:
```bash
sudo apt install -y cc65
```

## Key Assembly Files

### z2mmc5.s Structure
- MMC5 register setup and initialization
- Bank switching routines
- Interrupt handlers for MMC5 features
- Patches to original game code for MMC5 compatibility

### Critical Constants
- `BANK_SIZE = $2000` (8192 bytes per bank)
- `NUM_PRG_BANKS = $10` (16 program banks)
- MMC5 register addresses defined in mmc5regs.inc

## Development Workflow

Always validate any changes by:
1. Running a clean build to ensure no syntax errors
2. Checking that the ROM file size is reasonable (~400KB)
3. Verifying no unexpected linker errors beyond the known warning
4. Testing with a NES emulator if making functional changes

The project has no automated tests - validation is through successful build and emulator testing.

## Repository Structure Quick Reference

```
.
├── Makefile              # Main build system
├── compile.bat           # Windows build script  
├── z2mmc5.s             # Main assembly source
├── mmc5regs.inc         # MMC5 register definitions
├── z2mmc5.cfg           # Linker configuration
├── z2mmc5.bps           # Pre-built patch file
└── .gitignore           # Excludes build artifacts
```

When working with this codebase, always ensure you have the original Zelda II ROM file before attempting builds, and use appropriate timeouts for package installation commands.