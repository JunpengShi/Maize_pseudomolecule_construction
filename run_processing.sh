#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -S /bin/bash
#

## this script was used to process the mapped GBS tags

perl get_the_mapping_position_of_GBS_tags.pl /NAS6/shijunpeng/data/12_maize_genome/Lu_Pan_genome_anchors/Lu_2015_NatCommun_panGenomeAnchors20150219.V4.txt ./Lu_2015_NatCommun_panGenomeAnchors20150219.V4.bwa_mem.A632.q60.sorted.bam ./Lu_2015_NatCommun_panGenomeAnchors20150219.V4.bwa_mem.A632.q60.sorted.coor 

## judge the mapping position of each scaffold with at least 10 continous tags within 500kb

perl get_the_mapping_position_of_scaffolds.pl ./Lu_2015_NatCommun_panGenomeAnchors20150219.V4.bwa_mem.A632.q60.sorted.coor 500000 10 ./A632.scaffolds.anchored.merged_500kb.markers_10.coor 

## get the anchored and oriented pseudomolecule sequence 

perl get_the_pseudomolecule_sequence.pl ./A632.scaffolds.anchored.merged_500kb.markers_10.coor.sorted ../A632.scaffolds.fa ./A632.pseudomolecules.v1.fasta 

