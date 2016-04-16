#!/usr/bin/perl
# renametaxfiles.pl
use strict; use warnings;

my @files = `ls *.taxonomy`;
chomp @files;

foreach my $file (@files) {
	my ($front) = $file =~ /(^.+\.noprimer)\./;
	my ($back)  = $file =~ /\.(Jm.taxonomy)/;
	system("mv $file $front.ksize4.$back");
}
	