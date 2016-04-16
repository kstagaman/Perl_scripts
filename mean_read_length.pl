#!/usr/bin/perl
# mean_read_length.pl
use strict; use warnings;

my @qualfiles = `ls *.quals`;
chomp @qualfiles;
my $num_qualfiles = @qualfiles;
my $sum_mean_quals = 0;
my $quals_count = 0;
my $j = 0;
open(OUT, ">mean_qualities.txt");

foreach my $qualfile (@qualfiles) {
     open(QUALS, "<$qualfile") or die "Error: cannot open one or more quality summary files";
     <QUALS>;

     while (my $line = <QUALS>) {
          my ($mean_qual) = $line =~ m/\d+\t\d+\t\d+\t\d+\t\d+\t(\d{1,2}\.\d{2})/;
          $sum_mean_quals += $mean_qual;
          $quals_count++;
     }

     close(QUALS);
     $j++;
     my $file_avg = $sum_mean_quals / $quals_count;
     print OUT "$qualfile average read qual: $file_avg\n";
}
close OUT;
my $mean_qual = $sum_mean_quals / $quals_count;

print "\n\tAverage read quality score: $mean_qual\n\n";
