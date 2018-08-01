#!/bin/perl

require "/RSCentral/AnalysisScripts/internalAnalysisLIBRARY.pl" ;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    P A R A M E T E R S
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    S U B R O U T I N E S
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub do_analysis {
	use sigtrap;
	use Socket;
	
	use Time::HiRes qw(gettimeofday sleep);
	@startTime = gettimeofday;                           

	#open(STDERR,">>/export/intranet/logs/debug");
	print "Content-type: text\/html\n\n";
	&getthistime('start');

	$username = $ENV{'REMOTE_USER'} || "-";
	$hostname = $ENV{"REMOTE_HOST"} || $ENV{"REMOTE_ADDR"};
	$scriptname = $ENV{"SCRIPT_FILENAME"} ;

	$permissions{'magadmin'} = "all" ;
	$permissions{'-'} = "all" ;
	$permission = $permissions{$username} ;
	
	$_ = $ENV{'SCRIPT_FILENAME'};
	($thissite) = /\/export\/(.*?)\/.*?\/.*?/ ;
#	print "<!--".$thissite."-->\n\n" ;

	@time = localtime(time);
	$thisdate    = ($time[5]+1900)."_".($time[4]+1)."_".$time[3];
	$thisyear    = ($time[5]+1900) ;
	$thismonth   = ($time[4]+1) ;
	$thismonthW  = ${'month'.($time[4]+1)} ;
	$thisday     = $time[3] ;
	$thishour    = $time[2] ;
	$thisweekday = $time[6] ; if ($thisweekday == 0) { $thisweekday = 7 }
	$datestamp   = $time[3]."/".$thismonthW."/".($time[5]+1900)." ".$time[2].":" ;
	if ($time[1] < 10) {
		$datestamp   .= "0" ;
	}
	$datestamp  .= $time[1];

#	&securitycheck;
	&read_input ;
	
	$analyse       = ($FORM{'analyse'} || 'SNAPSHOT') ;
	$analysebefore = ($FORM{'analysebefore'} || $analyse) ;
	$focus         = $FORM{'focus'} ;
	$POSTtype      = $FORM{'POSTtype'} ;
	$begin         = $FORM{'begin'} ;
	$oneline       = $FORM{'oneline'} ;
	$dayIN         = $FORM{'day'} ;
	$monthIN       = $FORM{'month'} ;
	$yearIN        = $FORM{'year'} ;
	$periods       = $FORM{'periods'} ;
	$listcount     = $FORM{'listcount'} || '30';
	$compareType   = $FORM{'compareType'} ;
	$graphprint    = $FORM{'graphprint'} ;
	$compare       = $FORM{'compare'} ;


	if ( ($ENV{'REQUEST_METHOD'} eq 'POST') && ($POSTtype eq "preferences") ) {
		&write_preferences ;
	}
	&read_preferences ;
	
	if ($graphprint) {
		$TEMPLATE = $TEMPLATEGRAPH ;
		if ($PRINTFORMAT eq "A4P"){
			$GRAPHHEIGHT = $PRINTHEIGHTA4P;
			$WIDTH = $PRINTWIDTHA4P;
		} elsif ($PRINTFORMAT eq "A4L"){
			$GRAPHHEIGHT = $PRINTHEIGHTA4L;
			$WIDTH = $PRINTWIDTHA4L;
		}
	}
	
#	&$sub_read_format ;
	$sidemenuflag = "status";
	&readsidemenu;
	
	$title{'INDEX'} = "Index" ;
	$title{'SNAPSHOT'} = "Snapshot" ;
	$title{'day'} = "Daily Breakdown" ;
	$title{'month'} = "Monthly Breakdown" ;
	
	$title = "Search Analysis" ;
	if ( $title{$analyse} ) { $title .= " &gt; ".$title{$analyse} ; }
	if ( $analyse eq "day" ) { $title .= " &gt; ".$dayIN."/".$monthIN."/".$yearIN ; }
	if ( $analyse eq "month" ) { $title .= " &gt; ".$monthIN."/".$yearIN ; }

	if ($yearIN == $thisyear && $monthIN eq $thismonthW && $dayIN == $thisday) {
		$TODAY = "TODAY" ;
	}

	if ($analyse eq "SNAPSHOT" || $analyse eq "summary") {
		$dayfile = $logtoday ;
		$dayIN = $thisday; $monthIN = $thismonthW ; $yearIN = $thisyear ;
		if ( $analyse eq "summary" ) {
			$SNAPSHOTDAYS = 2 ;
			$monthdir = " ".$logroot."/*/*" ;
		}
	} elsif ( ($analyse eq "words") || ($analyse eq "phrases") || ($analyse eq "subdivisions") || ($analyse eq "clients") ) {
		if ($yearIN == $thisyear && $monthIN eq $thismonthW && $dayIN == $thisday) {
			$TODAY = "TODAY" ;
			$dayfile = $logtoday ;
			#$monthdir = " ".$logroot."/".$yearIN."/".$monthNO{$monthIN} ;
		} elsif ($yearIN && $monthIN && $dayIN) {
			$dayfile = $logroot."/".$yearIN."/".$monthNO{$monthIN}."/".$yearIN."_".$monthNO{$monthIN}."_".$dayIN.".log";
		} elsif ($yearIN && $monthIN && !$dayIN) {
			$monthdir = " ".$logroot."/".$yearIN."/".$monthNO{$monthIN} ;
			if ($yearIN == $thisyear && $monthIN eq $thismonthW) {
				$dayfile = $logtoday ;
			}
		} elsif ($yearIN && !$monthIN && !$dayIN) {
			$monthdir = " ".$logroot."/".$yearIN."/*" ;
			if ($yearIN == $thisyear) {
				$dayfile = $logtoday ;
			}
		} elsif (!$yearIN && !$monthIN && !$dayIN) {
			$monthdir = " ".$logroot."/*/*" ;
			$dayfile = $logtoday;
		}
	} elsif ($analyse eq "day") {
		if ($yearIN == $thisyear && $monthIN eq $thismonthW && $dayIN == $thisday) {
			$dayfile = $logtoday ;
		} else {
			$dayfile = $logroot."/".$yearIN."/".$monthNO{$monthIN}."/".$yearIN."_".$monthNO{$monthIN}."_".$dayIN.".log";
		}
	} elsif ($analyse eq "month") {
		$firstdate = timelocal(0, 0, 0, 1, ($monthNO{$monthIN}-1), ($yearIN-1900)) ;
		for ($ii = 1 ; $ii <= 31 ; $ii++) {
			@time = localtime($firstdate + (($ii-1) * 24 * 60 * 60));
			$date     = ($time[5]+1900)."_".($time[4]+1)."_".$time[3];
			$year     = ($time[5]+1900) ;
			$month    = ($time[4]+1) ;
			$monthW   = ${'month'.($time[4]+1)} ;
			$day      = ($time[3]) ;
			$weekday  = $time[6] ; if ($weekday == 0) { $weekday = 7 }
			$weekdayW = ${'weekday'.$DISPLAY.'_'.$weekday} ;
			if ($monthW ne $monthIN) { next ;}
#			$dayfile .= " ".$logroot."/".$year."/".$month."/".$year."_".$month."_".$day.".log";
			if ($ii <= 1.5) {
				$monthdir = " ".$logroot."/".$year."/".$month ;
			}
		}
		if ($yearIN == $thisyear && $monthIN eq $thismonthW) {
			$dayfile .= " ".$logtoday ;
		}
	} elsif ($analyse eq "year") {
		if ($yearIN == $thisyear) {
			$dayfile .= " ".$logtoday ;
		}
		$monthdir = " ".$logroot."/".$yearIN."/*" ;
	} elsif ($analyse eq "ALLTIME") {
		$dayfile .= " ".$logtoday ;
		$monthdir = " ".$logroot."/*/*" ;
	}
	print "<!--dayfile=".$dayfile."-->\n" ;
	print "<!--monthdir=".$monthdir."-->\n\n" ;

	$mid = int($WIDTH/15) ;
	$step = int ($mid / 15) ;
	for ($ii = ($mid - $step * 5) ; $ii <= ($mid + $step * 5) ; $ii = $ii + $step) {
		$daysarray{$ii} = $ii ;
	}
	if (!$WIDTH_SNAPSHOTDAYS) {
		$WIDTH_SNAPSHOTDAYS = int ( ($WIDTH - (2 * 27)) / ( $SNAPSHOTDAYS + 1) ) - 2 ;
	}
	if (!$WIDTH_INTRADAY) {
		$WIDTH_INTRADAY = int ( ($WIDTH - (2 * 27)) / ( 48 + 1) ) - 2 ;
	}
	if (!$WIDTH_TIMESPLIT) {
		$WIDTH_TIMESPLIT = int ( ($WIDTH - (2 * 27)) / ( 34 + 1) ) - 2 ;
	}
	if (!$WIDTH_FULLMONTH) {
		$WIDTH_FULLMONTH = int ( ($WIDTH - (2 * 27)) / ( 31 + 1) ) - 3 ;
	}
	# get subdivision list:
	$grepcommand = "ls -1 $logroot/*/*/subdivdata/*/count";
	open(LIST, "$grepcommand | ") || print "Cannot execute" ;
	while (<LIST>) {
		chomp ;
#		print "<!--$_-->\n" ;
		($thisSubDiv) = /^\/.*\/(.*?)\/count$/ ;
#		print "<!--$thisSubDiv-->\n" ;
		if ( !$invalidSubdiv{$thisSubDiv}) {
			$allSubDivs{$thisSubDiv} = $thisSubDiv ;
		}
	}
	

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#     E N D of initial processing - process graphs...
	# ~~~~~~~~~~~~~~~~~~~~~~~~~
	# Process Snapshot graph
	&getthistime('Start of snapshot processing');
	if ( ($analyse eq "SNAPSHOT") || ($analyse eq "summary") ) {
		$lastday = 0;
		$ddd = 1 ;
		$maxSnapshotDays = 1 ;
		$space = " " ;
		$weekcolourcurrent = $BACKCOLOURON ;
		$currmoncolor = $BACKCOLOURON ;
		$currdaycolor = $BACKCOLOURON ;
		for ($ii = $SNAPSHOTDAYS ; $ii >= 0 ; $ii--) {
			&getthistime(" calcualting day ".$ii." ago ");
			@time = localtime(time - ($ii * 24 * 60 * 60));
			$date     = ($time[5]+1900)."_".($time[4]+1)."_".$time[3];
			$year     = ($time[5]+1900) ;
			$month    = ($time[4]+1) ;
			$monthW   = ${'month'.($time[4]+1)} ;
			$day      = ($time[3]) ;
			$weekday  = $time[6] ; if ($weekday == 0) { $weekday = 7 }
			$weekdayW = ${'weekday'.$DISPLANG.$weekday} ;
		
			${'weekdaydisplay'.$ii} = $weekdayW ;
			${'year'.$ii} = $year ;
			${'monthdisplay'.$ii} = $monthW ;
			${'day'.$ii} = $day ;
			if ($weekday > 5.5) { ${'dayimage'.$ii} = $COLOR2 ; } else { ${'dayimage'.$ii} = $COLOR1 ; }
		
			# &getsnapshotlabels ;
			
			if ($day < $lastday) {
				$ddd++ ;
				if ($currmoncolor eq $BACKCOLOUROFF) {
					$currmoncolor = $BACKCOLOURON ;
				} else {
					$currmoncolor = $BACKCOLOUROFF ;
				}
			}
			${'colspan'.$ddd}++ ;
			${'moncol'.$ddd} = $currmoncolor ;
			${'monthgraph'.$ddd} = $monthW ;
			${'monthgraphDisplay'.$ddd} = ${'month'.$DISPLANG.$month} ;
			${'yeargraph'.$ddd} = $year ;
			$lastday = $day ;
			
			${'weekdaydisplay'.$ii} = $weekdayW ;
#			print "<!--$ii~~".${'weekdaydisplay'.$ii}."-->\n" ;
			if ( $weekday > 1.5 ) {
				${'weekcolour'.$ii} = $weekcolourcurrent ;
			} else {
				if ($weekcolourcurrent eq $BACKCOLOUROFF) {
					$weekcolourcurrent = $BACKCOLOURON ;
				} else {
					$weekcolourcurrent = $BACKCOLOUROFF ;
				}
				${'weekcolour'.$ii} = $weekcolourcurrent ;
			}
			
			if ($ii == 0) {
				if ($permissions{$username} eq "all" && !$focus) {
					$grepcommand = "wc -l $dayfile" ;
				} else {
					$grepcommand = "grep \"cgi\t".($focus || $permissions{$username})."\t\" $logtoday | wc -l" ;
				}
			} else {
				if ( ( $permissions{$username} ne "all" || $focus ) ) {
					$grepcommand = "grep $date.log $logroot/$year/$month/subdivdata/".($focus || $permissions{$username})."/count" ;
				} else {
					$grepcommand = "grep $date.log $logroot/*/*/count" ;
				}
			}
			open(LIST, "$grepcommand | ") || print "Cannot execute" ;
			$_ = <LIST> ; chomp ;
			close(LIST);
#			print "<!--".$grepcommand."---RESPONSE=$_-->\n" ;
	
			if ( $_ =~ /count\:/ ) { 
				(${'count'.$ii}) = /^.*?count\:\s*(\d*).*?$/ ;
			} elsif ( $_ =~ /\s*([\d]*).*?/ ) {
				${'count'.$ii} = $1 ;
			} else {
				${'count'.$ii} = 0 ;
			}
			if (${'count'.$ii} > $maxSnapshotDays) { $maxSnapshotDays = ${'count'.$ii} ;}
	
			${'color'.$ii} = $currdaycolor ;
			if ($currdaycolor eq $BACKCOLOUROFF) {
				$currdaycolor = $BACKCOLOURON ;
			} else {
				$currdaycolor = $BACKCOLOUROFF ;
			}
		}
		
		for ($ii=1;$ii<=$ddd;$ii++) {
			if ( $WIDTH_SNAPSHOTDAYS * ${'colspan'.$ii} <= 17) {
				${'monthgraphDisplay'.$ii} =~ s/^([a-zA-Z]).*$/$1/iegs ;
			}
		}

	
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		# Get monthly count for all data
		&getmonthlydata ;
		
		($EVALUATE_DIVISIONS_42DAYS,$scale42max) = &getscale($maxSnapshotDays) ;
		for ($ii = $SNAPSHOTDAYS ; $ii >= 0 ; $ii--) {
			if (${'count'.$ii} == 0) {
				${'height'.$ii} = int(   $GRAPHHEIGHT   ) ;
			} else {
				${'height'.$ii} = int(   ($GRAPHHEIGHT * ${'count'.$ii}) / $scale42max   ) ;
			}
		}
		$EVALUATE_SCALES_42DAY = &$sub_output($SCALES) ;
	
#		if ($thisweekday > 5.5) { $image0 = $COLOR2 ; } else { $image0 = $COLOR1 ; }
#		#print "<!--Search_log=".$_."-->\n" ;
#		
#		if ($thisday > $lastday) {
#			${'colspan'.$ddd}++ ;
#		} else {
#			$ddd++ ;
#			${'colspan'.$ddd}++ ;
#		}
#		$weekdaydisplay0 = ${'weekday'.$thisweekday} ;
#		if ( $thisweekday > 1.5 ) {
#			$weekcolour0 = $weekcolourcurrent ;
#		} else {
#			if ($weekcolourcurrent eq $BACKCOLOUROFF) {
#				$weekcolourcurrent = $BACKCOLOURON ;
#			} else {
#				$weekcolourcurrent = $BACKCOLOUROFF ;
#			}
#			$weekcolour0 = $weekcolourcurrent ;
#		}
	}
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# processing Monthly
	&getthistime('Start of monthly processing');
	if ($analyse eq "month") {
		$lastday = 0;
		$xx = 1 ;
		$maxmonthly = 1 ;
		$space = " " ;
		$weekcolourcurrent = $BACKCOLOURON ;
		$currdaycolor = $BACKCOLOURON ;

		#Calculate Unix time stamp to start on
		$firstdate = timelocal(0, 0, 0, 1, ($monthNO{$monthIN}-1), ($yearIN-1900)) ;
		
		# calculate next and previous months:
		if ( $yearIN != $thisyear || $monthNO{$monthIN} != $thismonth || ($yearIN == $thisyear && $monthNO{$monthIN} != $thismonth) ) {
			$nextmonthM = $monthNO{$monthIN} + 1 ;
			if ($nextmonthM > 12) { $nextmonthM = 1 ; $nextmonthY = $yearIN + 1 ; } else { $nextmonthY = $yearIN ; }
			$nextmonthM = ${'month'.$nextmonthM} ;
		}
		$prevmonthM = $monthNO{$monthIN} - 1 ;
		if ($prevmonthM < 0.5) { $prevmonthM = 12 ; $prevmonthY = $yearIN - 1 ; } else { $prevmonthY = $yearIN ; }
		if (-e "$logroot/$prevmonthY/$prevmonthM") {
			$prevmonthM = ${'month'.$prevmonthM} ;
		} else {
			$prevmonthM = "" ; $prevmonthY = "" ;
		}
		
		for ($ii = 1 ; $ii <= 31 ; $ii++) {
			@time = localtime($firstdate + (($ii-1) * 24 * 60 * 60));
			$year     = ($time[5]+1900) ;
			$month    = ($time[4]+1) ;
			$monthW   = ${'month'.($time[4]+1)} ;
			$day      = ($time[3]) ;
			$date     = $year."_".$month."_".$day;
			$weekday  = $time[6] ; if ($weekday == 0) { $weekday = 7 }
			$weekdayW = ${'weekday'.$DISPLANG.$weekday} ;
			if ($monthW ne $monthIN) { next ;}
			$daysinmonth = $ii ;
		
			${'weekdaydisplay'.$ii} = $weekdayW ;
			${'year'.$ii} = $year ;
			${'monthdisplay'.$ii} = $monthW ;
			${'day'.$ii} = $day ;
			if ($weekday > 5.5) { ${'dayimage'.$ii} = $COLOR2 ; } else { ${'dayimage'.$ii} = $COLOR1 ; }
			
	#		print "<!--$time[0] | $time[1] | $time[2] | $time[3] | $time[4] | $time[5] | $time[6] | $time[7] | $weekdayW-->\n" ;
		
			if ( $weekday > 1.5 ) {
				${'weekcolour'.$ii} = $weekcolourcurrent ;
			} else {
				if ($weekcolourcurrent eq $BACKCOLOUROFF) {
					$weekcolourcurrent = $BACKCOLOURON ;
				} else {
					$weekcolourcurrent = $BACKCOLOUROFF ;
				}
				${'weekcolour'.$ii} = $weekcolourcurrent ;
			}
			
			${'count'.$ii} = &getdaycount($year,$month,$day) ;

			$count0 = $count0 + (${'count'.$ii}) ;
#			print "<!-- 2 \"$analyse\" Adding ".${'count'.$ii}." to \$count0 to get ".$count0."-->\n" ;
			if (${'count'.$ii} > $maxmonthly) { $maxmonthly = ${'count'.$ii} ; $maxmonthlydate = ${'month'.$thismonth}."/".$thisyear ;}
	
			${'color'.$ii} = $currdaycolor ;
			if ($currdaycolor eq $BACKCOLOUROFF) {
				$currdaycolor = $BACKCOLOURON ;
			} else {
				$currdaycolor = $BACKCOLOUROFF ;
			}
		}

		($EVALUATE_DIVISIONS_MONTHLY,$scalemonthlymax) = &getscale($maxmonthly) ;
		for ($ii = 1 ; $ii <= 31 ; $ii++) {
			@time = localtime($firstdate + (($ii-1) * 24 * 60 * 60));
			$monthW   = ${'month'.($time[4]+1)} ;
			if ($monthW ne $monthIN) { next ;}
			${'height'.$ii} = int(   ($GRAPHHEIGHT * ${'count'.$ii}) / $scalemonthlymax   ) ;
			${'monthcheck'.$ii} = "OK" ;
		}
		$EVALUATE_SCALES_MONTHLY = &$sub_output($SCALES) ;
	}

	&getthistime('Start of daily processing');
	if ( ($dayfile) || ($analyse eq "ALLTIME") || ($analyse eq "year") || ($analyse eq "month") || ($analyse eq "subdivisions") || ($analyse eq "clients") || ( $monthdir && ($analyse eq "words" || $analyse eq "phrases") ) ) {
		$fastesttime = 99999;
		$kk = 0 ;
		$maxtimesplit = 1 ;
		$maxdaily = 1 ;
#		print "<!--Markers=".$#searchmarkers."-->\n" ;

		if ( ($analyse eq "summary") || ($analyse eq "ALLTIME") || ($analyse eq "month") || ($analyse eq "year") || ($analyse eq "words") || ($analyse eq "phrases") || ($analyse eq "subdivisions") || ($analyse eq "clients") ) {
#			print "<!--About to read in figures-->\n" ;
			&readinfigures ;
		}
		if ( ($dayfile) || ($analyse eq "summary") || ($analyse eq "ALLTIME") || ($analyse eq "month" && $monthIN eq $thismonthW && $yearIN == $thisyear) || ($analyse eq "year" && $thisyear == $yearIN ) || ($analyse eq "words") || ($analyse eq "phrases") || ($analyse eq "subdivisions") || ($analyse eq "clients") ) {
			&getthistime('start Cat.ing in data');
			&catInData ;
			&getthistime('finish Cat.ing in data');
		}

		if ($goodcount > 0 ) {
			$avetime = int(($goodtime / $goodcount)*1000)/1000 ;
			$presearchtime = int(($presearchtime / $goodcount)*1000)/1000 ;
			$searchtime = int(($searchtime / $goodcount)*1000)/1000 ;
			$postsearchtime = int(($postsearchtime / $goodcount)*1000)/1000 ;
			$htmlgentime = int(($htmlgentime / $goodcount)*1000)/1000 ;
		} else {
			$avetime = "N/A" ;
		}
		if ($fastesttime > 5000) {
			$fastesttime = "N/A";
		} else {
			$fastesttime = int($fastesttime*1000)/1000 ;
		}
		$slowesttime = int($slowesttime*1000)/1000 || "N/A";
	
		if ($analyse eq "day") {
			$nextdate = timelocal(0, 0, 0, $dayIN, ($monthNO{$monthIN}-1), ($yearIN-1900)) + (24*60*60) ;
			if ($nextdate < time ) {
				@time = localtime($nextdate);
				$nextdayY     = ($time[5]+1900) ;
				$nextdayM     = ${'month'.($time[4]+1)} ;
				$nextdayD     = ($time[3]) ;
				print "<!---$nextdayY $nextdayM $nextdayD -->\n" ;
			}
			$prevdate = timelocal(0, 0, 0, $dayIN, ($monthNO{$monthIN}-1), ($yearIN-1900)) - (24*60*60) ;
			@time = localtime($prevdate);
			$prevdayY     = ($time[5]+1900) ;
			$prevdayM     = ${'month'.($time[4]+1)} ;
			$prevdayD     = ($time[3]) ;
			print "<!---$prevdayY $prevdayM $prevdayD -->\n" ;
		}
		
		($EVALUATE_DIVISIONS_DAILY,$scalemax) = &getscale($maxdaily) ;
		$EVALUATE_SCALES_DAILY = &$sub_output($SCALES) ;
		$yy = 0 ;
		for ($ii = 0 ; $ii <= 47 ; $ii++) {
			${'dailyheight'.$ii} = int (    ($GRAPHHEIGHT * ${'dailysplit'.$ii}) / ($scalemax||1)   ) ;
			if (${'dailyheight'.$ii} < 0.5) {${'dailyheight'.$ii} = "" ;}
#			print "<!--".$ii."~~".${'dailyheight'.$ii}."~~".${'dailysplit'.$ii}."-->\n" ;
			if ($dailycolourcurrent eq $BACKCOLOURON) {
				$dailycolourcurrent = $BACKCOLOUROFF ;
			} else {
				$dailycolourcurrent = $BACKCOLOURON ;
			}
			${'dailycolor'.$ii} = $dailycolourcurrent ;
			${'dailyaxis'.$ii} = int ($ii/2)."<br>".((($ii/2) - int ($ii/2))*6)."0" ;
		}

		($EVALUATE_DIVISIONS_TIMESPLIT,$scalemax) = &getscale($maxtimesplit) ;
		$EVALUATE_SCALES_TIMESPLIT = &$sub_output($SCALES) ;
		for ($jj = 0 ; $jj < ($#searchmarkers) ; $jj++) {
			${'timesplitheight'.$jj} = int (   ($GRAPHHEIGHT * ${'timesplit'.$jj}) / ($scalemax || 1)   ) ;
			${'timesplitscaleupper'.$jj} = $searchmarkers[$jj] ;
			${'timesplitscalelower'.$jj} = $searchmarkers[$jj+1] ;
		}

		# wordlists...
		if ($analyse eq "words") {
			$HARDlist = "wordlist" ;
			$ii = 0 ;
			if ($oneline) { $numberpercolumn = 100000 ; } else { $numberpercolumn = 50 ; } 
			foreach $word (sort { $topwords{$b} <=> $topwords{$a} } keys %topwords) {
#				print "<!--word=".$word."=".$topwords{$word}."-->\n" ;
				if ( ($ii >= $begin) && ($ii < ($begin + 200) )) {
					$jj = 1 + int (($ii - $begin)/$numberpercolumn) ;
					${'wordlist'.$jj}{$word} = $topwords{$word} ;
#					print "<!--Setting \$wordlist$jj{$word}=".${'wordlist'.$jj}{$word}."-->\n" ;
				}
				$ii++ ;
			}
		}

#		phrase lists
		if ($analyse eq "phrases") {
			$HARDlist = "phraselist" ;
			$ii = 0 ;
			if ($oneline) { $numberpercolumn = 100000 ; } else { $numberpercolumn = 50 ; } 
			foreach $phrase (sort { $topphrases{$b} <=> $topphrases{$a} } keys %topphrases) {
				if ( ($ii >= $begin) && ($ii < ($begin + 200) )) {
					$jj = 1 + int (($ii - $begin)/$numberpercolumn) ;
					${'phraselist'.$jj}{$phrase} = $topphrases{$phrase} ;
				}
				$ii++ ;
			}
		}

#		subdivision list
		if ($analyse eq "subdivisions") {
			$HARDlist = "subdivisionlist" ;
			$ii = 0 ;  # %subdivsearches   $subdivisioncount   99/33  = 3 columns of 33
			$numberpercolumn = 1 + int($subdivisioncount / 3) ;
			if ($numberpercolumn < 4 ) { $numberpercolumn = 4 ; }
			if ($oneline) { $numberpercolumn = 100000 ; }
			foreach $subdiv (sort { $subdivsearches{$b} <=> $subdivsearches{$a} } keys %subdivsearches) {
				if ( ($ii >= $begin) && ($ii < ($begin + 1000) )) {
					$jj = 1 + int (($ii - $begin)/$numberpercolumn) ;
					${'subdivisionlist'.$jj}{$subdiv} = $subdivsearches{$subdiv} ;
				}
				$ii++ ;
			}
		}

#		client list
		if ($analyse eq "clients") {
			$HARDlist = "clientlist" ;
			$ii = 0 ; 
			$numberpercolumn = 1 + int($clientcount / 4) ;
			if ($numberpercolumn < 5 ) { $numberpercolumn = 5 ; }
			if ($oneline) { $numberpercolumn = 100000 ; }
			foreach $client (sort { $clients{$b} <=> $clients{$a} } keys %clients) {
				if ( ($ii >= $begin) && ($ii < ($begin + 1000) )) {
					$jj = 1 + int (($ii - $begin)/$numberpercolumn) ;
					${'clientlist'.$jj}{$client} = $clients{$client} ;
				}
				$ii++ ;
			}
		}

	}

	if ( ($analyse eq "year") || ($analyse eq "ALLTIME") ) {
		&getmonthlydata ;
		if ( $analyse eq "year" ) {
			if ( $yearIN < $thisyear ) {
				$nextyearY = $yearIN + 1 ;
			}
			$prevyearY = $yearIN - 1 ;
			if (-e "$logroot/$prevyearY") {
			} else {
				$prevyearY = ""
			}
		}
	}

	if ( ($analyse eq "compare") && ($compareType) ) {
		&readInGeneralData ;
		if ($compareType eq "days" ) {
			for ($ii = 1 ; $ii <= $periods ; $ii++) {
				${'count_'.$ii.'_0'} = &getdaycount($FORM{'year'.$ii},$FORM{'month'.$ii},$FORM{'day'.$ii}) ;
				&catInData($FORM{'year'.$ii},$FORM{'month'.$ii},$FORM{'day'.$ii},"_".$ii) ;
			}
			for ($ii = 1 ; $ii <= $periods ; $ii++) {
				for ($jj = 0 ; $jj <= 23 ; $jj++) {
					for ($kk = 0 ; $kk <= $jj ; $kk++) {
						if ($kk < 9.5) {
							${'cumulativeperhour_'.$ii}{$jj} = ${'cumulativeperhour_'.$ii}{$jj} + ${'perhour_'.$ii}{'0'.$kk} ;
						} else {
							${'cumulativeperhour_'.$ii}{$jj} = ${'cumulativeperhour_'.$ii}{$jj} + ${'perhour_'.$ii}{$kk} ;
						}
					}
				}
			}
		} elsif ($compareType eq "months") {

		}
	}

	if ($count0 || ($count0 ne "" && ($count0 > 0.01) ) ) {
		$percentagezeroes = int( ($zeroes / $count0) * 1000 ) / 10 ;
	}

	if ($distinctIPs || ($distinctIPs ne "" && ($distinctIPs > 0.01) ) ) {
		$searchesPerIP = int( ($count0 / $distinctIPs) * 100 ) / 100 ;
	}

	#~~~~~~~~~~ print output ~~~~~~~~~~~~~
	&getthistime('Start of HTML processing');
	&$sub_write_output ;
	&getthistime('End of HTML processing');
	print "\n\n\n<!--This process took ".$timeval{'postoutput'}." seconds to complete-->" ;

	open(ANALYSISLOGGING,">>/RSCentral/Logs/log_SearchAnalysis");
	$datenow =`date`;
	chop $datenow;
	print ANALYSISLOGGING $hostname."\t".$username."\t".$datestamp."\t".$scriptname."\t".$analyse."\t".$timeval{'postoutput'}."\t".($buffer || $ENV{'QUERY_STRING'})."\n" ;
	close(ANALYSISLOGGING);

}


sub readinfigures {
	if ($permissions{$username} ne "all" || $focus) {
		$catmonthdir = $monthdir."/subdivdata/".($focus || $permissions{$username}) ;
	} else {
		$catmonthdir = $monthdir ;
	}
#	print "<!--catmonthdir: $catmonthdir-->\n" ;
	$grepcommand = "cat $catmonthdir/generaldata" ;
	open(LIST, "$grepcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		chomp ;
		@line = split(/\t/,$_) ;
		if ($line[0] !~ /max/) {
			${$line[0]} = ${$line[0]} + $line[1] ;
			print "<!--Adding $line[1] to \$$line[0]-->\n" ;
		} else {
			if ($line[0] =~ /date/i ) {
				if ($value > ${$setting}) {
					${$setting} = $value   ;
					${$line[0]} = $line[1] ;
				}
			} else {
				$setting = $line[0] ;
				$value = $line[1] ;
			}
		}
#		print "<!--Adding ".$line[1]." to \"".$line[0]."\" to get ".${$line[0]}."-->\n";
	}
	close(LIST);

	# read word list
	%topwords = "" ;
	$grepcommand = "cat $catmonthdir/wordlist" ;
	open(LIST, "$grepcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		$kk++ ; 	chomp ;
		@line = split(/\t/,$_) ;
		if (!$topwords{$line[0]}) {$wordcount++;}
		$topwords{$line[0]} = $topwords{$line[0]} + $line[1] ;
	}
	close(LIST);

	# read phrase list
	$grepcommand = "cat $catmonthdir/phraselist" ;
	open(LIST, "$grepcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		$kk++ ; 	chomp ;
		@line = split(/\t/,$_) ;
		if (!$topphrases{$line[0]}) {$phrasecount++;}
		$topphrases{$line[0]} = $topphrases{$line[0]} + $line[1] ;
	}
	close(LIST);

	# read client list
	$grepcommand = "cat $catmonthdir/clients" ;
	open(LIST, "$grepcommand | ") || print "Cannot execute" ;
	while (<LIST>) {
		chomp ;
		@line = split(/\t/,$_) ;
		if (!$clients{$line[0]}) {
			$clientcount++ ;
		}
		if ($line[0]) { $clients{$line[0]} = $clients{$line[0]} + $line[1] ; }
	}
	close(LIST);

	# read subdivision list
	if ($permissions{$username} eq "all" && !$focus) {
		$grepcommand = "cat $monthdir/subdivisions" ;
	} else {
		$grepcommand = "grep '".($focus || $permissions{$username})."' $monthdir/subdivisions" ;
	}
#	print "<!--SUBDIV grepcommand: $grepcommand-->\n" ;
	open(LIST, "$grepcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		$kk++ ; 	chomp ;
		if ($permissions{$username} eq "all" && !$focus) {
			@line = split(/\t/,$_) ;
			print "<!--HERE subdiv grep = ".$line[0]."-->\n" ;
		} else {
			($line[0],$line[1]) = /.*:(.*)\t(.*)/ ;
		}
		if ($line[0] && !$invalidSubdiv{$line[0]}) {
			if (!$subdivsearches{$line[0]}) {
				$subdivisioncount++ ;
			}
			$subdivsearches{$line[0]} = $subdivsearches{$line[0]} + $line[1] ;
		}
	}
	close(LIST);

	$grepcommand = "cat $catmonthdir/intraday" ;
	open(LIST, "$grepcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		chomp ;
		@line = split(/\t/,$_) ;
		${'dailysplit'.$line[0]} = ${'dailysplit'.$line[0]} + $line[1] ;
		if (  ${'dailysplit'.$line[0]} > $maxdaily) {
			$maxdaily = ${'dailysplit'.$line[0]} ;
		}
		$searchhour = int($line[0]/2) ;
		if ($searchhour <=9.5) { $searchhour = "0".$searchhour ; }
		$perhour{$searchhour} = $perhour{$searchhour} + $line[1] ;
	}
	close(LIST);

	$grepcommand = "cat $catmonthdir/timesplits" ;
	open(LIST, "$grepcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		chomp ;
#		print "<!--".$_."-->\n" ;
		@line = split(/\t/,$_) ;
		${'timesplit'.$line[0]} = ${'timesplit'.$line[0]} + $line[1] ;
#		print "<!--\$timesplit".$line[0]."=".${'timesplit'.$line[0]}."-->\n" ;
		if (  ${'timesplit'.$line[0]} > $maxtimesplit) {
			$maxtimesplit = ${'timesplit'.$line[0]} ;
		}
		if (  ${'timesplit'.$line[0]} == 0) {
			${'timesplit'.$line[0]} = "" ;
		}
	}
	close(LIST);
}

sub catInData {
	my($year,$month,$day,$subscript) = @_ ;
	my($ii) ;
	print "<!--CAT'ing in: $year,$month,$day,$subscript-->\n" ;
	if ($dayfile || $compareType eq "days") {
		if ($dayfile) {
			$grepcommand = "cat $dayfile" ;
			$subscript = "" ;
		} else {
			if ($day == $thisday && $month == $thismonth  && $year == $thisyear ) {
				$grepcommand = "cat $logtoday" ;
			} else {
				$grepcommand = "cat ".$logroot."/".$year."/".$month."/".$year."_".$month."_".$day.".log";
			}
		}
#		print "<!--$grepcommand-->\n" ;
		open(LIST, "$grepcommand | ") || print "Cannot execute" ;
		while (<LIST>) {
			chomp ;
			@line = split(/\t/,$_) ;
			if ($invalidSubdiv{$line[3]}) { next ; }
			$allSubDivs{$line[3]} = $line[3] ;
#			print "<!--$line[3]-->\n" ;
			if ( ( ( $permissions{$username} ne "all" ) && ( $line[3] ne $permissions{$username} ) ) || ( ( $focus ) && ( $line[3] ne $focus ) ) ) { next ; }
			$kk++ ;
			$_ = $line[2] ;
			($company) = /\/export\/([^\/]*)\//i ; $company =~ tr/[A-Z]/[a-z]/ ;
			if (!$clients{$company}) {
				$clientcount++ ;
			}
			$clients{$company}++ ;
			$line[11] =~ tr/[A-Z]/[a-z]/ ;
#			$rsboxes{$line[11].'-'.$line[12]}++ ;
			if (!$line[11] || $line[11] !~ /rs/i ) {
				$line[11] = "N/A" ;
			}
			$rsboxes{$line[11]}++ ;
			if ($line[7] && $line[8] && $line[9] && $line[10]) {
				$goodcount++ ;
				$goodtime = $goodtime + $line[10] ;
				$goodtime{$company} = $goodtime{$company} + $line[10];
				$goodcount{$company}++ ;

				$presearchtime = $presearchtime + $line[7] ;
				$searchtime = $searchtime + ($line[8]-$line[7]) ;
				$postsearchtime = $postsearchtime + ($line[9]-$line[8]) ;
				$htmlgentime = $htmlgentime  + ($line[10]-$line[9]) ;
				
				if ($line[10] < $fastesttime) {
					$fastesttime = $line[10] ;
				}
				if ($line[10] > $slowesttime) {
					$slowesttime = $line[10] ;
				}
				for ($jj = 0 ; $jj < ($#searchmarkers) ; $jj++) {
					if ( ($line[10] > $searchmarkers[$jj]) && ($line[10] < $searchmarkers[$jj+1]) ) {
						if ($jj > 21) {
							print "<!--Slow search at ".$line[1]." [$company] time=".$line[10]." query=\"$line[4]\"-->\n" ;
						}
						${'timesplit'.$jj}++ ;
						if (${'timesplit'.$jj} > $maxtimesplit) { $maxtimesplit = ${'timesplit'.$jj} ; }
						break ;
					}
				}
			}

			if (!$IPs{$line[0]}) {
				$distinctIPs++ ;
				$IPs{$line[0]} = $line[0] ;
			}
						
			@wordgiven = "" ;
			$line[4] =~ tr/[A-Z]/[a-z]/ ;
			$line[4] =~ s/\sand\s/$blank/eigs ;
			$line[4] =~ s/\sor\s/$blank/eigs ;
			while ($line[4] =~ /\s\s/i ) {
				$line[4] =~ s/\s\s/$blank/ ;
			}
			$line[4] =~ s/^\s(.*)$/$1/i ;
			$line[4] =~ s/^(.*)\s$/$1/i ;
			
			if ($line[4] =~ /\s/i) {
				@wordgiven = split(/\s/,$line[4]) ;
				for ($ii = 0 ; $ii <= $#wordgiven ; $ii++) {
					if (!$topwords{$wordgiven[$ii]}) {$wordcount++;}
					$topwords{$wordgiven[$ii]}++ ;
				}
				if (!$topphrases{$line[4]}) {$phrasecount++;}
				$topphrases{$line[4]}++ ;
			} else {
				$topwords{$line[4]}++ ;
			}

			if ($line[3] && !$invalidSubdiv{$line[3]}) {
				if (!$subdivsearches{$line[3]}) {
					$subdivisioncount++ ;
				}
				$subdivsearches{$line[3]}++ ;
			}

			if (!$line[5]) {${'zeroes'.$subscript}++ ;}
			
			$_ = $line[1] ;
			($searchhour,$searchminute) = /\s([\d]*):([\d]*):/i ;
			if ($searchminute >= 30 ) { $searchminute = 1 ; } else { $searchminute = 0;}
			${'dailysplit'.($searchhour*2+$searchminute)}++ ;
			if (  ${'dailysplit'.($searchhour*2+$searchminute)} > $maxdaily) {
				$maxdaily = ${'dailysplit'.($searchhour*2+$searchminute)} ;
			}
			${'perhour'.$subscript}{$searchhour}++ ;
			
			if ($line[19]) {
#				print "<!--Found a line with: ".$line[19]." bytes-->\n" ;
				$bandwidth = $bandwidth + $line[19] ;
			}
		}
		close(LIST);

		$counttoday = $kk ;
		
		if ( ($analyse ne "month") && ($analyse ne "SNAPSHOT") && ($analyse ne "summary") ) {
			$count0 = $count0 + $counttoday ;
#			print "<!-- 3 \"$analyse\" Adding ".$counttoday." to \$count0 to get ".$count0."-->\n" ;
		}
		
		foreach $company (keys %goodcount) {
			if ($goodcount{$company} > 0) {
				${'averagespeed'.$company} = (int(($goodtime{$company} / $goodcount{$company})*1000))/1000 ;
			}
		}
	
	}
}

sub getmonthlydata {
#	if ($analyse eq "year") {$yeartemp = $yearIN	; } else { $yeartemp = "*" ; }
	if ($analyse eq "year") {
		if ($permissions{$username} eq "all" && !$focus) {
			$grepcommand = "grep 'total' $logroot/".$yearIN."/*/count" ;
		} else {
			$grepcommand = "grep '".($focus || $permissions{$username})."' $logroot/".$yearIN."/*/subdivisions" ;
		}
	} else {
		if ($permissions{$username} eq "all" && !$focus) {
			$grepcommand = "grep 'total' $logroot/*/*/count" ;
		} else {
			$grepcommand = "grep '".($focus || $permissions{$username})."' $logroot/*/*/subdivisions | grep 'subdivisions:".($focus || $permissions{$username})."\t'" ;
		}
	}
	print "<!--FIRST  ".$grepcommand."-->\n" ;
	open(LIST, "$grepcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		$kk++ ;
		chomp ;
		if (/:/) {
			($yearM,$monthM,$totalM) = /^[^\d]*([\d]*)\/([\d]*)[^\d]*([\d]*)[^\d]*$/i ;
		} else {
			if ( $thisyear == $yearIN ) {
				$yearM = $thisyear ;
				$monthM = $thismonth ;
				($totalM) = /\s*?[^\d]*([\d]*)/ ;
			} else {
				# DODGY HACK TO GET RIGHT DATE when a customer's service starts in Dec - I.e. alstom:
				$yearM = $yearIN ;
				$monthM = 12 ;
				($totalM) = /\s*?[^\d]*([\d]*)/ ;
			}
		}
		print "<!--".$yearM."-".$monthM."=".$totalM."-->\n" ;
		if ($monthM < 10 ){ $zero = "0" } else {$zero = ""}

		$monthtotal{$yearM.'-'.$zero.$monthM} = $monthtotal{$yearM.'-'.$zero.$monthM} + $totalM ;
		if ($monthtotal{$yearM.'-'.$zero.$monthM} > $maxmonthly) { $maxmonthly = $monthtotal{$yearM.'-'.$zero.$monthM} ; $maxmonthlydate = ${'month'.$monthM}."/".$yearM ;}
		$grandtotal = $grandtotal + $monthtotal{$yearM.'-'.$zero.$monthM} ;
		if ($yearM == $thisyear) {
			$totalthisyear = $totalthisyear + $monthtotal{$yearM.'-'.$zero.$monthM} ;
		} elsif ($yearM == ($thisyear-1)) {
			$totallastyear = $totallastyear + $monthtotal{$yearM.'-'.$zero.$monthM} ;
		}
	}

	# Whatever happens, add $count0 to "thisyear/thismonth"
	if ( ( ($analyse eq "year") || ($analyse eq "month") || ($analyse eq "ALLTIME") || ($analyse eq "SNAPSHOT" ) || ( $analyse eq "summary" ) ) && ($yearIN == $thisyear) ) {
		if ($thismonth < 10 ){ $zero = "0" } else {$zero = ""} ;
#		$totalM = $totalM + $count0 ;
		$monthtotal{$thisyear.'-'.$zero.$thismonth} = $monthtotal{$thisyear.'-'.$zero.$thismonth} + $count0 ;
		if ($monthtotal{$thisyear.'-'.$zero.$thismonth} > $maxmonthly) { $maxmonthly = $monthtotal{$thisyear.'-'.$zero.$thismonth} ; $maxmonthlydate = ${'month'.$thismonth}."/".$thisyear ;}
		$grandtotal = $grandtotal + $count0 ;
		$totalthisyear = $totalthisyear + $count0 ;
	}
	
	
	$mmm= 0 ; $lastmonth = 999; $mmmyearspan = 0 ; $lastyear = 1933 ;
	($EVALUATE_DIVISIONS_MONTH,$scalemonthmax) = &getscale($maxmonthly) ;

#	foreach $monthloop (sort keys %monthtotal) {
#		print "<!--$monthloop=$monthtotal{$monthloop}-->\n" ;
#	}
	foreach $monthloop (sort keys %monthtotal) {
		$mmm++ ;
		$_ = $monthloop ; ($yearM,$monthM) = /^([\d]*)\-([\d]*)$/i ;
		if ( ($analyse eq "year" || $analyse eq "ALLTIME" ) ) {
			$count0 = $count0 + $monthtotal{$monthloop} ;
		}
#		print "<!--".$yearM."=".$thisyear." and ".$monthM."=".$thismonth." and ".$analyse."=year-->" ;
#		if ( $yearM == $thisyear && $monthM == $thismonth && ($analyse eq "year" || $analyse eq "ALLTIME") ) {
#			$monthtotal{$monthloop} = $monthtotal{$monthloop} + $counttoday ;
#			print "<!--Added ".$counttoday." to ".$monthloop." to get ".$monthtotal{$monthloop}."-->\n" ;
#		}

		${'monthM'.$mmm} = $monthM * 1 ;
		${'yearM'.$mmm} = $yearM * 1 ;
#		print "<!--Setting yearM$mmm to ".${'yearM'.$mmm}."-->\n" ;
		${'monthcount'.$mmm} = $monthtotal{$monthloop} ;
		if (${'monthcount'.$mmm} == 0) {
			${'monthheight'.$mmm} = int(   $GRAPHHEIGHT   ) ;
		} else {
			${'monthheight'.$mmm} = int(   ($GRAPHHEIGHT * ${'monthcount'.$mmm}) / $scalemonthmax   ) ;
		}

		${'Mmonthgraph'.$mmm} = ${'monthEN'.${'monthM'.$mmm}} ;
		${'MmonthgraphScaleDisplay'.$mmm} = ${'month'.$DISPLANG.${'monthM'.$mmm}} ;
		${'MmonthgraphTagDisplay'.$mmm} = ${'month'.$DISPLANG.${'monthM'.$mmm}} ;
		${'Myeargraph'.$mmm} = ${'yearM'.$mmm} ;
		if ($monthcolourcurrent eq $BACKCOLOUROFF) {
			$monthcolourcurrent = $BACKCOLOURON ;
		} else {
			$monthcolourcurrent = $BACKCOLOUROFF ;
		}
		${'Mmonthcolour'.$mmm} = $monthcolourcurrent ;
		if ( ${'yearM'.$mmm} == $lastyear) {
			${'Yearcolspan'.$mmmyearspan}++ ;
			${'Myeargraphyear'.$mmmyearspan} = $yearM ;
			${'Myeargraphdisplay'.$mmmyearspan} = $yearM ;
		} else {
			$mmmyearspan++ ;
#			print "<!--mmmyearspan=$mmmyearspan-->\n" ;
			if ($yearcolourcurrent eq $BACKCOLOUROFF) {
				$yearcolourcurrent = $BACKCOLOURON ;
			} else {
				$yearcolourcurrent = $BACKCOLOUROFF ;
			}
			${'Myearcolour'.$mmmyearspan} = $yearcolourcurrent ;
			${'Yearcolspan'.$mmmyearspan}++ ;
			${'Myeargraphyear'.$mmmyearspan} = $yearM ;
			${'Myeargraphdisplay'.$mmmyearspan} = $yearM ;
		}
		$lastyear = ${'yearM'.$mmm} ;
	}
	if ( ($analyse eq "ALLTIME") || ($analyse eq "year") ) {
		$count0 = $count0 - $counttoday ;
	}

	$EVALUATE_SCALES_MONTH = &$sub_output($SCALES) ;
	$widthmonth = int ( $WIDTH / ($mmm + 6) ) - 2 ;
	if ($widthmonth < 18) {
		for ($ii = 1 ; $ii <= $mmm ; $ii++) {
			${'MmonthgraphScaleDisplay'.$ii} =~ s/^([A-Z]).*$/$1/i ;
		}
	}
	if ($widthmonth < 23) {
		for ($ii = 1 ; $ii <= $mmmyearspan ; $ii++) {
			if (${'Yearcolspan'.$ii} < 1.5) {
				$_ = ${'Myeargraphdisplay'.$ii} ;
				(${'Myeargraphdisplay'.$ii}) = /^.*?([\d][\d])$/ ;
			}
		}
	}

}

sub linkDate {
	$linkdate = $_[0] ;
	$_ = $linkdate ;
	if ( /([\d]*)\/([a-zA-Z]{3})\/([\d]{4})/ ) {
		return "?analyse=day~day=$1~month=$2~year=$3" ;
	} elsif ( /([a-zA-Z]{3})\/([\d]{4})/ ) {
		return "?analyse=month~month=$1~year=$2" ;
	}
}

sub getthistime {
	@finishTime = gettimeofday;                                                                                                  
	for ($finishTime[1], $startTime[1]) { $_ /= 1_000_000 }                          
	$duration = ($finishTime[0]-$startTime[0])+($finishTime[1]-$startTime[1]) ;         
	$timeval{$_[0]} = int($duration*10000)/10000;
#	print "<!--Time at ".$_[0]." is ".$timeval{$_[0]}."-->\n" ;
}



sub getdaycount {
	my($year,$month,$day) = @_ ;
	my($date) = $year."_".$month."_".$day;
	if ($year == $thisyear && $month == $thismonth && $day == $thisday) {
		if ($permissions{$username} eq "all" && !$focus) {
			$grepcommand = "wc -l $logtoday" ;
		} else {
			$grepcommand = "grep \"cgi\t".($focus || $permissions{$username})."\t\" $logtoday | wc -l" ;
		}
#		print "<!--$grepcommand-->\n" ;
		open(LIST, "$grepcommand | ") || print "Cannot execute" ;
		$_ = <LIST> ;
		chomp ;
		close(LIST);
#		(${'count'.$subscript.($periodNumber || $day)}) = $_ * 1 ;
		return ($_ * 1) ;
	} else {
		if ($permissions{$username} eq "all" && !$focus) {
			$grepcommand = "grep '$date.log' $logroot/$year/$month/count" ;
#			print "<!--$grepcommand-->\n" ;
			open(LIST, "$grepcommand | ") || print "Cannot execute" ;
			$returnedVal = $_ = <LIST> ; chomp ;
			close(LIST);
#			(${'count'.$ii}) = /^\s*(\d*)\s*.*?$/ ;
			/^\s*([\d]*)\s*.*?$/ ;
			return $1 ;
		} else {
			$grepcommand = "grep '$date.log' $logroot/$year/$month/subdivdata/".($focus || $permissions{$username})."/count" ;
#			print "<!--$grepcommand-->\n" ;
			open(LIST, "$grepcommand | ") || print "Cannot execute" ;
			$_ = <LIST> ; chomp ;
			close(LIST);
#			(${'count'.$subscript.($periodNumber || $day)}) = /^.*?count\:\s*(\d*).*?$/ ;
			/^.*?count\:\s*(\d*).*?$/ ;
			return $1 ;
		}
	}
}



sub readInGeneralData {
	if ($permissions{$username} ne "all" || $focus) {
		$catmonthdir = " ".$logroot."/*/*/subdivdata/".($focus || $permissions{$username}) ;
	} else {
		$catmonthdir = " ".$logroot."/*/*" ;
	}
#	print "<!--catmonthdir: $catmonthdir-->\n" ;
	$grepcommand = "cat $catmonthdir/generaldata" ;
	open(LIST, "$grepcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		chomp ;
		@line = split(/\t/,$_) ;
		if ($line[0] !~ /max/) {
			${$line[0]} = ${$line[0]} + $line[1] ;
			print "<!--Adding $line[1] to \$$line[0]-->\n" ;
		} else {
			if ($line[0] =~ /date/i ) {
				if ($value > ${$setting}) {
					${$setting} = $value   ;
					${$line[0]} = $line[1] ;
					print "<!--Greater than: setting \$".$setting." to ".$value." and \$".$line[0]." to ".$line[1]."-->\n" ;
				}
			} else {
				$setting = $line[0] ;
				$value = $line[1] ;
			}
		}
	}
	close(LIST);
}



