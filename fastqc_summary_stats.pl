#!/usr/bin/perl
# fastqc_summary_stats.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\tUsage: fastqc_summary_stats.pl [-h -d <input directory -o <output directory] \n\n";

# defaults
my $help;
my $outDir = './';
my $curDir = './';

GetOptions (
    'help!' => \$help,
    'o=s'   => \$outDir,
    'd=s'   => \$curDir,
    ) or die $usage;

if ( $outDir !~ /\/$/ ) { $outDir = "$outDir\/" }
if ( $curDir !~ /\/$/ ) { $curDir = "$curDir\/" }

if ( $help ) {
    help_txt();
}
else {
    my @dirSet = glob "*_fastqc/";
    open OUT, ">${outDir}summary_stats.csv" or die "\n\tError: cannot create ${outDir}summary_stats.txt\n\n";
    print OUT "sample,read,depth,mean_q,med_q,dup_rate\n";
    
    foreach my $dir ( @dirSet ) {
        open INF, "<${dir}fastqc_data.txt" or die "\n\tError: cannot open ${dir}fastqc_data.txt\n\n";
        my ( $smpl ) = $dir =~ /(\w+)_S\d+_L\d+_/;
        my ( $read ) = $dir =~ /_(R[12])_/;
        my $totSeqs;
        my $qualSum  = 0;
        my $countSum = 0;
        my $meanQual;
        my $medQual = 0;
        my $dedupPc;
        
        while ( <INF> ) {
            if ( $_ =~ /^Total Sequences/ ) {
                ( $totSeqs ) = /(\d+)$/;
            }
            if ( $_ =~ /^\>\>Per sequence quality scores/ ) {
                $_ = <INF>;
                $_ = <INF>;

                while ( $_ =~ /^\d+\t\d+\.\d+$/ ) {
                    my ( $qual ) = /^(\d+)\t/;
                    my ( $count ) = /\t(\d+\.*\d*)$/;
                    $qualSum += ( $qual * $count );
                    $countSum += $count;
                    if( $countSum > ( $totSeqs/2 ) and $medQual == 0 ) { $medQual = $qual }
                    $_ = <INF>;
                }
            }
            if ( $_ =~ /^\#Total Deduplicated Percentage/ ) {
                ( $dedupPc ) = /\t(\d+\.\d{3})\d+$/;
            }
        }
        close INF;
        $meanQual = $qualSum/$totSeqs;
        print OUT "$smpl,$read,$totSeqs,";
        printf OUT "%.3f,", $meanQual; 
        print OUT "$medQual,$dedupPc\n";
    }
    close OUT;
}

sub help_txt {
    print $usage;
}