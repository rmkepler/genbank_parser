#!/usr/bin/perl
use strict;
use warnings;

#usage:parseGBnum.pl INFILE OUTFILE 

#Read in data returned directly from genbank (in the form of FILE SAMPLE GBNUM) and parse
# the data into a table, with a separate line for each sample and each accession in a
# column of its own. Spaces not allowed within file or sample name.


my $list = shift @ARGV; #read in the name of the data file
my $outname = shift @ARGV; #read in the name of the output file to be written

open (IN, '<', $list) #reads in the actual data file
	or die "can't open $list: $!\n";

my %full_hash; #Sample is the key, value is another hash with gene as key and GB as value
my %gene_hash; #a hash of just the gene names. Prevents duplicates by overwriting
 
while (my $line = <IN>) {
	chomp $line;
	my ($gene, $sample, $gbnum) = split(/\s+/, $line); #parses each line into its 3 parts. The number of spaces separating each column doesn't matter
	$gene =~ s/\..+//; #trims file extension from gene name
	$gene_hash{$gene} = 1; #populates %gene_hash.  Duplicates are simply overwritten
	$full_hash{$sample}{$gene} = $gbnum; #populates %full_hash
}

open (OUT, '>', $outname); #begin writing to output file

my @gkeys = sort keys %gene_hash; #sorted gene names

print OUT "\t",join("\t", @gkeys),"\n"; #Writes tab delimited file header

foreach my $sample_key (sort keys %full_hash) { #Cycles through each sample name
	my @gb_line = (); #Empty array that is populated with GBnums in loop below
	foreach my $gene1 (@gkeys) { #This loop queries hashes referenced in %full_hash
		if (exists $full_hash{$sample_key}{$gene1}) { 
			push (@gb_line, $full_hash{$sample_key}{$gene1}); #get GBnum if that sample had the gene
		} else { 
			push (@gb_line, ''); #If the sample does not have the gene, push an empty value
			}
	}
	print OUT $sample_key,"\t",join("\t", @gb_line),"\n"; #Prints a line with sample number and GBnums separated by tabs to the out file
}


__END__
