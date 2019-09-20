#!/bin/sh
SOURCE="/tmp/wiff"

## Simple script to convert Sciex wiff files to mzML files using proteowizard's
## msconvert utility (see the README for more information on installing
## msconvert - via docker).

find $SOURCE -type f -name "*.wiff"|while read fl; do
    res_fl="${fl%.wiff}.mzML"
    if [ -f "$res_fl" ]; then
	echo "file exists."
    else
	dr=`dirname "$fl"`
	docker run --rm -e WINEDEBUG=-all \
	       -v "$SOURCE:$SOURCE" \
	       chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
	       wine msconvert "$fl" -z -o "$dr"
    fi
done
