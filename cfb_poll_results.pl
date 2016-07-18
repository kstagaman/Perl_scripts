#!/usr/bin/perl
# cfb_poll_results.pl
use strict; use warnings;
use LWP::Simple;
use Getopt::Long;

my $usage = "\n\tcfb_poll_results.pl [-h -s -l] -y <YEAR> -w <WEEK> \n\n";

# defaults
my $help;
my $suppress;
my $line_only;
my $year;
my $week;

GetOptions (
	'help!'      => \$help,
	'suppress!'  => \$suppress,
	'line_only!' => \$line_only,
	'y=i'        => \$year,
	'w=i'        => \$week,
	) or die $usage;

die $usage unless $help or ($year and $week);

if ($help) {print $usage}
else {
	# global variables
	my $rcfb_pollTbl = "/Users/keaton/Documents/CFB\ poll\ prediction/rCFB_poll_tables/rcfb_pollTbl_$year\_$week.txt";
	my $week_file = "/Users/keaton/Documents/CFB\ poll\ prediction/Weekly_results/$year/cfb_poll_results.$year-wk$week.txt";
	my $master_file = "/Users/keaton/Documents/CFB\ poll\ prediction/cfb_poll_results.all.txt";
	open WKF, ">$week_file" or die "\n\tError: cannot open $week_file\n\n";
	open MAF, ">>$master_file" or die "\n\tError: cannot open $master_file\n\n" unless ($suppress);

	close RCFB;

	my $scores_url = "http://scores.espn.go.com/college-football/scoreboard/_/year/$year/seasontype/2/week/$week";
	my %Poll_names = ("http://espn.go.com/college-football/rankings/_/poll/1/year/$year/week/$week" => 'AP',
					  "http://espn.go.com/college-football/rankings/_/poll/2/year/$year/week/$week" => 'Coaches',
					  "http://espn.go.com/college-football/powerrankings/_/year/$year/week/$week"   => 'ESPN',
					   $rcfb_pollTbl                                                                => 'rCFB',
					);
	my @Vote_urls = sort {$Poll_names{$a} cmp $Poll_names{$b}} keys %Poll_names;
	my @game_scores;
	my @game_lines;
	my $game_counter = 0;

	### Get the scores for each top 25 game for the week ###
	$|++; print "Scores and game lines... ";
	my $score_content = get $scores_url;

	my ($scoreTbl) = $score_content =~ m/(<script>window.espn.scoreboardData.+?<\/script>)/;
	my @scores = $scoreTbl =~ m/\"score\":\"(\d+)\"/g;
	my @teams = $scoreTbl =~ m/\"location\":\"(.+?)\"/g;
	my @team_abrvs = $scoreTbl =~ m/\"abbreviation\":\"([A-Z\&]+)\",\"[cv][oe]/g;
	# print "@team_abrvs\n";
	my %teams_by_abrv;
	my @boxscore_urls = $scoreTbl =~ m/(http:\/\/espn\.go\.com\/college-football\/game\?gameId=\d+)/g;

	for (my $i=0; $i < @teams; $i+=2) {
		$game_scores[$game_counter] = {teamA  => $teams[$i],
									   teamB  => $teams[$i+1],
									   scoreA => $scores[$i],
									   scoreB => $scores[$i+1]};
		if($team_abrvs[$i] eq "TAMU") {$team_abrvs[$i] = "TA&M"}
		$teams_by_abrv{$team_abrvs[$i]} = $teams[$i];
		if($team_abrvs[$i+1] eq "TAMU") {$team_abrvs[$i+1] = "TA&M"}
		$teams_by_abrv{$team_abrvs[$i+1]} = $teams[$i+1];
		my $game_info = get $boxscore_urls[$game_counter];
		# print "$boxscore_urls[$game_counter]\n";
		my ($favored_team) = $game_info =~ m/Line: ([A-Z\&]+)/;
		if (!$favored_team or $favored_team eq "EVEN") {$favored_team = "NA"}
		if ($favored_team eq "TAMU") {$favored_team = "TA&M"}
		my ($game_line) = $game_info =~ m/Line: [A-Z\&]+ ([\-\d\.]+)/;
		if (!$game_line) {$game_line = 0}
		# print "$favored_team=$game_line\n";
		$game_lines[$game_counter] = {faveAbrv => $favored_team, line => $game_line};
		print "$week: $teams[$i] ($team_abrvs[$i]) $scores[$i] - $teams[$i+1] ($team_abrvs[$i+1]) $scores[$i+1], Line: $favored_team $game_line\n";
		$game_counter++;
	}

	print WKF "year\ttype\tpoll\tweek\tteam1\tteam2\tscore1\tscore2\trank1\trank2\tdiff_rank\tdiff_score\n";

	my $type = "line";
	my $poll = "line";
	my $rank1 = "NA";
	my $rank2 = "NA";
	my ($team1, $team2, $score1, $score2);

	for (my $i=0; $i < @game_scores; $i++) {
		if ($game_lines[$i]->{faveAbrv} ne "NA") {
			print "$game_lines[$i]->{faveAbrv}\n";
			if ($teams_by_abrv{$game_lines[$i]->{faveAbrv}} eq $game_scores[$i]->{teamA}) {
				# $|++; print "situation 1\n";
				$team1 = $game_scores[$i]->{teamA};
				$team2 = $game_scores[$i]->{teamB};
				$score1 = $game_scores[$i]->{scoreA};
				$score2 = $game_scores[$i]->{scoreB};
				
			} else {
				# $|++; print "situation 2\n";
				$team1 = $game_scores[$i]->{teamB};
				$team2 = $game_scores[$i]->{teamA};
				$score1 = $game_scores[$i]->{scoreB};
				$score2 = $game_scores[$i]->{scoreA};
			} 
		} else {
			if ($game_scores[$i]->{scoreA} > $game_scores[$i]->{scoreB}) {
				# $|++; print "situation 3\n";
				$team1 = $game_scores[$i]->{teamA};
				$team2 = $game_scores[$i]->{teamB};
				$score1 = $game_scores[$i]->{scoreA};
				$score2 = $game_scores[$i]->{scoreB};
			}
			elsif ($game_scores[$i]->{scoreB} > $game_scores[$i]->{scoreA}) {
				# $|++; print "situation 4\n";
				$team1 = $game_scores[$i]->{teamB};
				$team2 = $game_scores[$i]->{teamA};
				$score1 = $game_scores[$i]->{scoreB};
				$score2 = $game_scores[$i]->{scoreA};
			}
		}
		my $diff_rank = $game_lines[$i]->{line} * -1;
		my $diff_score = $score1 - $score2;

		print WKF "$year\t$type\t$poll\t$week\t$team1\t$team2\t$score1\t$score2\t$rank1\t$rank2\t$diff_rank\t$diff_score\n";   #
		print MAF "$year\t$type\t$poll\t$week\t$team1\t$team2\t$score1\t$score2\t$rank1\t$rank2\t$diff_rank\t$diff_score\n" unless ($suppress);  
	}
	$|++; print "done\n";

	### Get poll results available on ESPN ###
	unless ($line_only) {
		foreach my $Vote_url (@Vote_urls) {
			my $type;
			if ($Vote_url =~ /fei/) {$type = "stat"}
			else {$type = "poll"}
			my %team_votes = get_team_votes($Vote_url);

			# my @teams = sort {$team_votes{$b} <=> $team_votes{$a}} keys %team_votes; 
			# foreach my $team (@teams) {
			# 	print "$team\t$team_votes{$team}\n";
			# }

		$|++; print "$Vote_url:...";


			for (my $i=0; $i < @game_scores; $i++) {
				my ($team1, $team2, $score1, $score2, $rank1, $rank2);

				unless (defined $team_votes{$game_scores[$i]->{teamA}}) {
					if ($type eq "poll") {$team_votes{$game_scores[$i]->{teamA}} = 0}
					else {$team_votes{$game_scores[$i]->{teamA}} = '-0.4'}
					# print "1: $game_scores[$i]->{teamA}\n";
				}
				unless (defined $team_votes{$game_scores[$i]->{teamB}}) {
					if ($type eq "poll") {$team_votes{$game_scores[$i]->{teamB}} = 0}
					else {$team_votes{$game_scores[$i]->{teamB}} = '-0.4'}
					# print "2: $game_scores[$i]->{teamB}\n";
				}

				if ($team_votes{$game_scores[$i]->{teamA}} > $team_votes{$game_scores[$i]->{teamB}}) {
					$team1 = $game_scores[$i]->{teamA};
					$team2 = $game_scores[$i]->{teamB};
					$score1 = $game_scores[$i]->{scoreA};
					$score2 = $game_scores[$i]->{scoreB};
					$rank1 = $team_votes{$game_scores[$i]->{teamA}};
					$rank2 = $team_votes{$game_scores[$i]->{teamB}};
				}
				elsif ($team_votes{$game_scores[$i]->{teamB}} > $team_votes{$game_scores[$i]->{teamA}}) {
					$team1 = $game_scores[$i]->{teamB};
					$team2 = $game_scores[$i]->{teamA};
					$score1 = $game_scores[$i]->{scoreB};
					$score2 = $game_scores[$i]->{scoreA};
					$rank1 = $team_votes{$game_scores[$i]->{teamB}};
					$rank2 = $team_votes{$game_scores[$i]->{teamA}};
				}
				elsif ($team_votes{$game_scores[$i]->{teamA}} == $team_votes{$game_scores[$i]->{teamB}}) {
					if ($game_scores[$i]->{scoreA} > $game_scores[$i]->{scoreB}) {
						$team1 = $game_scores[$i]->{teamA};
						$team2 = $game_scores[$i]->{teamB};
						$score1 = $game_scores[$i]->{scoreA};
						$score2 = $game_scores[$i]->{scoreB};
						$rank1 = $team_votes{$game_scores[$i]->{teamA}};
						$rank2 = $team_votes{$game_scores[$i]->{teamB}};
					}
					elsif ($game_scores[$i]->{scoreB} > $game_scores[$i]->{scoreA}) {
						$team1 = $game_scores[$i]->{teamB};
						$team2 = $game_scores[$i]->{teamA};
						$score1 = $game_scores[$i]->{scoreB};
						$score2 = $game_scores[$i]->{scoreA};
						$rank1 = $team_votes{$game_scores[$i]->{teamB}};
						$rank2 = $team_votes{$game_scores[$i]->{teamA}};
					}
				}
				# print "$team1\t$team2\t$score1\t$score2\t$rank1\t$rank2\n";
				my $diff_rank = $rank1 - $rank2;
				my $diff_score = $score1 - $score2;

	  # 		print     " year\t type\t         poll\t          week\t team1\t team2\t score1\t score2\t rank1\t rank2\t diff_rank\t diff_score\n"
				print WKF "$year\t$type\t$Poll_names{$Vote_url}\t$week\t$team1\t$team2\t$score1\t$score2\t$rank1\t$rank2\t$diff_rank\t$diff_score\n";   #
				print MAF "$year\t$type\t$Poll_names{$Vote_url}\t$week\t$team1\t$team2\t$score1\t$score2\t$rank1\t$rank2\t$diff_rank\t$diff_score\n" unless ($suppress);   #
			}
			$|++; print "done\n";
		}
	}
	close WKF;
	close MAF unless ($suppress);
}

sub get_team_votes {
	my ($url) = @_;
	# print "$url\n";
	my $content = get $url;
	my @teams;
	my @votes;
	my %team_votes;

	if ($url =~ /espn.+\/rankings/) {
		my ($pollTbl) = $content =~ m/(<div class="responsive-table-wrap.+?<\/div>)/;
		(@teams) = $pollTbl =~ m/title=\"(.+?)\"/g;
		(@votes) = $pollTbl =~ m/<td>(\d+)<\/td>/g;

		my ($othersTbl) = $content =~ m/Others receiving votes: <\/span>(.+)<\/p>/;
		my @otherTeams = $othersTbl =~ m/\ *(.+?)\ \d+\,/g;
		my @otherVotes = $othersTbl =~ m/(\d+)\,/g;
		push @teams, @otherTeams;
		push @votes, @otherVotes;
	}
	elsif ($url =~ /espn.+\/powerrankings/) {
		$content =~ s/\R//g;
		my ($pollTbl) = $content =~ m/(<script>jQuery.getScriptCache.+?\/javascript">)/;
		(@teams) = $pollTbl =~ m/alt=\"(.+?)\"/g;
		(@votes) = $pollTbl =~ m/align="center">(\d+)<\/td>/g;

		my ($othersTbl) = $pollTbl =~ m/Others receiving votes:(.+?)<\/td>/;
		my @otherTeams = $othersTbl =~ m/\ *(.+?)\ \(\d+\)\,*/g;
		my @otherVotes = $othersTbl =~ m/\((\d+)\)/g;
		push @teams, @otherTeams;
		push @votes, @otherVotes;
	}
	else {
		open RCFB, "<$url" or die "\n\tError: cannot open $url\n\n";
		$_ = <RCFB>;
		while (<RCFB>) {
			if ($_ =~ /^\d/) {
				my ($team) = m/^\d+\t\ *(.+?)\t/;
				if ($team =~ /\d/) {
					($team) = $team =~ /(.+?)\ \(/;
				}
				my ($vote) = m/(\d+)$/;
				push @teams, $team;
				push @votes, $vote;
			}
			else {
				my @otherTeams = $_ =~ m/\ *(.+?)\ \d+\,*/g;
				my @otherVotes = $_ =~ m/(\d+)\,*/g;
				push @teams, @otherTeams;
				push @votes, @otherVotes;
			}
		}
	}
	@team_votes{@teams} = @votes;
	# foreach my $team (@teams) {
	# 	print "$team: $team_votes{$team}\n";
	# }
	return %team_votes;
}