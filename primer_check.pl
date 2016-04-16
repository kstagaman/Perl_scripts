#!/usr/bin/perl
# primer_check.pl
use strict; use warnings;
use Getopt::Long;
use String::Approx 'adistr';

# Use this script to find sequences in a fasta file that match your forward (fwd) and reverse (rev) primers (multiple fwd/rev primers supported)
# This script is to be used if you are not interested in keeping matching 1 and 2 reads together.  For that, use order_amplicons.pl

my $usage = "\n\tUsage: primer_check.pl [options: -h -k N -d PATH -m N -o N] -p FILE -i FASTA\n\n";

# default options
my $help;
my $bclen = 0;
my $outdir = './';
my $mismatch = 0;
my $offset = 0;
my $primer_file;
my $infile;

# "global" variables
my $filename;
my $extension;
my %primers;
my @primer_ids;
my @primer_seqs;

GetOptions (
	'help!' => \$help,
	'k=i'   => \$bclen,
	'd=s'   => \$outdir,
	'm=i'   => \$mismatch,
	'o=i'   => \$offset,
	'p=s'   => \$primer_file,
	'i=s'   => \$infile,
) or die $usage;

die $usage unless $primer_file and $infile or $help;
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}


if ($help) {
	help_text();
}
else {
	$mismatch = $mismatch / 100;

	# Check that the input file is in fasta format.
	open FMTCHK , "<$infile" or die "\n\tError: cannot open $infile\n\n";
	$_ = <FMTCHK>;
	if ($_ !~ /^\>/) {die "\n\tError: input format must be FASTA.\n\n"}
	close FMTCHK;

	($filename) = $infile =~ /(.+)\.(rem\.fa$|fa_1$|fa_2$)/;
	($extension) = $infile =~ /\.(rem\.fa$|fa_1$|fa_2$)/;

	open PRIMERS, "<$primer_file" or die "\n\tError: cannot open $primer_file\n\n";
	
	# Get the primers from the primer file and store in a hash
	# Primer labels are the keys, primer seqs are the values
	while (<PRIMERS>) {
		my @line = split "\t";
		die "\n\tError: primer file must be in correct format (see -help).\n\n" unless @line;
		chomp @line;
		$primers{$line[1]} = $line[0];
	}

	@primer_ids  = values %primers; # Store primer labels (ids) in own array
	@primer_seqs = keys %primers; # Store primer seqs in own array

	close PRIMERS;

	open IN, "<$infile";
	open FWD, ">${outdir}$filename.fwd.$extension" or die "\n\tError: cannot create $filename.fwd.$extension\n\n";
	open REV, ">${outdir}$filename.rev.$extension" or die "\n\tError: cannot create $filename.rev.$extension\n\n";
	open NPR, ">${outdir}$filename.noprimer.$extension" or die "\n\tError: cannot create $filename.noprimer.$extension\n\n";

	LINE: while (<IN>) {

		# Get an individual ID and sequence
		my $id = $_;
		my $seq = <IN>;
		chomp ($id, $seq);
		my @best_matches;

		# Iterate grabbing the first part of the sequence up to the offset
		# First iteration grabs a seq from base in pos 0, to base at length of each primer
		OFFSET: for (my $i=0; $i < $offset + 1 ; $i++) {
			my @primer_checks;
			
			foreach my $primer_seq (@primer_seqs) {
				my $primer_check = substr($seq, $i, length($primer_seq)) unless(length($primer_seq) > length($seq));
				push @primer_checks, $primer_check unless !$primer_check; # store the primer check in an array,
																		  # each of these checks corresponds to a primer
			}


			# Iterate over the length of the @primer_checks array
			# to compare the check seq against the primer seq in %primers
			PMR_CHK: foreach my $primer_check (@primer_checks) {

				# get the relative edit distances of each of the primers from the primer_check seq
				my %distr;
				@distr{@primer_seqs} = map { abs } adistr($primer_check, @primer_seqs);
				my @sorted_distr = sort { $distr{$a} <=> $distr{$b} } @primer_seqs;
				my $best_match = $sorted_distr[0];

				if ($distr{$best_match} == 0) {

					if ($primers{$best_match} =~ /fwd/) {
						print FWD "$id:$primers{$best_match}:score0\n$seq\n";
					} else {
						print REV "$id:$primers{$best_match}:score0\n$seq\n";
					}

					next LINE;
				}
				elsif ($distr{$best_match} < $mismatch) {
					$best_matches[$i]= {score => $distr{$best_match}, label => $primers{$best_match}, offset => $i};
				}
			}
		}

		if (@best_matches == 0) {
			print NPR "$id\n$seq\n";
		} else {
			my @sorted_best_matches = sort {$a->{score} <=> $b->{score} || $a->{offset} <=> $b->{offset}} @best_matches;
			if ($sorted_best_matches[0]->{label} =~ /fwd/) {
				print FWD "$id:$sorted_best_matches[0]->{label}:score$sorted_best_matches[0]->{score}\n$seq\n";
			} else {
				print REV "$id:$sorted_best_matches[0]->{label}:score$sorted_best_matches[0]->{score}\n$seq\n";
			}
		}
	}
	close IN; close FWD; close REV; close NPR; 
}

sub help_text {
	print $usage;
	print "\t\t -h: this helpful help screen.\n";
	print "\t\t -k: indicates barcodes have not been removed from the seqs, and their length, N.\n";
	print "\t\t -d: specifies a directory to write the output files to, default is the working directory.\n";
	print "\t\t -p: specifies the primer file (see required format below).\n";
	print "\t\t -m: specifies mismatches allowed as a percent of seq length (e.g. 10, 25), default is 0.\n";
	print "\t\t -o: specifies the number of bases from the beginning of the seq primer can match, default is 0.\n";
	print "\t\t -i: specifies the file containing the input sequences in fasta format.\n\n";

	print "\t\t",'###### Primer file format ######',"\n\n";
	print "\t\tThe Primer file should have one label and one primer on each line.\n";
	print "\t\tThe label and primer should be separated by a tab character ", '"\t".',"\n";
	print "\t\tExample:\n\n";
	print "\t\tfwd_1\tACGTAACGTAGTACTC\n";
	print "\t\tfwd_2\tCGTACCAGCTAGCTACGC\n";
	print "\t\trev_1\tGTACGACGCTCAGA\n\n";
}