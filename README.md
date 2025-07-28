# pathogen_reference
18 Pathogen Reference Fasta including indexes


# Methods 
18 pathogens were downloaded using ncbi datasets to downloaded the refseq reference genomes for the following viruses and single eukaryotic parasite Toxo gondii.

in_genome=("Herpes Simplex Virus 1" "Herpes Simplex Virus 2" "Varicella Zoster Virus" "Epstein-Barr Virus" "Human Cytomegalovirus" "Human Herpesvirus 6A" "Human Herpesvirus 6B" "Human Herpesvirus 7" "Human gammaherpesvirus 8" "Hepatitis B Virus" "Hepatitis C Virus" "Human T-lymphotropic Virus 1" "Human Immunodeficiency Virus 1" "Human Polyomavirus BKV" "Human Polyomavirus JCV" "Merkel Cell Polyomavirus" )
pro_genome=("Toxoplasma gondii") 

After doing benchmarking on a subset of samples it became clear that one contig `NW_017384310.1` had 100% positivity across all tested samples. 
In fact this has been previously discussed https://www.nature.com/articles/s41431-019-0494-2.

This motivated to use a more recently assembled reference sequence which as made using long read technologies + Hi-C. `GCA_019455545.1`

Added this reference onto the viral sequences and indexed with both bowtie2 and bwa.

