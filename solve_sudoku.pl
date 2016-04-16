#!/usr/bin/perl
# solve_sudoku.pl
use strict; use warnings; 

my $done = 0;
my @solved_puzzle;
my @past_nums;

while ($done == 0) {

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

print_puzzle(@puzzle_mat);

	my @nums = (1..9);
	for (my $d = 0; $d < 2; $d++) {
		my $empties = 0;	
	
		for (my $h = 0; $h < $index; $h++) {

			my $row = $hashref[$h]{row};
			my $col = $hashref[$h]{col};
			my $box = $hashref[$h]{box};
			my @new_nums;
			NUMS: while (1) {
				my @candidate_nums = choose(@nums);
				my $new = 0;
				foreach my $previous (@past_nums) {
					if (@candidate_nums ~~ $previous) {$new++}
				}
				if ($new == 0) {
					@new_nums = @candidate_nums;
					last NUMS;
				}
			}
		
			push @past_nums, [@new_nums];
			
			if ($hashref[$h]{val} == 0) {
				$empties++;
				my @othervals;	

				for (my $h2 = 0; $h2 < $index; $h2++) {	

					if ($hashref[$h2]{row} == $row or $hashref[$h2]{col} == $col or $hashref[$h2]{box} == $box) {
						my $otherval = $hashref[$h2]{val};
						push @othervals, $otherval;
					}	

					}

				TEST: for (my $n = 0; $n < 9; $n++) {
					my $test = 0;	

					foreach my $otherval (@othervals) {
	
						if ($otherval == $new_nums[$n]) {$test++}
					}

					$puzzle_mat[$hashref[$h]{row}][$hashref[$h]{col}] = $new_nums[$n] unless $test > 0;
					$hashref[$h]{val} = $new_nums[$n] unless $test > 0;
					last TEST unless $test > 0;
				}
			}
		}
		if ($empties == 0) {
			$done = 1;
			@solved_puzzle = @puzzle_mat;
		}
	}
	# print_puzzle(@puzzle_mat);
}

print_puzzle(@solved_puzzle);


sub print_puzzle { 
	my @puzzle_mat = @_;
	print "\n";
	for (my $i = 0; $i < 3; $i++) {
		print "\t";
		for (my $j = 0; $j < 3; $j++) {
			print "$puzzle_mat[$i][$j] ";
		}
		print " ";
		for (my $j = 3; $j < 6; $j++) {
			print "$puzzle_mat[$i][$j] ";
		}	
		print " ";
		for (my $j = 6; $j < 9; $j++) {
			print "$puzzle_mat[$i][$j] ";
		}	
		print "\n";
	}
	print "\n";
	for (my $i = 3; $i < 6; $i++) {
		print "\t";
		for (my $j = 0; $j < 3; $j++) {
			print "$puzzle_mat[$i][$j] ";
		}
		print " ";
		for (my $j = 3; $j < 6; $j++) {
			print "$puzzle_mat[$i][$j] ";
		}	
		print " ";
		for (my $j = 6; $j < 9; $j++) {
			print "$puzzle_mat[$i][$j] ";
		}	
		print "\n";
	}
	print "\n";
	for (my $i = 6; $i < 9; $i++) {
		print "\t";
		for (my $j = 0; $j < 3; $j++) {
			print "$puzzle_mat[$i][$j] ";
		}
		print " ";
		for (my $j = 3; $j < 6; $j++) {
			print "$puzzle_mat[$i][$j] ";
		}	
		print " ";
		for (my $j = 6; $j < 9; $j++) {
			print "$puzzle_mat[$i][$j] ";
		}	
		print "\n";
	}
	print "\n";
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
		