#!/bin/bash
/*
R01_1a_genData#_Data.app

Set Value of Variable: Path
Get Folder Contents
Sort Finder Items by Name in Desceing order
*/

for f in "$@"
do
	if [[ $f == *raw.txt ]]
	then
		g=${f%/*}
		h=$(echo $f|rev)
		nf=${h%%/*}
		mkdir -p "$g"/_biosemitemp/
		cd "$g"/_biosemitemp/
		fn=$(echo $nf|rev)
		echo $fn > _biosemitempa.txt
		ls -otr "$f" | awk '{printf("%s\t%s\t%s %s\n", $4, $7, $6, $5); }' > _biosemitempb.txt
		i=${fn%_*}
		j=${i%_*}
		echo ${j:(-11)} > _biosemitempc.txt
		md5 "$f" > _biosemitemp_d.txt
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
#pbcopy < _Data_Checksums.txt
mv _Data_Checksums.txt "$g"
rm -rf -- "$g"/_biosemitemp/

echo "test" > ~/Desktop/aaaaaa.txt