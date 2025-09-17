#!/bin/bash
#
#SBATCH --job-name=build_kraken
#SBATCH --partition=lareauc_cpu
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=52
#SBATCH --mem=820G


## Trying ncbi commandline tool?
## installed via conda so lets try it sis
#conda activate /data1/lareauc/users/gutierj/env/entrez

## esearch allows for the use of files as input 
## MY goal is to try to automate this as much as possible 

#in_genome=(HSV1 HSV2 VZV EBV CMV HHV6A HHV6B HHV7 KSHV HBV HCV HTLV1 HIV BKV JCV MCV Toxoplasma.gondii) 

## MISSING May92025: Kaposi Sarcoma, HIV (taxon worked but accession didnt maybe the refseq/annptated), HTLV, EBV

#mapping kaposi's sarcoma virus as "Human gammaherpesvirus 8"
#in_genome=("Herpes Simplex Virus 1" "Herpes Simplex Virus 2" "Varicella Zoster Virus" "Epstein-Barr Virus" "Human Cytomegalovirus" "Human Herpesvirus 6A" "Human Herpesvirus 6B" "Human Herpesvirus 7" "Human gammaherpesvirus 8" "Hepatitis B Virus" "Hepatitis C Virus" "Human T-lymphotropic Virus 1" "Human Immunodeficiency Virus 1" "Human Polyomavirus BKV" "Human Polyomavirus JCV" "Merkel Cell Polyomavirus" )
#pro_genome=("Toxoplasma gondii") 

#in_abv=(HSV1 HSV2 VZV EBV CMV HHV6A HHV6B HHV7 KSHV HBV HCV HTLV1 HIV BKV JCV MCV ) 
#pro_abv=( Toxoplasma.gondii ) 

pro_genome=("Chlamydia trachomatis" "Helicobacter pylori")
pro_abv=("Chlamydia.trachomatis" "Helicobacter.pylori")

len=${#pro_abv[@]}
let len=$len-1

## make output directory for the taxons and the sequences
mkdir -p taxons
mkdir -p seqs

#tax_file=taxons/input_taxons_pro.txt
#>$tax_file

for i in $(seq 0 $len);do 


#datasets download virus genome taxon ${in_taxon} --host human --annotated --refseq --include genome,gtf --filename ${out_pre}.zip  

#in_taxon="HSV1"
a_q=${pro_genome[$i]}
a_abv=${pro_abv[$i]}

echo $a_q $a_abv
## 1) Using query write the taxon ID for each thing 
datasets summary taxonomy taxon "${a_q}" --report ids_only --as-json-lines | jq -r '[.query[0], .taxonomy.tax_id] | @tsv' > taxons/${a_abv}_tax.tsv

one_tax=`awk -F '\t' '{print $2}' taxons/${a_abv}_tax.tsv`

datasets summary genome taxon ${one_tax} --annotated --assembly-source RefSeq --reference --as-json-lines | dataformat tsv genome > taxons/${a_abv}_summary.tsv

#echo $one_tax >> $tax_file

#done


one_acc=`tail -n +2 taxons/${a_abv}_summary.tsv | awk -F '\t' '{print $1}' `
datasets download genome accession ${one_acc} --include genome,gff3 --filename seqs/${a_abv}.zip   
done

## THIS IS FAILING??? 
#datasets download genome taxon --inputfile ${tax_file} --annotated --assembly-source RefSeq --reference --include genome,gff3 --filename seqs/bacterial.zip 

## okay I will try to do an explicit acc download 
#acc_file=taxons/bac_accs.txt

#tail -n +2 taxons/${a_abv}_summary.tsv | awk -F '\t' '{print $1}' | uniq > $acc_file
#datasets download genome accession --inputfile $acc_file  --include genome,gff3,protein --filename seqs/bacterial.zip   

## now extract the stuff and store 
## I did this manyally to curate more stuff... let me move the bacterial qeury over 


## OKAY so I want to use a new accession for the long reach toxo genome with 20 cleaner contigs to simplifiy the quantification 
# this paper: https://pubmed.ncbi.nlm.nih.gov/33906962/
## basically they did long read and hi-c to generate a high quality assembly of the toxo strain RH88 
## This is in contrast to the short read assembly of the ME49 strain
#    GCA_019455545.1
#datasets download genome accession GCA_019455545.1  --include genome,gff3,protein --filename seqs/toxo_rh88.zip          



