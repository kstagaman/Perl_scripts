#!/usr/bin/perl
# order_and_translate_rev_reads.pl
use strict; use warnings;

die "usage: order_and_translate_rev_reads.pl <IgM_primer_seqs_file.txt> <IgZ2_primer_seqs_file.txt>\n" unless @ARGV == 2;

my @IgMread1s = `ls IgM*.trunc.fa_1`;	# put all read 1 igm seq files in an array
my @IgMread2s = `ls IgM*.trunc.fa_2`;	# same for igm read 2 files
my @IgZ2read1s = `ls IgZ2*.trunc.fa_1`;	# and igz2 read 1s
my @IgZ2read2s = `ls IgZ2*.trunc.fa_2`;	# and igz2 read 2s
chomp (@IgMread1s, @IgMread2s, @IgZ2read1s, @IgZ2read2s);

for (my $i = 0; $i < @IgMread1s; $i++) {	# pair the 1st and 2nd read files for each igm sample so they can be sent to the order_amplicons subroutine
	my @IgMreads = ();
	$IgMreads[0] = $IgMread1s[$i];
	$IgMreads[1] = $IgMread2s[$i];
	$IgMreads[2] = $ARGV[0];
	order_amplicons(@IgMreads);
#	my $IgMreadscount = $i + 1;
#	print "$IgMreadscount IgM file pairs completed\n";
}

for (my $i = 0; $i < @IgZ2read1s; $i++) {	# pair the 1st and 2nd read files for each igz2 sample so they can be sent to the order_amplicons subroutine
	my @IgZ2reads = ();
	$IgZ2reads[0] = $IgZ2read1s[$i];
	$IgZ2reads[1] = $IgZ2read2s[$i];
	$IgZ2reads[2] = $ARGV[1];
	order_amplicons(@IgZ2reads);
#	my $IgZ2readscount = $i + 1;
#	print "$IgZ2readscount IgZ2 file pairs completed\n";
}

#my @IgMrevreads = `ls IgM*.rev.fa`;	# put all igm reverse reads from order_amplicons subroutine into an array
#my @IgZ2revreads = `ls IgZ2*.rev.fa`; # same for igz2 reverse reads
#chomp (@IgMrevreads, @IgZ2revreads);

#for (my $i = 0; $i < @IgMrevreads; $i++) { 
#	my ($IgMrevread) = $IgMrevreads[$i];
#	longest_Ig_ORF($IgMrevread);	# send each igm reverse read file to the longest_Ig_ORF subroutine to get translation of each sequence
#	my $IgMrevscount = $i + 1;
#	print "$IgMrevscount IgM reverse reads completed\n";
#}

#for (my $i = 0; $i < @IgZ2revreads; $i++) {
#	my ($IgZ2revread) = $IgZ2revreads[$i];
#	longest_Ig_ORF($IgZ2revread);	# send each igz2 reverse read file to the longest_Ig_ORF subroutine to get translation of each sequence
#	my $IgZ2revscount = $i + 1;
#	print "$IgZ2revscount IgZ2 reverse reads completed\n";
#}

system("mkdir Ordered_trunc_amplicon_files"); # make a directory to hold all output files from the order_amplicons subroutine
system("mv *.for.fa *.rev.fa *.UnmatchedRead1.fa *.UnmatchedRead2.fa Ordered_trunc_amplicon_files");
#system("mkdir Translated_rev_reads");	# make a directory to hold all of the translated reverse reads
#system("mv *translations* Translated_rev_reads");


sub order_amplicons {
 	my ($output_prefix) = $_[0] =~ /(Ig[MZ]2*_[ABCD]_\d{2}\.*\d*)\.\w/;

	my $n = 5; # set the number of bases from the beginning of the sequence in which the primer can start

	open READ1, "<$_[0]" or die "Error: Cannot open $_[0]\n";
	open READ2, "<$_[1]" or die "Error: Cannot open $_[1]\n";
	open PRIMERS, "<$_[2]" or die "Error: Cannot open $_[2]\n";
	open OUTFOR, ">$output_prefix.for.fa";
	open OUTREV, ">$output_prefix.rev.fa";
	open UNMATCH1, ">$output_prefix.UnmatchedRead1.fa";
	open UNMATCH2, ">$output_prefix.UnmatchedRead2.fa";

	my ($fwd_primer) = ();
	my ($rev_primer) = ();
	
	while (my $line = <PRIMERS>) {
		if ($line =~ m/^\>f/i) {
			$line = <PRIMERS>;
			($fwd_primer) = $line =~ m/(\w+)/;	# get foward primer sequence
		}
		if ($line =~ m/^\>r/i) {
			$line = <PRIMERS>;
			($rev_primer) = $line =~ m/(\w+)/;	# get reverse primer sequence
		}
	}
	close PRIMERS;
	
	while (<READ1>) {
		my $ID_line1 = $_;			# get line ID for first read
		my $sequence1 = <READ1>;	# get read1 sequence from next line
		my $ID_line2 = <READ2>;		# get line ID for second read
		my $sequence2 = <READ2>;	# get read2 sequence from next line
		chomp ($ID_line1, $sequence1, $ID_line2, $sequence2);
		
		for (my $i = 0; $i < $n; $i++) {
			# extracting possible primer sequences to compare starting from beginning and 	going in specified number of bases ($n)
			my $R1_for_prim_check = substr($sequence1, $i, length($fwd_primer));
			my $R1_rev_prim_check = substr($sequence1, $i, length($rev_primer));	
			my $R2_for_prim_check = substr($sequence2, $i, length($fwd_primer)); 
			my $R2_rev_prim_check = substr($sequence2, $i, length($rev_primer));
		
			# if forward primer in read1 and reverse primer in read2:
			if ($R1_for_prim_check =~ m/$fwd_primer/i and $R2_rev_prim_check =~ m/$rev_primer/i) {
				print OUTFOR "$ID_line1\n"; print OUTFOR "$sequence1\n";
				
				my $rev_sequence2 = reverse $sequence2;	# reverse the reverse primer sequence so that it is in the correct orientation
				$rev_sequence2 =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/; # makes complement
			
				print OUTREV "$ID_line2\n"; print OUTREV "$rev_sequence2\n";
			}
			# if REVERSE primer in read1 and FORWARD in read2;
			elsif ($R1_rev_prim_check =~ m/$rev_primer/i and $R2_for_prim_check =~ m/$fwd_primer/i)	{
				print OUTFOR "$ID_line2\n"; print OUTFOR "$sequence2\n";
				
				my $rev_sequence1 = reverse $sequence1;
				$rev_sequence1 =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/;
				
				print OUTREV "$ID_line1\n"; print OUTREV "$rev_sequence1\n";
			}
			# only write out to unmatched files if it's the final iteration
			elsif ($i == $n-1) { 
				print UNMATCH1 "$ID_line1\n"; print UNMATCH1 "$sequence1\n";
				print UNMATCH2 "$ID_line2\n"; print UNMATCH2 "$sequence2\n";
			}
		}
	}
	close READ1; close READ2; close OUTFOR; close OUTREV; close UNMATCH1; close UNMATCH2;
}

sub longest_Ig_ORF {
	my ($file) = @_;
	open(IN, "<$file") or die "Error: cannot open file\n";
	my ($tag) = $file =~ /(.+)\.fa/;
	open(OUT, ">$tag\_translations\.fa");
	
	my @aaseqs;
	my $line_count = 0;
	my @ids;
	
	while (<IN>) {
		my @seqs;
		if ($_ =~ /^\>/) {		# get fasta id tag for each nt seq
			my $id = $_; 
			chomp $id;
			push(@ids, $id);
		}
		
		else {
			$seqs[0] = $_;	# start with full sequence, this will be traslated from reading frame 1
			chomp @seqs;
			$seqs[1] = substr($seqs[0], 1, length($seqs[0]));	# get seq minus 1st nt for reading frame 2
			$seqs[2] = substr($seqs[0], 2, length($seqs[0]));	# get seq minus first 2 nt for reading frame 3
		
			foreach my $seq (@seqs) {
				my $aaseq = translate($seq);	# translate sequence in 3 reading frames
				if (@aaseqs == 0) {			
					push (@aaseqs, $aaseq) unless $aaseq =~ /\*/;
					print OUT "$ids[$line_count]\n";  # print seq id to out file
					print OUT "$aaseq\n";	# if this is the first aa seq without a stop codon, write to the out file
				}
				elsif ($aaseq !~ /\*/ and $aaseqs[0] !~ /$aaseq/ ) {
					splice (@aaseqs, 0, 1, $aaseq);
					print OUT "$ids[$line_count]\n";  # print seq id to out file
					print OUT "$aaseq\n";	# if the sequence has no stop codon, and doesn't match the prev seq, print to out file
				}
			}
			$line_count++;
			if ($line_count % 1000 == 0) {print "\t$line_count lines completed\n"}
		}
	}

	close IN; close OUT;
}

sub translate {
	my ($seq) = @_;
	my @aas;
	my $aa;
	for (my $i = 0; $i < length($seq) - 2; $i +=3) {
		my $codon = substr($seq, $i, 3);
		if    ($codon =~ m/[TU][TU][TUCY]/)             {$aa = 'F';}
		elsif ($codon =~ m/[TU][TU][AGR]/)              {$aa = 'L';}
		elsif ($codon =~ m/C[TU][ACGTUNMRWSYKVHDB]/)    {$aa = 'L';}
		elsif ($codon =~ m/A[TU][TUCAMWYH]/)            {$aa = 'I';}
		elsif ($codon =~ m/A[TU]G/)                     {$aa = 'M';}
		elsif ($codon =~ m/G[TU][ACGTUNMRWSYKVHDB]/)    {$aa = 'V';}
		elsif ($codon =~ m/[TU]C[ACGTUNMRWSYKVHDB]/)    {$aa = 'S';}
		elsif ($codon =~ m/AG[TUCY]/)	         	    {$aa = 'S';}
		elsif ($codon =~ m/CC[ACGTUNMRWSYKVHDB]/) 		{$aa = 'P';}
		elsif ($codon =~ m/AC[ACGTUNMRWSYKVHDB]/) 		{$aa = 'T';}
		elsif ($codon =~ m/GC[ACGTUNMRWSYKVHDB]/) 		{$aa = 'A';}
		elsif ($codon =~ m/[TU]A[TUCY]/)			 	{$aa = 'Y';}
		elsif ($codon =~ m/[TU]A[AGR]/)				 	{$aa = '*';}
		elsif ($codon =~ m/CA[TUCY]/)			 		{$aa = 'H';}
		elsif ($codon =~ m/CA[AGR]/)		     		{$aa = 'Q';}
		elsif ($codon =~ m/AA[TUCY]/)				 	{$aa = 'N';}
		elsif ($codon =~ m/AA[AGR]/)			 		{$aa = 'K';}
		elsif ($codon =~ m/GA[TUCY]/)			 		{$aa = 'D';}
		elsif ($codon =~ m/GA[AGR]/)			 		{$aa = 'E';}
		elsif ($codon =~ m/[TU]G[TUCY]/)			 	{$aa = 'C';}
		elsif ($codon =~ m/[TU]GA/)				 		{$aa = '*';}
		elsif ($codon =~ m/[TU]GG/)				 		{$aa = 'W';}
		elsif ($codon =~ m/CG[ACGTUNMRWSYKVHDB]/) 		{$aa = 'R';}
		elsif ($codon =~ m/AG[TUCY]/)			 		{$aa = 'S';}
		elsif ($codon =~ m/AG[AGR]/)			 		{$aa = 'R';}
		elsif ($codon =~ m/GG[ACGTUNMRWSYKVHDB]/) 		{$aa = 'G';}
		else 										 	{$aa = 'X';}
	    push(@aas, $aa);
	}
	my $aaseq = join("", @aas);
	return $aaseq;
}

 