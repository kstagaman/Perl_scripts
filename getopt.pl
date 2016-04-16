#!/usr/bin/perl
# getopt.pl
use strict; use warnings;
use Getopt::Std;
use vars qw($opt_h $opt_v);
our $opt_p; # alternative to our()
getopts('hvp:');

my $VERSION = "1.0"; # it's a good idea to version your programs

my $usage = "
usage: getopt.pl [options] <arguments...>
options:
  -h help
  -v version
  -p <some parameter>
";

if ($opt_h) {
	print $usage; # it's common to provide a -h to give help
	exit;
}

if ($opt_v) {
	print "version ", $VERSION, "\n";
	exit;
}

if ($opt_p) {print "Parameter is: $opt_p\n"}

print "Other arguments were: @ARGV\n";  