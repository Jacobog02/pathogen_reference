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
in_genome=("Herpes Simplex Virus 1" "Herpes Simplex Virus 2" "Varicella Zoster Virus" "Epstein-Barr Virus" "Human Cytomegalovirus" "Human Herpesvirus 6A" "Human Herpesvirus 6B" "Human Herpesvirus 7" "Human gammaherpesvirus 8" "Hepatitis B Virus" "Hepatitis C Virus" "Human T-lymphotropic Virus 1" "Human Immunodeficiency Virus 1" "Human Polyomavirus BKV" "Human Polyomavirus JCV" "Merkel Cell Polyomavirus" )
pro_genome=("Toxoplasma gondii") 

in_abv=(HSV1 HSV2 VZV EBV CMV HHV6A HHV6B HHV7 KSHV HBV HCV HTLV1 HIV BKV JCV MCV ) 
pro_abv=( Toxoplasma.gondii ) 

len=${#in_abv[@]}
let len=$len-1

## make output directory for the taxons and the sequences
mkdir -p taxons
mkdir -p seqs

tax_file=taxons/input_taxons.txt
>$tax_file

for i in $(seq 0 $len);do 
#printf "%s\n" "${in_genome[@]}" > input_abvs.txt

#esearch -db nuccore -input "input_abvs.txt"

## ^^ Above didnt work so I think I will try something else 
## using ncbi datasets I will search for refseq complete genomes metadata one by one 
## I can then download the genome fasta + gff3 data in the zip
## For each input/zip I will extract the fasta and gff3 into an output file via the accession. 
## At the end I can then concat the viruses together and go for it 

## THIS DOESNT WORK THE ViRUS DOSNT ALLOW GTF 
#datasets download virus genome taxon ${in_taxon} --host human --annotated --refseq --include genome,gtf --filename ${out_pre}.zip  

#in_taxon="HSV1"
a_q=${in_genome[$i]}
a_abv=${in_abv[$i]}

echo $a_q $a_abv
## 1) Using query write the taxon ID for each thing 
datasets summary taxonomy taxon "${a_q}" --report ids_only --as-json-lines | jq -r '[.query[0], .taxonomy.tax_id] | @tsv' > taxons/${a_abv}_tax.tsv

one_tax=`awk -F '\t' '{print $2}' taxons/${a_abv}_tax.tsv`

datasets summary virus genome taxon ${one_tax} --annotated --refseq --as-json-lines | dataformat tsv virus-genome > taxons/${a_abv}_summary.tsv

echo $one_tax >> $tax_file

done

## This does work! No gff3 though so maybe I can use the base download function with gff3 mode but i need accessions
#datasets download virus genome taxon ${one_tax} --annotated --refseq --filename seqs/${a_abv}.zip 
datasets download virus genome taxon --inputfile ${tax_file} --annotated --refseq --include genome,cds,protein,annotation --filename seqs/viral.zip 


#one_acc=`tail -n +2 taxons/${a_abv}_summary.tsv | awk -F '\t' '{print $1}' `
#datasets download genome accession ${one_acc} --include genome,gff3 --filename seqs/${a_abv}.zip   

## now extract the stuff and store 
## I did this manyally to curate more stuff... let me move the bacterial qeury over 


