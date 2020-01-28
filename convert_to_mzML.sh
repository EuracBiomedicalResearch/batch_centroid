#!/bin/bash
# SOURCE="/data/massspec/bbbznas01/wiff"
# DEST="/data/massspec/mzML"
SOURCE="/Users/jo/data/bbbznas01/wiff/"
DEST="/Users/jo/data/mzML/"
#DEST="$SOURCE"

## Note: $DEST can point to a folder where already converted and centroided
## mzML files are located. If a same-named file exists there, conversion of
## the wiff file is skipped. Note that the mzML file is still created IN THE
## SAME FOLDER as the wiff file.

## Simple script to convert Sciex wiff files to mzML files using proteowizard's
## msconvert utility (see the README for more information on installing
## msconvert - via docker).

find $SOURCE -type f -name "*.wiff"|while read fl; do
    res_fl="${fl%.wiff}.mzML"
    res_fl_dest=`echo $res_fl | sed "s|$SOURCE|$DEST|"`
    if [ -f "$res_fl_dest" ]; then
	echo "file $res_fl_dest exists, skipping"
    else
	dr=`dirname "$fl"`
	docker run --rm -e WINEDEBUG=-all \
	       -v "$SOURCE:$SOURCE" \
	       chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
	       wine msconvert "$fl" -z -o "$dr" --outfile "$res_fl" \
	       --chromatogramFilter "index [0,1]"
    fi
done

echo "-=== All done ===-"
