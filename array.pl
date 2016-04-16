#!/usr/bin/perl
# array.pl
use strict; use warnings;

my @animals = ('cat', 'dog', 'pig');
print "1st animal in array is: $animals[0]\n";
print "2nd animal in array is: $animals[1]\n";
print "Entire animals array contains: @animals\n";
push @animals, "fox"; # the array is now longer
print "Entire animals array contains: @animals\n";

my ($first, $second) = @animals;
print "First two animals: $first $second\n";
my @animals2 = @animals; #make a copy of @animals
@animals = (); #assigns @animals an empty list -> destroys contents
print "Animals array now contains: @animals\n";
print "Animals2 array still contains: @animals2\n";

my $value = pop(@animals2);
print "Animals2 array: $value\n";

pop(@animals2);
print "Animals2 array: @animals2\n";

unshift @animals2, "raccoon";
print "Animals2 array: @animals2\n";

splice (@animals2, 1, 0,"cow");
print "Animals2 array: @animals2\n";

@animals = ('cat', 'dog', 'pig'); #needed because @animals was emptied
print "Animals at array position 1.2 is $animals[1.2]\n";
print "Animals at array position 1.7 is $animals[1.7]\n";
print "Animals at array position -1 is $animals[-1]\n";
print "array length = ", scalar(@animals), "\n";

