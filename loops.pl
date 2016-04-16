#!/usr/bin/perl
# loops.pl
use strict; use warnings;

my @ animals = qw(cat dog cow);
my @ sounds = qw(Meow Woof Moo);
for (my $i = 0; $i < @animals; $i++) {
	print "$i) $animals[$i] $sounds[$i]\n";
}
foreach my $animal (@animals) {
	print "$animal\n";
}
for my $i (0..5) {print "$i\n"}
my $x = 1;
while($x < 1000){
	print "$x\n";
	$x += $x;
}
while (0) {
	print "this statement is never executed because 0 is false\n";
}
# while (1) {
#	print "this statement loops forever\n";
# }

while (@animals) {
	my $animal = shift @animals;
	print "$animal\n";
}

do {
	print "hello\n";
} while (0);