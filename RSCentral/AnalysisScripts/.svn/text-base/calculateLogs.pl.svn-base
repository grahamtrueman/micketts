#!/bin/perl

require "timelocal.pl" ;

@time = localtime((time - 2 * 60 * 60));
$blank = " " ;
$date = ($time[5]+1900)."_".($time[4]+1)."_".$time[3];
print $date."\n" ;
$year = ($time[5]+1900) ;
$month= ($time[4]+1) ;
$todo           = $ARGV[0] ;
$allorthismonth = $ARGV[1] ;

if (!$todo || ($allorthismonth ne "all" && $allorthismonth ne "this" && $allorthismonth !~ /[\d]{6}/ ) ) {
	print "Usage:\n\n" ;
	print "  ./calculateLogs.pl  company  type\n\n" ;
	print "company = export directory name or \"all\" for all companies\n" ;
	print "type    = \"all\" for all months data or \"this\" for this month \n" ;
	print "          or {yyyymm} for year yyyy and month mm  \n\n" ;
	exit ;
}

&setparameters ;
&readstoplist($stoplistfile) ;

&countall    ;
&wordcount   ;
#&getmaxdates ;

exit;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Sub-routines
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub wordcount {
	if ($allorthismonth eq "all" ) {
		$lscommand = "ls -1d /export/*/dblog/analysis/*/*" ;
	} elsif ($allorthismonth eq "this" ) {
		$lscommand = "ls -1d /export/*/dblog/analysis/$year/$month" ;
	} else {
		$_ = $allorthismonth  ;
		($yyyy,$mm) = /^([\d]{4})([\d]{2})$/ ;
		$lscommand = "ls -1d /export/*/dblog/analysis/$yyyy/".($mm*1) ;
	}
	open(DIRS, "$lscommand | ") || print "Cannot execute" ;
	while (<DIRS>) {
		chomp $_ ;
		$dir = $_ ;
		if ( ( ($dir =~ /$todo/) || ($todo eq "all") ) && ($dir !~ /prefer/) ) { 
			print "Evaluating breakdown for $dir\n" ;

			# Set counters to zero
			%phrasearray = "" ; %wordarray= "" ; %zerohits = "" ;
			%goodcount="" ; %goodtime = "" ;
			$zeroes = 0 ; $distinctIPs = 0 ; %IPs = "" ;
			$bandwidth = 0 ; %subdivbandwidth = "" ;
			%subdiv = "" ; %separatesubdiv = "" ;
			%subdivwordarray = "" ; %subdivphrasearray = "" ; 
			%subdivintradaysplit = "" ; %subdivtimesplit = "" ; %subdivzeroes = "" ; %clients = "" ;
			%subdivdistinctIPs = "" ;
			%subdivIPs = "" ;
			%subdivzerohitarray = "" ;

			for ($jj = 0 ; $jj <= 47 ; $jj++) {
				${'dailysplit'.$jj} = 0 ;
				${'hoursplit'.$jj} = ""
			}
			for ($jj = 0 ; $jj < ($#searchmarkers) ; $jj++) {
				${'timesplit'.$jj} = 0 ;
			}
			$goodcount = 0 ; $goodtime = 0 ; $fastesttime = 99999; $kk = 0 ; $maxtimesplit = 1 ; $maxdaily = 1 ;
			$weekdayMax{'1'} = 0 ;
			$weekdayMax{'2'} = 0 ;
			$weekdayMax{'3'} = 0 ;
			$weekdayMax{'4'} = 0 ;
			$weekdayMax{'5'} = 0 ;
			$weekdayMax{'6'} = 0 ;
			$weekdayMax{'7'} = 0 ;
			$maxdaycount = 0 ;
			$maxdaycountdate = "" ;
			$max30Min = 0 ;
			$max1Hr = 0 ;
			$max4Hr = 0 ;
			$max30MinDate = "" ;
			$max1HrDate = "" ;
			$max4HrDate = "" ;
			# Finished setting counters to zero
			
			open(DAYS, "ls -1d $dir/*.log | ") || print "Cannot execute" ;
			while (<DAYS>) {
				chomp ;
				$thisdayfile = $_ ;
				($yearcalc,$monthcalc,$daycalc) = /^.*?\/(\d\d\d\d)_([\d]*)_([\d]*)\.log$/ ;
#				print "                 Running ".$yearcalc." ".$monthcalc." ".$daycalc."  " ;

				for ($jj = 0 ; $jj <= 47 ; $jj++) {
					${'thisdailysplit'.$jj} = 0 ;
					if ($jj < 10) {
						${'thishoursplit0'.$jj} = 0 ;
					} else {
						${'thishoursplit'.$jj} = 0 ;
					}
				}

				&readinfo ;

				if ($thisdaycount > $maxdaycount) {
					$maxdaycount = $thisdaycount ;
					$maxdaycountdate = $daycalc."/".${'month'.$monthcalc}."/".$yearcalc ;
				}

				if ($monthcalc && $yearcalc && $daycalc) {
					$UNIXdate = timelocal(0, 0, 0, $daycalc, ($monthcalc - 1), ($yearcalc-1900)) ;
					@time = localtime($UNIXdate);
					$weekdaycalc  = $time[6] ; if ($weekdaycalc == 0) { $weekdaycalc = 7 }
	#				print "  Today is: ".${'weekdayName'.$weekdaycalc}."\n" ;
					if ($thisdaycount > $weekdayMax{$weekdaycalc}) {
						$weekdayMax{$weekdaycalc} = $thisdaycount ;
						$weekdayMaxDate{$weekdaycalc} = $daycalc."/".${'month'.$monthcalc}."/".$yearcalc ;
					}
				}

				# post calculate busiest 4 hr spell: using "thisdailysplit"
				for ($jj = 0 ; $jj <= 40 ; $jj++) {
					$thismax4Hr = 0;
					for ($kk = $jj ; $kk <= ($jj+7) ; $kk++) {
						if ($kk <= 9.5) {
							$thismax4Hr = $thismax4Hr + ${'thisdailysplit0'.$kk} ;
						} else {
							$thismax4Hr = $thismax4Hr + ${'thisdailysplit'.$kk} ;
						}
					}
					if ($thismax4Hr > $max4Hr) {
						$max4Hr = $thismax4Hr ;
						# calculate times:
						$max4HrStartTime = int($jj/2) ;
						$max4HrFinishTime = $max4HrStartTime + 4 ;
						if (int($jj/2) == ($jj/2)) {
							$max4HrStartTime .= ":00" ;
							$max4HrFinishTime .= ":00" ;
						} else {
							$max4HrStartTime .= ":30" ;
							$max4HrFinishTime .= ":30" ;
						}
						$max4HrDate = $daycalc."/".${'month'.$monthcalc}."/".$yearcalc." (".$max4HrStartTime." to ".$max4HrFinishTime.")" ;
					}
				}

				# Is a new partial intraday record or hourly record set?
				for ($jj=0;$jj<=23;$jj++) {
					$tt = 0 ;
					for ($kk=0;$kk<=$jj;$kk++) {
						if ($kk < 10) {
							$tt = $tt + ${'thishoursplit0'.$kk}
						} else {
							$tt = $tt + ${'thishoursplit'.$kk}
						}
					}
					if ($tt > ${'maxPartial'.$jj}) {
						${'maxPartial'.$jj} = $tt ;
						${'maxDatePartial'.$jj} = $daycalc."/".${'month'.$monthcalc}."/".$yearcalc ;
					}
					#print "Max partial count to hour ".$jj." is ".${'maxPartial'.$jj}." on ".${'maxDatePartial'.$jj}."\n"
				}

			}
			close(DAYS) ;

			&writeoutput ;			
		}
	}
	close(DIRS) ;
}

sub countall {
	open(COUNT, "ls -1d /export/*/dblog/analysis | ") || print "Cannot execute" ;
	while (<COUNT>) {
		chomp $_ ;
		if ( $_ =~ /$todo/ || $todo eq "all") {
			($company) = /^\/export\/(.*?)\/dblog\/analysis$/ ;
			print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" ;
			print "Counting $company\n" ;
			system("/RSCentral/AnalysisScripts/countAll.pl $company $allorthismonth");
		}
	}
	close(COUNT) ;
}

sub readinfo {
			$thisdaycount = 0 ;
			open(WORDS, "cat $thisdayfile | ") || print "Cannot execute" ;
			while (<WORDS>) {
				$whole = $_ ;
				chomp ; chomp $whole ;
				@line = split(/\t/,$_) ;
				#print "Found ".$line[0]."\n" ;
				if ( grep ($line[0] eq $_,@excludemach) ) { next }
				
				@words = "" ;
				$thisdaycount++ ;
				$_ = $line[2] ;
				($thisclient) = /\/export\/(.*?)\/cgi-bin/i ; $thisclient =~ tr/[A-Z]/[a-z]/ ;
				$clients{$thisclient}++ ;
				
				$line[4] =~ tr/[A-Z]/[a-z]/ ;
				# | no longer needed - both in stoplist                |
				# | $line[4] =~ s/\s((and)|(or))\s/$blank/eigs ;       |
				$line[4] =~ s/\"/$blank/egs ;
				while ($line[4] =~ /([\"\[\]])|(\^\>\d)/i ) {
					$line[4] =~ s/([\"\[\]])|(\^\>\d)/$blank/egs ;
				}
				while ($line[4] =~ /\s\s/i ) {
					$line[4] =~ s/\s\s/$blank/ ;
				}
				$line[4] =~ s/^\s(.*)$/$1/i ;
				$line[4] =~ s/^(.*)\s$/$1/i ;
				if ($line[4] =~ /\~/ ) {
					$line[4] =~ s/^(.*?)\~.*$/$1/i ;
				}

				if ( $line[5]==0 || !$line[5] || $line[5] eq "" ) {
					${'zeroes'.$subscript}++ ;
					$subdivzeroes{$line[3]}++ ;
					$zerohits{$line[4]}++ ;
					$subdivzerohitarray{$line[3].'-=-'.$line[4]}++ ;
#					print "<!--Found Zero hit ".$line[4]."-->\n" ;
				}
				
				# $line[4] =~ tr/"// ;
				if ($line[4] =~ /\s/i) {
					@words = split(/\s/,$line[4]) ;
					for ($ii = 0 ; $ii <= $#words ; $ii++) {
						if ( grep ($words[$ii] eq $_,@stoplist)  ) { next }
						$wordarray{$words[$ii]}++ ;
						$subdivwordarray{$line[3].'-=-'.$words[$ii]}++ ;
					}
					$phrasearray{$line[4]}++ ;
					$subdivphrasearray{$line[3].'-=-'.$line[4]}++ ;
				} else {
					if ( !grep ($line[4] eq $_,@stoplist) ) {
						$wordarray{$line[4]}++ ;
						$subdivwordarray{$line[3].'-=-'.$line[4]}++ ;
					}
				}
				
				$subdiv{$line[3]}++ ;
				$_ = $line[1] ;
				($thisday,$thismonth,$thisyear) = /([\d]*)\/([\d]*)\/([\d]*)\s/i ;
				$separatesubdiv{$thisyear.'_'.$thismonth.'_'.$thisday.' '.$line[3]}++ ;
				if ($line[7] && $line[8] && $line[9] && $line[10]) {
					$goodcount++ ;
					$goodtime = $goodtime + $line[10] ;
					$goodcount{$company}++ ;
					$goodtime{$company} = $goodtime{$company} + $line[10];
					if ($line[10] < $fastesttime) {
						$fastesttime = $line[10] ;
					}
					if ($line[10] > $slowesttime) {
						$slowesttime = $line[10] ;
					}
					for ($jj = 0 ; $jj < ($#searchmarkers) ; $jj++) {
						if ( ($line[10] > $searchmarkers[$jj]) && ($line[10] < $searchmarkers[$jj+1]) ) {
							${'timesplit'.$jj}++ ;
							$subdivtimesplit{$line[3].'-=-'.$jj}++ ;
							if (${'timesplit'.$jj} > $maxtimesplit) { $maxtimesplit = ${'timesplit'.$jj} ; }
						}
					}
				}
				
				# Calculate daily splits
				$_ = $line[1] ;
				($searchhour,$searchminute) = /\s([\d]*):([\d]*):.*?/i ;
				if (!$searchhour) {
					$searchhour = 0 ; # print "Bad line: $whole\n" ;
				} else {
					if ($searchminute >= 30 ) { $searchminute = 1 ; } else { $searchminute = 0;}
					${'dailysplit'.($searchhour*2+$searchminute)}++ ;
					${'thisdailysplit'.($searchhour*2+$searchminute)}++ ;
					if (${'thisdailysplit'.($searchhour*2+$searchminute)} > $max30Min) {
						$max30Min = ${'thisdailysplit'.($searchhour*2+$searchminute)}  ;
						$temp = $searchminute*30 ;
						if ($searchminute < 0.5) {
							$temp = "00" ;
							$temp2 = "30" ; $upperhour = $searchhour ;
						} else {
							$temp = "30" ;
							$temp2 = "00" ; $upperhour = $searchhour + 1 ; if ($upperhour > 23.5) {$upperhour = "0";}
						}
						$max30MinDate = $daycalc."/".${'month'.$monthcalc}."/".$yearcalc."  (".$searchhour.":".($temp)." to ".$upperhour.":".$temp2.")"  ;
					}
					${'thishoursplit'.$searchhour}++ ;
					if (${'thishoursplit'.$searchhour} > $max1Hr) {
	#					print "Setting Max 1Hr split to ".$max1Hr." (thishoursplit".$searchhour.")\n" ;
						$max1Hr = ${'thishoursplit'.$searchhour}  ;
						$temp = $searchhour + 1 ; if ($temp > 23.5) {$temp = 0 ;}
						$max1HrDate = $daycalc."/".${'month'.$monthcalc}."/".$yearcalc."  (".$searchhour.":00 to ".$temp.":00)"  ;
					}
					$subdivintradaysplit{$line[3].'-=-'.($searchhour*2+$searchminute)}++ ;
					
				}
				
				# Calculate discrete users
				if (!$IPs{$line[0]}) {
					$distinctIPs++ ;
					$IPs{$line[0]} = $line[0] ;
				}
				if (!$subdivIPs{$line[3]}{$line[0]}) {
					$subdivdistinctIPs{$line[3]}++ ;
					$subdivIPs{$line[3]}{$line[0]} = $line[0] ;
				}
				
				
				$bandwidth = $bandwidth + $line[19] ;
				$subdivbandwidth{$line[3]} = $subdivbandwidth{$line[3]} + $line[19] ;

				@line = "" ;
			}
			close(WORDS) ;
}

sub writeoutput {
			# write General Data
			open(GENERAL,">$dir/generaldata")|| print "cannot open $dir/generaldata\n";
			print GENERAL "zeroes\t".$zeroes."\n" ;
			print GENERAL "bandwidth\t".$bandwidth."\n" ;
			print GENERAL "distinctIPs\t".$distinctIPs."\n" ;
			print GENERAL "goodcount\t".$goodcount."\n" ;
			print GENERAL "goodtime\t".$goodtime."\n" ;
			print GENERAL "maxdaycount\t".$maxdaycount."\n" ;
			print GENERAL "maxdaycountdate\t".$maxdaycountdate."\n" ;
			for ($ddd = 1 ; $ddd <= 7 ; $ddd++) {
				print GENERAL "max".${'weekdayName'.$ddd}."\t".$weekdayMax{$ddd}."\n" ;
				print GENERAL "max".${'weekdayName'.$ddd}."Date\t".$weekdayMaxDate{$ddd}."\n" ;
			}
			print GENERAL "max30Min\t".$max30Min."\n" ;
			print GENERAL "max30MinDate\t".$max30MinDate."\n" ;
			print GENERAL "max1Hr\t".$max1Hr."\n" ;
			print GENERAL "max1HrDate\t".$max1HrDate."\n" ;
			print GENERAL "max4Hr\t".$max4Hr."\n" ;
			print GENERAL "max4HrDate\t".$max4HrDate."\n" ;
			for ($jj=0;$jj<=23;$jj++) {
				print GENERAL "maxPartial".$jj."\t".${'maxPartial'.$jj}."\n" ;
				print GENERAL "maxPartial".$jj."Date\t".${'maxDatePartial'.$jj}."\n" ;
			}
			close(GENERAL) ;

			
			# write SEARCH TIMES timesplits
			open(INTRADAY,">$dir/intraday")|| print "cannot open $dir/intraday\n";
			for ($jj = 0 ; $jj <= 47 ; $jj++) {
				print INTRADAY $jj."\t".${'dailysplit'.$jj}."\n" ;
			}
			close(INTRADAY) ;

			# write client data
			open(CLIENTS,">$dir/clients")|| print "CLIENTS: cannot open $dir/clients\n";
			foreach $client (sort { $clients{$b} <=> $clients{$a} } keys %clients) {
				if (!$client ) { next ; }
				print CLIENTS $client."\t".$clients{$client}."\n" ;
			}
			close(CLIENTS) ;
			
			# write SEARCH TIMES timesplits
			open(SEARCHTIMES,">$dir/timesplits")|| print "cannot open $dir/timesplits\n";
			for ($jj = 0 ; $jj < ($#searchmarkers) ; $jj++) {
				print SEARCHTIMES $jj."\t".${'timesplit'.$jj}."\n" ;
			}
			close(SEARCHTIMES) ;
			
			# write word list
			open(WORDSOUT,">$dir/wordlist")|| print "cannot open $dir/wordlist\n";
			$count = 0 ;
			foreach $word (sort { $wordarray{$b} <=> $wordarray{$a} } keys %wordarray) {
				if ($count > $maxcount || !$word ) { next ; }
				$count++ ;
				print WORDSOUT $word."\t".$wordarray{$word}."\n" ;
			}
			close(WORDSOUT) ;
	
			# write phrase list
			open(PHRASESOUT,">$dir/phraselist")|| print "cannot open $dir/phraselist\n";
			$count = 0 ;
			foreach $phrase (sort { $phrasearray{$b} <=> $phrasearray{$a} } keys %phrasearray) {
				if ($count > $maxcount || !$phrase ) { next ; }
				$count++ ;
				print PHRASESOUT $phrase."\t".$phrasearray{$phrase}."\n" ;
			}
			close(PHRASESOUT) ;
	
			# write Zeroes list
			open(ZEROESOUT,">$dir/zerohitlist")|| print "cannot open $dir/phraselist\n";
			$count = 0 ;
			foreach $zerohit (sort { $zerohits{$b} <=> $zerohits{$a} } keys %zerohits) {
				if ($count > $maxcount || !$zerohit ) { next ; }
				$count++ ;
				print ZEROESOUT $zerohit."\t".$zerohits{$zerohit}."\n" ;
			}
			close(ZEROESOUT) ;
	
			# write subdivision list
			open(SUBDIVOUT,">$dir/subdivisions")|| print "cannot open $dir/subdivisions\n";
			foreach $subdivision (sort { $subdiv{$b} <=> $subdiv{$a} } keys %subdiv) {
				if ( !$subdivision ) { next ; }
				print SUBDIVOUT $subdivision."\t".$subdiv{$subdivision}."\n" ;
			}
			close(SUBDIVOUT) ;
			
			# write subdivision counts
			system("rm -rf $dir/subdivdata/*") ;
			if (-e "$dir/subdivdata" ) {
			} else {
				system("mkdir $dir/subdivdata") ;
			}
			foreach $separate (sort keys %separatesubdiv) {
				$_ = $separate ;
				# $thisdate.' '.$line[3]
				($thisdate,$thissubdiv) = /^([^\s]*)\s([^\s]*)$/ ;
#				print $thisdate." ".$thissubdiv." '".$separate."' ".$separatesubdiv{$separate}."\n" ;
				# Check $thissubdiv is there...
				if (-e "$dir/subdivdata/$thissubdiv" ) {
				} else {
					system("mkdir $dir/subdivdata/$thissubdiv")  ;
				}
				# Write count data:
				open(SUBDIVDATA,">>$dir/subdivdata/$thissubdiv/count")|| print "SUBDIVDATA: Cannot open $dir/subdivdata/$thissubdiv/count ($line[1])\n";
				print SUBDIVDATA "count: ".$separatesubdiv{$separate}."  $thisdate.log\n" ;
				close(SUBDIVDATA) ;
			}
			%count = "" ;
			foreach $subdivword (sort {$subdivwordarray{$b} <=> $subdivwordarray{$a}} keys %subdivwordarray) {
#				open(DUMP,">>$dir/subdivdata/dump")|| print "DUMP: Cannot open $dir/subdivdata/dump\n";
#				print DUMP "'$subdivword'\t".$subdivwordarray{$subdivword}."\n" ;
#				close(DUMP) ;
				$_ = $subdivword ;
				($thissubdiv,$thisword) = /(.*)\-\=\-(.*)/ ;
				$count{$thissubdiv}++ ;
				if ( ($count{$thissubdiv} > $maxcount) || (!$thisword)) { next ; }
				if (-e "$dir/subdivdata/$thissubdiv" ) {
				} else {
					system("mkdir $dir/subdivdata/$thissubdiv")  ;
				}
				open(SUBDIVWORDS,">>$dir/subdivdata/$thissubdiv/wordlist")|| print "SUBDIVWORDS: Cannot open $dir/subdivdata/$thissubdiv/wordlist ($line[1])\n";
				print SUBDIVWORDS $thisword."\t".$subdivwordarray{$subdivword}."\n" ;
				close(SUBDIVWORDS) ;
			}
			%count = "" ;
			foreach $subdivphrase (sort {$subdivphrasearray{$b} <=> $subdivphrasearray{$a}} keys %subdivphrasearray) {
				$_ = $subdivphrase ;
				($thissubdiv,$thisphrase) = /(.*)\-\=\-(.*)/ ;
				$count{$thissubdiv}++ ;
				if ( ($count{$thissubdiv} > $maxcount) || (!$thisphrase)) { next ; }
				if (-e "$dir/subdivdata/$thissubdiv" ) {
				} else {
					system("mkdir $dir/subdivdata/$thissubdiv")  ;
				}
				open(SUBDIVPHRASES,">>$dir/subdivdata/$thissubdiv/phraselist")|| print "SUBDIVPHRASES: Cannot open $dir/subdivdata/$thissubdiv/phraselist ($line[1])\n";
				print SUBDIVPHRASES $thisphrase."\t".$subdivphrasearray{$subdivphrase}."\n" ;
				close(SUBDIVPHRASES) ;
			}
			%count = "" ;
			foreach $subdivzero (sort {$subdivzerohitarray{$b} <=> $subdivzerohitarray{$a}} keys %subdivzerohitarray) {
				$_ = $subdivzero ;
				($thissubdiv,$thiszerohitquery) = /(.*)\-\=\-(.*)/ ;
				$count{$thissubdiv}++ ;
				if ( ($count{$thissubdiv} > $maxcount) || (!$thiszerohitquery)) { next ; }
				if (-e "$dir/subdivdata/$thissubdiv" ) {
				} else {
					system("mkdir $dir/subdivdata/$thissubdiv")  ;
				}
				open(SUBDIVZEROES,">>$dir/subdivdata/$thissubdiv/zerohitlist")|| print "SUBDIVZEROES: Cannot open $dir/subdivdata/$thissubdiv/zerohitlist ($line[1])\n";
				print SUBDIVZEROES $thiszerohitquery."\t".$subdivzerohitarray{$subdivzero}."\n" ;
				close(SUBDIVZEROES) ;
			}
			foreach $subdivintraday (keys %subdivintradaysplit) {
				$_ = $subdivintraday ;
				($thissubdiv,$thisintraday) = /(.*)\-\=\-(.*)/ ;
				if (-e "$dir/subdivdata/$thissubdiv" ) {
				} else {
					system("mkdir $dir/subdivdata/$thissubdiv")  ;
				}
				open(SUBDIVINTRADAY,">>$dir/subdivdata/$thissubdiv/intraday")|| print "SUBDIVINTRADAY: Cannot open $dir/subdivdata/$thissubdiv/intraday ($line[1])\n";
				print SUBDIVINTRADAY $thisintraday."\t".$subdivintradaysplit{$subdivintraday}."\n" ;
				close(SUBDIVINTRADAY) ;
			}
			foreach $subdivsplit (keys %subdivtimesplit) {
				$_ = $subdivsplit ;
				($thissubdiv,$thissplit) = /(.*)\-\=\-(.*)/ ;
				open(SUBDIVTIMESPLITS,">>$dir/subdivdata/$thissubdiv/timesplits")|| print "SUBDIVTIMESPLITS: Cannot open $dir/subdivdata/$thissubdiv/timesplits ($line[1])\n";
				print SUBDIVTIMESPLITS $thissplit."\t".$subdivtimesplit{$subdivsplit}."\n" ;
				close(SUBDIVTIMESPLITS) ;
			}
			foreach $thissubdiv (keys %subdivzeroes) {
				open(SUBDIVGENERAL,">>$dir/subdivdata/$thissubdiv/generaldata")|| print "SUBDIVGENERAL: Cannot open $dir/subdivdata/$thissubdiv/generaldata ($line[1])\n";
				print SUBDIVGENERAL "zeroes\t".$subdivzeroes{$thissubdiv}."\n" ;
				close(SUBDIVGENERAL) ;
			}
			foreach $thissubdiv (keys %subdivbandwidth) {
				open(SUBDIVGENERAL,">>$dir/subdivdata/$thissubdiv/generaldata")|| print "SUBDIVGENERAL: Cannot open $dir/subdivdata/$thissubdiv/generaldata ($line[1])\n";
				print SUBDIVGENERAL "bandwidth\t".$subdivbandwidth{$thissubdiv}."\n" ;
				close(SUBDIVGENERAL) ;
			}
			foreach $thissubdiv (keys %subdivdistinctIPs) {
				open(SUBDIVGENERAL,">>$dir/subdivdata/$thissubdiv/generaldata")|| print "SUBDIVGENERAL: Cannot open $dir/subdivdata/$thissubdiv/generaldata ($line[1])\n";
				print SUBDIVGENERAL "distinctIPs\t".$subdivdistinctIPs{$thissubdiv}."\n" ;
				close(SUBDIVGENERAL) ;
			}
	
			# write zero hit phrase list
#			open(ZEROPHRASESOUT,">$dir/zerophraselist")|| print "cannot open $dir/zerophraselist\n";
#			$count = 0 ;
#			foreach $zerophrase (sort { $zerohitphrases{$b} <=> $zerohitphrases{$a} } keys %zerohitphrases) {
#				if ($count > 100 || !$zerophrase ) { next ; }
#				$count++ ;
#				print ZEROPHRASESOUT $zerophrase."\t".$zerohitphrases{$zerophrase}."\n" ;
#			}
#			close(ZEROPHRASESOUT) ;
#	
#			# write zero hit word list
#			open(ZEROWORDSOUT,">$dir/zerowordlist")|| print "cannot open $dir/zerowordlist\n";
#			$count = 0 ;
#			foreach $zeroword (sort { $zerohitwords{$b} <=> $zerohitwords{$a} } keys %zerohitwords) {
#				if ($count > 100 || !$zeroword ) { next ; }
#				$count++ ;
#				print ZEROWORDSOUT $zeroword."\t".$zerohitwords{$zeroword}."\n" ;
#			}
#			close(ZEROWORDSOUT) ;

}

sub readstoplist {
	my $file=$_[0] ;
	open(STP,$file) || print "Can't read stop listed words!" ;
	while(<STP>) {
		chomp; push(@stoplist, $_) ; 
		print $_." ";
	}
	print $_."\n\n";
	close(STP) ;
}

sub setparameters {

	$stoplistfile = "/rs/Conf/stoplist" ;
	$maxcount     = 500 ;

	@excludemach = (
		'193.131.98.'      ,
		'193.195.79.81'    ,
		'193.195.79.82'    ,
		'193.195.79.83'    ,
		'193.195.79.84'    ,
		'82.69.15.203'     ,
		'194.112.48.220'   ,
		'194.112.44.51'    ,
		'82.69.0.68'       ,
		'212.135.200.224'  ,
		'217.155.33.181'   ,
		'195.44.1.1'       ,
		'212.23.31.237'    ,
		'62.3.64.138'      ,
		'62.3.70.70'       ,
		'217.169.5.151'    ,
		'62.3.69.40'       ,
		'217.155.34.32'    ,
		'217.155.32.174'   ,
		'193.128.255.228'  ,
		'217.155.36.125'   ,
		'82.68.122.160'    ,
		'82.68.122.161'    ,
		'82.68.122.162'    ,
		'82.68.122.163'    ,
		'82.68.122.164'    ,
		'82.68.122.165'    ,
		'82.68.122.166'    ,
		'82.68.122.167'    ,
		'82.68.66.80'      ,
		'82.69.22.79'      ,
		'82.69.29.6'       ,
		'82.69.3.206'      ,
		'82.69.5.157'      ,
		'81.6.215.105'     ,
		'82.68.82.48'      ,
		'82.68.116.104'    ,
		'62.49.143.35'     ,
		'82.69.41.35'   
	);
	
	@searchmarkers = (
	0,    
	0.1,
	0.2,
	0.3,
	0.4,
	0.5,
	0.6,
	0.7,
	0.8,
	0.9,
	1.0,
	1.1,
	1.2,
	1.3,
	1.4,
	1.5,
	1.7,
	1.9,
	2.1,
	2.3,
	2.5,
	3.0,
	3.5,
	4.0,
	5.0,
	7.5,
	10,
	15,
	20,
	25,
	30, 
	40,
	50,
	60,
	999
	);
	$weekdayName1 = "Monday" ;
	$weekdayName2 = "Tuesday" ;
	$weekdayName3 = "Wednesday" ;
	$weekdayName4 = "Thursday" ;
	$weekdayName5 = "Friday" ;
	$weekdayName6 = "Saturday" ;
	$weekdayName7 = "Sunday" ;
	$month1 = "Jan" ;
	$month2 = "Feb" ;
	$month3 = "Mar" ;
	$month4 = "Apr" ;
	$month5 = "May" ;
	$month6 = "Jun" ;
	$month7 = "Jul" ;
	$month8 = "Aug" ;
	$month9 = "Sep" ;
	$month10 = "Oct" ;
	$month11 = "Nov" ;
	$month12 = "Dec" ;
}

