#!/usr/bin/perl
# longest_ORF.pl
use strict; use warnings;

die "usage: longest_ORF.pl <dna sequence/fasta file>\n" unless @ARGV == 1;

print "\n\tLook for start codons in translation?(yes/no) ";
$a = <STDIN>;
chomp $a;
until ($a eq "yes" or $a eq "no") {
	print "Yes or no, please. ";
	$a = <STDIN>;
	chomp $a;
}

print "\tPrint all unique translations?(yes/no) ";
$b = <STDIN>;
chomp $b;
until ($b eq "yes" or $b eq "no") {
	print "Yes or no, please. ";
	$b = <STDIN>;
	chomp $b;
}

print "\n";

if ($ARGV[0] =~ /\.[fa|fasta]/) {
	my ($name) = $ARGV[0] =~ /(\S)\.fa/;
	open NT, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
	if    ($a eq "yes" and $b eq "yes") {open AA, ">$name.all_trans_start_codon.fa" or die "Error: cannot create $name.all_trans_start_codon.fa\n"}
	elsif ($a eq "no" and $b eq "yes")  {open AA, ">$name.all_trans_no_start_codon.fa" or die "Error: cannot create $name.all_trans_no_start_codon.fa\n"}
	elsif ($a eq "yes" and $b eq "no")  {open AA, ">$name.best_trans_start_codon.fa" or die "Error: cannot create $name.best_trans_start_codon.fa\n"}
	elsif ($a eq "no" and $b eq "no")  {open AA, ">$name.best_trans_no_start_codon.fa" or die "Error: cannot create $name.best_trans_no_start_codon.fa\n"}

	while (<NT>) {
		if ($_ =~ /^\>/) {
			my ($id) = $_;
			chomp $id;
			$_ = <NT>;
			my ($seq) = $_ =~ /([ACGTN]+)/i;
			($seq) = uc($seq);
			
			my @translations = translate($seq);
			my @orfs;
			
			for (my $i = 0; $i < @translations; $i++) {
				my $aaseq = $translations[$i];
				my $j = 0;
				
				for ($j = 0; $j < length($aaseq); $j++) {
					my $aa = substr($aaseq, $j, 1);
					if ($aa =~ /_/) {last}
				}
				
				my $orf = substr($aaseq, 0, $j + 1);
				push @orfs, $orf;
			}
			
			my %orflengths;
			
			foreach my $orf (@orfs) {
				$orflengths{$orf} = length($orf);
			}
			
			my @longests = sort {$orflengths{$b} <=> $orflengths{$a}} keys %orflengths;
			
			if ($b eq "no") {
					print AA "$id\|$orflengths{$longests[0]}aa\n$longests[0]\n";
			}
			else {
				my @printeds;
				print AA "$id\n";
				print AA "$longests[0]\n";
				push @printeds, $longests[0];
				for (my $i = 1; $i < @longests; $i++) {
						unless(grep $_ =~ /$longests[$i]/, @printeds) {
							print AA "$longests[$i]\n" ;
							push @printeds, $longests[$i];
						}
				}
			}
		}
	}
}
else {
	my ($seq) = @ARGV;
	($seq) = uc($seq);
	my @translations = translate($seq);
	my @orfs;

	for (my $i = 0; $i < @translations; $i++) {		# look at each translation separately
		my $aaseq = $translations[$i];
		my $j = 0;
	
		for ($j = 0; $j < length($aaseq); $j++) {	# look along the length of the sequece for
			my $aa = substr($aaseq, $j, 1);			# a stop codon
			if ($aa =~ /_/) {last}
		}
		
		my $orf = substr($aaseq, 0, $j + 1);		# put ORFs that begin with a start codon and end
		push(@orfs, $orf);							# with a stop codon into an array
	}
	
	my %orflengths = ();
	foreach my $orf (@orfs) {						# put each ORF and its length into a hash
		$orflengths{$orf} = length($orf)-1;
	}
	my @longest = sort {$orflengths{$b} <=> $orflengths{$a}} keys %orflengths;  # sort ORFs by length
	
	print "\nLongest ORF:\t$longest[0]\n\nLength:\t\t$orflengths{$longest[0]} amino acids\n\n";
}











sub translate {
	my ($seq) = @_;
	my @orfs;
	my @translations;
	
	if ($a eq "yes") {
		for (my $i = 0; $i < length($seq) - 2; $i++) {
			my $subseq = substr($seq, $i, 3);	# look at the sequence in groups of 3
		
			if ($subseq =~ /A[TU]G/) {		# find all start codons and put the sequence into the ORF array
				my $orf = substr($seq, $i, length($seq));
				push @orfs, $orf ;
			}
			
		}
	}
	elsif ($a eq "no") {
		for (my $i = 0; $i < length($seq) - 2; $i++) {
			my $orf = substr($seq, $i, length $seq);	# look at the sequence in groups of 3
			push @orfs, $orf;
		}
	}
	
	die "\nError: translate(): no start codon in sequence $seq\n\n" unless @orfs >= 1;
		
	for (my $i = 0; $i < @orfs; $i++) {  # look at each ORF individually
		my $orf = $orfs[$i];
		my $aa;
		my @aaseqs;
		
		for (my $j = 0; $j < length($orf) - 2; $j +=3) {  # translate each codon 
			my $orfsubseq = substr($orf, $j, 3);
			if    ($orfsubseq =~ m/[TU][TU][TUCY]/)             {$aa = 'F';}
			elsif ($orfsubseq =~ m/[TU][TU][AGR]/)              {$aa = 'L';}
			elsif ($orfsubseq =~ m/C[TU][ACGTUNMRWSYKVHDB]/)    {$aa = 'L';}
			elsif ($orfsubseq =~ m/A[TU][TUCAMWYH]/)            {$aa = 'I';}
			elsif ($orfsubseq =~ m/A[TU]G/)                     {$aa = 'M';}
			elsif ($orfsubseq =~ m/G[TU][ACGTUNMRWSYKVHDB]/)    {$aa = 'V';}
			elsif ($orfsubseq =~ m/[TU]C[ACGTUNMRWSYKVHDB]/)    {$aa = 'S';}
			elsif ($orfsubseq =~ m/AG[TUCY]/)	         	    {$aa = 'S';}
			elsif ($orfsubseq =~ m/CC[ACGTUNMRWSYKVHDB]/) 		{$aa = 'P';}
			elsif ($orfsubseq =~ m/AC[ACGTUNMRWSYKVHDB]/) 		{$aa = 'T';}
			elsif ($orfsubseq =~ m/GC[ACGTUNMRWSYKVHDB]/) 		{$aa = 'A';}
			elsif ($orfsubseq =~ m/[TU]A[TUCY]/)			 	{$aa = 'Y';}
			elsif ($orfsubseq =~ m/[TU]A[AGR]/)				 	{$aa = '_';}
			elsif ($orfsubseq =~ m/CA[TUCY]/)			 		{$aa = 'H';}
			elsif ($orfsubseq =~ m/CA[AGR]/)		     		{$aa = 'Q';}
			elsif ($orfsubseq =~ m/AA[TUCY]/)				 	{$aa = 'N';}
			elsif ($orfsubseq =~ m/AA[AGR]/)			 		{$aa = 'K';}
			elsif ($orfsubseq =~ m/GA[TUCY]/)			 		{$aa = 'D';}
			elsif ($orfsubseq =~ m/GA[AGR]/)			 		{$aa = 'E';}
			elsif ($orfsubseq =~ m/[TU]G[TUCY]/)			 	{$aa = 'C';}
			elsif ($orfsubseq =~ m/[TU]GA/)				 		{$aa = '_';}
			elsif ($orfsubseq =~ m/[TU]GG/)				 		{$aa = 'W';}
			elsif ($orfsubseq =~ m/CG[ACGTUNMRWSYKVHDB]/) 		{$aa = 'R';}
			elsif ($orfsubseq =~ m/AG[TUCY]/)			 		{$aa = 'S';}
			elsif ($orfsubseq =~ m/AG[AGR]/)			 		{$aa = 'R';}
			elsif ($orfsubseq =~ m/GG[ACGTUNMRWSYKVHDB]/) 		{$aa = 'G';}
			else 										 		{$aa = 'X';}
		    push @aaseqs, $aa ;
		}
		
		my $aaseq = join "", @aaseqs ;  # make a new amino acid sequence
		push @translations, $aaseq ;
	}
	
	return(@translations);		
}		
