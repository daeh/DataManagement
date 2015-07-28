#!/bin/bash
/*
R01_1a_genData#_Data.app

Get value of Variable: Path
*/



mkdir ~/Desktop/temptest
echo `pwd` > ~/Desktop/temptest/0.txt
printf "pwd: " > ~/Desktop/temptest/debug1.txt ## debug

############################

for a in "$@"
do

    ###compress data folder###

    cd "$a"
    /Applications/Keka.app/Contents/Resources/keka7z a -t7z "$a.7z" "$a" -mx9
    cd "$a"
    cd ..
    wd=$(pwd) #root for all EEG data folders

	####determine md5 hash for primary archive###
    shopt -s nullglob
    for c1 in *.7z
    do
        if [[ $c1 == *.7z ]]
        then
            mkdir -p _biosemitemp/
            cd _biosemitemp/
            echo $c1 > _biosemitempa.txt
            ls -otr "$c1" | awk '{printf("%s\t%s\t%s %s\n", $4, $7, $6, $5); }' > _biosemitempb.txt
            i1=${c1%_*}
            j1=${i1%_*}
            echo ${j1:(-11)} > _biosemitempc.txt
            md5 "$c1" > _biosemitemp_d.txt
            tr '\n' '\t' < _biosemitempa.txt  > _biosemitemp_a.txt
            tr '\n' '\t' < _biosemitempb.txt  > _biosemitemp_b.txt
            tr '\n' '\t' < _biosemitempc.txt  > _biosemitemp_c.txt
            cat _biosemitemp_*.txt >> _biosemitempcat.txt
        fi
    done

    sed 's/MD5 //g' _biosemitempcat.txt > _biosemitempcata.txt
    sed 's/[)(]//g' _biosemitempcata.txt > _biosemitempcatb.txt
    sed 's/ = /	/g' _biosemitempcatb.txt > _biosemitempcatc.txt
    sort -k6 _biosemitempcatc.txt -o _biosemitempfinalb.txt
    echo -e "File\tSize\tTime Modified\tDate Modified\tDate_Time Created\tLocation\tMD5 Hash" > _biosemitempfinala.txt
    cat _biosemitempfinal*.txt >> _biosemitemparch.txt
    mv _biosemitemparch.txt "$wd"
    cat _biosemitemparch.txt >> _OriginArchHash.txt
 ###   rm -rf _biosemitemparch.txt
 ###   rm -rf "$exdir"/_biosemitemp/

	######

    mv "$a.7z" "$a"

    printf "pwd: %s \na: %s \n" "`pwd`" "$a" > ~/Desktop/temptest/debug.txt ## debug

    ### copy to remote storge volume1 ###

    vol1="/Volumes/ATTENDback/EEG/"     #primary storage volume
    vol2="/Volumes/ATTENDdata/EEG/"  #backup volume

    cp -rf "$a" "$vol1" ###copy to primary volume
    
    printf "1: \npwd: %s \na: %s \n" "`pwd`" "$a" > ~/Desktop/temptest/debug.txt ## debug
    echo cp -rf _OriginArchHash.txt "$vol1" > ~/Desktop/temptest/1.txt ## debug
    echo cp -rf _OriginArchHash.txt "$vol2" > ~/Desktop/temptest/2.txt ## debug

    cp -rf _OriginArchHash.txt "$vol1"
    cp -rf _OriginArchHash.txt "$vol2"

    ### get folder name ###

    h=$(echo $a|rev)
    nf=${h%%/*}
    fn=$(echo $nf|rev) #copied folder

    ###copy to remote backup volume###

    cp -rf cd "$vol1$fn" "$vol2" #copy from vol1 vol2

    cd "$vol2$fn"
#    echo -e "$vol2$fn" > ~/Desktop/testdumps/target.txt  ## debug
#    echo `pwd` > ~/Desktop/testdumps/pwdone.txt  ## debug

    ###Verify End Archive###

#    md5 *.7z >> ../ArchiveChecksums.txt

	####determine md5 hash for end archive###
    shopt -s nullglob
    for c2 in *.7z
    do
        if [[ $c2 == *.7z ]]
        then
            mkdir -p _biosemitemp/
            cd _biosemitemp/
            echo $c2 > _biosemitempa.txt
            ls -otr "$c2" | awk '{printf("%s\t%s\t%s %s\n", $4, $7, $6, $5); }' > _biosemitempb.txt
            i2=${c2%_*}
            j2=${i2%_*}
            echo ${j2:(-11)} > _biosemitempc.txt
            md5 "$c2" > _biosemitemp_d.txt
            tr '\n' '\t' < _biosemitempa.txt  > _biosemitemp_a.txt
            tr '\n' '\t' < _biosemitempb.txt  > _biosemitemp_b.txt
            tr '\n' '\t' < _biosemitempc.txt  > _biosemitemp_c.txt
            cat _biosemitemp_*.txt >> _biosemitempcat.txt
        fi
    done

    sed 's/MD5 //g' _biosemitempcat.txt > _biosemitempcata.txt
    sed 's/[)(]//g' _biosemitempcata.txt > _biosemitempcatb.txt
    sed 's/ = /	/g' _biosemitempcatb.txt > _biosemitempcatc.txt
    sort -k6 _biosemitempcatc.txt -o _biosemitempfinalb.txt
    echo -e "File\tSize\tTime Modified\tDate Modified\tDate_Time Created\tLocation\tMD5 Hash" > _biosemitempfinala.txt
    cat _biosemitempfinal*.txt >> _biosemitemparch.txt
    mv _biosemitemparch.txt "$vol2"
    cat _biosemitemparch.txt >> _ArchiveChecksums.txt
 ###   rm -rf _biosemitemparch.txt
 ###   rm -rf "$exdir"/_biosemitemp/

    ###Extract End Archive###
##    rm -rf "$vol2$ex"
    
    ext="$vol2"
    ext+="TempExt/"


    if [ ! -d "$ext" ]; then
		mkdir "ext"
	fi

    cd "$vol2$fn"

    shopt -s nullglob
    for b in *.7z
    do
       /Applications/Keka.app/Contents/Resources/keka7z x "$b" -o"$ext" -y
    done
    exdir="$ext$fn" #extracted directory

    cd "$exdir"

    ###Verify Expanded Files###

    shopt -s nullglob
    for d in *_raw.txt
    do
        if [[ $d == *_raw.txt ]]
        then
            exdir+="/"
            c="$exdir$d"

            mkdir -p _biosemitemp/
            cd _biosemitemp/

            echo $c > _biosemitempa.txt
            ls -otr "$c" | awk '{printf("%s\t%s\t%s %s\n", $4, $7, $6, $5); }' > _biosemitempb.txt
            ic=${c%_*}
            jc=${ic%_*}
            echo ${jc:(-11)} > _biosemitempc.txt
            md5 "$c" > _biosemitemp_d.txt
            tr '\n' '\t' < _biosemitempa.txt  > _biosemitemp_a.txt
            tr '\n' '\t' < _biosemitempb.txt  > _biosemitemp_b.txt
            tr '\n' '\t' < _biosemitempc.txt  > _biosemitemp_c.txt
            cat _biosemitemp_*.txt >> _biosemitempcat.txt
        fi
    done

    sed 's/MD5 //g' _biosemitempcat.txt > _biosemitempcata.txt
    sed 's/[)(]//g' _biosemitempcata.txt > _biosemitempcatb.txt
    sed 's/ = /	/g' _biosemitempcatb.txt > _biosemitempcatc.txt
    sort -k6 _biosemitempcatc.txt -o _biosemitempfinalb.txt
    echo -e "File\tSize\tTime Modified\tDate Modified\tDate_Time Created\tLocation\tMD5 Hash" > _biosemitempfinala.txt
    cat _biosemitempfinal*.txt >> _Data_Checksums_Expanded.txt
    mv _Data_Checksums_Expanded.txt "$exdir"
    rm -rf "$exdir"/_biosemitemp/

done

#echo `pwd` > ~/Desktop/testdumps/two.txt

