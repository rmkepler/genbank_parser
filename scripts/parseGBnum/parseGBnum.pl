#!usr/bin/perl
use strict;
use warnings;

#This script will read in a tab-delimited file returned directly from genbank and 
#parse the data into a table, with a separate line for each sample and each
#accession in a column of its own. 

#usage:parseGBnum.pl INFILE OUTFILE 

my $list = shift @ARGV;
my $outfile = shift @ARGV;

open (IN, '<', $list);
my %gb_hash;
 
while (my $line = <IN>) {
	chomp $line;
	my ($gene, $sample, $gbnum) = split(/\s+/, $line);
	$gene =~ s/\..+//;
	$gb_hash{$sample}{$gene} = $gbnum;
}
my $thing; #this is where I will start dereferencing later
my $placeholder:
__END__
