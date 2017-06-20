#!/usr/bin/perl
# bt2_get_ig_aligned.pl
use strict; use warnings;
use Getopt::Long;

# use this script to get ig matched seqs after running bowtie
# make sure sample ID is unique to working directory and ensembl ids directory
# this script must be run in the same directory as the aligned FASTQ and SAM files

my $usage = "\n\tbt2_get_ig_aligned.pl [options: -h] {-p | -u} -s <sample ID> -e <ensembl ids CSV>\n\n";

# defaults
my $help;
my $paired;
my $unpaired;
my $sample;
my $ensembl_ids;

GetOptions (
    'help!'    => \$help,
    'paired!'  => \$paired,
    'unpaired' => \$unpaired,
    's=s'      => \$sample,
    'e=s'      => \$ensembl_ids,
) or die $usage;

die $usage unless $sample or $help;

if ($help) {
    help_text();
}
else {

    if ($paired) {
        my ($fq1) = glob "$sample*1.fq";
        my ($fq2) = glob "$sample*2.fq";
        my $sam = "$sample.p.sam";

        open EIDS, "<$ensembl_ids" or die "\n\tError: cannot open $ensembl_ids\n\n";
        my %ig_ids;
        $_ = <EIDS>;
        
        while (<EIDS>) {
            my ($trans_id)   = /,(ENSDART\d+),/;
            my ($trans_name) = /$trans_id,(.+),/;
            if ($trans_name =~ /igh/) {$ig_ids{$trans_id} = $trans_name}
        }

        close EIDS;

        open SAM, "<$sam" or die "\n\tError: cannot open $sam\n\n";
        my %sam_1ids;
        my %sam_2ids;

        while (<SAM>) {

            if ($_ !~ /^@/) {
                my ($seq_id)   = /^(\w+)\t/;
                my ($trans_id) = /$seq_id\t\d+\t(ENSDART\d+)\t/;
                
                if    ($seq_id =~ /_1$/) {
                    $sam_1ids{$seq_id} = $trans_id;
                }
                elsif ($seq_id =~ /_2$/) {
                    $sam_2ids{$seq_id} = $trans_id;
                }
            }
        }

        close SAM;

        open FQ1, "<$fq1"                     or die "\n\tError: cannot open $fq1\n\n";
        open FQ2, "<$fq2"                     or die "\n\tError: cannot open $fq2\n\n";
        open FA1, ">$sample.ig.1.fa"          or die "\n\tError: cannot create $sample.ig.1.fa\n\n";
        open FA2, ">$sample.ig.2.fa"          or die "\n\tError: cannot create $sample.ig.2.fa\n\n";
        open FAU, ">$sample.ig.u.fa"          or die "\n\tError: cannot create $sample.ig.u.fa\n\n";
        open CSV, ">$sample\_bt2_p_stats.csv" or die "\n\tError: cannot create $sample\_bt2_stats.csv\n\n";
        print CSV "sample,seq.id,paired,match,mate.match\n";

        my $line1;
        my $line2 = <FQ2>;

        while ($line1 = <FQ1>) {

            if ($line1 =~ /^@[ACGT]{5}_\d_.+1$/ and $line2 =~ /^@[ACGT]{5}_\d_.+2$/) {
                my ($seq_id1) = $line1 =~ /@(\w+)/;
                my ($seq_id2) = $line2 =~ /@(\w+)/;
                my $seq1 = <FQ1>;
                my $seq2 = <FQ2>;
                chomp ($seq1, $seq2);


                if (exists $ig_ids{$sam_1ids{$seq_id1}} and exists $ig_ids{$sam_2ids{$seq_id2}}) {
                    print FA1 "\>$seq_id1:$ig_ids{$sam_1ids{$seq_id1}}\n$seq1\n";
                    print FA2 "\>$seq_id2:$ig_ids{$sam_2ids{$seq_id2}}\n$seq2\n";
                    print CSV "$sample,$seq_id1,1,$ig_ids{$sam_1ids{$seq_id1}},$ig_ids{$sam_2ids{$seq_id2}}\n";
                    print CSV "$sample,$seq_id2,1,$ig_ids{$sam_2ids{$seq_id2}},$ig_ids{$sam_1ids{$seq_id1}}\n";
                }
                elsif (exists $ig_ids{$sam_1ids{$seq_id1}}) {
                    print FAU "\>$seq_id1:$ig_ids{$sam_1ids{$seq_id1}}\n$seq1\n";
                    print CSV "$sample,$seq_id1,0,$ig_ids{$sam_1ids{$seq_id1}},NA\n";
                }
                elsif (exists $ig_ids{$sam_2ids{$seq_id2}}) {
                    print FAU "\>$seq_id2:$ig_ids{$sam_2ids{$seq_id2}}\n$seq2\n";
                    print CSV "$sample,$seq_id2,0,$ig_ids{$sam_2ids{$seq_id2}},NA\n";
                }
            }

            $line2 = <FQ2>;
        }

        close FQ1; close FQ2; close FA1; close FA2; close FAU; close CSV;

    }
    elsif ($unpaired) {
        my ($fq1) = glob "$sample.fq_1*fq";
        my ($fq2) = glob "$sample.fq_2*fq";
        my ($fqr) = glob "$sample.rem.fq*fq";
        my $sam1 = "$sample.fq_1.u.sam";
        my $sam2 = "$sample.fq_2.u.sam";
        my $samr = "$sample.rem.fq.u.sam";

        open EIDS, "<$ensembl_ids" or die "\n\tError: cannot open $ensembl_ids\n\n";
        my %ig_ids;
        $_ = <EIDS>;
        
        while (<EIDS>) {
            my ($trans_id)   = /,(ENSDART\d+),/;
            my ($trans_name) = /$trans_id,(.+),/;
            if ($trans_name =~ /igh/) {$ig_ids{$trans_id} = $trans_name}
        }

        close EIDS;

        open SAM1, "<$sam1" or die "\n\tError: cannot open $sam1\n\n";
        open SAM2, "<$sam2" or die "\n\tError: cannot open $sam2\n\n";
        open SAMR, "<$samr" or die "\n\tError: cannot open $samr\n\n";
        my (%sam1_ids, %sam2_ids, %samr_ids);

        while (<SAM1>) {

            if ($_ !~ /^@/) {
                my ($seq_id)   = /^(\w+)\t/;
                my ($trans_id) = /$seq_id\t\d+\t(ENSDART\d+)\t/;
                $sam1_ids{$seq_id} = $trans_id;
            }
        }

        while (<SAM2>) {

            if ($_ !~ /^@/) {
                my ($seq_id)   = /^(\w+)\t/;
                my ($trans_id) = /$seq_id\t\d+\t(ENSDART\d+)\t/;
                $sam2_ids{$seq_id} = $trans_id;
            }
        }

        while (<SAMR>) {

            if ($_ !~ /^@/) {
                my ($seq_id)   = /^(\w+)\t/;
                my ($trans_id) = /$seq_id\t\d+\t(ENSDART\d+)\t/;
                $samr_ids{$seq_id} = $trans_id;
            }
        }

        close SAM1; close SAM2; close SAMR;

        open FQ1, "<$fq1"                     or die "\n\tError: cannot open $fq1\n\n";
        open FQ2, "<$fq2"                     or die "\n\tError: cannot open $fq2\n\n";
        open FQR, "<$fqr"                     or die "\n\tError: cannot open $fqr\n\n";
        open FA1, ">$sample.ig.1.fa"          or die "\n\tError: cannot create $sample.ig.1.fa\n\n";
        open FA2, ">$sample.ig.2.fa"          or die "\n\tError: cannot create $sample.ig.2.fa\n\n";
        open FAR, ">$sample.ig.rem.fa"        or die "\n\tError: cannot create $sample.ig.rem.fa\n\n";
        open CSV, ">$sample\_bt2_u_stats.csv" or die "\n\tError: cannot create $sample\_bt2_stats.csv\n\n";
        print CSV "sample,seq.id,paired,match\n";

        while (<FQ1>) {

            if ($_ =~ /^@[ACGT]{5}_\d_.+1$/) {
                my ($seq_id) = /@(\w+)/;
                my $seq = <FQ1>;
                chomp $seq;

                if (exists $ig_ids{$sam1_ids{$seq_id}}) {
                    print FA1 "\>$seq_id:$ig_ids{$sam1_ids{$seq_id}}\n$seq\n";
                    print CSV "$sample,$seq_id,0,$ig_ids{$sam1_ids{$seq_id}}\n";
                }
            }
        }

        close FQ1; close FA1;

        while (<FQ2>) {

            if ($_ =~ /^@[ACGT]{5}_\d_.+2$/) {
                my ($seq_id) = /@(\w+)/;
                my $seq = <FQ2>;
                chomp $seq;

                if (exists $ig_ids{$sam2_ids{$seq_id}}) {
                    print FA2 "\>$seq_id:$ig_ids{$sam2_ids{$seq_id}}\n$seq\n";
                    print CSV "$sample,$seq_id,0,$ig_ids{$sam2_ids{$seq_id}}\n";
                }
            }
        }

        close FQ2; close FA2;

        while (<FQR>) {

            if ($_ =~ /^@[ACGT]{5}_\d_.+[12]$/) {
                my ($seq_id) = /@(\w+)/;
                my $seq = <FQR>;
                chomp $seq;

                if (exists $ig_ids{$samr_ids{$seq_id}}) {
                    print FAR "\>$seq_id:$ig_ids{$samr_ids{$seq_id}}\n$seq\n";
                    print CSV "$sample,$seq_id,0,$ig_ids{$samr_ids{$seq_id}}\n";
                }
            }
        }

        close FQR; close FAR; close CSV;
    }
    else {
        die "$usage\t-p or -u must be specified\n\n";
    }
} 







sub help_text {
    print $usage;
    print "\t\t-h: this helpful help screen\n";
    print "\t\t-p: FASTQ files are result of paired-end bowtie2 alignment\n";
    print "\t\t-u: FASTQ files are result of single-end bowtie2 alignment\n";
    print "\t\t-s: unique sample ID to select appropriate files that go togther (e.g. ma26, zc30)\n";
    print "\t\t-e: CSV file containing Ensembl transcript IDS and their names\n\n"
}

