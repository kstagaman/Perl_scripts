#!/usr/bin/perl
# split_by_segs.pl
use warnings;
use Getopt::Long;

my $usage = "\n\tsplit_by_segs.pl [-h -q -o PATH] -seg <V/J/Jm/Jz> -i FASTA\n\n";

# defaults
my $help;
my $quiet;
my $outdir = './';
my $seg_type;
my $infile;

GetOptions (
	'help!'  => \$help,
	'quiet!' => \$quiet,
	'o=s'    => \$outdir,
	'seg=s'  => \$seg_type,
	'i=s'    => \$infile,
) or die $usage;

if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

die $usage unless $help or $seg_type and $infile;
die $usage unless $help or $seg_type =~ /^(V|J[mz]*)$/;

if ($help) {help_text()}
else {

	# "global" variables
	my $num_segs;
	my @file_handles;
	my %num_seqs_per_seg;
	my ($name) = $infile =~ /^(\w+)\./;

	if ($seg_type eq "V")     {$num_segs = 39}
	elsif ($seg_type eq "Jm") {$num_segs = 5}
	elsif ($seg_type eq "Jz") {$num_segs = 2}

	my $num = 0;

	if ($seg_type ne "J") {

		for (my $i=1; $i <= $num_segs; $i++) {
			$num = $i;
			if (length $i == 1 and $seg_type eq "V") {$num = "0$i"}
			my $handle = "$seg_type$num";
			push @file_handles, $handle;
			open $handle, ">$outdir$name.$seg_type$num.fa" or die "\n\tError: cannot create $outdir$name.$seg_type$num.fa\n\n";
		}
		print "$num $seg_type outfiles created\n" unless $quiet;

	} else {

		my ($m_files, $z_files);
		for (my $m=1; $m <= 5; $m++) {
			my $handle = "${seg_type}m$m";
			push @file_handles, $handle;
			open $handle, ">$outdir$name.${seg_type}m$m.fa" or die "\n\tError: cannot create $outdir$name.${seg_type}m$m.fa\n\n";
			$m_files = $m;
		}

		for (my $z=1; $z <= 2; $z++) {
			my $handle = "${seg_type}z$z";
			push @file_handles, $handle;
			open $handle, ">$outdir$name.${seg_type}z$z.fa" or die "\n\tError: cannot create $outdir$name.${seg_type}z$z.fa\n\n";
			$z_files = $z;
		}

		print "$m_files ${seg_type}m outfiles created\n" unless $quiet;
		print "$z_files ${seg_type}z outfiles created\n" unless $quiet;
	}
	
	

	open IN, "<$infile" or die "\n\tError: cannot open $infile\n\n";

	while (<IN>) {

		if ($_ =~ /^\>/) {
			my $id = $_;
			my ($seg) = $id =~ /($seg_type[mz]*\d{1,2})/;
			my $seq = <IN>;
			chomp ($id, $seq);

			print $seg "$id\n$seq\n";
			$num_seqs_per_seg{$seg}++;
		}
	}

	foreach my $handle (@file_handles) {
		close $handle;
	}

	my @segs = sort keys %num_seqs_per_seg;
	
	unless ($quiet) {

		foreach my $seg (@segs) {
			print "$seg: $num_seqs_per_seg{$seg} seqs\n";
		}
	}
	
}


sub help_text {
	print $usage;
}