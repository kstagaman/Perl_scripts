#!/usr/bin/perl
# batch_make_jobs.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\tbatch_make_jobs.pl [options -h -d PATH -q QUEUE] -N FILE\n\n";

# defaults
my $help;
my $name;
my $wd = `pwd`;
my $queue = 'generic';

# "global" variables
my $threads = 12;

GetOptions(
	'help!' => \$help,
	'N=s'   => \$name,
	'd=s'   => \$wd,
	'q=s'   => \$queue,
) or die $usage;

die $usage unless $name or $help;
chomp $wd;
if ($wd !~ /\/$/) {$wd = "$wd\/"}

if ($help) {
	help_text();
}
else {
	if ($queue =~ /fat/) {$threads = 32}

	open OUT, ">$name.job" or die "\n\tError: cannot create $name.job";

	print OUT '#/bin/bash -l', "\n\n";
	print OUT '######################### set torque paths and options here ###########################', "\n\n";
	print OUT '#PBS ', "-N $name\n";
	print OUT '#PBS ', "-o /home2/stagaman/ACISS_jobs/Logs\n";
	print OUT '#PBS ', "-e /home2/stagaman/ACISS_jobs/Logs\n";
	print OUT '#PBS ', "-d $wd\n";
	print OUT '#PBS ', "-k oe\n";
	print OUT '#PBS ', "-q $queue\n\n\n";

	###### Set commands for batch job in the next lines here ######
	print OUT "module load blast\n\n";
	print OUT "blastn -db /research/sequences/GenBank/blast/db/nt -query $name -out ${name}.blastout ";
	print OUT "-num_descriptions 5 -num_alignments 0 -num_threads $threads\n";
}

sub help_text {
	print $usage;
	print "\t\t -h: this helpful help screen.\n";
	print "\t\t -d: specifies the working directory for the job.\n";
	print "\t\t -q: specifies the queue the job will be submitted to.\n";
	print "\t\t -N: specifies the name of the job (the file that will be used in the job).\n";
}