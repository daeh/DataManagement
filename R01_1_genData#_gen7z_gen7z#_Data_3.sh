/*

get value of variable: path

*/

#mkdir ~/Desktop/temptest

### NB that when passed the variable 'Path' from the applescript directly, it is the data folder, 
### when passed after file sorting, it is individual files withing the folder ###

### replacing text w/ sed requires a literal tab that needs to be entered directly into automator
### and cannot be copy/pasted. Find instances marked #SED

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

######################## debug old file removal
#rm -rf "$a"/"$current".7z
######################## end debug block


    echo "$(date)" > "$verifycopy"   ###this maybe should be moved to earlier bash script in automator

    ###compress data folder###

    cd "$a" # data folder

    rm -f *.7z # Do NOT make recursive!

    /Applications/Keka.app/Contents/Resources/keka7z a -t7z "$a.7z" "$a" -mx9

    mv -f "$a.7z" "$a"

    # e.g. "$a.7z" = /Users/tnl/BioSemiRuns/R01/IDtest_S01_051215.7z
    # e.g. "$a" = /Users/tnl/BioSemiRuns/R01/IDtest_S01_051215
    # e.g. `pwd` = /Users/tnl/BioSemiRuns/R01/IDtest_S01_051215
    # e.g. /Applications/Keka.app/Contents/Resources/keka7z a -t7z /Users/tnl/BioSemiRuns/R01/IDtest_S01_051215.7z /Users/tnl/BioSemiRuns/R01/IDtest_S01_051215 -mx9
    # e.g. mv -f /Users/tnl/BioSemiRuns/R01/IDtest_S01_051215.7z /Users/tnl/BioSemiRuns/R01/IDtest_S01_051215

    ####determine md5 hash for primary archive###
    shopt -s nullglob
    for c1 in *.7z
    do
        if [[ $c1 == *.7z ]]
        then
            mkdir -p "$a"/_biosemitemp/
            echo "$c1" > "$a"/_biosemitemp/_biosemitempa.txt
            ls -otr "$c1" | awk '{printf("%s\t%s\t%s %s\n", $4, $7, $6, $5); }' > "$a"/_biosemitemp/_biosemitempb.txt
            echo -e "\t""$a" > "$a"/_biosemitemp/_biosemitempc.txt
            md5 "$c1" > "$a"/_biosemitemp/_biosemitempd.txt

            sed 's/([^)]*)//g' "$a"/_biosemitemp/_biosemitempd.txt > "$a"/_biosemitemp/_biosemitemp_d.txt

            tr '\n' '\t' < "$a"/_biosemitemp/_biosemitempa.txt  > "$a"/_biosemitemp/_biosemitemp_a.txt
            tr '\n' '\t' < "$a"/_biosemitemp/_biosemitempb.txt  > "$a"/_biosemitemp/_biosemitemp_b.txt
            tr '\n' '\t' < "$a"/_biosemitemp/_biosemitempc.txt  > "$a"/_biosemitemp/_biosemitemp_c.txt
            cat "$a"/_biosemitemp/_biosemitemp_*.txt >> "$a"/_biosemitemp/_biosemitempcat.txt
        fi
    done

    sed 's/MD5 //g' "$a"/_biosemitemp/_biosemitempcat.txt > "$a"/_biosemitemp/_biosemitempcata.txt

    sed 's/ = //g' "$a"/_biosemitemp/_biosemitempcata.txt > "$a"/_biosemitemp/_biosemitempcatb.txt
    sort -k6 "$a"/_biosemitemp/_biosemitempcatb.txt -o "$a"/_biosemitemp/_biosemitempfinalb.txt
##    echo -e "File\tSize\tTime Modified\tDate Modified\t\tLocation\tMD5 Hash" > "$a"/_biosemitemp/_biosemitempfinala.txt
    cat "$a"/_biosemitemp/_biosemitempfinal*.txt >> "$a"/_biosemitemp/_temparch_"$current".txt
    mv "$a"/_biosemitemp/_temparch_"$current".txt "$wd"

    ### makes verification file for current archive ###
    awk -F"\t" '{print $7}' "$wd"/_temparch_"$current".txt > "$verifymd5" #makes verification file for current archive

    md51raw=`cat "$a"/_biosemitemp/_biosemitempd.txt` # raw md5 output for error reporting

    rm -rf "$a"/_biosemitemp/





    

    ### copy to remote storge volume1 ###


    vol1="/Volumes/ATTENDdata/EEG"     #primary storage volume
    vol2="/Volumes/ATTENDback/EEG"  #backup volume

    v1data="$vol1"/"$current"
    v2data="$vol2"/"$current"

    cp -Rf "$a" "$vol1" #copy to primary volume
    cp -Rf _OriginArchiveChecksums.txt "$vol1"
    cp -Rf _OriginArchiveChecksums.txt "$vol2"
    #cp -Rf "$verifymd5" "$vol2"







        ### get folder name ###

        h=$(echo $a|rev)
        nf=${h%%/*}
        fn=$(echo $nf|rev) #copied folder

        ###copy to remote backup volume###

        wd="$vol2"        #EEG folder
        a="$vol2"/"$fn"   #data folder on vol 2

        finalwd="$wd"
        finaldata="$a"

        cp -Rf "$vol1"/"$fn" "$vol2" #copy from vol1 vol2

        ### test if copies were successful ###
if [[ -d "${v1data}" && -d "${v2data}" ]] ; then


        ###Verify End Archive###

    #    md5 *.7z >> ../ArchiveChecksums.txt

        ####determine md5 hash for end archive###

    ########################
        # data folder = $vol2$fn
        #root for all EEG data folders = $vol2
       
        cd "$a" # data folder on vol 2



        ####determine md5 hash for final archive###
        shopt -s nullglob
        for c1 in *.7z
        do
            if [[ $c1 == *.7z ]]
            then
                mkdir -p "$a"/_biosemitemp/
                echo "$c1" > "$a"/_biosemitemp/_biosemitempa.txt
                ls -otr "$c1" | awk '{printf("%s\t%s\t%s %s\n", $4, $7, $6, $5); }' > "$a"/_biosemitemp/_biosemitempb.txt
                echo -e "\t""$a" > "$a"/_biosemitemp/_biosemitempc.txt
                md5 "$c1" > "$a"/_biosemitemp/_biosemitempd.txt

                sed 's/([^)]*)//g' "$a"/_biosemitemp/_biosemitempd.txt > "$a"/_biosemitemp/_biosemitemp_d.txt



                tr '\n' '\t' < "$a"/_biosemitemp/_biosemitempa.txt  > "$a"/_biosemitemp/_biosemitemp_a.txt
                tr '\n' '\t' < "$a"/_biosemitemp/_biosemitempb.txt  > "$a"/_biosemitemp/_biosemitemp_b.txt
                tr '\n' '\t' < "$a"/_biosemitemp/_biosemitempc.txt  > "$a"/_biosemitemp/_biosemitemp_c.txt
                cat "$a"/_biosemitemp/_biosemitemp_*.txt >> "$a"/_biosemitemp/_biosemitempcat.txt
            fi
        done

        sed 's/MD5 //g' "$a"/_biosemitemp/_biosemitempcat.txt > "$a"/_biosemitemp/_biosemitempcata.txt


        sed 's/ = //g' "$a"/_biosemitemp/_biosemitempcata.txt > "$a"/_biosemitemp/_biosemitempcatb.txt
        sort -k6 "$a"/_biosemitemp/_biosemitempcatb.txt -o "$a"/_biosemitemp/_biosemitempfinalb.txt
##        echo -e "File\tSize\tTime Modified\tDate Modified\t\tLocation\tMD5 Hash" > "$a"/_biosemitemp/_biosemitempfinala.txt
        cat "$a"/_biosemitemp/_biosemitempfinal*.txt >> "$a"/_biosemitemp/_temparch_"$current".txt
        mv "$a"/_biosemitemp/_temparch_"$current".txt "$wd"

        ### makes verification file for final archive ###
        finalmd5="$wd"/_MD5_"$current"_final.txt
        awk -F"\t" '{print $7}' "$wd"/_temparch_"$current".txt > "$finalmd5" #makes verification file for current archive


        md52raw=`cat "$a"/_biosemitemp/_biosemitempd.txt` # raw md5 output for error reporting

        rm -rf "$a"/_biosemitemp/

        
        

    ########################

        ###Extract End Archive###
    ##    rm -rf "$vol2$ex"
        
        cd "$vol2"
    #    cd ..
        ext=$(pwd)
        ext+="/TempExt/"


        if [ ! -d "$ext" ]; then
            mkdir "$ext"
        fi

        cd "$a" #data directory on vol2

        shopt -s nullglob
        for b in *.7z
        do
            /Applications/Keka.app/Contents/Resources/keka7z x "$b" -o"$ext" -y
        done

        ###Verify Expanded Files###

    ########################
        # data folder = $vol2$fn
        # root for all EEG data folders = $vol2
       
        expdata="$ext$fn" #extracted data directory on vol2
        cd "$expdata"

        ####determine md5 hash for expanded data###
        shopt -s nullglob
        for f in ./*
        do
            if [[ $f == *raw.txt ]]
            then
                h=$(echo $f|rev)
                nf=${h%%/*}
                fn=$(echo $nf|rev)   # now $fn is raw.txt file name (no path location) e.g. 62_05s_test_15_030615_1719_Run1_raw.txt
                p="$expdata"/"$fn" # to get full path of file

                mkdir -p "$expdata"/_biosemitemp/
                cd "$expdata"/_biosemitemp/

   #     echo "$expdata" > ~/Desktop/temptest/1a.txt ## debug
   #     echo `pwd` > ~/Desktop/temptest/2pwd.txt ## debug

                echo "$fn" > "$expdata"/_biosemitemp/_biosemitempa.txt
                ls -otr "$p" | awk '{printf("%s\t%s\t%s %s\n", $4, $7, $6, $5); }' > "$expdata"/_biosemitemp/_biosemitempb.txt
                i=${fn%_*}
                j=${i%_*}
                echo ${j:(-11)} > "$expdata"/_biosemitemp/_biosemitempc.txt
                md5 "$p" > "$expdata"/_biosemitemp/_biosemitemp_d.txt
                tr '\n' '\t' < "$expdata"/_biosemitemp/_biosemitempa.txt  > "$expdata"/_biosemitemp/_biosemitemp_a.txt
                tr '\n' '\t' < "$expdata"/_biosemitemp/_biosemitempb.txt  > "$expdata"/_biosemitemp/_biosemitemp_b.txt
                tr '\n' '\t' < "$expdata"/_biosemitemp/_biosemitempc.txt  > "$expdata"/_biosemitemp/_biosemitemp_c.txt
                cat "$expdata"/_biosemitemp/_biosemitemp_*.txt >> "$expdata"/_biosemitemp/_biosemitempcat.txt
            fi
        done

        sed 's/MD5 //g' "$expdata"/_biosemitemp/_biosemitempcat.txt > "$expdata"/_biosemitemp/_biosemitempcata.txt
        sed 's/[)(]//g' "$expdata"/_biosemitemp/_biosemitempcata.txt > "$expdata"/_biosemitemp/_biosemitempcatb.txt
        sed 's/ = /	/g' "$expdata"/_biosemitemp/_biosemitempcatb.txt > "$expdata"/_biosemitemp/_biosemitempcatc.txt  # IMPORTANT: this is a literal tab, #SED
                                                                     # but needs to be input in automators. does not survive copy/paste
        sort -k6 "$expdata"/_biosemitemp/_biosemitempcatc.txt -o "$expdata"/_biosemitemp/_biosemitempfinalb.txt
        echo -e "File\tSize\tTime Modified\tDate Modified\tDate_Time Created\tLocation\tMD5 Hash" > "$expdata"/_biosemitemp/_biosemitempfinala.txt
        cat "$expdata"/_biosemitemp/_biosemitempfinal*.txt >> "$expdata"/_biosemitemp/_Expanded_Data_Checksums.txt

        mv "$expdata"/_biosemitemp/_Expanded_Data_Checksums.txt "$expdata"


        ### remove all non-hash files from expanced data folder ###

        cd "$expdata"
        shopt -s nullglob
        for ff in ./*
        do
            if [[ $ff != *_Data_Checksums.txt ]]
            then
                h=$(echo $ff|rev)
                nf=${h%%/*}
                fn=$(echo $nf|rev)   # now $fn is raw.txt file name (no path location) e.g. 62_05s_test_15_030615_1719_Run1_raw.txt
                pp="$expdata"/"$fn" # to get full path of file
                rm -rf "$pp"
            fi
        done


md51=`cat "$verifymd5"`
md52=`cat "$finalmd5"`

if [ "$md51" == "$md52" ]; then
    rm -rf "$verifymd5"
    rm -rf "$finalmd5"
else
    echo -e "$md51raw" > "$errormd5" #original archive md5
    echo -e "$md52raw" >> "$errormd5" #final archive md5
    echo -e "\n" >> "$errormd5" #final archive md5

fi
       # dfr=`diff "$verifymd5" "$finalmd5"` ##### IMPORTANT does not work if there are spaces in the name. MAJOR ISSUE

        # if [ "a" -ne "a" ] ; then  #difference found
        #     # echo -e "test" > "$errormd5"
        #     # echo -e "$current\n" > "$errormd5"
        #     # echo -e "Original:" >> "$errormd5" 
        #     # cat "$verifymd5" >> "$errormd5" 
        #     # echo -e "Final: " >> "$errormd5" 
        #     # cat "$finalmd5" >> "$errormd5" 
        #     # echo -e "\n\n" >> "$errormd5"
        # # else #no difference
        # #     echo `pwd` > ~/Desktop/testdumps/nodifferencefound.txt
        # fi
        # #rm -rf "$verifymd5"
        # #rm -rf "$finalmd5"




############things to be done after python script####################

        #### add archive md5 hashsums to lists ###
        cat "$localwd"/_temparch_"$current".txt >> "$localwd"/_OriginArchiveChecksums.txt
        cat "$finalwd"/_temparch_"$current".txt >> "$finalwd"/_ArchiveChecksums.txt


        ### remove all files except for checksums ###
        rm -rf "$localwd"/_temparch_"$current".txt
        rm -rf "$finalwd"/_temparch_"$current".txt
        #rm -rf "$verifymd5"  # these place in above if statement once md5 hashes are confimred identical
        #rm -rf "$finalmd5"

        rm -rf "$verifycopy"


    ### debug ###
    #    printf "1: \npwd: %s \na: %s \nc1: %s \nwd: %s \n" "`pwd`" "$a" "$c1" "$wd" >> ~/Desktop/temptest/debug.txt ## debug
    #    echo cp -rf _OriginArchiveChecksums.txt "$vol1" > ~/Desktop/temptest/1.txt ## debug
    #    echo "$ext" > ~/Desktop/temptest/1ext.txt ## debug
    #    echo `pwd` > ~/Desktop/temptest/1ext.txt ## debug
    #############

# else
#     echo "$(date)" > "$errorcopy"
fi

done

##### remember to replace SED \t with literal tab ######


