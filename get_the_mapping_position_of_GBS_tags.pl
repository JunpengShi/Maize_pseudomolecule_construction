#!/usr/bin/perl
use strict;
use warnings;

die usage() if @ARGV == 0;
my ($Lu_2015_NatCommun_panGenomeAnchors20150219,$bam,$output) = @ARGV;

my $seq_number;
my %hash_chr_pos;
open NEW,"$Lu_2015_NatCommun_panGenomeAnchors20150219" or die;
while(<NEW>){
	chomp;
	next if (/^Tag/);
	my @array = split /\s+/;
	$seq_number++;
	## modified in 2018/04/21 to satisfy the file of Lu_2015_NatCommun_panGenomeAnchors20150219.V4.txt
	$hash_chr_pos{"Lu_GBS_tag_$seq_number"} = "$array[2]\t$array[3]";
}
close NEW;

open NEW1,"samtools view $bam |" or die;
open NEW2,">$output" or die;

while(<NEW1>){
	chomp;
	my @array = split /\s+/;
	print NEW2 "$hash_chr_pos{$array[0]}\t$_\n";
}

close NEW1;
close NEW2;


sub usage{
	my $die =<<DIE;
	usage : perl *.pl Lu_2015_NatCommun_panGenomeAnchors20150219.txt *.filtered.bam output.coor
DIE
}
