#!/usr/bin/perl
# seq_stats.pl
use strict; use warnings;
use Getopt::Long;

# Use this script on either FASTA or FASTQ files to get basic stats such as number of sequences, min, max, median, and mean seq length.

my $usage = "\n\tseq_stats.pl [-h -d -o <path> -b <\"pattern\">] -i <file>\n\n";

# defaults
my $help;
my $dist;
my $outdir = "./";
my $batch;
my $infile;

GetOptions (
	'help!' => \$help,
	'dist!' => \$dist,
	'o=s'   => \$outdir,
	'b=s'   => \$batch,
	'i=s'   => \$infile,
) or die $usage;

die $usage unless $help or $infile or $batch;

if ($outdir !~ /\/$/) {$outdir="$outdir\/"}

if ($help) {
	print $usage;
	print "\t\t-h: this help screen\n";
	print "\t\t-d: output a distribution of lengths file?\n";
	print "\t\t-o: output directory, default is current (./)\n";
	print "\t\t-b: run script on batch of files, give pattern to match in quotes\n";
	print "\t\t-i: the input file for running script on single sequence file\n";
}

else {
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$year = $year + 1900;
	$mon = $mon + 1;
	if ($mon < 10) {$mon = "0$mon"}
	if ($mday < 10) {$mday = "0$mday"}
	if ($hour < 10) {$hour = "0$hour"}
	if ($min < 10) {$min = "0$min"}

	open OUT, ">${outdir}seq_stats_$year\_$mon\_$mday\_$hour\_$min.txt" or die "\n\tError: cannot create ${outdir}seq_stats_$year\_$mon\_$mday\_$hour\_$min.txt";

	if ($batch) {
		my @infiles = glob $batch;

		foreach my $infile (@infiles) {
			$|++; print "$infile ... ";
			my ($filename) = $infile =~ /(.+)\.fa*s*t*[aq]*$/;

			my $seqCount = 0;
			my $sumLengths = 0;
			my @seqLengths;
			my $fileType;
			my $minLength;
			my $maxLength;
			my $medLength;
			my $meanLength;

			open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";

			my $line1 = <INF>;
			if    ($line1 =~ /^\>/) {$fileType = "A"}
			elsif ($line1 =~ /^\@/) {$fileType = "Q"}
			else {die "\n\tError: $infile is not FASTA or FASTQ\n\n"}
			close INF;

			open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";
			open DST, ">${outdir}filename.seq_lens.txt" or die "\n\tError: cannot create ${outdir}filename.seq_lens.txt\n\n";

			while (<INF>){
				if ($fileType eq "A") {
					if ($_ !~ /^\>/) {
						my $seq = $_;
						chomp $seq;
						my $seqLength = length $seq;
						push @seqLengths, $seqLength;
						$seqCount++;
						print DST "$seqLength\n";
					}
				}

				else {
					if ($_ =~ /^\@HWI-/) {
						my $seq = <INF>;
						chomp $seq;
						my $seqLength = length $seq;
						push @seqLengths, $seqLength;
						$seqCount++;
						print DST "$seqLength\n";
					}
				}
			}

			close INF; close DST;

			my @sortedLengths = sort {$a <=> $b} @seqLengths;
			$minLength = $sortedLengths[0];
			$maxLength = $sortedLengths[-1];

			if (@sortedLengths % 2 == 0) {
				my $medIndex1 = (@sortedLengths / 2) - 1;
				my $medIndex2 = (@sortedLengths / 2);
				$medLength = ($sortedLengths[$medIndex1] + $sortedLengths[$medIndex2]) / 2;
			}
			else {
				my $medIndex = (@sortedLengths - 1) / 2;
				$medLength = $sortedLengths[$medIndex];
			}

			foreach my $seqLength (@sortedLengths) {
				$sumLengths = $sumLengths + $seqLength;
			}
			$meanLength = $sumLengths / $seqCount;
			print  OUT "$infile:\n";
			printf OUT "\tnumber of seqs:\t%d\n", $seqCount;
			printf OUT "\tmin seq length:\t%d\n", $minLength;
			printf OUT "\tmax seq length:\t%d\n", $maxLength;
			printf OUT "\tmed seq length:\t%.1f\n", $medLength;
			printf OUT "\tavg seq length:\t%.2f\n", $meanLength;

			$|++; print "done\n";
		}
	}

	else {
		$|++; print "$infile ... ";

		my ($filename) = $infile =~ /(.+)\.fa*s*t*[aq]*$/;

		my $seqCount = 0;
		my $sumLengths = 0;
		my @seqLengths;
		my $fileType;
		my $minLength;
		my $maxLength;
		my $medLength;
		my $meanLength;

		open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";

		my $line1 = <INF>;

		if    ($line1 =~ /^\>/) {$fileType = "A"}
		elsif ($line1 =~ /^\@/) {$fileType = "Q"}
		else {die "\n\tError: $infile is not FASTA or FASTQ\n\n"}
		close INF;

		open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";
		open DST, ">${outdir}filename.seq_lens.txt" or die "\n\tError: cannot create ${outdir}filename.seq_lens.txt\n\n";

		while (<INF>){
			if ($fileType eq "A") {
				if ($_ !~ /^\>/) {
					my $seq = $_;
					chomp $seq;
					my $seqLength = length $seq;
					push @seqLengths, $seqLength;
					$seqCount++;
					print DST "$seqLength\n";
				}
			}

			else {
				if ($_ =~ /^\@HWI-/) {
					my $seq = <INF>;
					chomp $seq;
					my $seqLength = length $seq;
					push @seqLengths, $seqLength;
					$seqCount++;
					print DST "$seqLength\n";
				}
			}
		}
		close INF; close DST;

		my @sortedLengths = sort {$a <=> $b} @seqLengths;
		$minLength = $sortedLengths[0];
		# print "min: $minLength\n";
		$maxLength = $sortedLengths[-1];
		# print "max: $maxLength\n";

		if (@sortedLengths % 2 == 0) {
			my $medIndex1 = (@sortedLengths / 2) - 1;
			my $medIndex2 = (@sortedLengths / 2);
			$medLength = ($sortedLengths[$medIndex1] + $sortedLengths[$medIndex2]) / 2;
			# print "med: $medLength\n";
		}
		else {
			my $medIndex = (@sortedLengths - 1) / 2;
			$medLength = $sortedLengths[$medIndex];
			# print "med: $medLength\n";
		}

		foreach my $seqLength (@sortedLengths) {
			$sumLengths = $sumLengths + $seqLength;
		}
		# print "sum: $sumLengths\n";
		$meanLength = $sumLengths / $seqCount;
		# print "mean: $meanLength\n";

		print  OUT "$infile:\n";
		printf OUT "\tnumber of seqs:\t%d\n", $seqCount;
		printf OUT "\tmin seq length:\t%d\n", $minLength;
		printf OUT "\tmax seq length:\t%d\n", $maxLength;
		printf OUT "\tmed seq length:\t%.1f\n", $medLength;
		printf OUT "\tavg seq length:\t%.2f\n", $meanLength;
		
		$|++; print "done\n";
	}
close OUT;

}