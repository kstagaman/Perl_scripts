#!/usr/bin/perl
# encrypt_.pl
use strict; use warnings;

die "Usage: encrypt_.pl <txt file>\n" unless @ARGV==1;

my %char_hash;
my @char_array = ("a".."z", "A".."Z", "0".."9", ",", ".", ";", ":", "\'", "\"", "/", "\\", "(", ")", "[", "]", "{", "}", '#', '$', '@', '%', '^', '*', '!', '~', '_', '+', '=', '-', '<', '>', '&', " ", "\t");
# print "@char_array\n";
my $mod = @char_array - 1;

for (my $i=0; $i < @char_array; $i++) {
	$char_hash{$char_array[$i]} = $i;
}

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";

if ($ARGV[0] !~ /\.encrypted$/) {
	open OUT, ">$ARGV[0].encrypted" or die "Error: cannot create $ARGV[0].encrypted\n";

	my $date = `date`;
	my ($shift) = $date =~ /\d{2}\:(\d{2})\:\d{2}/;
	# print "$shift\n";

	while (<IN>) {
		# print "$_";
		my $line = $_;
		chomp $line;
		my @line = split('', $line);

		foreach my $char (@line) {
			my $char_val = $char_hash{$char};
			my $new_char_val = ($char_val + $shift) % $mod;
			my ($new_char) = $char_array[$new_char_val];
			# print "$char\t$char_val\t$shift\t$new_char_val\t$new_char\n";
			print OUT "$new_char";
			$shift++;
		}
		print OUT "\n";
	}

}
else {
	my ($filename) = $ARGV[0] =~ /(.+)\.encrypted$/;
	open OUT, ">extracted_$filename" or die "Error: cannot create extracted_$filename\n";

	my $key = `ls -T -l -o $ARGV[0]`;
	my ($shift) = $key =~ /\d{2}\:(\d{2})\:\d{2}/;
	# print "$shift\n";

	while (<IN>) {
		my $line = $_;
		chomp $line;
		my @line = split('', $line);

		foreach my $char (@line) {
			my $char_val = $char_hash{$char};
			my $new_char_val = ($char_val - $shift) % $mod;
			my ($new_char) = $char_array[$new_char_val];
			# print "$char\t$char_val\t$shift\t$new_char_val\t$new_char\n";
			print OUT "$new_char";
			$shift++;
		}
		print OUT "\n";
	}
}


close IN; close OUT;

