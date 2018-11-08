#!/bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Created by Arina 16/10/2017
#
# this script will parse output of
# PLIP programm into number of
# receptor-ligand interactions
#
# takes input file as an only argument
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

keyRes_table=$1
FILE=$2
Rec_name=$(head -1 $FILE | awk '{print $NF}')

echo "Receptor: $Rec_name"

KeyRes1=$(grep -e $Rec_name $keyRes_table | cut -f2)
KeyRes2=$(grep -e $Rec_name $keyRes_table | cut -f3)
KeyRes3=$(grep -e $Rec_name $keyRes_table | cut -f4)

echo -e "Key residues: $KeyRes1\t$KeyRes2\t$KeyRes3"

csplit -sf file -n 1 $FILE '/SMALLMOLECULE$/' '{*}'
rm file0

for FILE2 in file*; do

lig=$(cat $FILE2 | sed '1q;d' | cut -d':' -f1)
hb=$(cat $FILE2 | sed -ne '/\*\*Hydrogen Bonds\*\*/,/^$/p' | sed '/^+.*+$/d' | wc -l)
if [[ $hb > 0 ]]; then hb=$(($hb-3)); fi
halb=$(cat $FILE2 | sed -ne '/\*\*Halogen Bonds\*\*/,/^$/p' | sed '/^+.*+$/d' | wc -l)
if [[ $halb > 0 ]]; then halb=$(($halb-3)); fi
hydph=$(cat $FILE2 | sed -ne '/\*\*Hydrophobic Interactions\*\*/,/^$/p' | sed '/^+.*+$/d' | wc -l)
if [[ $hydph > 0 ]]; then hydph=$(($hydph-3)); fi
picat=$(cat $FILE2 | sed -ne '/\*\*pi-Cation Interactions\*\*/,/^$/p' | sed '/^+.*+$/d' | wc -l)
if [[ $picat > 0 ]]; then picat=$(($picat-3)); fi
pist=$(cat $FILE2 | sed -ne '/\*\*pi-Stacking\*\*/,/^$/p' | sed '/^+.*+$/d' | wc -l)
if [[ $pist > 0 ]]; then pist=$(($pist-3)); fi
salt=$(cat $FILE2 | sed -ne '/\*\*Salt Bridges\*\*/,/^$/p' | sed '/^+.*+$/d' | wc -l)
if [[ $salt > 0 ]]; then salt=$(($salt-3)); fi
hb1=$(cat $FILE2 | sed -ne '/\*\*Hydrogen Bonds\*\*/,/^$/p' | sed '/^+.*+$/d' | sed "s/^| //g" | \
grep -e "^$KeyRes1 " | wc -l)
hb2=$(cat $FILE2 | sed -ne '/\*\*Hydrogen Bonds\*\*/,/^$/p' | sed '/^+.*+$/d' | sed "s/^| //g" | \
grep -e "^$KeyRes2 " | wc -l)
hb3=$(cat $FILE2 | sed -ne '/\*\*Hydrogen Bonds\*\*/,/^$/p' | sed '/^+.*+$/d' | sed "s/^| //g" | \
grep -e "^$KeyRes3 " | wc -l)

echo -e "$lig\t$hb\t$halb\t$hydph\t$picat\t$pist\t$salt\t$hb1\t$hb2\t$hb3" 

done

rm file*

exit 0

