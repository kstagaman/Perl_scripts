#!/usr/bin/perl
# blast_output.pl
use strict; use warnings;

# use this script to parse the ouput from blast_files.sh or any standard blastn output file 

die "Usage: blast_output.pl <input file>\n" unless @ARGV == 1;

open BLAST, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";

my ($sample) = $ARGV[0] =~ /(\S+)\.blastout/;
my ($ig) = $sample =~ /^([mz])/;
my ($tank) = $sample =~ /^[mz]([abcd])/;
my ($fish) = $sample =~ /^[mz][abcd](\d{2})/;
my ($seq_type) = $sample =~ /\.(\w+)$/;
my ($primer_match) = "NA";
if ($sample !~/[mz][abcd][23][678901]\.[gu]/) {
	($primer_match) = $sample =~ /[mz][abcd][23][678901]\.(.+)\.[gu]/;
}

open PARSED, ">$ARGV[0].parsed" or die "Error: cannot create $ARGV[0].parsed\n";

while (<BLAST>) {
	if ($_ =~ /Query=/) {
		my ($query) = $_ =~ /= (.+)\s+/;
		print PARSED "\n\>$query\n";
	}
	if ($_ =~ /^ref|^emb|^gb|^gi/) {
		my ($ref_num) = $_ =~ /^\s*\S*[gb|emb|ref]\|(\S+)\|/;
		my ($dscrpt)  = $_ =~ /\|\w*\s+(.+)\s+\d{1,3}\.*\d*\s+\d/;
		my ($score)   = $_ =~ /\|\w*\s+.+\s+(\d{1,3}\.*\d*)\s+\d/;
		my ($e_val)   = $_ =~ /\d\s+(\S+)\s+$/;
		print PARSED "$ref_num\t$dscrpt\t$score\t$e_val\n";
	}
	if ($_ =~ /No hits found/) {
		print PARSED "No_hits_found\n";
	}
}

close BLAST; close PARSED;

open PARSED, "<$ARGV[0].parsed" or die "Error: cannot open $ARGV[0].parsed";
open IGS, ">$ARGV[0].igs" or die "Error: cannot create $ARGV[0].igs";
open STATS, ">$ARGV[0].stats.csv" or die "Error: cannot create $ARGV[0].stats.csv";  # abundance/length stats for individual seqs
print STATS "sample,ig,tank,fish,seq.type,primer.match,uniq.seq.num,abund,len,danio.hit,ig.hit,no.hit\n"; # STATS header

my $ig_count = 0;
my $danio_count = 0;
my $nohit_count = 0;
my $totalseq_count = 0;
my @ids;
my @frac_ig_hits;
my @top_accessions;

while (<PARSED>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_;
		chomp $id;
		my ($uniq_seq_num) = $id =~ /^\>\s*(\d+):/;
		my ($abund)      = $id =~ /:N(\d+):/;
		my ($len)        = $id =~ /:(\d+)bp$/;
		my $danio_hit = 0;
		my $ig_hit    = 0;
		my $no_hit    = 0;
		print STATS "$sample,$ig,$tank,$fish,$seq_type,$primer_match,$uniq_seq_num,$abund,$len,";
		$totalseq_count++;

		my $ighit_count = 0;
		my $daniohit_count = 0;
		my $match_count = 0;

		$_ = <PARSED>;
		my ($top_accession) = $_ =~ /^(\S+)\t/;
#		while ($_ =~ /^\w/) {
			$match_count++;
			
			if ($top_accession =~ /danio/i or $_ =~ /zebrafish/i) { #
				$daniohit_count++;
			}

			if ($top_accession =~ /immuno/) { #
				$ighit_count++;
			}
			

			if ($top_accession =~ /No_hits_found/) { #
				$nohit_count++;
				$no_hit = 1;
			}
			
#			$_ = <PARSED>;
#		}
		
		if ($daniohit_count > 0) {
			$danio_count++;
			$danio_hit = 1;
		}
		
		if ($ighit_count > 0) {
			$ig_count++;
			$ig_hit = 1;
			push @ids, $id;
			my ($frac_ig_hit) = "$ighit_count/$match_count";
			push @frac_ig_hits, $frac_ig_hit;
			push @top_accessions, $top_accession;
		}

		print STATS "$danio_hit,$ig_hit,$no_hit\n";
	}
}

close PARSED; 

my $frac_ig = $ig_count / $totalseq_count;
my $frac_nohit = $nohit_count / $totalseq_count;
my $frac_danio = $danio_count / $totalseq_count;

printf IGS "Number total seqs: %d\nNumber seqs blasting to Ig: %d (%.2f)\n
Number seqs blasting to Danio: %d (%.2f)\nNumber seqs with no hits: %d (%.2f)\n",
 $totalseq_count, $ig_count, $frac_ig, $danio_count, $frac_danio, $nohit_count, $frac_nohit;

print IGS "sequence\tig_hits/total_hits\ttop_accession_number\n";

for (my $i = 0; $i < @ids; $i++) {
	print IGS "$ids[$i]\t$frac_ig_hits[$i]\t$top_accessions[$i]\n";
}		

close IGS;