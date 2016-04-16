#!/usr/bin/perl
# cat_all_vj_templates.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\tcat_all_vj_templates.pl [-h] -v <V seg FASTA> -j <J seg FASTA> -c <C seg FASTA>\n\n";

# Defaults
my $help;
my $v_file;
my $j_file;
my $c_file;

GetOptions (
	'help!' => \$help,
	'v=s'   => \$v_file,
	'j=s'   => \$j_file,
	'c=s'   => \$c_file,
) or die $usage;

die $usage unless ($v_file and $j_file and $c_file) or $help;

if ($help) {print $usage}
else {

	# "global" varialbes
	my (%vsegs, %jsegs, %csegs);

	open VIN, "<$v_file" or die "\n\tError: cannot open $v_file\n\n";
	while (<VIN>) {
		if ($_ =~ /^\>/) {
			my ($id) = /^>(\S+)/;
			my ($seq) = <VIN> =~ /^([ACGT]+)/;
			
			$vsegs{$id} = $seq;
		}
	}
	close VIN;

	open JIN, "<$j_file" or die "\n\tError: cannot open $j_file\n\n";
	while (<JIN>) {
		if ($_ =~ /^\>/) {
			my ($id) = /^>(\S+)/;
			my ($seq) = <JIN> =~ /^([ACGT]+)/;
			
			$jsegs{$id} = $seq;
		}
	}
	close JIN;

	open CIN, "<$c_file" or die "\n\tError: cannot open $c_file\n\n";
	while (<CIN>) {
		if ($_ =~ /^\>/) {
			my ($id) = /^>(\S+)/;
			my ($seq) = <CIN> =~ /^([ACGT]+)/;
			
			$csegs{$id} = $seq;
		}
	}
	close CIN;

	open OUT, ">vjc_combos.fa" or die "\n\tError: cannot create vjc_combos.fa\n\n";

	my @vs = sort keys %vsegs;
	my @js = sort keys %jsegs;
	my @cs = sort keys %csegs;

	foreach my $v (@vs) {

		foreach my $j (@js) {
			my $rev_j = revcomp($jsegs{$j});

			foreach my $c (@cs) {
				my $rev_c = revcomp($csegs{$c});
				print OUT "\>$v:$j:$c\n$vsegs{$v}$rev_j$rev_c\n";
			}
		}
	}
	close OUT;
}

sub revcomp {
	my ($seq) = @_;
	$seq = uc($seq);
	my $rev = reverse($seq);
	$rev =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/; # makes complement
	return $rev;
}