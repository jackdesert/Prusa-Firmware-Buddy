
# --bootloader yes tells it to only build the "_boot" version, not the "no_boot" version
# Using custom version suffix (matching +xxxx to show that it has been modified
# (Note bumping to +5737 to be one higher than the default +5736)
BUDDY_NO_VIRTUALENV=1 python utils/build.py --preset mini --generate-bbf --bootloader yes --version-suffix '+5737-allow-nozzle-preheat-and-zero-bed-temp' --version-suffix-short '+5737'
