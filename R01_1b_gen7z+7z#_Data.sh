#!/bin/bash
/*
R01_1b_gen7z+7z#_Data.app
Set Value of Variable: Path
*/

for a in "$@"
do
	cd "$a"
#	cd ..
#	b=$(pwd)
	cd /Applications/Keka.app/Contents/Resources/
	./keka7z a -t7z "$a.7z" "$a" -mx9
	cd "$a"
	cd ..
	md5 "$a.7z" >> ArchiveChecksums.txt
	mv "$a.7z" "$a"
done