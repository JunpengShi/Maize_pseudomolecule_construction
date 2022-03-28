#!/bin/bash
#$ -cwd
#$ -j y
#$ -S /bin/bash
#

bwa mem -t 4 ./A632.scaffolds.fa /NAS6/shijunpeng/data/12_maize_genome/Lu_Pan_genome_anchors/Lu_2015_NatCommun_panGenomeAnchors20150219.V4.fa | samtools view -bSq60 - | samtools sort - ./pseudomolecule_A632/Lu_2015_NatCommun_panGenomeAnchors20150219.V4.bwa_mem.A632.q60.sorted 