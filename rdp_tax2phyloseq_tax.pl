#!/usr/bin/perl
# rdp_tax2phyloseq_tax.pl
use strict; use warnings;
use Getopt::Long;

# Use this script to take output from RDP Classifier and make it more manageable for phyloseq {R}.

my $usage = "\n\trdp_tax2phyloseq_tax.pl [-h -o <output PATH>] -i <input TXT>\n\n";

# defaults
my $help;
my $outDir = './';
my $inFile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'i=s'   => \$inFile,
) or die $usage;

die $usage unless $help or $inFile;
if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}

if ($help) {print $usage}
else {
	my ($fileName) = $inFile =~ /(.+)\.txt$/;
	my $outFile = "${outDir}$fileName.phyloseq.txt";

	open OUT, ">$outFile" or die "\n\tError: cannot create $outFile\n\n";
	print OUT "\tDomain\tDomain_support\tPhylum\tPhylum_support\tClass\tClass_support\tSubclass\tSubclass_support\t";
	print OUT "Order\tOrder_support\tSuborder\tSuborder_support\tFamily\tFamily_support\tGenus\tGenus_support\n";

	open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
	while (<INF>) {
		my $taxon;
		my ($domain,   $domain_sup,
			$phylum,   $phylum_sup,
			$class,    $class_sup,
			$subclass, $subclass_sup,
			$order,    $order_sup,
			$suborder, $suborder_sup,
			$family,   $family_sup,
			$genus,    $genus_sup
			) = ('NA') x 16;
		# print "$domain\t$domain_sup\t$phylum\t$phylum_sup\t$class\t$class_sup\t$subclass\t$subclass_sup\t";
		# print "$order\t$order_sup\t$suborder\t$suborder_sup\t$family\t$family_sup\t$genus\t$genus_sup\n";

		($taxon)         = /^(X\d+)/;
		($domain)        = /\"*(\w+)\"*\tdomain/   unless ($_ !~ /domain/);
		($domain_sup)    = /domain\t(\d\.\d+)/     unless ($_ !~ /domain/);
		($phylum)        = /\"*(\w+)\"*\tphylum/   unless ($_ !~ /phylum/);
		($phylum_sup)    = /phylum\t(\d\.\d+)/     unless ($_ !~ /phylum/);
		($class)         = /\"*(\w+)\"*\tclass/    unless ($_ !~ /class/);
		($class_sup)     = /class\t(\d\.\d+)/      unless ($_ !~ /class/);
		($subclass)      = /\"*(\w+)\"*\tsubclass/ unless ($_ !~ /subclass/);
		($subclass_sup)  = /subclass\t(\d\.\d+)/   unless ($_ !~ /subclass/);
		($order)         = /\"*(\w+)\"*\torder/    unless ($_ !~ /order/);
		($order_sup)     = /order\t(\d\.\d+)/      unless ($_ !~ /order/);
		($suborder)      = /\"*(\w+)\"*\tsuborder/ unless ($_ !~ /suborder/);
		($suborder_sup)  = /suborder\t(\d\.\d+)/   unless ($_ !~ /suborder/);
		($family)        = /\"*(\w+)\"*\tfamily/   unless ($_ !~ /family/);
		($family_sup)    = /family\t(\d\.\d+)/     unless ($_ !~ /family/);
		($genus)         = /\"*(\w+)\"*\tgenus/    unless ($_ !~ /genus/);
		($genus_sup)     = /genus\t(\d\.\d+)/      unless ($_ !~ /genus/);

		print OUT "$taxon\t$domain\t$domain_sup\t$phylum\t$phylum_sup\t$class\t$class_sup\t$subclass\t$subclass_sup\t";
		print OUT "$order\t$order_sup\t$suborder\t$suborder_sup\t$family\t$family_sup\t$genus\t$genus_sup\n";
	}
	close INF; close OUT;
}