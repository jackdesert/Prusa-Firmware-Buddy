#! /bin/bash

set -e
# Remove bbf files so that previous files will not be used by accident
rm /Volumes/PRUSA_MINI/*.bbf

cp build/products/*.bbf /Volumes/PRUSA_MINI/
sync

echo Done copying to thumb drive
