#!/usr/bin/perl
use strict;
use warnings;

die usage() if @ARGV == 0;

my ($Lu_2015_NatCommun_panGenomeAnchors20150219,$merge_distance,$minimal_supporting_marker,$output) = @ARGV;

## this hash table was used to judge if the scaffolds was placed reversly
my %hash_coors;
print "Start reading tag coordinates.................\n";
my $total_tag_number;
open NEW,"$Lu_2015_NatCommun_panGenomeAnchors20150219" or die;
while(<NEW>){
	chomp;
	my @array = split /\s+/;
	next if (/^Null/);
	## change the scaffold names
	$array[4] =~ s/\|/_/g;$array[4] =~ s/:/_/g;
	$total_tag_number++;
	open NEW1,">>./$array[4].coor.bed" or die;
	my $start = $array[1] - 1;
	print NEW1 "$array[0]\t$start\t$array[1]\t$array[2]\t100\t+\n";
	## the mapping position of each tag
	$hash_coors{$array[4]}{"$array[0]_$array[1]"} = $array[5];
}
close NEW;
print "Tag reading Done...............($total_tag_number tags)\n\n";
print "#####################################################################\n";

open NEW,">$output" or die;
my @files = <./*.coor.bed>;
foreach my $file(@files){
	print "Processing scaffold: $file \n";
	
	system("sort -k 1,1 -k 2,2n -k 3,3n $file >$file.sorted");
	system("bedtools merge -n -d $merge_distance -nms -i $file.sorted >$file.sorted.merged");
	## get the region with the most clustered tags
	system("sort -k 5,5nr $file.sorted.merged >$file.sorted.merged.sorted");

	open NEW1,"$file.sorted.merged.sorted" or die;
	chomp(my $header = <NEW1>);
	my @aa = split /\s+/,$header;
	my $target_chr = $aa[0];
	my $target_start = $aa[1];
	my $target_end = $aa[2];
	## the scaffold name
	my $temp = $file;
	$temp =~ s/\.\///;
	$temp =~ s/\.coor\.bed//;
	print "Scaffold name was $temp\n";
#	print "The high-confidence anchored region is: $target_chr:$target_start-$target_end\n";

	if($aa[-1] >= $minimal_supporting_marker){
		print "The high-confidence anchored region is: $target_chr:$target_start-$target_end\n";
		my @array_anchored_tags;
		open NEW2,"$file" or die;
		while(<NEW2>){
			chomp;
			my @array = split /\s+/;
			## the coordinates in scaffolds were already sorted
			if($array[0] eq "$target_chr" and $array[2] > $target_start and $array[2] <= $target_end){
				push @array_anchored_tags,$array[2];
			}
		}
		close NEW2;

		my $add1 = $array_anchored_tags[0] + $array_anchored_tags[1] + $array_anchored_tags[2] + $array_anchored_tags[3] + $array_anchored_tags[4];
#		my $reverse_scaffold = 0;
		my $add2 = $array_anchored_tags[-5] + $array_anchored_tags[-4] + $array_anchored_tags[-3] + $array_anchored_tags[-2] + $array_anchored_tags[-1];
#		for(my $number = 0;$number < (@array_anchored_tags - 1);$number++){
#			if($array_anchored_tags[$number] < $array_anchored_tags[$number + 1]){
#				$forward_scaffold++;
#			}
#			elsif($array_anchored_tags[$number] > $array_anchored_tags[$number + 1]){
#				$reverse_scaffold++;
#			}
#		}
		print "The upstream tags were ($array_anchored_tags[0],$array_anchored_tags[1],$array_anchored_tags[2],$array_anchored_tags[3],$array_anchored_tags[4])\nThe downstream tags were ($array_anchored_tags[-5],$array_anchored_tags[-4],$array_anchored_tags[-3],$array_anchored_tags[-2],$array_anchored_tags[-1])\n";
	#	print "#####################################################################\n";

		if($add1 < $add2){
			print NEW "$header\t$temp\t+\n";
		}
		elsif($add1 > $add2){
			print NEW "$header\t$temp\t-\n";
		}
		else{
			print NEW "$header\t$temp\t+\n";
		}
#		else{
#			print NEW "$header\t$temp\t+\n";
#		}
	}
	print "#####################################################################\n";
	

#	if($aa[-1] >= $minimal_supporting_marker){
#		my $left_position = $aa[1] + 1;
#		my $right_position = $aa[2];
#		my $a = 0;my $b = 0;
#		$a = $hash_coors{$temp}{"$aa[0]_$left_position"};
#		$b = $hash_coors{$temp}{"$aa[0]_$right_position"};
#		print "$a\t$b\n";
#		if($hash_coors{$temp}{"$aa[0]_$left_position"} < $hash_coors{$temp}{"$aa[0]_$right_position"}){
#			print NEW "$header\t$temp\t+\n";
#		}
#		else{
#			print NEW "$header\t$temp\t-\n";
#		}
#	}	
#	close NEW1;

#	system("rm $file");
#	system("rm $file.sorted");
#	system("rm $file.sorted.merged");
#	system("rm $file.sorted.merged.sorted");
}
close NEW;

system("sort -k 1,1 -k 2,2n -k 3,3n $output >$output.sorted");

sub usage{
	my $die =<<DIE;
	usage : perl *.pl Lu_2015_NatCommun_panGenomeAnchors20150219.bwa_mem.huangzaosi.scaffold.q60.sorted.coor merge_distance minimal_supporting_marker output.coor 
DIE
}
