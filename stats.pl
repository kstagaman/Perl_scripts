#!/usr/bin/perl
# stats.pl
use strict; use warnings;

die "usage: stats.pl <number1> <number2> <etc>\n" unless @ARGV > 1;

my (@data) = @ARGV;
#count
my $count = @data;
print "Count:	$count\n";

#sum
my $sum = 0;
for (my $i = 0; $i < @data; $i++) {
	$sum += $data[$i]
}
print "Sum:	$sum\n";

#mean
my $mean = $sum / $count;
print "Mean:	$mean\n";

#min and max
my @sorted_data = sort {$a <=> $b} @data;
my @sorted_data2 = @sorted_data;
my $min = shift(@sorted_data);
print "Min:	$min\n";
my $max = pop(@sorted_data);
print "Max:	$max\n";

#median (1st attempt)
#if ($count == 2) {
#	my $two_med = ($data[0] + $data[1]) / 2;
#	print "Median:	$two_med\n";
#}
#elsif ($count == 3) {
#	print "Median:	@sorted_data\n";
#}
#elsif ($count % 2 == 0) {
#	while (1) {
#		pop(@sorted_data2);
#		shift(@sorted_data2);
#		my $length = @sorted_data2;
#		last if $length < 3;
#	}
#	my $even_med = ($sorted_data2[0] + $sorted_data2[1]) / 2;
#	print "Median: $even_med\n";	
#} else {
#	while (1) {
#		pop(@sorted_data);
#		shift(@sorted_data);
#		my $length = @sorted_data;
#		last if $length < 2;
#	}
#	print "Median:	@sorted_data\n";
#}

#median (more efficient)
if ($count % 2 == 0) {
	my $offset1 = ($count / 2) - 1;
	my $offset2 = -($count / 2);
	my $med_val1 = splice(@sorted_data2, $offset1, 1);
	my $med_val2 = splice(@sorted_data2, $offset2, 1);
	my $even_med = ($med_val1 + $med_val2) / 2;
	print "Median:	$even_med\n";
} else {
	my $offset3 = ($count / 2);
	my $odd_med = splice(@sorted_data2, $offset3, 1);
	print "Median:	$odd_med\n";
}

#variance
my $var_sum = 0;
for (my $i = 0; $i < @data; $i++) {
	$var_sum += ($mean - $data[$i]) ** 2;
}
my $var = $var_sum / ($count - 1);
print "Var:	$var\n";

#sd
my $sd = sqrt $var;
print "SD:	$sd\n";