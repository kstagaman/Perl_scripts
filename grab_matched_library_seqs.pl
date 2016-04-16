#!/usr/bin/perl
# grab_matched_library_seqs.pl
use strict; use warnings;
use Getopt::Long;

# Use this script to get library matches from a UCLUST UC file and pull their sequences from the library FASTA file

my $usage = "\n\tgrab_matched_library_seqs.pl [-h -o -p <primers FASTA> -f <fwd primer SEQ> -r <rev primer SEQ>] -u <UC file> -l <library FASTA>\n\n";

# defaults
my $help;
my $outDir = './';
my $primerFile;
my $fwdPrimer;
my $revPrimer;
my $ucFile;
my $libFile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'u=s'   => \$ucFile,
	'p=s'   => \$primerFile,
	'f=s'   => \$fwdPrimer,
	'r=s'   => \$revPrimer,
	'l=s'   => \$libFile,
	) or die $usage;

die $usage unless $help or ($ucFile and $libFile);
die "\n\tOnly one primer is specified\n\n" if ($fwdPrimer and !$revPrimer) or ($revPrimer and !$fwdPrimer);
if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}

if ($help) {print $usage} 
else {
	my $outFile = "${outDir}matched_lib_seqs.fasta";
	my %libSeqByIDs;
	if ($primerFile) {
		open PRM, "<$primerFile" or die "\n\tError: cannot open $primerFile\n\n";
		while (<PRM>) {
			next if ($fwdPrimer and $revPrimer);
			if ($_ =~ /^\>/) {
				if ($_ =~ /f[ow][rd]/) {
					$fwdPrimer = <PRM>;
					chomp $fwdPrimer;
					# print "$fwdPrimer\n";
				}
				elsif ($_ =~ /rev/) {
					$revPrimer = <PRM>;
					chomp $revPrimer;
					$revPrimer = &revcomp($revPrimer);
					# print "$revPrimer\n";
				}
				else {
					die "\n\tPrimer file header lines must identify primers as (forward|for|fwd) and (reverse|rev)\n\n";
				}
			}
		}
	}
	$fwdPrimer = &expand_wobble_bps($fwdPrimer);
	$revPrimer = &expand_wobble_bps($revPrimer);
	# print "$fwdPrimer\t$revPrimer\n";

	open LIB, "<$libFile" or die "\n\tError: cannot open $libFile\n\n";
	while (<LIB>) {
		if ($_ =~ /^\>/) {
			my ($seqID) = /^\>(\S+)/;
			my $fullSeq = <LIB>;
			chomp $fullSeq;

			my ($seq) = $fullSeq =~ /$fwdPrimer([A-Z]+)$revPrimer/;
			if (!$seq) {
				if ($fullSeq =~ /$fwdPrimer/) {
					($seq) = $fullSeq =~ /$fwdPrimer([A-Z]{300})/;
				}
				elsif ($fullSeq =~ /$revPrimer/) {
					($seq) = $fullSeq =~ /([A-Z]{300})$revPrimer/;
				}
				else {
					$seq = $fullSeq;
				}
			}

			$libSeqByIDs{$seqID} = $seq;
		}
	}
	close LIB;

	open UCF, "<$ucFile"  or die "\n\tError: cannot open $ucFile\n\n";
	open OUT, ">$outFile" or die "\n\tError: cannot open $outFile\n\n";
	while (<UCF>) {
		if ($_ =~ /^L/) {
			my ($clusterID) = /^L\t(\S+)\t/;
			my ($seqID)     = /(\S+)\t\S+$/;
			print OUT "\>$clusterID|\*|$seqID\n$libSeqByIDs{$seqID}\n";
		}
	}
}


sub revcomp {
	my ($seq) = @_;
	$seq = uc($seq);
	my $rev = reverse($seq);
	$rev =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/; # makes complement
	return $rev;
}

sub expand_wobble_bps {
	my ($seq) = @_;
	$seq = uc($seq);
	$seq =~ s/R/\[AG\]/g;
	$seq =~ s/Y/\[CT\]/g;
	$seq =~ s/S/\[GC\]/g;
	$seq =~ s/W/\[AT\]/g;
	$seq =~ s/K/\[GT\]/g;
	$seq =~ s/M/\[AC\]/g;
	$seq =~ s/B/\[CGT\]/g;
	$seq =~ s/D/\[AGT\]/g;
	$seq =~ s/H/\[ACT\]/g;
	$seq =~ s/V/\[ACG\]/g;
	$seq =~ s/N/\[ACGT\]/g;
	return $seq;
}
