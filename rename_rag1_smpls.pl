#!/usr/bin/perl
# rename_rag1_smpls.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\trename_rag1_smpls.pl [-h -o -i] -m <mapping TXT> -f <input FASTA>\n\n";

# defaults
my $help;
my $outDir = './';
my $individual;
my $mapFile;
my $fastaFile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'i!'    => \$individual,
	'm=s'   => \$mapFile,
	'f=s'   => \$fastaFile
	) or die $usage;

die $usage unless $help or ($mapFile and $fastaFile);
if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}

if ($help) {print $usage}
else {
	# 'global' variables
	my %smpl_data;
	my %group_count;
	my ($outName) = $fastaFile =~ /(\S+)\.fasta$/;
	my $outFile = "${outDir}${outName}_relabelled.fasta";

	open MAP, "<$mapFile" or die "\n\tError: cannot open $mapFile\n\n";
	$_ = <MAP>;
	while (<MAP>) {
		my $line = $_;
		my @fields = split ("\t", $line);
		# print "$fields[1]\n";
		if ($fields[7] eq "NA") {$fields[7] = "food"}
		if ($fields[8] eq "NA") {
			if ($fields[7] eq "food")        {$fields[8] = "food"}
			elsif ($fields[7] eq "cohoused") {$fields[8] = "mix"}
			else {
				if ($fields[6] =~ /[ABC]/)   {$fields[8] = "all.wt"}
				else                         {$fields[8] = "all.ko"} 
			}
		}
		$smpl_data{$fields[0]} = {type => $fields[3], dpf => "$fields[5]", house => $fields[7], gntyp => $fields[8]};
	}
	close MAP;

	open INF, "<$fastaFile" or die "\n\tError: cannot open $fastaFile\n\n";
	open OUT, ">$outFile" or die "\n\tError: cannot create $outFile\n\n";

	if ($individual) {
		while (<INF>){
			if ($_ =~ /^\>/) {
				my ($smpl) = /(\w+)_Read/;
				my ($read) = /_Read(\d+)\|/;
				my ($abund) = /\|freq:(\d+)/;
				my $seq = <INF>;
				chomp $seq;
				my $group = "$smpl_data{$smpl}->{type}\-$smpl_data{$smpl}->{dpf}\-$smpl_data{$smpl}->{house}\-$smpl_data{$smpl}->{gntyp}";
				$group_count{$group}++;
				print OUT "\>$group:$group_count{$group}_Read$read|freq:$abund\n";
				print OUT "$seq\n";
			}
		}
	}
	else {
		LINE: while (<INF>) {
			if ($_ =~ /^\>/) {
				my ($smpl) = /(\w+)_Read/;
				next LINE if ($smpl_data{$smpl}->{gntyp} eq "ht");
				my ($read) = /_Read(\d+)\|/;
				my ($abund) = /\|freq:(\d+)/;
				# print "$smpl\t$read\t$abund\n";
				my $seq = <INF>;
				chomp $seq;
				my $group = "$smpl_data{$smpl}->{type}\-$smpl_data{$smpl}->{dpf}\-$smpl_data{$smpl}->{house}\-$smpl_data{$smpl}->{gntyp}";
				$group_count{$group}++;
				print OUT "\>${group}_Read$group_count{$group}|freq:$abund\n";
				print OUT "$seq\n";
			}
		}
	}
	close INF; close OUT;
}
