#!/usr/bin/perl
# sorting.pl
use strict; use warnings;

my @list = qw( c b a C B A a b c 3 2 1); # an unsorted list
my @sorted_list = sort @list;
print "default: @sorted_list\n";
@sorted_list = sort {$a <=> $b} @list;
print "numeric: @sorted_list\n";
@list = qw(2 34 -1000 1.6 8 121 73.2 0);
@sorted_list = sort {$b <=> $a} @list;
print "reversed numeric: @sorted_list\n";
@list = qw( c b a C B A a b c 3 2 1);
@sorted_list = sort {$a <=> $b or uc($a) cmp uc($b)} @list;
print "combined: @sorted_list\n";