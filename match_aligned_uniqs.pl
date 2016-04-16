#!/usr/bin/perl
# match_aligned_uniqs.pl
use strict; use warnings;
use Getopt::Long;

# use this script on Ig seqs that have been run through split_by_segs.pl, unique_seqs.pl, and mafft aligned.
# this script uses the uniq_map.txt file generated by unique_seqs.pl to expand the unique V and J seqs,
# match them in their respective samples, and recollapse to unique reads.

my $usage = "\n\tUsage match_aligned_uniqs.pl [-h -q -o PATH] -mapdir <PATH to uniq_map files> -regex <id for files>\n\n"; ###########

# defaults
my $help;
my $quiet;
my $outdir = './';
my $mapdir;
my $regex;

GetOptions (
	'help!'     => \$help,
	'quiet!'    => \$quiet,
	'o=s'       => \$outdir,
	'mapdir=s'  => \$mapdir,
	'regex=s'   => \$regex,
) or die $usage;

die $usage unless $help or ($mapdir and $regex);
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}
if ($mapdir !~ /\/$/) {$mapdir = "$mapdir\/"}

if ($help) {print $usage}
else {
	my @infiles   = glob "$regex";
	my $num_files = @infiles;

	print "$num_files files included\n" unless $quiet;

# expand unique sequences
	foreach my $infile (@infiles) {
		my ($fileid) = $infile =~ /^(\S+)\.gt\d+/;
		my $mapfile  = "${mapdir}$fileid.uniq_map.txt";

		if ($fileid =~ /V/) {open TMP, ">>all_Vs.fa" or die "\n\tError: cannot open all_Vs.fa\n\n"}
		if ($fileid =~ /J/) {open TMP, ">>all_Js.fa" or die "\n\tError: cannot open all_Js.fa\n\n"}

		open MAP, "<$mapfile" or die "\n\tError: cannot open $mapfile\n\n";
		my %uniq_map;
		my $current_id;

		while (<MAP>) {
			if ($_ =~ /^\d/) {
				($current_id) = /^(\d+)/;
			}
			elsif ($_ =~ /^\t\>/) {
				my ($smpl_id) = /^\t(\>\S+)/;
				push @{$uniq_map{$current_id}}, $smpl_id;

			}
		}
		close MAP;

		open ALN, "<$infile" or  die "\n\tError: cannot open $infile\n\n";
		my %smpl_seq_ids;

		while (<ALN>) {
			if ($_ =~ /^\>/) {
				my ($uniq_id) = /^\>(\d+):/;
				my ($length)  = /(\d+bp)$/;
				
				my ($seq) = <ALN> =~ /([aAcCgGtT\-]+)/;

				foreach my $smpl_id (@{$uniq_map{$uniq_id}}) {
					$smpl_seq_ids{$smpl_id} = [$length, $seq];
				}

			}
		}
		close ALN;

		my @smpl_ids = sort keys %smpl_seq_ids;

		foreach my $smpl_id (@smpl_ids) {
			print TMP "$smpl_id:$smpl_seq_ids{$smpl_id}[0]\n$smpl_seq_ids{$smpl_id}[1]\n";
		}

		close TMP;
	}
	print "unique seqs expanded\n" unless $quiet;

# order V and J seqs
	open VIN, "<all_Vs.fa" or die "\n\tError: cannot open all_Vs.fa\n\n";
	open VOR, ">${outdir}all_Vs.ordered.fa" or die "\n\tError: cannot open ${outdir}all_Vs.ordered.fa\n\n";
	my %v_seq_ids;

	while (<VIN>) {
		
		if ($_ =~ /^\>/) {
			my ($id)  = /^\>(\S+):V/;
			my ($seg) = /:(V\S+)$/;
			
			my $seq = <VIN>;
			chomp $seq;

			$v_seq_ids{$id} = [$seg, $seq];
		}
	}
	close VIN;

	my @v_ids = sort keys %v_seq_ids;

	open JIN, "<all_Js.fa" or die "\n\tError: cannot open all_Js.fa\n\n";
	open JOR, ">${outdir}all_Js.ordered.fa" or die "\n\tError: cannot open ${outdir}all_Js.ordered.fa\n\n";

	my %j_seq_ids;

	while (<JIN>) {
		
		if ($_ =~ /^\>/) {
			my ($id)  = /^\>(\S+):J/;
			my ($seg) = /:(J\S+)$/;
			
			my $seq = <JIN>;
			chomp $seq;

			$j_seq_ids{$id} = [$seg, $seq];
		}
	}
	close JIN;

	foreach my $v_id (@v_ids) {

		if ($j_seq_ids{$v_id}) {
			print VOR "\>$v_id:$v_seq_ids{$v_id}[0]\n$v_seq_ids{$v_id}[1]\n";
			print JOR "\>$v_id:$j_seq_ids{$v_id}[0]\n$j_seq_ids{$v_id}[1]\n";
		}
	}
	print "ids ordered and paired\n" unless $quiet;

	close VOR; close JOR;

	system("rm all_[VJ]s.fa");

# match V and J segments
	open VS,  "<${outdir}all_Vs.ordered.fa" or die "\n\tError: cannot open ${outdir}all_Vs.ordered.fa\n\n";
	open JS,  "<${outdir}all_Js.ordered.fa" or die "\n\tError: cannot open ${outdir}all_Js.ordered.fa\n\n";
	open CAT, ">${outdir}all_VJ.cat.fa"     or die "\n\tError: cannot open ${outdir}all_VJ.cat.fa\n\n";

	my $vline;
	my $jline = <JS>;

	while ($vline = <VS>) {

		if ($vline =~ /^\>/ and $jline =~ /^\>/) {
			my ($id)   = $vline =~ /^\>([mz][abcd]\d{2}:\w+):/;
			my ($vseg) = $vline =~ /(V\d{2})/;
			my ($jseg) = $jline =~ /(J[mz]\d)/;
			my ($vlen) = $vline =~ /:(\d+)bp$/;
			my ($jlen) = $jline =~ /:(\d+)bp$/;
			my $vseq = <VS>;
			my $jseq = <JS>;

			my $total_len = $vlen + $jlen;
			chomp ($vseq, $jseq);

			print CAT "\>$id:$vseg:$jseg:$vlen\+$jlen\=${total_len}bp\n$vseq$jseq\n";

			$jline = <JS>;
		}
	}
	print "matching V and J concatenated\n" unless $quiet;

	close VS; close JS; close CAT;

# get unique seqs from the concatenated file
	open CAT, "<${outdir}all_VJ.cat.fa" or die "\n\tError: cannot open ${outdir}all_VJ.cat.fa\n\n";

	my %uniq_cats;
	my %cats_map;

	while (<CAT>) {

		if ($_ =~ /^\>/) {
			my $id  = $_;
			my $seq = <CAT>;
			chomp ($id, $seq);
			$uniq_cats{$seq}++;
			push @{$cats_map{$seq}}, $id;
		}
	}
	close CAT;

	open QFA, ">${outdir}all_VJ.cat.uniq.fa"      or die "\n\tError: cannot open ${outdir}all_VJ.cat.uniq.fa\n\n";
	open QMP, ">${outdir}all_VJ.cat.uniq_map.txt" or die "\n\tError: cannot open ${outdir}all_VJ.cat.uniq_map.txt\n\n";

	my @sorted_cats = sort {$uniq_cats{$b} <=> $uniq_cats{$a}} keys %uniq_cats;
	my $i = 1;

	foreach my $seq (@sorted_cats) {
		my $len = length $seq;

		print QFA "\>$i:N$uniq_cats{$seq}:${len}bp\n$seq\n";
		print QMP "$i\n";

		foreach my $id (@{$cats_map{$seq}}) {
			print QMP "\t$id\n";
		}
		$i++;
	}
	print "concatenated segs collapsed into unique sequences\n" unless $quiet;
	
	close QFA; close MAP;
}
