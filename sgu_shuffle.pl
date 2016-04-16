#!/usr/bin/perl
# sgu_shuffle.pl
use strict; use warnings;

my @start_order = qw(A 2 3 4 5 6 7 8 9 T J Q K);
my @first_shuffle_log;
my @answer;
my $second_order = 0;
my $end_order_joined = "T9Q8K34A5J627";
my @end_order;


open LOG, ">shuffle.log";

ITER: until ($second_order eq $end_order_joined) {
	my @start_copy = @start_order;
	my @first_shuffle;

	for(my $i=0; $i < @start_order; $i++) {
		my $num_elements = @start_copy;
		my $position = int rand $num_elements;

		my $card = splice @start_copy, $position, 1;
		push @first_shuffle, $card;
	}
	my $shuffle_record = join '', @first_shuffle;

	if (grep {/$shuffle_record/} @first_shuffle_log) {next ITER}

	@answer = @first_shuffle;
	my @second_shuffle;

	for (my $i=0; $i < @start_order; $i++) {
		my ($index) = grep {$first_shuffle[$_] eq $start_order[$i]} 0..$#first_shuffle;
		# my $shift = ($index - $i) % 13;

		if ($index == $i) {next ITER}

		$second_shuffle[$index] = $first_shuffle[$i];
	}

	push @first_shuffle_log, $shuffle_record;

	@end_order = @second_shuffle;
	$second_order = join '', @second_shuffle;
	print LOG "$shuffle_record\t";
	print LOG "$second_order\n";
}
close LOG;

print "@start_order\n";
print "@answer\n";
print "@end_order\n\n";
