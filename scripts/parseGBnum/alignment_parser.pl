#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use Text::CSV;
use Bio::SeqIO;
use Bio::DB::Fasta;
use Bio::SimpleAlign;
use Bio::AlignIO;

my $table = shift;
my %tbl_hash;
my $dir = getcwd();

open my $fh, "<", $table or die "$table: $!\n";
my $csv = Text::CSV->new ({
        binary    => 1, # Allow special character. Always set this 
        auto_diag => 1, # Report irregularities immediately
    });

my $header = $csv->getline($fh);
$csv->column_names(@$header); # use header

while (my $row = $csv->getline_hr ($fh)) {
        my $key = $row->{isolate};
        my $value = $row->{GB_info};
        $tbl_hash{$key} = $value;
}
close $fh;

opendir (DIR, $dir) or die $!;

while (my $file = readdir(DIR)) {
    next unless (-f "$dir/$file");
    if ($file =~ /^(.+).fasta$/) {
        mkdir $1;
        my $fasdb = Bio::DB::Fasta->new($file) or die "$file could not be read: $!";
		my @fas_ids = $fasdb->get_all_primary_ids;
        my $str = Bio::AlignIO->new(-file => $file);
        my $aln = $str->next_aln();
        my @gb_ids;
		foreach my $fas_id (@fas_ids) {
			if (exists $tbl_hash{$fas_id}) {
                push (@gb_ids, $fas_id);
            }
            else {
                my $seq = $aln->get_seq_by_id($fas_id);
                $aln->remove_seq($seq);
            }
        }
        my $new = $aln->remove_columns(['all_gaps_columns']);
        $new->sort_alphabetically;
        my $out_aln = Bio::AlignIO->new(-file => ">$1/$1_gb_aln.phy", -format =>'phylip', -interleaved => '0');{
            $out_aln->write_aln($new);
        }
        open (my $fh, '>>', "$1/$1_gb_aln.phy");
        print $fh "\n";
        foreach my $gb_id (sort @gb_ids) {
            print $fh ">",$tbl_hash{$gb_id},"\n";
        }
        my $out_aln2 = Bio::AlignIO->new(-file => ">$1/$1_gb_dummy.phy", -format =>'phylip', -interleaved => '0');{
            $out_aln2->write_aln($new);
        }
    }
}

closedir (DIR);

system ("rm *.index");

__END__
