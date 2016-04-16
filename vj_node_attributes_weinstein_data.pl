#!/usr/bin/perl
# vj_node_attributes_weinstein_data.pl
use strict; use warnings;

# use this script to take the V and J seg assignments from as fasta file to create a node attribute file for cytoscape

die "Usage: vj_node_attributes_weinstein_data.pl <fasta file>\n" unless @ARGV == 1;

my ($filename) = $ARGV[0] =~ /(.+)_vj\.fas*t*a*$/;
open FA, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
open VNA, ">$filename\_vsegs.noa" or die "Error: cannot create $filename\_vsegs.noa\n";
open JNA, ">$filename\_jsegs.noa" or die "Error: cannot create $filename\_jsegs.noa\n";

print VNA "V_seg \(class=java.lang.String\)\n";
print JNA "J_seg \(class=java.lang.String\)\n";

while (<FA>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_ =~ /^\>(\w+):/;
		my ($vseg) = $_ =~ /:(V\d+):/;
		my ($jseg) = $_ =~ /:(J[mz]\d)$/;
		print VNA "$id = $vseg\n";
		print JNA "$id = $jseg\n";
	}
}

close FA; close VNA; close JNA;