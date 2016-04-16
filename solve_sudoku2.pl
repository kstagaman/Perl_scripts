#!/usr/bin/perl
# solve_sudoku2.pl
use strict; use warnings; 

my @solved_puzzle;

open IN, "<$ARGV[0]";
my @puzzle_mat;
my $line_num = 0;

while (<IN>) {
	chomp $_;
	my @row = split "", $_;
	die "\nError: line $line_num does not contain 9 values\n\n" unless @row == 9;
	push @puzzle_mat, [@row];
	$line_num++;
}

close IN;
	
die "\nError: puzzle does not contain 9 lines\n\n" unless $line_num == 9;

my @base_nums = (1..9);
# print "@base_nums\n";

until (@solved_puzzle > 0) {
	my @hashref;
	my $index = 0;

	for (my $i = 0; $i < 9; $i++) {
	
		for (my $j = 0; $j < 9; $j++) {
			if    ($i < 3 and $j < 3) {$hashref[$index] = {row => $i, col => $j, box => 0, val => $puzzle_mat[$i][$j]}}
			elsif ($i < 3 and $j < 6) {$hashref[$index] = {row => $i, col => $j, box => 1, val => $puzzle_mat[$i][$j]}}
			elsif ($i < 3)            {$hashref[$index] = {row => $i, col => $j, box => 2, val => $puzzle_mat[$i][$j]}}
				
			elsif ($i < 6 and $j < 3) {$hashref[$index] = {row => $i, col => $j, box => 3, val => $puzzle_mat[$i][$j]}}
			elsif ($i < 6 and $j < 6) {$hashref[$index] = {row => $i, col => $j, box => 4, val => $puzzle_mat[$i][$j]}}
			elsif ($i < 6)            {$hashref[$index] = {row => $i, col => $j, box => 5, val => $puzzle_mat[$i][$j]}}
				
			elsif ($j < 3)	          {$hashref[$index] = {row => $i, col => $j, box => 6, val => $puzzle_mat[$i][$j]}}
			elsif ($j < 6)			  {$hashref[$index] = {row => $i, col => $j, box => 7, val => $puzzle_mat[$i][$j]}}
			else					  {$hashref[$index] = {row => $i, col => $j, box => 8, val => $puzzle_mat[$i][$j]}}
			$index++;
		}
	}

	my @hashref_copy = @hashref;
	# print_puzzle(@hashref_copy);

	for (my $d = 0; $d < 2; $d++) {
		my $empties = 0;
		
		for (my $h = 0; $h < $index; $h++) {
			my $row = $hashref_copy[$h]{row};
			my $col = $hashref_copy[$h]{col};
			my $box = $hashref_copy[$h]{box};
			# print "$row\t$col\t$box\n";
			my @test_nums = choose(@base_nums);

			# print "@test_nums\n";
			if ($hashref_copy[$h]{val} == 0) {
				$empties++;
				my @othervals;
				
				for (my $h2 = 0; $h2 < $index; $h2++) {
					
					if ($hashref_copy[$h2]{row} == $row or $hashref_copy[$h2]{col} == $col or $hashref_copy[$h2]{box} == $box) {
						my $otherval = $hashref_copy[$h2]{val};
						push @othervals, $otherval;
					}
				}
				
				TEST: for (my $n = 0; $n < 9; $n++) {
					
					unless (grep $_ == $test_nums[$n], @othervals) {
						$hashref_copy[$h]{val} = $test_nums[$n];
						last TEST;
					}
				}
			}	
					
		}
		if ($empties == 0) {
			@solved_puzzle = @hashref_copy;
		}
	# print_puzzle(@hashref_copy);	
	}
	# print_puzzle(@hashref_copy);
}

print_puzzle(@solved_puzzle);


sub print_puzzle { 
	my @print_hashref = @_;
	print "\n\t";
	for (my $i = 0; $i < 3; $i++)   {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 3; $i < 6; $i++)   {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 6; $i < 9; $i++)   {print "$print_hashref[$i]{val} "}
	print "\n\t";
	for (my $i = 9; $i < 12; $i++)  {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 12; $i < 15; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 15; $i < 18; $i++) {print "$print_hashref[$i]{val} "}
	print "\n\t";
	for (my $i = 18; $i < 21; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 21; $i < 24; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 24; $i < 27; $i++) {print "$print_hashref[$i]{val} "}
	print "\n\n\t";
	for (my $i = 27; $i < 30; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 30; $i < 33; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 33; $i < 36; $i++) {print "$print_hashref[$i]{val} "}
	print "\n\t";
	for (my $i = 36; $i < 39; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 39; $i < 42; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 42; $i < 45; $i++) {print "$print_hashref[$i]{val} "}
	print "\n\t";
	for (my $i = 45; $i < 48; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 48; $i < 51; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 51; $i < 54; $i++) {print "$print_hashref[$i]{val} "}
	print "\n\n\t";
	for (my $i = 54; $i < 57; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 57; $i < 60; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 60; $i < 63; $i++) {print "$print_hashref[$i]{val} "}
	print "\n\t";
	for (my $i = 63; $i < 66; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 66; $i < 69; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 69; $i < 72; $i++) {print "$print_hashref[$i]{val} "}
	print "\n\t";
	for (my $i = 72; $i < 75; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 75; $i < 78; $i++) {print "$print_hashref[$i]{val} "}
	print " ";
	for (my $i = 78; $i < 81; $i++) {print "$print_hashref[$i]{val} "}
	print "\n\n";
	
}

sub choose {
	my @numbers = @_;
	my @new_numbers;
	while (@numbers) {
		my $offset = int rand @numbers;
		my $new_number = splice @numbers, $offset, 1;
		push @new_numbers, $new_number;
	}
	return(@new_numbers);
}
		