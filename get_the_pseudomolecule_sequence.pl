#!/usr/bin/perl
use strict;
use warnings;

die usage() if @ARGV == 0;
my ($anchors,$scaffolds_fasta,$output_pseudomolecule) = @ARGV;

my %hash_seq;
my $seq_name;
open NEW,"$scaffolds_fasta" or die;
while(<NEW>){
	chomp;
	if(/^>/){
		$_ =~ s/>//;
		$_ =~ s/\|/_/g;$_ =~ s/:/_/g;
		my @aa = split /\s+/;
		$seq_name = $aa[0];
	}
	else{
		$hash_seq{$seq_name} .= $_;
	}
}
close NEW;

my %hash_anchored_scaffolds;
my $chromosome_number = 0;
open NEW1,"$anchors" or die;
while(<NEW1>){
	chomp;
	my @array = split /\s+/;
	## get the scaffolds that anchored
	$hash_anchored_scaffolds{$array[-2]} = $array[-1];
	open NEW,">>$output_pseudomolecule.chr$array[0]" or die;
	if($array[-1] eq "+"){
		print NEW "$hash_seq{$array[-2]}NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN";
	}
	elsif($array[-1] eq "-"){
		## judge if the scaffold should reverse complement to the pseudomolecules
		my $seq_new = reverse_comple($hash_seq{$array[-2]});
		print NEW "$seq_new"."NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN";
	}
	close NEW;
}
close NEW1;

open NEW,">$output_pseudomolecule" or die;
for(my $number = 1;$number <= 10;$number++){
	print NEW ">chr$number\t";
	open NEW1,"$output_pseudomolecule.chr$number" or die;
	my $seq = <NEW1>;
	my $length = length ($seq);
	print NEW "len=$length\n";
	$seq =~ s/.{60}(?=.)/$&\n/g;
	print NEW "$seq\n";
	close NEW1;
	system("rm $output_pseudomolecule.chr$number");
}
close NEW;

foreach my $seq(keys %hash_seq){
	if(exists $hash_anchored_scaffolds{$seq}){
		next;
	}
	else{
		open NEW,">>$output_pseudomolecule" or die;
		print NEW ">$seq\n$hash_seq{$seq}\n";
		close NEW;
	}
}	

sub reverse_comple{
	my ($seq) = @_;
	$seq = reverse ($seq);
	$seq =~ tr/ATCGatcg/TAGCtagc/;
	return $seq;
}

sub usage{
	my $die =<<DIE;
	usage : perl *.pl huangzaosi.scaffolds.anchored.merged_100kb.markers_10.coor.sorted huangzaosi.scaffold.fasta output_pseudomolecule.fasta
DIE
}
