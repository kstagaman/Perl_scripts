#!/usr/bin/perl
# truncate_paired_reads.pl
use strict; use warnings;

my @files = `ls *[0-9].fa_[12]`;
chomp @files;
my $allseqcount = 0;
my $truncseqcount = 0;

foreach my $file (@files) {
	my ($sample) = $file =~ /sample_(.+)\.fa_[12]/;
	my ($suffix) = $file =~ /sample_.+\.(fa_[12])/;
	open IN, "<$file" or die "Error: cannot open $file\n";
	open OUT, ">$sample.trunc.$suffix" or die "Error: cannot create file $sample.trunc.$suffix\n";
	while (<IN>) {
		if ($_ =~ /^\>/) {
			$allseqcount++;
			my ($id) = $_ =~ /^(\>.+)/;
			$_ = <IN>;
			my ($seq) = $_ =~ /([ACGTN]+)/;
			if (length $seq >= 115) {
				$truncseqcount++;
				my $truncseq = substr($seq, 0, 114);
				print OUT "$id\n$truncseq\n";
			}
			else {
				print OUT "$id\nNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\n";
			}
		}
	}
	close IN; close OUT;
}

print "\nSeqs before truncation:\t$allseqcount\n";
print "Seqs after truncation:\t$truncseqcount\n\n";