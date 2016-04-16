#!/usr/bin/perl
# ncaaf_schedule.pl
use warnings;
use Getopt::Long;
use LWP::Simple;
use DateTime;

my $usage = "\n\tncaaf_schedule.pl [-h -o <output PATH> -f <FILE>] -y <YEAR> -w <WEEK>\n\n";

# defaults
my $help;
my $outDir = './';
my $file;
my $year;
my $week;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'f=s'   => \$file,
	'y=i'   => \$year,
	'w=i'   => \$week,
	) or die $usage;

if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}
die $usage unless $help or ($year and $week);

if ($help) {print $usage}
else {
	# 'global' variables
	# my @weeks = split ('-', $week_str);
	my $outFile;
	my $outputOperator;
	if ($file) {
		$outputOperator = '>>';
		$outFile = $file;
	} else {
		$outputOperator = '>';
		$outFile = "ncaaf_schedule_y${year}_w${week}.txt";
	}

	open (OUT, $outputOperator, $outFile) or die "\n\tError: cannot open $outFile\n\n";
	if (!$file) {print OUT "Subject\tStart Date\tEnd Date\tAll Day Event\tDescription\tLocation\tPrivate\tAdded to Calendar?\tEventID\n";}

	my $url = "http://espn.go.com/college-football/schedule/_/year/$year/group/80/week/$week";

	my $html_page = get $url or die "\n\tError: cannot get $url\n\n";
	$html_page =~ tr/\r\n//d;

	my @tables = $html_page =~ m/<table.+?<\/table>/g;
	foreach my $table (@tables) {
		# print "$table\n\n";
		my @elements = $table =~ m/<td.+?<\/td>/g;
		# print "@elements\n\n";

		for(my $i=0; $i < @elements - 5; $i += 6) {
			# print "$elements[$i]\n\n";
			my ($away_team) = $elements[$i]   =~ m/<span>(.+)<\/span>/;
			my ($home_team) = $elements[$i+1] =~ m/<span>(.+)<\/span>/;
			my ($raw_time)  = $elements[$i+2] =~ m/data-date=\"(.+?)\">/;
			# print "$raw_time\n\n";
			my (@channels);
			if    ($elements[$i+3] =~ m/alt=/)              {(@channels)    = $elements[$i+3] =~ m/alt=\"(\w+)\"/g}
			elsif ($elements[$i+3] =~ m/class=\"network\"/) {($channels[0]) = $elements[$i+3] =~ m/\"network\">(\w+)</}
			else                                            {($channels[0]) = 'NA'}

			my ($raw_year)     = $raw_time =~ m/(\d+)\-\d+\-\d+T/;
			my ($raw_month)    = $raw_time =~ m/\d+\-(\d+)\-\d+T/;
			my ($raw_day)      = $raw_time =~ m/\d+\-\d+\-(\d+)T/;
			my ($raw_hour)     = $raw_time =~ m/T(\d{2}):/;
			my ($raw_minute)   = $raw_time =~ m/T\d{2}:(\d{2})/;
			# print "$raw_year-$raw_month-$raw_day\n\n";

			my $raw_dt1 = DateTime->new(
				year   => $raw_year, 
				month  => $raw_month, 
				day    => $raw_day, 
				hour   => $raw_hour, 
				minute => $raw_minute
				);
			my $raw_dt2 = DateTime->new(
				year   => $raw_year, 
				month  => $raw_month, 
				day    => $raw_day, 
				hour   => $raw_hour, 
				minute => $raw_minute
				);
			# print "$raw_dt\n";
			my $pt_strt_dt = $raw_dt1->subtract(hours => 7);
			my $pt_end_dt  = $raw_dt2->subtract(hours => 4);
			my $pt_strt_date = $pt_strt_dt->ymd('-');
			my $pt_strt_time = $pt_strt_dt->hms(':');
			my $pt_end_date  = $pt_end_dt->ymd('-');
			my $pt_end_time  = $pt_end_dt->hms(':');

			my $channel_str;
			if (@channels > 1) {$channel_str = join(' & ', @channels)}
			else               {$channel_str = $channels[0]}

			print OUT "$away_team \@ $home_team\t$pt_strt_date $pt_strt_time\t$pt_end_date $pt_end_time\tFALSE\t\t$channel_str\tFALSE\t\t\n";
		}
	}
	close OUT;
}
