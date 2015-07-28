#!/bin/bash
/*
R01_1test_genData#_gen7z_gen7z#_Data
Set Value of Variable: Path
Get Folder Contents
Sort Finder Items by Name in Desceing order
*/


for a in "$@"
do
    cd "$a" # data folder
    cd ..
    wd=$(pwd) #root for all EEG data folders
    current=${a##*/} #data folder name
    verifycopy="$wd"/_INCOMPLETE_"$current".txt
    verifymd5="$wd"/_MD5_"$current".txt

    errormd5="$wd"/_ERROR_"$current".txt
    errorcopy="wd"/_CPERR_"$current".txt

    localwd="$wd"
    localdata="$a"



    ###compress data folder###

    cd "$a" # data folder

    rm -f *.7z

    
done