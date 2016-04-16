#!/usr/bin/perl
# barcode_splitter.pl
use warnings;
use Getopt::Long;

# Use this script to take illumina data and split into files based on barcodes
# Takes paired end or single end, FASTA or FASTQ

my $usage = "\n\tUsage: barcode_splitter.pl [options: -h -f -o -s] -b <barcode file> -1 <read1 file> [-2 <read2 file>]\n\n";

# default options
my $help;
my $output = 'fastq';
my $directory = './';
my $offset = 0;
my $bcfile;
my $read1;
my $read2;

# "global" variables
my $file_type; 			# type of file being read (read1 & read2)
my %barcodes;  			# hash, keys: barcodes, values: sample label
my @bcs;       			# array of barcodes, taken from %barcodes keys
my $bclength;			# length of barcodes, taken from 1st element in @bcs
my %outfile_handles;	# hash, keys: "[barcode]R[12]", values: handle for outfile (OUT\dR[12])

GetOptions(
	'1=s'   => \$read1,
	'2=s'   => \$read2,
	'b=s'   => \$bcfile,
	'f=s'   => \$output,
	'o=s'   => \$directory,
	's=i'   => \$offset,
	'help!' => \$help,

) or die $usage;

die $usage unless(defined $read1  or $help);
die $usage unless(defined $bcfile or $help);
if ($directory !~ /\/$/) {$directory = "$directory\/"}

if ($help) {
	print $usage;
	print "\t\t-h: this helpful help screen.\n";
	print "\t\t-f: type of output, fasta or fastq, default fastq.\n";
	print "\t\t-o: directory in which the output file are to be written into.\n";
	print "\t\t-s: number of base pairs from the beginning of the line the barcode is allowed to start, default is 0.\n";
	print "\t\t-b: a text file containing the barcodes and their labels, see below for format.\n";
	print "\t\t-1: read 1 file.\n";
	print "\t\t-2: read 2 file (optional).\n\n";

	print "\t\t",'###### Barcode file format ######',"\n\n";
	print "\t\tThe Barcode file should have one label and one barcode on each line.\n";
	print "\t\tThe label and barcode should be separated by a tab character ", '"\t".',"\n";
	print "\t\tExample:\n\n";
	print "\t\tSmpl1\tACGTA\n";
	print "\t\tSmpl2\tCGTAC\n";
	print "\t\tSmpl3\tGTACG\n\n";
}
else {

	open CHECK, "<$read1" or die "Error: cannot open $read1\n";
	my $line = <CHECK>;
	if ($line =~ /^\@/) {
		$file_type = 'fastq';
	}
	elsif ($line =~ /^\>/) {
		$file_type = 'fasta';
		$output = 'fasta';
	}
	else {
		die "Read files must be in FASTQ or FASTA format\n";
	}
	close CHECK;

	open BCS, "<$bcfile" or die "Error: cannot open $bcfile\n";
	while (<BCS>) {
		my ($sample)  = $_ =~ /^(\S+)\t/;
		my ($barcode) = $_ =~ /\t([ACGT]+)$/;
		$barcodes{$barcode} = $sample;
	}
	close BCS;

	@bcs = keys %barcodes;
	$bclength = length $bcs[0];

	if    ($read2 and $file_type eq 'fastq' and $output eq 'fastq') { 
		parse_two_fastq($read1, $read2, 'fq');
	}
	elsif ($read2 and $file_type eq 'fastq' and $output eq 'fasta') { 
		parse_two_fastq($read1, $read2, 'fa');
	}
	elsif ($read2 and $file_type eq 'fasta') {
		parse_two_fasta($read1, $read2);
	}
	elsif ($file_type eq 'fastq' and $output eq 'fastq') {
		parse_one_fastq($read1, 'fq');
	}
	elsif ($file_type eq 'fastq' and $output eq 'fasta') {
		parse_one_fastq($read1, 'fa');
	} 
	else {
		parse_one_fasta($read1);
	}
}


sub parse_two_fastq { ###
	open R1, "<$_[0]" or die "Error: cannot open $_[0]\n";
	open R2, "<$_[1]" or die "Error: cannot open $_[1]\n";
		
	my $out = 0;
	foreach $bc (@bcs) {
		my $outfileR1 = "OUT${out}R1"; # handle for paired match from read1
		my $outfileR2 = "OUT${out}R2"; # handle for paired match from read2
		my $outfileUP = "OUT${out}UP"; # handle for unpaired match from reads 1 and 2
		$outfile_handles{"${bc}R1"} = $outfileR1;
		$outfile_handles{"${bc}R2"} = $outfileR2;
		$outfile_handles{"${bc}UP"} = $outfileUP;
 		open $outfileR1, ">${directory}$barcodes{$bc}.$_[2]_1"   or die "Error: cannot create $barcodes{$bc}.$_[2]_1\n";
		open $outfileR2, ">${directory}$barcodes{$bc}.$_[2]_2"   or die "Error: cannot create $barcodes{$bc}.$_[2]_2\n";
		open $outfileUP, ">${directory}$barcodes{$bc}.rem.$_[2]" or die "Error: cannot create $barcodes{$bc}.rem.$_[2]\n";
 		$out++;
	}

	my $l1;
	my $l2 = <R2>;
	while ($l1 = <R1>) { 
		my ($id1) = $l1 =~ /^@(.+)/;
		my ($id2) = $l2 =~ /^@(.+)/; 
			# print "ID1:\t$id1\n";
			# print "ID2:\t$id2\n";
		$l1 = <R1>;
		$l2 = <R2>;
		my ($seq1) = $l1;
		my ($seq2) = $l2;
			# print "SEQ1:\t$seq1";
			# print "SEQ2:\t$seq2";
		$l1 = <R1>;
		$l2 = <R2>;
		$l1 = <R1>;
		$l2 = <R2>;
		my ($qual1) = $l1;
		my ($qual2) = $l2;
			# print "QUAL1:\t$qual1";
			# print "QUAL2:\t$qual2";
		$l2 = <R2>;
		chomp ($seq1, $qual1, $seq2, $qual2);
		
		my (@bc_check1s, @bc_check2s);
		for (my $i = 0; $i <= $offset; $i++) {
			my $bc_check1 = substr $seq1, $i, $bclength;
			my $bc_check2 = substr $seq2, $i, $bclength;
			push @bc_check1s, $bc_check1;
			push @bc_check2s, $bc_check2;
		}

		my $bc_check1 = 'check1';
		my $bc_check2 = 'check2';
		my ($outseq1, $outseq2);
		my ($outqual1, $outqual2);
		CHK1: for (my $i = 0; $i < @bc_check1s; $i++) {
			if ($bc_check1s[$i] ~~ @bcs) {
				$bc_check1 = $bc_check1s[$i];
				$outseq1 = substr $seq1, $bclength + $i;
				$outqual1 = substr $qual1, $bclength + $i;
					# print "OUTSEQ1:\t$outseq1\nOUTQUAL1:\t$outqual1\n";
				last CHK1;
			}
		}
		CHK2: for (my $j = 0; $j < @bc_check2s; $j++) {
			if ($bc_check2s[$j] ~~ @bcs) {
				$bc_check2 = $bc_check2s[$j];
				$outseq2 = substr $seq2, $bclength + $j;
				$outqual2 = substr $qual2, $bclength + $j;
				last CHK2;
			}
		}

		if ($_[2] eq 'fq') {

			if ($bc_check1 eq $bc_check2) {
				print {$outfile_handles{"${bc_check1}R1"}} "\@$id1\n$outseq1\n\+\n$outqual1\n"; 
				print {$outfile_handles{"${bc_check2}R2"}} "\@$id2\n$outseq2\n\+\n$outqual2\n"; 
					# print "BC: ${bc_check1}R1\n";
					# print "BC: ${bc_check2}R2\n";
					# print $outfile_handles{"${bc_check1}R1"}; print "\n";
					# print $outfile_handles{"${bc_check2}R2"}; print "\n";
			} else {
				print {$outfile_handles{"${bc_check1}UP"}} "\@$id1\n$outseq1\n\+\n$outqual1\n" unless $bc_check1 eq 'check1';
				print {$outfile_handles{"${bc_check2}UP"}} "\@$id2\n$outseq2\n\+\n$outqual2\n" unless $bc_check2 eq 'check2';
			}

		} else {

			if ($bc_check1 eq $bc_check2) {
				print {$outfile_handles{"${bc_check1}R1"}} "\>$id1\n$outseq1\n";
				print {$outfile_handles{"${bc_check2}R2"}} "\>$id2\n$outseq2\n";
			} else {
				print {$outfile_handles{"${bc_check1}UP"}} "\>$id1\n$outseq1\n";
				print {$outfile_handles{"${bc_check2}UP"}} "\>$id2\n$outseq2\n";
			}
		}
	}
}

sub parse_two_fasta { ###
	open R1, "<$_[0]" or die "Error: cannot open $_[0]\n";
	open R2, "<$_[1]" or die "Error: cannot open $_[1]\n";
		
	my $out = 0;
	foreach $bc (@bcs) {
		my $outfileR1 = "OUT${out}R1"; # handle for paired match from read1
		my $outfileR2 = "OUT${out}R2"; # handle for paired match from read2
		my $outfileUP = "OUT${out}UP"; # handle for unpaired match from reads 1 and 2
		$outfile_handles{"${bc}R1"} = $outfileR1;
		$outfile_handles{"${bc}R2"} = $outfileR2;
		$outfile_handles{"${bc}UP"} = $outfileUP;
 		open $outfileR1, ">${directory}$barcodes{$bc}.fa_1"   or die "Error: cannot create $barcodes{$bc}.fa_1\n";
		open $outfileR2, ">${directory}$barcodes{$bc}.fa_2"   or die "Error: cannot create $barcodes{$bc}.fa_2\n";
		open $outfileUP, ">${directory}$barcodes{$bc}.rem.fa" or die "Error: cannot create $barcodes{$bc}.rem.fa\n";
 		$out++;
	}

	my $l1;
	my $l2 = <R2>;
	while ($l1 = <R1>) { 
		my ($id1) = $l1 =~ /^\>(.+)/;
		my ($id2) = $l2 =~ /^\>(.+)/; 
			# print "ID1:\t$id1\n";
			# print "ID2:\t$id2\n";
		$l1 = <R1>;
		$l2 = <R2>;
		my ($seq1) = $l1;
		my ($seq2) = $l2;
			# print "SEQ1:\t$seq1";
			# print "SEQ2:\t$seq2";
		$l2 = <R2>;
		chomp ($seq1, $seq2);
		
		my (@bc_check1s, @bc_check2s);
		for (my $i = 0; $i <= $offset; $i++) {
			my $bc_check1 = substr $seq1, $i, $bclength;
			my $bc_check2 = substr $seq2, $i, $bclength;
			push @bc_check1s, $bc_check1;
			push @bc_check2s, $bc_check2;
		}

		my $bc_check1 = 'check1';
		my $bc_check2 = 'check2';
		my ($outseq1, $outseq2);
		CHK1: for (my $i = 0; $i < @bc_check1s; $i++) {
			if ($bc_check1s[$i] ~~ @bcs) {
				$bc_check1 = $bc_check1s[$i];
				$outseq1 = substr $seq1, $bclength + $i;
				last CHK1;
			}
		}
		CHK2: for (my $j = 0; $j < @bc_check2s; $j++) {
			if ($bc_check2s[$j] ~~ @bcs) {
				$bc_check2 = $bc_check2s[$j];
				$outseq2 = substr $seq2, $bclength + $j;
				last CHK2;
			}
		}

		if ($bc_check1 eq $bc_check2) {
			print {$outfile_handles{"${bc_check1}R1"}} "\>$id1\n$outseq1\n";
			print {$outfile_handles{"${bc_check2}R2"}} "\>$id2\n$outseq2\n";
		} else {
			print {$outfile_handles{"${bc_check1}UP"}} "\>$id1\n$outseq1\n" unless $bc_check1 eq 'check1';
			print {$outfile_handles{"${bc_check2}UP"}} "\>$id2\n$outseq2\n" unless $bc_check2 eq 'check2';
		}
	}
}

sub parse_one_fastq {	###
	open R1, "<$_[0]" or die "Error: cannot open $_[0]\n";
		
	my $out = 0;
	foreach $bc (@bcs) {
		my $outfileR1 = "OUT${out}R1";
		$outfile_handles{"${bc}R1"} = $outfileR1;
 		open $outfileR1, ">${directory}$barcodes{$bc}.$_[1]" or die "Error: cannot create $barcodes{$bc}.$_[1]\n";
 		$out++;
	}

	my $l1;
	while ($l1 = <R1>) { 
		my ($id1) = $l1 =~ /^@(.+)/; 
			# print "ID1:\t$id1\n";
		$l1 = <R1>;
		my ($seq1) = $l1;
			# print "SEQ1:\t$seq1";
		$l1 = <R1>;
		$l1 = <R1>;
		my ($qual1) = $l1;
			# print "QUAL1:\t$qual1";
		chomp ($seq1, $qual1);
		
		my @bc_check1s;
		for (my $i = 0; $i <= $offset; $i++) {
			my $bc_check1 = substr $seq1, $i, $bclength;
			push @bc_check1s, $bc_check1;
		}

		PRINT: for (my $i = 0; $i < @bc_check1s; $i++) {
			
			if ($bc_check1s[$i] ~~ @bcs) {
				my $outseq1 = substr $seq1, $bclength + $i;
				my $outqual1 = substr $qual1, $bclength + $i;

				if ($_[1] eq 'fq') {
					print {$outfile_handles{"$bc_check1s[$i]R1"}} "\@$id1\n$outseq1\n\+\n$outqual1\n";
				} else {
					print {$outfile_handles{"$bc_check1s[$i]R1"}} "\>$id1\n$outseq1\n";
				}

				last PRINT;
			}

		}
	}
}

sub parse_one_fasta { ###
	open R1, "<@_" or die "Error: cannot open @_\n";
		
	my $out = 0;
	foreach $bc (@bcs) {
		my $outfileR1 = "OUT${out}R1";
		$outfile_handles{"${bc}R1"} = $outfileR1;
 		open $outfileR1, ">${directory}$barcodes{$bc}.fa" or die "Error: cannot create $barcodes{$bc}.fa\n";
 		$out++;
	}

	my $l1;
	while ($l1 = <R1>) { 
		my ($id1) = $l1 =~ /^\>(.+)/; 
			# print "ID1:\t$id1\n";
		$l1 = <R1>;
		my ($seq1) = $l1;
			# print "SEQ1:\t$seq1";
		$l1 = <R1>;
		$l1 = <R1>;
		my ($qual1) = $l1;
			# print "QUAL1:\t$qual1";
		chomp ($seq1, $qual1);
		
		my @bc_check1s;
		for (my $i = 0; $i <= $offset; $i++) {
			my $bc_check1 = substr $seq1, $i, $bclength;
			push @bc_check1s, $bc_check1;
		}

		PRINT: for (my $i = 0; $i < @bc_check1s; $i++) {
			
			if ($bc_check1s[$i] ~~ @bcs) {
				my $outseq1 = substr $seq1, $bclength + $i;
				my $outqual1 = substr $qual1, $bclength + $i;
				print {$outfile_handles{"$bc_check1s[$i]R1"}} "\>$id1\n$outseq1\n";
				last PRINT;
			}

		}
	}
}














