# Buddy
[![GitHub release](https://img.shields.io/github/release/prusa3d/Prusa-Firmware-Buddy.svg)](https://github.com/prusa3d/Prusa-Firmware-Buddy/releases)
[![Build Status](https://holly.prusa3d.com/buildStatus/icon?job=Prusa-Firmware-Buddy%2FMultibranch%2Fmaster)](https://holly.prusa3d.com/job/Prusa-Firmware-Buddy/job/Multibranch/job/master/)

This repository includes source code and firmware releases for the Original Prusa 3D printers based on the 32-bit ARM microcontrollers.

The currently supported models are:
- Original Prusa MINI/MINI+
- Original Prusa MK3.9
- Original Prusa MK4
- Original Prusa XL

## Getting Started

### Requirements

- Python 3.8 or newer

### Cloning this repository

Run `git clone https://github.com/prusa3d/Prusa-Firmware-Buddy.git`.

### Building (on all platforms, without an IDE)

Run `python utils/build.py`. The binaries are then going to be stored under `./build/products`.

- Without any arguments, it will build a release version of the firmware for all supported printers and bootloader settings.
- To generate `.bbf` versions of the firmware, use: `./utils/build.py --generate-bbf`.
- Use `--build-type` to select build configurations to be built (`debug`, `release`).
- Use `--preset` to select for which printers the firmware should be built.
- By default, it will build the firmware in "prerelease mode" set to `beta`. You can change the prerelease using `--prerelease alpha`, or use `--final` to build a final version of the firmware.
- Use `--host-tools` to include host tools in the build (`bin2cc`, `png2font`, ...)
- Find more options using the `--help` flag!

#### Examples:

Build only the files you need to flash via USB thumbdrive, and only for the MINI
(Note this will only create "boot" file, not "_no_boot", since "_no_boot" is only useful
for flashing via non-USB. (Note no_boot allows more
```bash
```


Build the firmware for MINI and XL in `debug` mode:

```bash
python utils/build.py --preset mini,xl --build-type debug
```

Build the firmware for MINI using a custom version of gcc-arm-none-eabi (available in `$PATH`) and use `Make` instead of `Ninja` (not recommended):

```bash
python utils/build.py --preset mini --toolchain cmake/AnyGccArmNoneEabi.cmake --generator 'Unix Makefiles'
```

## Docker

Or in Docker:

sudo docker run -it --rm --mount type=bind,source=/home/jd/Prusa-Firmware-Buddy,target=/prusa python:3.10 bash

## Quick and Dirty Guide to Editing One Line of Code and Flashing Your Board

This uses the `_boot` version, and is flashable using the USB stick.
This is adequate for small amounts of changes where you do not expect
to go to the extra trouble and extra memory requirements of a debug build.
See [LINKME to the doc talking about _boot]

### Git Clone
```bash
git clone https://github.com/prusa3d/Prusa-Firmware-Buddy
cd Prusa-Firmware-Buddy
```


### Make your edits

### Simplified Compilation

The goal here is to only generate the files you need.
You need the `_boot` files, not the `_no_boot` files.
Here is an explanation of the difference: [LINKME!]

```bash
# Create virtualenv
python -m venv env

# Activate virtualenv
source env/bin/activate

# Compile
BUDDY_NO_VIRTUALENV=1 python utils/build.py \
    --preset mini \
    --generate-bbf \
    --bootloader yes \
    --version-suffix '+5737-allow-nozzle-preheat-and-zero-bed-temp' \
    --version-suffix-short '+5737'
```bash

Notes on arguments:
- BUDDY_NO_VIRTUALENV: this environment variable tells the build script not to create
                       a virtualenv (that way it uses the one you created and activated above)
- --version-suffix: [Optional] You can specify your own version suffix so that after the firmware
                    is loaded onto your board, the info tab will show you that yours is
                    installed
- --version-suffix-short: [Optional] Similar to --version-suffix. Make sure `version_suffix` starts
                          with whatever value you used for `version_suffix_short`

--bootloader yes: Tells the compiler to only compile the version that is bootable via usb.

--generate-bbf: Tells the compiler to only compile the bbf version



### Break the appendix

See https://help.prusa3d.com/article/zoiw36imrs-flashing-custom-firmware.
### Flash your Custom Firmware
See https://help.prusa3d.com/article/zoiw36imrs-flashing-custom-firmware.

### How to Downgrade or Samegrade

Insert the USB stick with your .bbl
Boot the buddy board.
Wait one or two seconds, then double-press the knob.

See [LINKME]


#### Windows 10 troubleshooting

If you have python installed and in your PATH but still getting cmake error `Python3 not found.` Try running python and python3 from cmd. If one of it opens Microsoft Store instead of either opening python interpreter or complaining `'python3' is not recognized as an internal or external command,
operable program or batch file.` Open `manage app execution aliases` and disable `App Installer` association with `python.exe` and `python3.exe`.

### Development

The build process of this project is driven by CMake and `build.py` is just a high-level wrapper around it. As most modern IDEs support some kind of CMake integration, it should be possible to use almost any editor for development. Below are some documents describing how to setup some popular text editors.

- [Visual Studio Code](doc/editor/vscode.md)
- [Vim](doc/editor/vim.md)
- [Eclipse, STM32CubeIDE](doc/editor/stm32cubeide.md)
- [Other LSP-based IDEs (Atom, Sublime Text, ...)](doc/editor/lsp-based-ides.md)

#### Contributing

If you want to contribute to the codebase, please read the [Contribution Guidelines](doc/contributing.md).

#### XL and Puppies

With the XL, the situation gets a bit more complex. The firmware of XLBuddy contains firmwares for the puppies (Dwarf and Modularbed) to flash them when necessary. We support several ways of dealing with those firmwares when developing:

1. Build Dwarf/Modularbed firmware automatically and flash it on startup by XLBuddy (the default)
    - The Dwarf & ModularBed firmware will be built from this repo.
    - The puppies are going to be flashed on startup by the XLBuddy. The puppies have to be running the [Puppy Bootloader](http://github.com/prusa3d/Prusa-Bootloader-Puppy).

2. Build Dwarf/Modularbed from a given source directory and flash it on startup by XLBuddy.
    - Specify `DWARF_SOURCE_DIR`/`MODULARBED_SOURCE_DIR` CMake cache variable with the local repo you want to use.
    - Example below would build modularbed's firmware from /Projects/Prusa-Firmware-Buddy-ModularBed and include it in the xlBuddy firmware.
    ```
    cmake .. --preset xl_release_boot -DMODULARBED_SOURCE_DIR=/Projects/Prusa-Firmware-Buddy-ModularBed
    ```
    - You can also specify the build directory you want to use:
    ```
    cmake .. --preset xl_release_boot \
        -DMODULARBED_SOURCE_DIR=/Projects/Prusa-Firmware-Buddy-ModularBed  \
        -DMODULARBED_BINARY_DIR=/Projects/Prusa-Firmware-Buddy-ModularBed/build
    ```
3. Use pre-built Dwarf/Modularbed firmware and flash it on startup by xlBuddy
    - Specify the location of the .bin file with `DWARF_BINARY_PATH`/`MODULARBED_BINARY_PATH`.
    - For example
    ```
    cmake .. --preset xl_release_boot -DDWARF_BINARY_PATH=/Downloads/dwarf-4.4.0-boot.bin
    ```

4. Do not include any puppy firmware, and do not flash the puppies by XLBuddy.
    ```
    -DENABLE_PUPPY_BOOTLOAD=NO
    ```
    - With the `ENABLE_PUPPY_BOOTLOAD` set to false, the project will disable Puppy flashing & interaction with Puppy bootloaders.
    - It is up to you to flash the correct firmware to the puppies (noboot variant).

5. Keep bootloaders but do not write firmware on boot.
    ```
    -DPUPPY_SKIP_FLASH_FW=YES
    ```
    - With the `PUPPY_SKIP_FLASH_FW` set to true, the project will disable Puppy flashing on boot.
    - You can keep other puppies that are not debugged in the same state as before.
    - Use puppy build config with bootloaders (e.g. `xl-dwarf_debug_boot`) on one or more puppies.
    - Recommend breakpoint at the end of `puppy_task_body()` to prevent buddy from resetting the puppy immediately when puppy stops on breakpoint.

See /ProjectOptions.cmake for more information about those cache variables.

#### Running tests

```bash
mkdir build-tests
cd build-tests
cmake ..
make tests
ctest .
```

The simplest way to to debug (step through) a test is to specify CMAKE_BUILD_TYPE when configuring `cmake -DCMAKE_BUILD_TYPE=Debug ..` , build it with `make tests` as previously stated and then run the test with `gdb <path to test binary>` e.g. `gdb tests/unit/configuration_store/eeprom_unit_tests`.

## Flashing Custom Firmware

To install custom firmware, you have to break the appendix on the board. Learn how to in the following article https://help.prusa3d.com/article/zoiw36imrs-flashing-custom-firmware.

## Feedback

- [Feature Requests from Community](https://github.com/prusa3d/Prusa-Firmware-Buddy/labels/feature%20request)

## Credits

- [Marlin](https://marlinfw.org/) - 3D printing core driver
- [Klipper](https://www.klipper3d.org/) - input shaper code based on Klipper

## License

The firmware source code is licensed under the GNU General Public License v3.0 and the graphics and design are licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0). Fonts are licensed under different license (see [LICENSE](LICENSE.md)).
