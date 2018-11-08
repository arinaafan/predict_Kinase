#!/bin/bash

path=$(pwd)

REC="$path/recept"
LIG="$path/cryst_lig"
DOC="$path/dock"
COMPL="$path/compl"
ligfile="$path/test.sdf"
smina="$path/./smina.static"
r6_born="/home/arina/soft/r6_born/R6bornRadius/./bornRadius"
babel="/usr/local/bin/./obabel"
HingeReg_table="$path/Kinases_HingeReg.tab"

# 1. Calculate nof_Atoms and nof_RotB for ligands with ICM-Pro

$path/./calc_Lig_desc.icm if="${ligfile}"

# 2. Calculate solvation energy for free ligands

# 2.1 Prepare PQR files for ligads to run r6_born utility with Amber tools and acpype script
for file in *mol2; do
	comp=$(echo $file | sed "s/\.mol2//")
	python ~/soft/acpype/acpype.py -i $comp.mol2
	ambpdb -p $comp\.acpype/$comp\_AC.prmtop -c $comp\.acpype/$comp\_AC.inpcrd -pqr > $comp.pqr
	done
	
# 2.2 Run r6_born utility to calculate solvation energy of free ligands
echo -e "Comp\tTOTAL_EELEC\tTOTAL_SOLV\tPOLAR_SOLV\tNONPOLAR_SOLV\tCOULOMB" > lig_solv.tab
for file in *pqr; do
	comp=$(echo $file | sed "s/\.pqr//")
	ener=$($r6_born -pqr $comp.pqr -energy all | sed "s/ \{1,\}/\t/g" | cut -f3,7,5,9,11)
	echo -e "$comp\t$ener" | sed "s/ \{1,\}/\t/g" >> lig_solv.tab
	done

# 3. Run docking with SMINA and process docking results with ICM-Pro

echo -e "Compl\tgauss_o0_w0_5_c8_\trepulsion_o0_c8_\thydrophobic_g0_5_b1_5_c8_\tnon_hydrophobic_g0_5_b1_5_c8_\tvdw_i6_j12_s1_100_c8_\tnon_dir_h_bond_lj_o_0_7_100_c8_\tnon_dir_anti_h_bond_quadratic_o0_c8_\tnon_dir_h_bond_g_0_7_b0_c8_\tacceptor_acceptor_quadratic_o0_c8_\tdonor_donor_quadratic_o0_c8_\tgauss_o3_w2_c8_\telectrostatic_i2_100_c8_\tad4_solvation_d_sigma3_6_s_q0_01097_c8_" > smina.scores.tab

echo -e "Compl\tminimizedAffinity\tICM_hbonds\tICM_area" > compl.tab

for rec in $REC/*pdb; do
	pdbid=$(echo $rec | sed "s/.*\(.\{4\}\)\.pdb/\1/")
	echo $pdbid
	$smina -r $rec --autobox_ligand $LIG/$pdbid.mol2 --autobox_add 6 -l $ligfile --exhaustiveness 16 --addH off --num_modes 1 -o $DOC/$pdbid.test1.docked.sdf
	$smina --score_only --custom_scoring $path/allterms -r $rec -l $ligfile | grep -e "##" | sed "1d" | sed "s/^## /$pdbid\_/g;s/ /\t/g" >> smina.scores.tab
	$path/./save_compl.icm if1="${DOC}/${pdbid}.test1.docked.sdf" if2="${rec}" outp="${COMPL}" outpf="compl.tab"
	done

# 4. Re-score protein-ligand complexes with X-score

echo -e "sc1\tsc2\tsc3\tscCons\txEnergy\tCompl" > xscores.tab

for rec in $REC/*pdb; do
        pdbid=$(echo $rec | sed "s/.*\(.\{4\}\)\.pdb/\1/")
        echo $pdbid
	$babel $DOC/$pdbid.test1.docked.sdf -omol2 -O $DOC/$pdbid.test1.docked.mol2
	xscore -score $rec $DOC/$pdbid.test1.docked.mol2 | grep 'Molecule' | sed "s/v/$pdbid\_v/g" | sed "s/ \{1,\}/\t/g" | cut -f3- >> xscores.tab
	done

# 5. Analyse protein-ligand contacts with PLIP (pyMol based tool)

echo -e "Compl\tH_bond\tHal_bond\tHydrophobic\tpi_Cation\tpi_Stacking\tSalt_Bridges\tHR_1\tHR_2\tHR_3" > inter.report.tab

for compl in compl/*.pdb; do
	plipcmd -f $compl -vt -o inter
        comp_name=$(echo $compl | sed "s/compl\///;s/\.pdb//")
	bash $path/parse_plip.sh $HingeReg_table inter/report.txt | grep -e 'RES' | sed "s/RES/$comp_name/" >> inter.report.tab
	done

# 6. Join tables into summary descriptors table 'test_compl_descr.tab' with R
    
Rscript $path/joinTabs.R

exit 0
