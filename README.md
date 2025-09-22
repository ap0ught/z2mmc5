# Z2MMC5 - Zelda II MMC5 Conversion

This project converts **Zelda II - The Adventure of Link (USA)** to use the MMC5 mapper, enabling enhanced features and capabilities over the original MMC1 mapper.

## Overview

The MMC5 (Multi-Memory Controller 5) is a more advanced mapper chip that provides:
- 8KB PRG-ROM banking (vs 16KB on MMC1)
- 8KB CHR-ROM banking with split screen capabilities
- Extended RAM and battery-backed saves
- Scanline IRQ support for advanced graphics effects
- Flexible mirroring modes

This conversion maintains full compatibility with the original game while unlocking the enhanced capabilities of the MMC5 mapper.

## Features

- **Enhanced Banking**: More flexible memory management with 8KB PRG banks
- **Advanced Graphics**: CHR banking enables better sprite and background management
- **IRQ Support**: Scanline interrupts for advanced visual effects
- **Extended RAM**: Additional memory space for enhanced functionality
- **Battery Backup**: Save data persistence with battery-backed RAM

## Requirements

### Source ROM
You need a clean copy of:
- **Zelda II - The Adventure of Link (USA).nes**
- MD5: `d0690f3b2b1d80bcd0c616fbfdfm28ce` (verify your ROM)

### Build Tools
- **CA65/LD65**: CC65 assembler and linker suite
- **Make**: GNU Make or compatible
- **xdelta3**: For creating xdelta patches (optional)
- **Lunar IPS**: For creating IPS patches (optional) 
- **flips**: For creating BPS patches (optional)

## Quick Start

### Windows
1. Ensure you have the CC65 suite installed and in your PATH
2. Place your source ROM as `Zelda II - The Adventure of Link (USA).nes` in the project directory
3. Run `compile.bat`
4. The converted ROM will be created as `z2mmc5.nes`

### Linux/Mac
```bash
# Install CC65 (varies by distribution)
# Ubuntu/Debian: sudo apt-get install cc65
# macOS: brew install cc65

# Build the ROM
make SRC_ROM="Zelda II - The Adventure of Link (USA).nes" TGT_NAME=z2mmc5
```

## Output Files

The build process generates several files:

- **z2mmc5.nes**: The converted ROM file
- **z2mmc5.bps**: BPS patch file (recommended)
- **z2mmc5.ips**: IPS patch file  
- **z2mmc5.xdelta**: xdelta patch file
- **z2mmc5.dbg**: Debug symbols file

## Patch Files

Instead of distributing the full ROM, you can distribute patch files:

- **BPS (recommended)**: Most accurate, includes checksums
- **IPS**: Widely supported, good compatibility
- **xdelta**: Efficient compression, good for distribution

Apply patches using tools like:
- Lunar IPS (for IPS files)
- flips (for BPS files)  
- xdelta3 (for xdelta files)

## Technical Details

### Memory Layout
- **PRG-ROM**: 16 banks × 8KB (128KB total)
- **CHR-ROM**: 16 banks × 8KB (128KB total)
- **PRG-RAM**: 8KB battery-backed
- **Mapper**: iNES Mapper 5 (MMC5)

### Bank Configuration
- Fixed banks: $E000-$FFFF (Bank F)
- Switchable: $8000-$DFFF (configurable 8KB banks)
- RAM: $6000-$7FFF (8KB battery-backed)

### Key Features Implemented
- 8KB PRG banking mode
- 8KB CHR banking mode  
- Horizontal mirroring mode
- Battery-backed PRG-RAM
- IRQ handling for scanline effects

## Compatibility

### Emulators
Tested and working on:
- **Mesen**: Full MMC5 support
- **FCEUX**: Good MMC5 compatibility
- **Nestopia**: Basic MMC5 support
- **RetroArch/QuickNES**: Limited MMC5 support

### Flash Carts
Compatible with:
- **EverDrive N8**: Full MMC5 support
- **PowerPak**: Good MMC5 compatibility
- **Most MMC5-capable flash carts**

### Real Hardware
Works on original NES/Famicom with MMC5 boards:
- EKROM boards
- ELROM boards
- Custom MMC5 reproductions

## Contributing

See [README.dev](README.dev) for development setup and contribution guidelines.

## Legal Notice

This project creates patches for legally owned ROM files. You must own an original copy of Zelda II - The Adventure of Link to use this software. The project does not distribute copyrighted game content.

## License

This project is released under the MIT License. See the original game's copyright for ROM content restrictions.

## Credits

- **Original Game**: Nintendo / Zelda II development team
- **MMC5 Conversion**: ap0ught
- **Tools**: CC65 development team
- **Community**: NESdev community for technical documentation

## Support

For issues, questions, or contributions:
- Create an issue on GitHub
- Check existing documentation in README.dev
- Consult NESdev wiki for technical details

---

*Note: This project is for educational and preservation purposes. Respect copyright laws and only use with legally obtained ROM files.*