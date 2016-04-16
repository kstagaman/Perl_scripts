#!/usr/bin/perl
# match_miseq_bcs2smpls.pl
use strict; use warnings;
use Getopt::Long;

# when sequences are returned from the UIdaho MiSeq, the sequeneces are in the R1 and R4 files, while their respective
# barcodes are in R2 and R3. Before using this script, use fastx_barcode_splitter.pl (fastx_toolkit) to split R2 and R3
# into their ID'd p7 and p5 files. Also run a joining program on the sequence reads so that you only have one file of 
# sequences. Then, run this script to identify the joined sequences by their barcodes as specific samples. This script
# requires all sequence-containing files to be in FASTA format.

my $usage = "\n\tmatch_miseq_bcs2smpls.pl [-h -o] -5 <\"p5 file pattern\"> -7 <\"p7 file pattern\"> -s <sample id file> -i <sequence file>\n\n";

# defaults
my $help;
my $outdir = './';
my $p5regex;
my $p7regex;
my $smplIDfile;
my $seqFile;

GetOptions(
	'help!' => \$help,
	'o=s'   => \$outdir,
	'5=s'   => \$p5regex,
	'7=s'   => \$p7regex,
	's=s'   => \$smplIDfile,
	'i=s'   => \$seqFile,
) or die $usage;

die $usage unless $help or ($p5regex and $p7regex and $smplIDfile and $seqFile);
if ($outdir !~/\/$/) {$outdir = "$outdir\/"}

if ($help) {
	print $usage;
	print "\t\th: this helpful help screen\n";
	print "\t\to: output director, default is current\n";
	print "\t\t5: a regex pattern that matches files containing barcodes matching p5 barcodes, must include directory\n";
	print "\t\t7: a regex pattern that matches files containing barcodes matching p7 barcodes, must include directory\n";
	print "\t\ts: a file containing the combinations of p5 and p7 barcodes that are used for each sample, see format below\n";
	print "\t\ti: input file of joined sequences to identify\n\n";
	print "\t\tThe format for the sample id file is as follows:\n";
	print "\t\t\tsample_name\tp7_xx\tp5_xx\n\n";
	print "\t\tThe first two lines of a sample id file might look like this:\n";
	print "\t\t\tsample_1\tp7_01\tp5_01\n";
	print "\t\t\tsample_2\tp7_02\tp5_01\n\n";
}
else {
	# global variables
	my ($outname) = $seqFile =~ /\.*\/*(\S+)\.fas*t*a*$/;
	# print "$outname\n";
	my @p5_files = glob $p5regex;
	my @p7_files = glob $p7regex;
	my %smplsBy_p7p5;
	my %p5_headers;
	my %p5_sequenced_bcs;
	my %p7_headers;
	my %p7_sequenced_bcs;
	my %smplCounts;
	my %sequenced_smpl_bcs;

	open IDS, "<$smplIDfile" or die "\n\tError: cannot open $smplIDfile\n\n";
	while (<IDS>) {
		my ($smpl) = /^(\w+)\t/;
		my ($p7)   = /([pP]7_\d{2})/;
		# print "p7: $p7\n";
		my ($p5)   = /([pP]5_\d{2})/;
		# print "p5: $p5\n";
		my $p7p5 = "$p7$p5";
		$smplsBy_p7p5{$p7p5}  = $smpl;
	}
	close IDS;
	$|++;
	print "\tSamples and IDS collected\n";

	foreach my $p5_file (@p5_files) {
		my ($p5) = $p5_file =~ /(p5_\d{2})/;

		open P5, "<$p5_file" or die "\n\tError: cannot open $p5_file\n\n";
		while (<P5>) {
			if ($_ =~ /^\>/) {
				my ($header) = /^(\S+)\s/;
				# print "p5_header: $header\n";
				my ($bc_seq) = <P5> =~ /^([ACGTN]{8,10})/;
				# print "p5_bc_seq: $bc_seq\n";

				$p5_headers{$header} = $p5;
				$p5_sequenced_bcs{$header} = $bc_seq;
			}
		}
		close P5;
		# my @test = keys %p5_headers;
		# print "all_p5_headers: @test\n";
		$|++;
		print "\t$p5 ids and headers collected\n";
	}

	foreach my $p7_file (@p7_files) {
		my ($p7) = $p7_file =~ /(p7_\d{2})/;

		open P7, "<$p7_file" or die "\n\tError: cannot open $p7_file\n\n";
		while (<P7>) {
			if ($_ =~ /^\>/) {
				my ($header) = /^(\S+)\s/;
				my ($bc_seq) = <P7> =~ /^([ACGTN]{8,10})/;
				# print "p7_bc_seq: $bc_seq\n";

				$p7_headers{$header} = $p7;
				$p7_sequenced_bcs{$header} = $bc_seq;
			}
		}
		close P7;
		$|++;
		print "\t$p7 ids and headers collected\n";
	}

	open SEQ, "<$seqFile" or die "\n\tError: cannot open $seqFile\n\n";
	open OUT, ">${outdir}$outname.smpls.fa" or die "\n\tError: cannot create ${outdir}$outname.smpls.fa\n\n";
	open BAD, ">${outdir}$outname.bad_headers.txt" or die "\n\tError: cannot create ${outdir}$outname.bad_headers.txt\n\n";
	print BAD "header_matched_no_p5\theader_matched_no_p7\n";
	$|++;
	print "\tWorking on sequences...\n";
	while (<SEQ>) {

		if ($_ =~ /^\>/) {
			my ($header) = /^(\S+)\s/;
			my $seq = <SEQ>;
			chomp $seq;

			my $p5 = $p5_headers{$header};
			my $p5_seq = $p5_sequenced_bcs{$header};
			my $p7 = $p7_headers{$header};
			my $p7_seq = $p7_sequenced_bcs{$header};
			# print "p5: $p5\n";
			# print "p7: $p7\n";

			if (!$p5 and !$p7) {
				$p5 = "NA";
				$p7 = "NA";
				print BAD "$header\t$header\n";
			}
			elsif (!$p5){
				$p5 = "NA";
				print BAD "$header\tNA\n";
			}
			elsif (!$p7){
				$p7 = "NA";
				print BAD "NA\t$header\n";
			}
 
			if (!$p5_seq) {$p5_seq = "NA"}
			if (!$p7_seq) {$p7_seq = "NA"}

			my $p7p5 = "$p7$p5";

			my $smpl;
			if ($p7p5 =~ /NA/) {
				$smpl = "$p7-$p5";
			} else {
				$smpl = $smplsBy_p7p5{$p7p5};
			}
			if (!$smpl) {$smpl = "Invalid_p7-p5_combo:$p7-$p5"}
			print OUT "$header:$smpl:$p7-$p5:$p7_seq-$p5_seq\n$seq\n";
			$smplCounts{$smpl}++;
			my $bc_pair = "$p7_seq-$p5_seq";
			# print "bc_pair: $bc_pair\n";
			push @{$sequenced_smpl_bcs{$smpl}}, $bc_pair;
		}
	}
	close SEQ; close OUT;

	open SCT, ">${outdir}$outname.smplCts.txt" or die "\n\tError: cannot create ${outdir}$outname.smplCts.txt\n\n";
	print SCT "sample\ttotal_count\tsequenced_barcodes\tindiv_count\n";
	$|++;
	print "\tPrinting sample abundance stats...\n";

	my @smpls = sort keys %smplCounts;
	foreach my $smpl (@smpls){
		my @bc_pairs = @{$sequenced_smpl_bcs{$smpl}};
		my %uniq_bc_pairs;

		foreach my $bc_pair (@bc_pairs){
			$uniq_bc_pairs{$bc_pair}++;
		}

		my @uniq_bc_pairs = sort {$uniq_bc_pairs{$b} <=> $uniq_bc_pairs{$a}} keys %uniq_bc_pairs;
		foreach my $uniq_bc_pair (@uniq_bc_pairs){
			print SCT "$smpl\t$smplCounts{$smpl}\t$uniq_bc_pair\t$uniq_bc_pairs{$uniq_bc_pair}\n";
		}
	}
	close SCT;
}