#!/usr/bin/perl
# order_amplicons.pl
# Script is written to take in FASTA files and search for primer sequences starting within the first $n bases
# expected (determined by length of for loop at line 53) and write the pairs to new files if found.

use strict; use warnings;

die "Usage: order_amplicons.pl <igm/gz2> <primer file.txt>\n" unless @ARGV == 2;
die "Usage: order_amplicons.pl <igm/gz2> <primer file.txt>\n" unless $ARGV[0] =~ /g[mz]2*/;

my (@read1s, @read2s);

if ($ARGV[0] eq "igm") {
	@read1s = `ls *m[abcd]*fa_1`;
	@read2s = `ls *m[abcd]*fa_2`;
}
elsif ($ARGV[0] eq "igz2"){
	@read1s = `ls *z[abcd]*fa_1`;
	@read2s = `ls *z[abcd]*fa_2`;
}
chomp(@read1s, @read2s);

open PRIMERS, "<$ARGV[1]" or die "Error: Cannot open $ARGV[1]\n";
		# primer file should contain 
			# 1st line: >fwd_1
			# 2nd line: [forward 1 primer sequence]
			# 3rd line: >fwd_n
			# 4th line: [forward n primer sequence]  
			# 5th line: >rev
			# 6th line: [reverse primer sequence]

my @fwd_primers = ();
my ($rev_primer) = ();

while (<PRIMERS>) {
	if ($_ =~ /^\>fwd/) {
		$_ = <PRIMERS>;
		my ($fwd_primer) = $_ =~ /(\w+)/;	# get foward primer sequence
		push @fwd_primers, $fwd_primer;
	}
	if ($_ =~ /^\>rev/) {
		$_ = <PRIMERS>;
		($rev_primer) = $_ =~ /(\w+)/;	# get reverse primer sequence
	}
}
close PRIMERS;

for (my $i = 0; $i < @read1s; $i++) {

	my $n = 5; # set the number of bases from the beginning of the sequence in which the primer can start

	open READ1, "<$read1s[$i]" or die "Error: Cannot open $read1s[$i]\n";
	open READ2, "<$read2s[$i]" or die "Error: Cannot open $read2s[$i]\n";
	
	my ($output_prefix) = $read1s[$i] =~ /^(\w+)\.fa_[12]/;
	open OUTFWD, ">$output_prefix.fwd.fa";
	open OUTREV, ">$output_prefix.rev.fa";
	open UNMATCH1, ">$output_prefix.noprimer1.fa";
	open UNMATCH2, ">$output_prefix.noprimer2.fa";



	while (<READ1>) {
		my $ID_line1 = $_;			# get line ID for first read
		my $sequence1 = <READ1>;	# get read1 sequence from next line
		my $ID_line2 = <READ2>;		# get line ID for second read
		my $sequence2 = <READ2>;	# get read2 sequence from next line
		chomp ($ID_line1, $sequence1, $ID_line2, $sequence2);
		
		for (my $i = 0; $i < $n; $i++) {
			# extracting possible primer sequences to compare starting from beginning and going 
			# in specified number of bases ($n)
			my (@R1_fwd_prim_checks, @R2_fwd_prim_checks);

			foreach my $fwd_primer (@fwd_primers){
				my $R1_fwd_prim_check = substr($sequence1, $i, length($fwd_primer));
				my $R2_fwd_prim_check = substr($sequence2, $i, length($fwd_primer));
				push @R1_fwd_prim_checks, $R1_fwd_prim_check;
				push @R2_fwd_prim_checks, $R2_fwd_prim_check;
			}
		
			my $R1_rev_prim_check = substr($sequence1, $i, length($rev_primer));	
			my $R2_rev_prim_check = substr($sequence2, $i, length($rev_primer));
		
			# if forward primer in read1 and reverse primer in read2:
			PMR_CHECK: for (my $j = 0; $j < @R1_fwd_prim_checks; $j++) {
				if ($R1_fwd_prim_checks[$j] ~~ @fwd_primers and $R2_rev_prim_check =~ /$rev_primer/) {
				print OUTFWD "$ID_line1\n"; print OUTFWD "$sequence1\n";
			
					my $rev_sequence2 = reverse $sequence2;	# reverse the reverse primer sequence so that it is 
														    # in the correct orientation
					$rev_sequence2 =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/; # makes complement
				
					print OUTREV "$ID_line2\n"; print OUTREV "$rev_sequence2\n";
					last PMR_CHECK;
				}
				# if reverse primer in read1 and foward in read2;
				elsif ($R1_rev_prim_check =~ /$rev_primer/ and $R2_fwd_prim_checks[$j] ~~ @fwd_primers)	{
					print OUTFWD "$ID_line2\n"; print OUTFWD "$sequence2\n";
				
					my $rev_sequence1 = reverse $sequence1;
					$rev_sequence1 =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/;
					
					print OUTREV "$ID_line1\n"; print OUTREV "$rev_sequence1\n";
					last PMR_CHECK;
				}
				# only write out to unmatched files if it's the final iteration
				elsif ($i == $n-1 and $j == @R1_fwd_prim_checks-1) { 
					print UNMATCH1 "$ID_line1\n"; print UNMATCH1 "$sequence1\n";
					print UNMATCH2 "$ID_line2\n"; print UNMATCH2 "$sequence2\n";
				}
			}
		}
	}
	close READ1; close READ2; close OUTFWD; close OUTREV; close UNMATCH1; close UNMATCH2;
}