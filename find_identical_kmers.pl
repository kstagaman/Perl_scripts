my #!/usr/bin/perl
# find_identical_kmers.pl
use strict; use warnings;
use Getopt::Long;
use String::Approx 'adistr';

# Use this script to break sequences from a FASTA file into specified kmers and then see if any kmer is shared by all sequences.
# The main purpose of this script is to find possible primer sequences common for multiple sequences.

my $usage = "\n\tfind_identical_kmers.pl [-h -o <OUT PATH> -m <MISMATCHES>] -k <KMER SIZE> -i <FASTA INPUT>\n\n";

# defaults
my $help;
my $outdir = './';
my $mismatch = 0;
my $kmer;
my $infile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outdir,
	'm=i'   => \$mismatch,
	'k=i'   => \$kmer,
	'i=s'   => \$infile,
	) or die $usage;

die $usage unless $help or ($kmer and $infile);
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($help) {help_txt()}
else {
	# global variables
	my ($filename) = $infile =~ /\/*([\w\s\-]+)\.fas*t*a*$/;
	my $outfile = "$filename.shared_${kmer}mers_m$mismatch.txt";
	$mismatch = $mismatch / $kmer;
	my %kmers;
	my @ids;
	my %matching_counts;
	my %matched_seqs;
	my @sorted_matching_seqs;
	my $total_seqs;

	open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";

	while (<INF>) {

		if ($_ =~ /^\>/) {
			my $id = $_;
			my $seq = <INF>;
			chomp $id; chomp $seq;
			$seq = uc $seq;
			push @ids, $id;
			my $end = length($seq) - $kmer;

			for (my $i=0; $i <= $end; $i++) {
				my $subseq = substr($seq, $i, $kmer);
				push @{$kmers{$id}}, $subseq;
			}
		}
	}
	close INF;

	my @used_subseqs;

	SUBSEQ: for (my $i=0; $i < @{$kmers{$ids[0]}}; $i++) {
		my $subseq = ${$kmers{$ids[0]}}[$i];
		next SUBSEQ if (grep /$subseq/, @used_subseqs);
		push @used_subseqs, $subseq;
		# print "subseq: $subseq\n";

		for (my $j=1; $j < @ids; $j++) {
			# my @compared_subseqs;
			my %distr;
			@distr{@{$kmers{$ids[$j]}}} = map { abs } adistr($subseq, @{$kmers{$ids[$j]}});
			my @sorted_distr = sort {$distr{$a} <=> $distr{$b}} @{$kmers{$ids[$j]}};
			my $best_comparison = $sorted_distr[0];

			if ($distr{$best_comparison} <= $mismatch) {
				$matching_counts{$subseq}++;
				push (@{$matched_seqs{$subseq}}, $best_comparison) if ($mismatch > 0);
			}

			# COMPARISON: foreach my $compared_subseq (@sorted_distr) {
				# print "$subseq-$compared_subseq: $distr{$compared_subseq}\n" if ($distr{$compared_subseq} < $mismatch);

				# if ($distr{$compared_subseq} <= $mismatch) {
					# next COMPARISON if (grep /$compared_subseq/, @compared_subseqs);
					# $matching_counts{$subseq}++;
					# if ($mismatch > 0) {push @{$matched_seqs{$subseq}}, $compared_subseq}
					# push @compared_subseqs, $compared_subseq;
				# }
			# }
		}
	}

	@sorted_matching_seqs = sort {$matching_counts{$b} <=> $matching_counts{$a}} keys %matching_counts;
	$total_seqs = @ids;
	open OUT, ">$outfile" or die "\n\tError: cannot create $outfile\n\n";

	foreach my $matching_seq (@sorted_matching_seqs) {
		$matching_counts{$matching_seq}++;
		print "$matching_seq: $matching_counts{$matching_seq}\/$total_seqs\n";

		if ($matching_counts{$matching_seq} == ($total_seqs)) {
			# print "$matching_seq\n";
			# print OUT "$matching_seq\n";
			for my $bp (split '', $matching_seq) {
				# print "$bp\t";
				print OUT "$bp\t";
			}
			# print "\n";
			print OUT "\n";

			if ($mismatch > 0) {

				foreach my $matched_seq (@{$matched_seqs{$matching_seq}}) {
					print "\t$matched_seq\n" unless ($matched_seq eq $matching_seq);
					# print OUT "$matched_seq\n" unless ($matched_seq eq $matching_seq);

					unless ($matched_seq eq $matching_seq) {

						for my $bp (split '', $matched_seq) {
							# print "$bp\t";
							print OUT "$bp\t";
						}
					}
					# print "\n";
					print OUT "\n";
				}
			}

			# print "\n";
			print OUT "\n";
		}
	}
	close OUT;
}

sub help_txt {
	print $usage;
	print "\t\t-h: the helpful help screen\n";
	print "\t\t-o: output directory, default is current (./)\n";
	print "\t\t-m: number of allowable mismatches in comparing kmers\n";
	print "\t\t-k: kmer size to compare between sequences\n";
	print "\t\t-i: input FASTA file\n\n";
}