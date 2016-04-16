#!/usr/bin/perl
# cfb_scoring_data.pl
use strict; use warnings;
use LWP::Simple;
use Getopt::Long;


my $usage = "\n\tcfb_scoring_data.pl [-h -m <master TXT>] -y <YEAR> -w <WEEK>\n\n";

# defaults
my $help;
my $masterFile;
my $year;
my $week;


GetOptions (
	'help!'     => \$help,
	'm=s'       => \$masterFile,
	'y=i'       => \$year,
	'w=i'       => \$week,
	) or die $usage;

die $usage unless $help or ($year and $week);

if ($help) {print $usage}
else {
	my $outFile;
	my $readType;
	if ($masterFile) {
		$outFile = $masterFile;
		$readType = '>>';
	} 
	else {
		$outFile = "cfb_scoring_data_y${year}_w${week}.txt";
		$readType = '>';
	}
	my $scores_url = "http://scores.espn.go.com/college-football/scoreboard/_/year/$year/seasontype/2/week/$week";
	my $content = get $scores_url;
	# get play-by-play url for each game of the week
	my (@pbpURLs) = $content =~ m/(http:\/\/espn\.go\.com\/college-football\/playbyplay\?gameId=\d+)/g;

	open (OUT, $readType, $outFile) or die "\n\tError: cannot open $outFile\n\n";
	unless ($masterFile) {
		print OUT "game.id\taway.team\thome.team\twinning.team\tquarter\tscoring.team\tscore.type\tscore.time.full\tscore.time.min\tscore.time.sec\taway.score.total\thome.score.total\n";
	}
	foreach my $pbpURL (@pbpURLs) {
		my ($gameId) = $pbpURL =~ m/gameId=(\d+)/;
		my $pbpContent = get $pbpURL;
		my ($scoringSum) = $pbpContent =~ m/class\=\"scoring-summary\"(.+article)\>/;
		my $awayTeam;
		my $awayFinalScore;
		my $homeFinalScore;
		my $winningTeam;
		my $homeTeam;
		my $currHomeScore = 0;
		my $currAwayScore = 0;
		my (@quarters) = $pbpContent =~ m/class\=\"quarter\" colspan\=\"\d+\"\>(\w+ *\w*)\</g;
		QTR: for (my $i=0; $i < @quarters; $i++) {
			my $quarterContent;
			if ($i < (@quarters - 1)) {
				($quarterContent) = $scoringSum =~ m/$quarters[$i](.+?)$quarters[$i+1]/;
				if ($i == 0) {
					($awayTeam) = $quarterContent=~ m/class\=\"away\-team\"\>(.+?)\</;
					($awayFinalScore) = $pbpContent =~ m/class\=\"team\-name\"\>$awayTeam\<.+?class\=\"final\-score\"\>(\d+?)\</;
					($homeTeam) = $quarterContent =~ m/class\=\"home\-team\"\>(.+?)\</;
					($homeFinalScore) = $pbpContent =~ m/class\=\"team\-name\"\>$homeTeam\<.+?class\=\"final\-score\"\>(\d+?)\</;
					if ($awayFinalScore > $homeFinalScore) {
						$winningTeam = $awayTeam;
					}
					elsif ($homeFinalScore > $awayFinalScore) {
						$winningTeam = $homeTeam;
					}
					else {
						$winningTeam = 'Tie';
					}
				}
			} else {
				($quarterContent) = $scoringSum =~ m/$quarters[$i](.+)article/;
			}
			next QTR unless $quarterContent;
			# print "$pbpURL\n$quarters[$i]\n$quarterContent\n\n";
			my (@scoreTypes) = $quarterContent =~ m/class\=\"score\-type\"\>(.+?)\</g;
			my $lenScoreTypes = @scoreTypes;
			my (@scoreTimes) = $quarterContent =~ m/class\=\"time\-stamp\"\>(.+?)\</g;
			if ($quarters[$i] =~ m/Overtime/i) {@scoreTimes = ('NA:NA') x $lenScoreTypes}
			my (@awayScores) = $quarterContent =~ m/class\=\"away\-score\"\>(\d+?)</g;
			my (@homeScores) = $quarterContent =~ m/class\=\"home\-score\"\>(\d+?)</g;
			
			for (my $j=0; $j < @scoreTypes; $j++) {
				my $quarter;
				if ($quarters[$i] =~ /Quarter/) {
					($quarter) = $quarters[$i] =~ m/(\w+) Quarter/;
				} 
				else {
					$quarter = $quarters[$i];
				}

				my $awayScoreDiff = $awayScores[$j] - $currAwayScore;
				my $homeScoreDiff = $homeScores[$j] - $currHomeScore;
				$currAwayScore = $awayScores[$j];
				$currHomeScore = $homeScores[$j];

				my $scoringTeam = $awayTeam;
				if ($awayScoreDiff == 0) {
					$scoringTeam = $homeTeam;
				}
				my ($scoreTimeMin, $scoreTimeSec) = split(':', $scoreTimes[$j]);
				print OUT "$gameId\t$awayTeam\t$homeTeam\t$winningTeam\t$quarter\t$scoringTeam\t$scoreTypes[$j]\t$scoreTimes[$j]\t$scoreTimeMin\t$scoreTimeSec\t$awayScores[$j]\t$homeScores[$j]\n";
			} 
		}
		# print "$awayTeam\-$homeTeam\n";
	}
	close OUT;
}