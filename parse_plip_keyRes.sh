#!/bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Created by Arina 16/10/2017
#
# this script will parse output of
# PLIP programm into number of
# receptor-ligand interactions
# only for 3 res in Hinge region
#
# takes 2 arguments: input file (report.txt)
# and complex name for output table
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

keyRes_table='Kinases_HingeReg.tab' # table with Seq numbers of key residues 

FILE=$1
name=$2

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
hb1=$(cat $FILE2 | sed -ne '/\*\*Hydrogen Bonds\*\*/,/^$/p' | sed '/^+.*+$/d' | sed "s/^| //g" | grep -e "^$KeyRes1 " | wc -l)
hb2=$(cat $FILE2 | sed -ne '/\*\*Hydrogen Bonds\*\*/,/^$/p' | sed '/^+.*+$/d' | sed "s/^| //g" | grep -e "^$KeyRes2 " | wc -l)
hb3=$(cat $FILE2 | sed -ne '/\*\*Hydrogen Bonds\*\*/,/^$/p' | sed '/^+.*+$/d' | sed "s/^| //g" | grep -e "^$KeyRes3 " | wc -l)

echo -e "$name\t$lig\t$hb1\t$hb2\t$hb3" 

done

rm file*

exit 0

