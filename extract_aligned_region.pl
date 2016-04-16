#!/usr/bin/perl
# extract_aligned_region.pl
use strict; use warnings;
use Getopt::Long;

# Use this script on an aligned uclust output FASTA to grab the regions that are aligned.

my $usage = "\n\textract_aligned_region.pl [-h -o] -i <input FASTA>\n\n";

# defaults
my $help;
my $outDir = './';
my $inFile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'i=s'   => \$inFile,
	) or die $usage;

die $usage unless $help or $inFile;
if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}

if ($help) {print $usage} 
else {
	# "global" variables
	my %seqs_by_ID;
	my %leadingGapLens;
	my %trailingGapLens;
	my $maxSeqLen = 0;
	my ($outName) = $inFile =~ /(\S+)\.fas*t*a*$/;
	my $outFile = "${outDir}${outName}.trimmed.fasta";
	open OUT, ">$outFile" or die "\n\tError: cannot create $outFile\n\n";
	open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";

	while (<INF>) {
		if ($_ =~ /^\>/) {
			my ($seqID) = /^\>0\|\S+?\|(\S+)$/;
			my $seq = <INF>;
			chomp $seq;
			my $seqLen = length $seq;
			my ($leadingGaps) = $seq =~ /^(\-*)/;
			my ($trailingGaps) = $seq =~ /(\-*)$/;
			my $leadingGapLen = length $leadingGaps;
			my $trailingGapLen = length $trailingGaps;

			if ($seqLen > $maxSeqLen) {$maxSeqLen = $seqLen}
			$leadingGapLens{$leadingGapLen}++;
			$trailingGapLens{$trailingGapLen}++;
			$seqs_by_ID{$seqID} = $seq;
		}
	}
	close INF; 

	my @sortedLeadingGapLens = sort {$leadingGapLens{$b} <=> $leadingGapLens{$a}} keys %leadingGapLens;
	my @sortedTrailingGapLens = sort {$trailingGapLens{$b} <=> $trailingGapLens{$a}} keys %trailingGapLens;
	my $medianLeadingGapLen = $sortedLeadingGapLens[0];
	my $medianTrailingGapLen = $sortedTrailingGapLens[0];
	print "leading: $medianLeadingGapLen\ttrailing: $medianTrailingGapLen\n";

	my @seqIDs = sort keys %seqs_by_ID;
	foreach my $seqID (@seqIDs) {
		if (length $seqs_by_ID{$seqID} < $maxSeqLen) {
			my $currLen = length $seqs_by_ID{$seqID};
			my $diff = $maxSeqLen - $currLen;
			my @additions = ('-') x $diff;
			my $addition = join ('', @additions);
			$seqs_by_ID{$seqID} = "$seqs_by_ID{$seqID}$addition";
		}
		my $seq = substr ($seqs_by_ID{$seqID}, $medianLeadingGapLen, -($medianTrailingGapLen));
		$seq =~ s/\-//g;
		if (length $seq > 300) {
			print "original:\n$seqs_by_ID{$seqID}\ntrimmed:\n$seq\n\n";
		}
		print OUT "\>$seqID\n$seq\n";
	}
	close OUT;
}
