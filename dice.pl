#!/usr/bin/perl
# dice.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\tUsage: dice.pl [options: -h -s <# sides> -n <# dice> -b <bonus> -e (apply bonus to each roll)]\n\n";

# defaults
my $s  = 6;
my $n  = 1;
my $b  = 0;
my $e;
my $bonus;
my $h;
my @raw_rolls;
my @mod_rolls;
my $roll_total = 0;

GetOptions (
	's=i'   => \$s,
	'n=i'   => \$n,
	'b=i'   => \$b,
	'e!'    => \$e,
	'help!' => \$h,
);

if ($h) {
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-s: number of sides for the dice you want to roll, i.e. d#\n";
	print "\t\t-n: number of dice you want to roll\n";
	print "\t\t-b: the bonus you want to add, default is to add it to total\n";
	print "\t\t-e: bonus is added to each roll\n\n";
}
else {

	open DATA, ">>/Users/keaton/Code/Data/dice_data.csv" or die "\n\tError: cannot open dice_data.csv\n\n";

	for (my $i = 0; $i < $n; $i++) {
		my $raw_roll = (int rand $s) + 1;
		push @raw_rolls, $raw_roll;
	}

	if ($e) {
		print "\n\t${n}d$s + ${b}e:\n\n";
		foreach my $raw_roll (@raw_rolls) {
			my $mod_roll = $raw_roll + $b;
			push @mod_rolls, $mod_roll;
			$roll_total += $mod_roll;
		}

		for (my $i = 0; $i < @mod_rolls; $i++) {
			print "\t\t$mod_rolls[$i] ($raw_rolls[$i] + $b)\n";
		}

		print "\t      ------\n";
		print "\t\t$roll_total\n\n";
		
		my $raw_total = $roll_total - ($b * $n);

		print DATA "$s,$n,$b,e,$raw_total,$roll_total\n";

	} else {

		print "\n\t${n}d$s + ${b}:\n\n";

		foreach my $raw_roll (@raw_rolls) {
			print "\t\t$raw_roll\n" unless $n == 1 and $b == 0;
			$roll_total += $raw_roll;
		}

		my $total = $roll_total + $b;

		if ($b == 0) {
			print "\t      ------\n" unless $n == 1;
			print "\t\t$total\n\n";
		} else {
			print "\t\t+$b\n";
			print "\t      ------\n";
			print "\t\t$total\n\n";
		}

		print DATA "$s,$n,$b,t,$roll_total,$total\n";
		
	}
}

