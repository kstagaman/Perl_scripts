#!/usr/bin/perl
# assign_vdj_attributes.pl
use strict; use warnings;

# use this script with a ?_canonical.noa file to generate other node attribute files for cytoscape giving the V, D, and J assignments for the canonical nodes

die "Usage: assign_vdj_attributes.pl <?_canonical.noa>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
my ($file_id) = $ARGV[0] =~ /(.+)\.noa$/;

open VS, ">$file_id\_vsegs.noa" or die "Error: cannot create $file_id\_vsegs.noa\n";
open DS, ">$file_id\_dsegs.noa" or die "Error: cannot create $file_id\_dsegs.noa\n";
open JS, ">$file_id\_jsegs.noa" or die "Error: cannot create $file_id\_jsegs.noa\n";

print VS "vseg\t(class=String)\n";
print DS "dseg\t(class=String)\n";
print JS "jseg\t(class=String)\n";

while (<IN>) {
	if ($_ =~ /^Z/) {
		my ($seq_id) = $_ =~ /^(Z_\d+)/;
		my ($vseg) = $_ =~ /(V[0-9|\.]+)\-D/;
		my ($dseg) = $_ =~ /(D[0-9|\.]+)\-J/;
		my ($jseg) = $_ =~ /(J[0-9|\.]+)$/;
		
		print VS "$seq_id = $vseg\n";
		print DS "$seq_id = $dseg\n";
		print JS "$seq_id = $jseg\n";
	}
}