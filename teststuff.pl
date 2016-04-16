#!/usr/bin/perl
# teststuff.pl
use warnings; use strict;
# use String::Approx 'amatch'; ### USE THIS FOR MATCHING PRIMERS
# use String::Approx 'adist';
# use String::Approx 'adistr';
# use Algorithm::Combinatorics 'permutations';
# use Scalar::Util 'reftype';
use LWP::Simple;
# use LWP::UserAgent;
# use HTML::TableExtract;
# use DateTime;

my $year = 2015;
my $week = 1;
# my $scores_url = "http://scores.espn.go.com/college-football/scoreboard/_/year/$year/seasontype/2/week/$week";
# my $ua = LWP::UserAgent->new();
# my $req = new HTTP::Request GET => "$scores_url
# +";
# my $res = $ua->request($req);
# my $score_content = $res->content;
# print "$score_content\n";

# my $rcfb_pollTbl = "/Users/keaton/Documents/CFB\ poll\ prediction/rCFB_poll_tables/rcfb_pollTbl_2015\_4.txt";
# my %team_votes;
# open RCFB, "<$rcfb_pollTbl" or die "\n\tError: cannot open $rcfb_pollTbl\n\n";
# my @teams;
# my @votes;
# $_ = <RCFB>;
# while (<RCFB>) {
# 	if ($_ =~ /^\d/) {
# 		my ($team) = m/^\d+\t\ *([\w\&\ ]+)/;
# 		my ($vote) = m/(\d+)$/;
# 		push @teams, $team;
# 		push @votes, $vote;
# 	}
# 	else {
# 		my @otherTeams = $_ =~ m/\ *(.+?)\ \d+\,*/g;
# 		my @otherVotes = $_ =~ m/(\d+)\,*/g;
# 		push @teams, @otherTeams;
# 		push @votes, @otherVotes;
# 	}
# 	@team_votes{@teams} = @votes;
# }
# my @game_scores;
# my $game_counter = 0;
my $score_content = get "http://scores.espn.go.com/college-football/scoreboard/_/year/$year/seasontype/2/week/$week";
print "$score_content\n";
# my ($scoreTbl) = $score_content =~ m/(<script>window.espn.scoreboardData.+?<\/script>)/;
# # print "$scoreTbl\n";
# my @scores = $scoreTbl =~ m/\"score\":\"(\d+)\"/g;
# # print "@scores\n";
# my @teams = $scoreTbl =~ m/\"location\":\"(.+?)\"/g;
# # print "@teams\n";

# for (my $i=0; $i < @teams; $i+=2) {
# 	$game_scores[$game_counter] = {teamA  => $teams[$i],
# 								   teamB  => $teams[$i+1],
# 								   scoreA => $scores[$i],
# 								   scoreB => $scores[$i+1]};
# 	$game_counter++;
# }

# # foreach my $game (@game_scores) {
# # 	print "$game->{teamA}: $game->{scoreA} | $game->{teamB}: $game->{scoreB}\n";
# # }
# my $url = "http://espn.go.com/college-football/rankings/_/poll/1/year/2015/week/1";
# my $content = get $url;
# 	my %team_votes;
# 	if ($url =~ /espn/) {
# 		my ($pollTbl) = $content =~ m/(<div class="responsive-table-wrap.+?<\/div>)/;
# 		my (@teams) = $pollTbl =~ m/title=\"(.+?)\"/g;
# 		my (@votes) = $pollTbl =~ m/<td>(\d+)<\/td>/g;
# 		@team_votes{@teams} = @votes;
# 		my ($othersTbl) = $content =~ m/Others receiving votes: <\/span>(.+)<\/p>/;
# 		my @otherTeams = $othersTbl =~ m/\ *(.+?)\ \d+\,/g;
# 		my @otherVotes = $othersTbl =~ m/(\d+)\,/g;
# 		@team_votes{@otherTeams} = @otherVotes;
# 		push @teams, @otherTeams;
# 		foreach my $team (@teams) {
# 			print "$team: $team_votes{$team}\n";
# 		}
# 	}


# my $html_page = get "http://espn.go.com/college-football/schedule";
# $html_page =~ tr/\r\n//d;
# my @tables = $html_page =~ m/<table.+?<\/table>/g;
# foreach my $table (@tables) {
# 	# print "$table\n\n";
# 	my @elements = $table =~ m/<td.+?<\/td>/g;
# 	# print "@elements\n\n";

# 	for(my $i=0; $i < @elements - 5; $i += 6) {
# 		# print "$elements[$i]\n\n";
# 		my ($away_team) = $elements[$i]   =~ m/<span>(.+)<\/span>/;
# 		my ($home_team) = $elements[$i+1] =~ m/<span>(.+)<\/span>/;
# 		my ($raw_time)  = $elements[$i+2] =~ m/data-date=\"(.+?)\">/;
# 		my (@channels);
# 		if    ($elements[$i+3] =~ m/alt=/)              {(@channels)    = $elements[$i+3] =~ m/alt=\"(\w+)\"/g}
# 		elsif ($elements[$i+3] =~ m/class=\"network\"/) {($channels[0]) = $elements[$i+3] =~ m/\"network\">(\w+)</}
# 		else                                            {($channels[0]) = 'NA'}

# 		my ($raw_year)     = $raw_time =~ m/(\d+)\-\d+\-\d+T/;
# 		my ($raw_month)    = $raw_time =~ m/\d+\-(\d+)\-\d+T/;
# 		my ($raw_day)      = $raw_time =~ m/\d+\-\d+\-(\d)+T/;
# 		my ($raw_hour)     = $raw_time =~ m/T(\d{2}):/;
# 		my ($raw_minute)   = $raw_time =~ m/T\d{2}:(\d{2})/;

# 		my $raw_dt = DateTime->new(
# 			year   => $raw_year, 
# 			month  => $raw_month, 
# 			day    => $raw_day, 
# 			hour   => $raw_hour, 
# 			minute => $raw_minute
# 			);
# 		# print "$raw_dt\n";
# 		my $pt_dt = $raw_dt->subtract(hours => 7);
# 		print "$pt_dt: $away_team at $home_team on @channels\n\n";
# 	}
# }





# my $week = "W1";
# my $html_page = get "http://espn.go.com/college-football/schedule";
# my $te = HTML::TableExtract->new(slice_columns => 0, keep_html => 1);
# $te->parse($html_page);
# my $tr = $te->tables_report(1,0);
# print "$tr\n";
# print "\$te: $te\n";
# foreach my $ts ($te->tables) {
# 	# print "$ts\n";
# 	foreach my $row ($ts->rows) {
# 		# next if (!@{$row}[0] or !@{$row}[1]);
# 		# next if (@{$row}[0] eq "Team" or @{$row}[1] eq "Pts");
# 		# my $row_string = join ("\t", @{$row});
# 		# my ($matchup) = @{$row}[0] =~ /([\w\ \&]+)/;
# 		print "@{$row}\n\n";
# 	}
# }


# my $smplseq = "smpl-sequence";
# my ($smpl, $seq) = split('-', $smplseq);
# print "sample: $smpl\nseq: $seq\n";
# # my @test = ('smpl1', 'smpl2');
# # print "test: @test\n";

# my %smpls_by_seq = ('abc' => ['smpl1', 'smpl2'], 'def' => ['smpl1', 'smpl2']);
# print "@{$smpls_by_seq{'abc'}}\n";

# my @uniq_seqs = ('abc', 'def');
# foreach my $uniq_seq (@uniq_seqs) {
# 	my @smplseqs = map{"@{$smpls_by_seq{$uniq_seq}}[$_]-$uniq_seq"} 0..$#{$smpls_by_seq{$uniq_seq}};
# 	print "smplseqs: @smplseqs\n";
# }

# my %seq_cts = ('abc' => 3, 'def' => 4);
# my @seqs = ('abc', 'def');
# my @cts = @seq_cts{@seqs};
# print "cts: @cts\n";



# for fa in *fasta; do smpl=`echo $fa | cut -d '.' -f 1`; name=`echo $fa | cut -d '.' -f 1-4`; sed "s/^>/>$smpl\-/g" $fa > With_smpl_headers/$name.fasta; echo $fa; done


# my $operator = '>';

# if (eval ("4 $operator 2")) {
# 	print "TRUE\n";
# }
# else {
# 	print "FALSE\n";
# }


# my @array = ('one', 'two', 'three', 'four', 'five');
# print "@array\n";
# my %hash;
# # for my $item (@array) {
# # 	$hash{$item} = 0;
# # }

# $hash{$_} = 0 for @array;

# for (values %hash) { s/\d+/1/g };

# foreach my $item (@array) {
# 	print "$hash{$item}\n";
# }

# # my $ua = LWP::UserAgent->new();
# # my $req = new HTTP::Request GET => 'http://www.bcftoys.com/2014-fei
# # +';
# # my $res = $ua->request($req);
# # my $content = $res->content;

# # use Math::GSL::Randist qw/:all/;
# # use Math::GSL::RNG;

# my %team_votes;  ##



# my $year = 2013;
# my $week = 2;

# my $url = 'http://collegefootball.ap.org/poll/2013/2';
# my $content = get $url;

# my $current_team;
# for my $line (split qr /\R/, $content) {
# 	# print "$line\n

# 	for my $chunk (split '><', $line) {
# 		# print "$chunk\n";
# 		if ($chunk =~ /\"\/teams/) {
# 			$chunk =~ s/&amp;/&/;
# 			($current_team) = $chunk =~ />(.+)<\/a/;
# 		}
# 		if ($chunk =~ /\"(votes-title|info-votes-wrap)\"/) {
# 			my ($votes) = $chunk =~ />([\d\,]+)<\//;
# 			unless (!$votes) {$votes =~ s/,//}
# 			unless (!$current_team) {$team_votes{$current_team} = $votes}
# 		}
# 		if ($chunk =~ /p>[\w\d\,\(\)\s]+<\/p/) {
# 			my ($others) = $chunk =~ /p>([\w\d\,\(\)\s]+)<\/p/;
# 			# print "$others\n";
# 			for my $each_other (split ',', $others) {
# 				my ($team)  = $each_other =~ /\s*(.+) \(*\d/;
# 				my ($votes) = $each_other =~ /(\d+)/;
# 				$votes =~ s/,//;
# 				$team =~ s/&amp;/&/;
# 				$team_votes{$team} = $votes;
# 			}
# 		}
# 	}
# }


# # my $rcfb = 'http://www.reddit.com/r/CFB/comments/2l9qrq/week_11_2014_rcfb_poll_1_mississippi_state_2/';

# # my $rcfb_content = get $rcfb;

# # my $current_team;
# # LINE: for my $line (split qr /\R/, $rcfb_content) {
# # 	# print "$line\n";
# # 	if ($line =~ /a href=\"\#f/) {
# # 		# print "$line\n";
# # 		($current_team) = $line =~ /a>\s+(.+)<\/td/;
# # 		$current_team =~ s/&amp;/&/;
# # 		# print "$current_team\n";
# # 	}
# # 	elsif ($line =~ /align=\"left\">\d+<\/td/) {
# # 		my ($score) = $line =~ /align=\"left\">(\d+)/;
# # 		$team_votes{$current_team} = $score;
# # 	}
# # 	if ($line =~ /Others Receiving Votes/i) {
# # 		my ($others) = $line =~ /:\s(.+)\s+<\/p>/;
# # 		# print "$others\n";

# # 		for my $each_other (split ', ', $others) {
# # 			my ($team) = $each_other =~ /(.+)\s\d/;
# # 			my ($votes) = $each_other =~ /$team\s(\d+)/;
# # 			$team =~ s/&amp;/&/;
# # 			$team_votes{$team} = $votes;
# # 		}
# # 		last LINE;
# # 	}
# # }

# my @teams = sort {$team_votes{$b} <=> $team_votes{$a}} keys %team_votes;
# foreach my $team (@teams) {
# 	print "$team\t$team_votes{$team}\n";
# }





# # my $scores_url = 'http://scores.espn.go.com/ncf/scoreboard?seasonYear=2014&seasonType=2&weekNumber=11';

# # my $score_content = get $scores_url;

# # my @current_teams;
# # my @current_scores;
# # # print "$team_counter\n";
# # for my $line (split qr/\R/, $score_content) {
# # 	# print "$line\n";

# # 	if ($line =~ /games-date/) {
# # 		my $team_counter = 0;
# # 		# print "$line\n";

# # 		for my $chunk (split '><', $line) {
# # 			# print "$team_counter\t$chunk\n";
# # 			# print "$chunk\n";

# # 			if ($chunk =~ /team\/_\/id/) {
# # 				my ($team) = $chunk =~ /\">(.+)<\/a>/;
# # 				# print "$team\n";
# # 				$current_teams[$team_counter] = $team;
# # 			}
# # 			if ($chunk =~ /class=\"final\"/) {
# # 				my ($score) = $chunk =~ /\">(\d+)<\/li/;
# # 				# print "$score\n";
# # 				$current_scores[$team_counter] = $score;
# # 				if ($score) {$team_counter = ($team_counter + 1) % 3}
# # 			}
# # 			if ($team_counter == 2) {
# # 				print "$current_teams[0]\t$current_scores[0]\n";
# # 				print "$current_teams[1]\t$current_scores[1]\n\n";
# # 				$game_scores[$game_counter] = {teamA  => $current_teams[0],
# # 											   teamB  => $current_teams[1],
# # 											   scoreA => $current_scores[0],
# # 											   scoreB => $current_scores[1]};
# # 				$game_counter++;
# # 				$team_counter = ($team_counter + 1) % 3; 
# # 			}
# # 		}
# # 	}
# # }





# ###################

# # my @urls = ('http://espn.go.com/college-football/rankings/_/poll/1/seasontype/3',
# # 			'http://espn.go.com/college-football/rankings/_/poll/2/seasontype/3',
# # 			'http://espn.go.com/college-football/powerrankings');

# # my @urls = 'http://espn.go.com/college-football/rankings/_/poll/1/year/2014/week/11';
# # # my $content = get $url;
# # foreach my $url (@urls) {
# # 	my %team_votes = get_team_votes($url);

# # 	my @teams = sort {$team_votes{$b} <=> $team_votes{$a}} keys %team_votes;
# # 	foreach my $team (@teams) {
# # 		print "$team\t$team_votes{$team}\n";
# # 	}
# # }

# # sub get_team_votes {
# # 	my ($url) = @_;
# # 	# print "$url\n";
# # 	my $content = get $url;
# # 	# print "$content\n";
# # 	my %team_votes;

# # 	for my $line (split qr/\R/, $content) {

# # 		if ($line =~ /team\/_\/id/) {
# # 			# print "$line\n";
# # 			my $current_team;

# # 			for my $chunk (split '><', $line) {
# # 				# print "$chunk\n";

# # 				if ($chunk =~ /Others receiving votes:/) {
# # 					my ($others) = $chunk =~ /:<*\/*s*p*a*n*>* (.+)<\//;

# # 					for my $each_other (split ',', $others) {
# # 						my ($team)  = $each_other =~ /\s*(.+) \(*\d/;
# # 						my ($votes) = $each_other =~ /(\d+)/;
# # 						$votes =~ s/,//;
# # 						$team_votes{$team} = $votes;
# # 					}
# # 				}
# # 				if ($chunk =~ /team\/_\/id/) { 
# # 					($current_team) = $chunk =~ /\">(.+)<\/a/;
# # 					# if ($current_team) {print "current team: $current_team\t"}
# # 				}
# # 				if ($chunk =~ /(class|align)=\"(points|center)\"/) {
# # 					my ($votes) = $chunk =~ /\">([\d\,]+)<\//;
# # 					# print "$votes\n";
# # 					unless (!$votes) {$votes =~ s/,//}
# # 					unless (!$current_team) {$team_votes{$current_team} = $votes}
# # 				}
# # 			}
# # 		}
# # 	}
# # 	return %team_votes;
# # }




# ##########


# # my @array1 = (1,2,3,4);
# # my @array2 = (5,6,7,9);

# # if (@array1 == @array2) {print "TRUE\n"} else {print "FALSE\n"}

# # my @data = (1, 2, 3);
# # my $reftype = reftype(\@data);
# # print "reftype: $reftype\n";
# # my @perms = permutations(\@data);
# # foreach my $perm (@perms) {
# # 	print "@{$perm}\n";
# # }


# # # my $rng = Math::GSL::RNG->new;
# # # my $random_numbers = $rng->raw();
# # # my $x = gsl_ran_lognormal($random_numbers, 1, 0.05);

# # # print "$x\n";

# # # print join(':', split('b', 'abc')), "\n";


# # # my $string = "3456789";

# # # my ($substr) = $string =~ /^[A-Z]{0,0}(\d+)/;
# # # print "$substr\n";


# # # my @perl_files = glob "*pl";

# # # foreach my $file (@perl_files) {
# # # 	print "$file\n";
# # # }


# # # my @pdfs = glob "*pdf*";
# # # my @manuals = glob @pdfs, "*manual*";

# # # print "pdfs: @pdfs\n";
# # # print "manuals: @manuals\n";

# # # my $string = "CCATG";

# # # my ($revstring) = revcomp($string);

# # # print "string: $string\nrevstr: $revstring\n";



# # # sub revcomp {
# # # 	my ($seq) = @_;
# # # 	$seq = uc($seq);
# # # 	my $rev = reverse($seq);
# # # 	$rev =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/; # makes complement
# # # 	return $rev;
# # # }



# # # my $x = "ighv9-2";
# # # my $y = "9-2";
# # # if ($x =~ /$y/) {print "$x matches $y\n"}
# # # else {print "$x doesn't match $y\n"}

# # # for (my $i=0; $i < 1000000000000; $i++) {
# # # 	if ($i % 100000 == 0) {print "\r\t$i"}
# # # }
# # # print "\n";


# # # open IN, "<ensembl_ids.psrq20.p.csv";

# # # $_ = <IN>;

# # # while (<IN>) {
# # # 	print "$_";
# # # }

# # # for (my $i=00; $i < 10; $i++) {print "$i\n"}


# # # my @array1 = (
# # # 	{clust => 0, id => "seq1", seq => "ACGT"},
# # #  	{clust => 0, id => "seq2", seq => "CGTA"},
# # #  	{clust => 1, id => "seq1", seq => "GTAC"},
# # # );

# # # my %clusters;

# # # foreach my $elem (@array1) {
# # # 	$clusters{$elem->{clust}}++;
# # # } 

# # # my @clusters = keys %clusters;

# # # print "\@clusters: @clusters\n";

# # # my $test = 1e-1 + 1e-1;

# # # print $test, "\n";

# # # if (grep /^jmseg_stats.pl$/, glob "*") {print "jmseg exists\n"}
# # # else 			 				  	 {print "jmseg exists not\n"}


# # # print "testing", ' printing', "\n";
# # # abcdefghij abcdefghik qbcdefghij abcdefghlm qrcdefghij abcdefglmn qrsdefghij
# # my @inputs = qw/qrsdefghij abcdefghij qbcdefghij abcdefghik abcdefghlm qrcdefghij abcdefglmn abcdefghi/;
# # my $pattern = "abcdefghij";

# # my ($match) = amatch($pattern, ["S1"], @inputs); 
# # my @matches = amatch($pattern, ["i", "S1", "D0"], @inputs); ### USE THIS FOR MATCHING PRIMERS

# # my %d;
# # @d{@inputs} = map { abs } adistr($pattern, @inputs);
# # my @d = sort { $d{$a} <=> $d{$b} } @inputs;
# # my @keys = keys %d;
# # my @values = values %d;
# # my $test_str = "defghi";
# # my $index = length($match) - length($test_str) - 1;
# # my $sublength = 4;
# # my $substr = substr($match, $index, 6);
# # print "Match_substr: $substr\n";
# # # my $dir = './';
# # # my @glob = glob "${dir}[file|Jan]*txt";
# # # print "glob: @glob\n";

# # # foreach $input (@inputs) {
# # # 	my $mismatches = length($pattern) * $d{$input};
# # # 	print "input: $input\tmismatches: $mismatches\n";
# # # }

# # print "Pattern: $pattern\n";
# # print "Inputs:  @inputs\n";
# # print "\$match: $match\n";
# # print "\@matches: @matches\n";
# # print "Best matches: @d\n";
# # print "Best match: $d[0]\n";
# # print "Best match score: $d{$d[0]}\n";
# # print "Best match scores:";
# # foreach my $match (@d) {
# # 	print " $d{$match}";
# # }
# # print "\n";

# # foreach my $key (@keys) {
# # 	print "$key: $d{$key}\n";
# # }

# # # open OUT, ">test_file.out";
# # # die OUT, "There was an error";
# # # close OUT;


# # # print "Do you want?\n";
# # # chomp(my $answer = <>);
# # # print "$answer\n";

# # # my $k = 4;
# # # my $l = 5;
# # # my $m = (4 + 5) % 8;
# # # print "m = $m\n";

# # # my @array = qw/apple pear wine applewine pearwine/;
# # # my @array2 = qw/applewine pear/;

# # # foreach my $element (@array) {
# # # 	my @new_array = grep /$element/, @array;
# # # 	print "$element: @new_array\n";
# # # }
# # # print "\n\$element ~~ \@array test:\n";
# # # foreach my $element (@array2){
# # # 	if ($element !~ @array) {print "$element matches\n"}
# # # 	else				    {print "$element doesn't match\n"}
# # # }

# # # print "\n\@array2 ~~ \@array test:";
# # # if (@array2 ~~ @array) {print "array matches\n"}
# # # else				   {print "array doesn't match\n"}

# # # my $string1 = "ACGAGCTCGAGGAGACTCGATGCAGTCGATC";
# # # my $string2 = "CGAGGAGACTCGA";

# # # if ($string1 =~ /$string2/) {print "string matches\n"}
# # # else						{print "no string match\n"}

# # # my $t = @array - 1;
# # # print "t=$t\n";

# # # my @array3 = @array[1..@array-1];
# # # print "$array[1..4]\n";
# # # print "@array3\n";
# # # print "$array[-1]\n";

# # # for (my $i = 0; $i <= 0; $i++) {
# # # 	print "this is i: $i\n";
# # # }

# # # my $out = 0;
# # # my @outfiles;
# # # foreach my $element (@array) {
# # # 	my $outfile = "FILE$out";
# # # 	push @outfiles, $outfile;
# # # 	open $outfile, ">$element.txt" or die "cannot create $element.txt\n";
# # # 	print $outfile "hello world\n";
# # # 	$out++;
# # # }

# # # foreach my $outfile (@outfiles) {
# # # 	print $outfile "goodbye world\n";
# # # 	close $outfile;
# # # }

# # # my %hash1;
# # # my $key1 = "key1";
# # # $hash1{$key1} = 1;
# # # print "test: \$hash1{\$key1} = 1\n";
# # # if  (exists $hash1{$key1}) {print "exists\n"}
# # # else					   {print "doesn't exist\n"}

# # # my $hash2;
# # # my $key2 = "key2";
# # # $hash2{$key2};
# # # print "test: \$hash2{\$key2}\n";
# # # if  (exists $hash2{$key2} == 0) {print "doesn't exist\n"}
# # # else					        {print "exists\n"}



# # # print '$array[0], $array[0.5], $array[1], $array[1.5]', "\n";
# # # print "$array[0], $array[0.5], $array[1], $array[1.5]\n";


# # # print "rand stuff:\n";

# # # my $int = int rand (20);

# # # print "$int\n";










