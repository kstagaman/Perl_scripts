#!/usr/bin/perl
# codonsearch.pl
use strict; use warnings;

#my $seq = "ACG TAC GAA GAC CCA ACA GAT AGC GCG TGC CAG AAA TAG ATT";
my $seq = "ACG TAC GAA GAC ccA ACA GAT AGC gcg TGC CAG aaa TAG ATT";

#if 	  ($seq =~ m/CCA/) {print "Contains proline (CCA)\n"}
#elsif ($seq =~ m/CCC/) {print "Contains proline (CCC)\n"}
#elsif ($seq =~ m/CCG/) {print "Contains proline (CCG)\n"}
#elsif ($seq =~ m/CCT/) {print "Contains proline (CCT)\n"}
#else				   {print "No proline today. Boo hoo\n"}

#if ($seq =~ m/CC./) {
#	print "Contains proline ($&)\n";
#}
#if ($seq =~ m/CG./) {
#	print "Contains arginine ($&)\n";
#}
#if ($seq =~ m/CG[ACGT]/) {
#	print "Contains arginine ($&)\n";
#}
#if ($seq =~ m/[Cc][Cc][ACGTacgt]/) {
#	print "Contains proline ($&)\n";
#}
if ($seq =~ m/CC[ACGT]/i) {
	print "Contains proline ($&)\n";
}
if ($seq =~ m/[a-z]/) {
	print "Contains at least one lower case letter\n";
}
