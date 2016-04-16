#!/usr/bin/perl
# cfb_poll_results.pl
use strict; use warnings;
use LWP::Simple;
use Getopt::Long;

my $usage = "\n\tcfb_poll_results.pl [-h -s] -y <YEAR> -w <WEEK> \n\n";

# defaults
my $help;
my $suppress;
my $year;
my $week;

GetOptions (
	'help!'     => \$help,
	'suppress!' => \$suppress,
	'y=i'       => \$year,
	'w=i'       => \$week,
	) or die $usage;

die $usage unless $help or ($year and $week);

if ($help) {print $usage}
else {
	# global variables
	my $rcfb_url;
	my $week_file = "/Users/keaton/Documents/CFB\ poll\ prediction/Weekly_results/$year/cfb_poll_results.$year-wk$week.txt";
	my $master_file = "/Users/keaton/Documents/CFB\ poll\ prediction/cfb_poll_results.all.txt";
	open WKF, ">$week_file" or die "\n\tError: cannot open $week_file\n\n";
	open MAF, ">>$master_file" or die "\n\tError: cannot open $master_file\n\n" unless ($suppress);

	open RCFB, "</Users/keaton/Documents/CFB\ poll\ prediction/rcfb_poll_urls.txt" or die "\n\tError: cannot open /Users/keaton/Documents/CFB\ poll\ prediction/rcfb_poll_urls.txt\n\n";

	while (<RCFB>) {
		my $url = $_;
		chomp $url;
		if ($url =~ /\/week_${week}_.*$year/) {
			die "\n\tr/CFB poll URL has to start with http, not https\n\n" if ($url =~ /https/);
			$rcfb_url = $url;
		}
	}
	close RCFB;

	my $scores_url = "http://scores.espn.go.com/ncf/scoreboard?seasonYear=$year&seasonType=2&weekNumber=$week";

	my %Poll_names = ("http://espn.go.com/college-football/rankings/_/poll/1/year/$year/week/$week" => 'AP',
					  "http://espn.go.com/college-football/rankings/_/poll/2/year/$year/week/$week" => 'Coaches',
					  "http://espn.go.com/college-football/powerrankings/_/year/$year/week/$week"   => 'ESPN',
					   $rcfb_url                                                                    => 'rCFB',
					); #"/Users/keaton/Documents/CFB\ poll\ prediction/Fei_html_files/$year-fei.html" => 'FEI',

	my @Vote_urls = sort {$Poll_names{$a} cmp $Poll_names{$b}} keys %Poll_names;
	my @game_scores;
	my $game_counter = 0;

	### Get the scores for each top 25 game for the week ###

	my $score_content = get $scores_url;

	my @current_teams;
	my @current_scores;
	# print "$team_counter\n";

	for my $line (split qr/\R/, $score_content) {
		# print "$line\n";

		if ($line =~ /games-date/) {
			my $team_counter = 0;
			# print "$line\n";

			for my $chunk (split '><', $line) {
				# print "$team_counter\t$chunk\n";
				# print "$chunk\n";

				if ($chunk =~ /team\/_\/id/) {
					# print "$chunk\n";
					my ($team) = $chunk =~ /\">(.+)<\/a>/;
					# print "$team\n";
					$current_teams[$team_counter] = $team;
				}
				elsif ($chunk =~ /class=\"final\" id/) {
					# print "$chunk\n";
					my ($score) = $chunk =~ /\">(\d+)<\/li/;
					# print "$score\n";
					$current_scores[$team_counter] = $score;
					$team_counter = ($team_counter + 1) % 3;
				}
				if ($team_counter == 2) {
					# print "$current_teams[0]\t$current_scores[0]\n";   #
					# print "$current_teams[1]\t$current_scores[1]\n\n"; #
					$game_scores[$game_counter] = {teamA  => $current_teams[0],
												   teamB  => $current_teams[1],
												   scoreA => $current_scores[0],
												   scoreB => $current_scores[1]};
					$game_counter++;
					$team_counter = ($team_counter + 1) % 3; 
				}
			}
		}
	}


	### Get poll results available on ESPN ###

print WKF "year\ttype\tpoll\tweek\tteam1\tteam2\tscore1\tscore2\trank1\trank2\tdiff_rank\tdiff_score\n";   #

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
			}
			unless (defined $team_votes{$game_scores[$i]->{teamB}}) {
				if ($type eq "poll") {$team_votes{$game_scores[$i]->{teamB}} = 0}
				else {$team_votes{$game_scores[$i]->{teamB}} = '-0.4'}
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
			my $diff_rank = $rank1 - $rank2;
			my $diff_score = $score1 - $score2;

  # 		print     " year\t type\t         poll\t          week\t team1\t team2\t score1\t score2\t rank1\t rank2\t diff_rank\t diff_score\n"
			print WKF "$year\t$type\t$Poll_names{$Vote_url}\t$week\t$team1\t$team2\t$score1\t$score2\t$rank1\t$rank2\t$diff_rank\t$diff_score\n";   #
			print MAF "$year\t$type\t$Poll_names{$Vote_url}\t$week\t$team1\t$team2\t$score1\t$score2\t$rank1\t$rank2\t$diff_rank\t$diff_score\n" unless ($suppress);   #
		}
		$|++; print "done\n";
	}
	close WKF;
	close MAF unless ($suppress);
}

sub get_team_votes {
	my ($url) = @_;
	# print "$url\n";
	my $content;
	unless ($url =~ /fei/) {
		$content = get $url;
	}
	# print "$content\n";
	my %team_votes;
	if ($url =~ /espn/) {
		my $page = get $url;
		my $te = HTML::TableExtract->new(headers => ["Team", "Pts"]);
		$te->parse($html_page);
		foreach my $ts ($te->tables) {
			foreach my $row ($ts->rows) {
				my ($team) = @{$row}[0] =~ /([\w\ \&]+)/;
				$team_votes{$team}= @{$row}[1];
			}
		}
	}
	elsif ($url =~ /reddit/) {
		my $current_team;
		my $reddit_type = 'new';

		LINE: for my $line (split qr /\R/, $content) {
			# print "$line\n";
			if ($line =~ /<pre><code>/) {$reddit_type = 'old'}

			if ($reddit_type eq 'new') {
				last LINE if (defined $team_votes{$current_team} and $line eq '</tbody></table>');
				if ($line =~ /<td align=\"left\"><a href=\"\#*f*/) {
					# print "$line\n";
					$line =~ s/&amp;/&/;
					($current_team) = $line =~ /a>\s+(\w+\s*\w*\&*\w*)\s{0,1}/;
					$current_team =~ s/\s$//;
					# print "$current_team\t"
					# print "$current_team\n";
				}
				if ($line =~ /align=\"(left|center|right)\">\d+<\/td/) {
					my ($score) = $line =~ />(\d+)</;
					# print "$score\n";
					unless (defined $team_votes{$current_team}) {$team_votes{$current_team} = $score}
				}
				if ($line =~ /Other.*s Receiving Votes/i) {
					my ($others) = $line =~ /:\s+(.+)\s*<\/p>/;
					# print "$others\n";

					for my $each_other (split ', ', $others) {
						my ($team) = $each_other =~ /(.+)\s\d/;
						my ($votes) = $each_other =~ /$team\s(\d+)/;
						$team =~ s/&amp;/&/;
						$team_votes{$team} = $votes;
					}
					last LINE;
				}
			}
			else {

				if ($line =~ /^\d/) {
					$line =~ s/&amp;/&/;
					my ($team) = $line =~ /^\d+\s+(\w+\s{0,1}[\w\&]*)/;
					$team =~ s/\s$//;
					my ($votes) = $line =~ /\-\s+(\d+)$/;
					# print "$team\t$votes\n";
					$team_votes{$team} = $votes;
				}
			}
			if ($line =~ /Other.*s Receiving Votes/i) {
				my ($others) = $line =~ /:\s+(.+)\s*<\/p>/;
				# print "$others\n";

				for my $each_other (split ', ', $others) {
					my ($team) = $each_other =~ /(.+)\s\d/;
					my ($votes) = $each_other =~ /$team\s(\d+)/;
					$team =~ s/&amp;/&/;
					# print "$team\t$votes\n";
					$team_votes{$team} = $votes;
				}
				last LINE;
			}
		}
	}
	elsif ($url =~ /fei/) {
		### Add check for existence of fei file
		my $page = $url;
		my $fei_week = "W$week";
		my $te = HTML::TableExtract->new(headers => ["Team", $fei_week]);
		$te->parse_file($page);
		foreach my $ts ($te->tables) {
			foreach my $row ($ts->rows) {
				next if (!@{$row}[0] or !@{$row}[1]);
				next if (@{$row}[0] eq "TEAM" or @{$row}[1] eq $fei_week);
				$team_votes{@{$row}[0]} = @{$row}[1];
			}
		}

	return %team_votes;
}



