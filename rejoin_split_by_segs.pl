#!/usr/bin/perl
# rejoin_sorted_split_by_segs.pl
use strict; use warnings;
use Getopt::Long;


# run this script in a directory containing all the files that have been split based on their segments

my $usage = "\n\tUsage: rejoin_split_by_segs.pl [-h -q -o PATH] -seg <V/J/Jm/Jz> -id <file identifier>\n\n";

# defaults
my $help;
my $quiet;
my $outdir = './';
my $seg_type;
my $identifier;

GetOptions (
	'help!'  => \$help,
	'quiet!' => \$quiet,
	'o=s'    => \$outdir,
	'seg=s'  => \$seg_type,
	'id=s'   => \$identifier,
) or die $usage;

die $usage unless $help or $seg_type and $identifier;
die $usage unless $help or $seg_type =~ /^(V|J[mz]*)$/;
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($help) {help_text()}
else {

	# "global" variables
	my %seqs_by_ids;
	my @ids;
	my @smpl_files = glob "*$identifier*";
	my @seg_files = grep {/$seg_type/} @smpl_files;

	foreach my $seg_file (@seg_files) {
		open IN, "<$seg_file" or die "\n\tError: cannot open $seg_file\n\n";

		while (<IN>) {

			if ($_ =~ /^\>/) {
				my $id = $_;
				my $seq = <IN>;
				chomp ($id, $seq);
				$seqs_by_ids{$id} = $seq;
			}
		}
		close IN;
	}

	@ids = sort keys %seqs_by_ids;

	open OUT, ">${outdir}all_${seg_type}s.fa" or die "\n\tError: cannot create ${outdir}all_${seg_type}s.fa\n\n";
	foreach my $id (@ids) {
		print OUT "$id\n$seqs_by_ids{$id}\n";
	}
	close OUT;
}



sub help_text {
	print $usage;
}