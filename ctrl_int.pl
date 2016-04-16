#!/usr/bin/perl
# ctrl_int.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\tctrl_int.pl [-help] -t <N total investors> -a <N investors in agreement>\n\n";

# defaults
my $help;
my $investors = 1;
my $in_agree = 0;

GetOptions (
	'help!' => \$help,
	't=i'   => \$investors,
	'a=i'   => \$in_agree,
) or die $usage;

if ($help) {help_txt()}
else {
	if ($investors == 0) {die "\n\tThere are $investors investors, no one is in control.\n\n"}
	
	my $cutoff_pct = 100 * (0.5 + ($investors - $in_agree) / $investors) / 2;

	if ($investors == $in_agree) {print "\n\tEveryone's in agreement, why are you using this?\n\n"}
	elsif ($investors < $in_agree) {print "\n\tYou're drunk, go home.\n\n"}
	elsif ($in_agree > 1) {
		print "\n\tWith a total of $investors investors, the $in_agree investor(s) in agreement\n";
		printf "\trequire greater than %.2f", $cutoff_pct;
		print "\% of shares to proceed.\n\n";
	}
	elsif ($in_agree == 1) {
		print "\n\tWith a total of $investors investors, a controlling interest can be obtained\n";
		printf "\twith greater than %.2f", $cutoff_pct;
		print "\% of shares.\n\n";
	}
	
	
}


sub help_txt {
	print $usage;
}