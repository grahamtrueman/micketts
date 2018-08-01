#!/bin/perl

require('/RSCentral/AnalysisScripts/analysisConfig.pl') ;
require "/RSCentral/AnalysisScripts/searchAnalysisLIBRARY.pl" ;
require "/RSCentral/Pearl-Web/mail.pl" ;

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
	
	$HTMLdir = "/RSCentral/AnalysisScripts/" ;

	$DB             = 'DBI:mysql:remotesearch:db1'            ;
	$DBusername     = 'remotesearch'                          ;
	$DBpassword     = 'findforme'                             ;

	$scriptname = $ENV{'SCRIPT_FILENAME'} ;

	&gettime('start');
	$username = $ENV{'REMOTE_USER'} || "-";
	$hostname = $ENV{'REMOTE_HOST'} || $ENV{'REMOTE_ADDR'};
	open(IN,"hostname |") ;
	$servername = <IN> ;
	chomp $servername;
	close(IN) ;
	
	&readstoplist("/rs/Conf/stoplist") ;
	$excludeips = "egrep -v '(".join(")|(",@excludemach).")'" ;
	
	$permissions{'magadmin'} = "all" ;
	$permissions{'-'} = "all" ;
	$permission = $permissions{$username} ;
	
	$_ = $ENV{'SCRIPT_FILENAME'};
	($thissite) = /\/export\/([^\/]*)/ ;
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

	$lastmonthY = $thisyear ;
	$lastmonth = ($time[4]); if ($lastmonth < 0.5) { $lastmonth = 12 ; $lastmonthY-- }
	$lastmonthW  = ${'month'.$lastmonth} ;

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

	$URI = $ENV{'SCRIPT_NAME'} ;
	# Sanofi download catch
	if ( $URI =~ /^\/download\/Magus_([^\/]*)_(\d\d\d\d)(\d\d)\.csv/ ) {
		print "Content-type: text\/csv; charset=UTF-8\n\n";
		$focus = $FORM{'focus'} = $downloadsiteId = $1 ; $NOSTAMP = "YES" ;
		$analyse = $FORM{'analyse'} = "month" ;
		$monthIN = $FORM{'month'} = $lastmonthW = ${'month'.($3*1)} ;
		$yearIN = $FORM{'year'} = $2 ;
		
		#if ( $FORM{'month'} && $FORM{'year'} ) {
		#	$analyse = $FORM{'analyse'} = "month" ;
		#} elsif ( !$FORM{'month'} && $FORM{'year'} ) {
		#	$analyse = $FORM{'analyse'} = "year" ;
		#} else {
		#	$analyse = $FORM{'analyse'} = "month" ;
		#	$lastmonthY = $thisyear ;
		#	$lastmonth = $thismonth-1 ;
		#	if ($lastmonth < 0.5) { $lastmonth = 12 ; $lastmonthY-- }
		#	$monthIN = $FORM{'month'} = $lastmonthW  = ${'month'.$lastmonth} ;
		#	$yearIN = $FORM{'year'} = $lastmonthY ;
		#}
	} elsif ($FORM{'type'} eq 'xml') {
		print "Content-type: application\/xml\n\n";	
		$NOSTAMP = "YES" ;
	} else {
		print "Content-type: text\/html; charset=UTF-8\n\n";	
	}
	
	# Read the language variation from the cookie and set to English if not there
	if (!$displang) { &readCookie("displang"); }
	if (!$displang) { $displang = "en"; }
	$formatfile = "/RSCentral/AnalysisScripts/formatlang_".$displang;
	
	&$sub_loadFragments($formatfile) ;
	#&$sub_read_format;

	if ($FORM{'type'} eq 'emailer') {
		&$sub_loadFragments($emailerformat) ;
	}
	if ($FORM{'type'} eq 'xml') {
		&$sub_loadFragments($xmlformat) ;
	}
	
	#Set default permissions
#	print "<!--Logged in as $username-->\n" ;
	if ($permissions{$username} && $permissions{$username} ne "all") {
		if ( $permissions{$username} !~ /\,/ ) {
			$focus = $permissions{$username} ;
			$permissionSplit = 0 ;
		} else {
			if ( $FORM{'focus'} ) {
				if ( $focus ne $username && $permissions{$username} =~ /$FORM{'focus'}/) {
					$permissionSplit = 2 ;
					$focus = $FORM{'focus'}
				} else {
					$permissionSplit = 1 ;
					$focus = $username ;
				}
			} else {
				$permissionSplit = 1 ;
				$focus = $username ;
			}
			@focusList = split(/\,/,$permissions{$username}) ;
			foreach $i (@focusList) { $allSubDivs{$i}=$i }
		}
	}
	
	if ($corpoOnly) { $focus = "corporate" ; }
	
	#If names of the scripts are not set in local script, it sets the default
	if (!$adminName){
		$adminName = "searchAdmin.cgi";
	}
	if (!$analysisName){
		$analysisName = "searchAnalysis.cgi";
	}
	if (!$searchName){
		$searchName = "/cgi-bin/RS.cgi";
	}
	
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
	} elsif ( ($analyse eq "words") || ($analyse eq "phrases") || ($analyse eq "subdivisions") || ($analyse eq "clients") || ($analyse eq "zeroes") ) {
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
		$firstdate = timelocal(0, 0, 0, 1, ($monthNO{$monthIN}-1), ($yearIN-1900)) + 4 * 60 * 60 ;
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
#	print "<!--dayfile=".$dayfile."-->\n" ;
#	print "<!--monthdir=".$monthdir."-->\n\n" ;

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
	# get definitive subdivision list only if it is not set with a permissions list:
	if (!$permissionSplit) {
		$systemcommand = "ls -1 $logroot/*/*/subdivdata/*/count";
		open(LIST, "$systemcommand | ") || print "Cannot execute" ;
		while (<LIST>) {
			chomp ;
			($thisSubDiv) = /^\/.*\/([^\/]*)\/count$/ ;
			if ( !$invalidSubdiv{$thisSubDiv} ) {
				$allSubDivs{$thisSubDiv} = $thisSubDiv ;
			}
		}
	}

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#     E N D of initial processing - process graphs...
	# ~~~~~~~~~~~~~~~~~~~~~~~~~
	# Process Snapshot graph
	&gettime('Start of snapshot processing');
	if ( ($analyse eq "SNAPSHOT") || ($analyse eq "summary") ) {
		$lastday = 0;
		$ddd = 1 ;
		$maxSnapshotDays = 1 ;
		$space = " " ;
		$weekcolourcurrent = $BACKCOLOURON ;
		$currmoncolor = $BACKCOLOURON ;
		$currdaycolor = $BACKCOLOURON ;
		for ($ii = $SNAPSHOTDAYS ; $ii >= 0 ; $ii--) {
			&gettime(" calculating day ".$ii." ago ");
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
			
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			# find system command for this day
			if ($ii == 0) {
				# looking for today's total
				if ($permissions{$username} eq "all" && !$focus) {
					$systemcommand = "cat $dayfile | $excludeips | wc -l " ;
				} else {
					# let's find the right pattern to match in today's file...
					if ($permissionSplit==1) {
						$matchText = "\"".$subdivCode{$username}."\"" ;
					} else {
						$matchText = "\"\t".($focus || $permissions{$username})."\t\"" ;
					}
					$systemcommand = "/usr/xpg4/bin/grep -E ".$matchText." $logtoday | wc -l" ;
				}
			} else {
				# looking for an archive day's total
				
				if ( ( $permissions{$username} ne "all" || $focus ) ) {
					if ($permissionSplit==1) {
						$systemcommand = "ls -1 $logroot/$year/$month/subdivdata/*/count | /usr/xpg4/bin/grep -E \"".$subdivCode{$username}."\" | xargs cat | grep $date.log" ;
					} else {
						$systemcommand = "grep $date.log $logroot/$year/$month/subdivdata/".($focus || $permissions{$username})."/count" ;
					}
				} else {
					$systemcommand = "grep $date.log $logroot/*/*/count" ;
				}
			}
			open(LIST, "$systemcommand | ") || print "Cannot execute" ;
			while(<LIST>) {
				chomp ;
				if ( $_ =~ /count\:/ ) { 
					($thiscT) = /^.*?count\:\s*(\d*).*?$/ ;
				} elsif ( $_ =~ /\s*([\d]*).*?/ ) {
					$thiscT = $1 ;
				} else {
					$thiscT = 0 ;
				}
				${'count'.$ii} = ${'count'.$ii} + $thiscT
			}
			close(LIST);
			${'count'.$ii} = ${'count'.$ii}*1 ;
			$DEBUG .= "<!-- SystemCommandToGetDay ".$ii.": ".$systemcommand." |---|count=".${'count'.$ii}."|-- -->\n\n" if $DEBUGlevel >= 3 ;
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
	
	}
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# processing Monthly
	&gettime('Start of monthly processing');
	if ($analyse eq "month") {
		$lastday = 0;
		$xx = 1 ;
		$maxmonthly = 1 ;
		$space = " " ;
		$weekcolourcurrent = $BACKCOLOURON ;
		$currdaycolor = $BACKCOLOURON ;

		#Calculate Unix time stamp to start on
		$firstdate = timelocal(0, 0, 0, 1, ($monthNO{$monthIN}-1), ($yearIN-1900)) + 4 * 60 * 60 ;
		
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
			if (${'count'.$ii} > $maxmonthly) {
#				print "<!-- setting max monthly to: ~~| \$count$ii=".${'count'.$ii}."|~~ -->\n\n" ;
				$maxmonthly = ${'count'.$ii} ; $maxmonthlydate = ${'month'.$thismonth}."/".$thisyear ;
			}
	
			${'color'.$ii} = $currdaycolor ;
			if ($currdaycolor eq $BACKCOLOUROFF) {
				$currdaycolor = $BACKCOLOURON ;
			} else {
				$currdaycolor = $BACKCOLOUROFF ;
			}
		}

#		print "<!--Getting scale for monthhly ~~|".$maxmonthly."|~~ -->" ;
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

	&gettime('Start of daily processing');
	if ( ($dayfile) || ($analyse eq "ALLTIME") || ($analyse eq "year") || ($analyse eq "month") || ($analyse eq "subdivisions") || ($analyse eq "clients") || ($analyse eq "zeroes") || ( $monthdir && ($analyse eq "words" || $analyse eq "phrases") ) ) {
		$fastesttime = 99999;
		$kk = 0 ;
		$maxtimesplit = 1 ;
		$maxdaily = 1 ;
#		print "<!--Markers=".$#searchmarkers."-->\n" ;

		if ( ($analyse eq "summary") || ($analyse eq "ALLTIME") || ($analyse eq "month") || ($analyse eq "year") || ($analyse eq "words") || ($analyse eq "phrases") || ($analyse eq "subdivisions") || ($analyse eq "clients") || ($analyse eq "zeroes") ) {
#			print "<!--About to read in figures-->\n" ;
			&readinfigures ;
		}
		if ( ($dayfile) || ($analyse eq "summary") || ($analyse eq "ALLTIME") || ($analyse eq "month" && $monthIN eq $thismonthW && $yearIN == $thisyear) || ($analyse eq "year" && $thisyear == $yearIN ) || ($analyse eq "words") || ($analyse eq "phrases") || ($analyse eq "subdivisions") || ($analyse eq "clients") || ($analyse eq "zeroes") ) {
			&gettime('start Cat.ing in data');
			&catInData ;
			&gettime('finish Cat.ing in data');
		}

		if ($goodcount > 0 ) {
			$avetime = int(($goodtime / $goodcount)*1000)/1000 ;
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
#				print "<!---$nextdayY $nextdayM $nextdayD-->\n" ;
			}
			$prevdate = timelocal(0, 0, 0, $dayIN, ($monthNO{$monthIN}-1), ($yearIN-1900)) - (24*60*60) ;
			@time = localtime($prevdate);
			$prevdayY     = ($time[5]+1900) ;
			$prevdayM     = ${'month'.($time[4]+1)} ;
			$prevdayD     = ($time[3]) ;
#			print "<!---$prevdayY $prevdayM $prevdayD-->\n" ;
		}
		
		($EVALUATE_DIVISIONS_DAILY,$scalemax) = &getscale($maxdaily) ;
		$EVALUATE_SCALES_DAILY = &$sub_output($SCALES) ;
		$yy = 0 ;
		for ($ii = 0 ; $ii <= 47 ; $ii++) {
			${'dailyheight'.$ii} = int (    ($GRAPHHEIGHT * ${'dailysplit'.$ii}) / $scalemax   ) ;
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

#		zero list
		if ($analyse eq "zeroes") {
			$HARDlist = "zeroeslist" ;
			$ii = 0 ; 
			$numberpercolumn = 1 + int($clientcount / 4) ;
 			if ($numberpercolumn < 5 ) { $numberpercolumn = 50 ; }
			if ($oneline) { $numberpercolumn = 100000 ; }
			foreach $zerohit (sort { $zerohits{$b} <=> $zerohits{$a} } keys %zerohits) {
				if ( ($ii >= $begin) && ($ii < ($begin + 1000) )) {
					$jj = 1 + int (($ii - $begin)/$numberpercolumn) ;
					#print "<!--Setting Zero result: ~~|".$zerohit."|~~ ".$zerohits{$zerohit}."-->\n" ;
					${'zeroeslist'.$jj}{$zerohit} = $zerohits{$zerohit} ;
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
	if ($Xtype ne 'emailer') {
		&gettime('Start of HTML processing');
		# print $RSERROR ;
		&$sub_write_output ;
	} else {
		# Ready to send mail then print acknowledgement
		$errorpageCount = &errorpages ;
		$emaileroutput = &$sub_output($TEMPLATE) ;

		my(@res) = &getDB("emailers","email","id=".$Xid) ;
		$recipient = $res[0] ;
		#if ($recipient ne '') {
		$emailId=int(1000000*rand()) ;
		&sendmailHTML($recipient,"Shell Monthly Newsletter for '".($focus||"corporate")."' (".$lastmonthW." ".$lastmonthY.") [id=".$emailId."]","Shell Newsletter Server<searchadmin\@magus.co.uk>",$emaileroutput."<!--id=".$emailId."-->") ;
		$TEMPLATE = $EMAILERTEMPLATE."<!--id=".$emailId."-->" ;
		&$sub_write_output ;
	}
	print "\n\n\n<!--This process took ".$timeval{'postoutput'}." seconds to complete-->\n\n" if !$NOSTAMP;

	open(ANALYSISLOGGING,">>/RSCentral/Logs/log_SearchAnalysis");
	$datenow =`date`;
	chop $datenow;
	print ANALYSISLOGGING $hostname."\t".$username."\t".$datestamp."\t".$scriptname."\t".$analyse."\t".$timeval{'postoutput'}."\t".($buffer || $ENV{'QUERY_STRING'})."\n" ;
	close(ANALYSISLOGGING);

}
#  +---------------------------------------------+
#  |        E N D   O F   A N A L Y S I S        |  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  +---------------------------------------------+

sub readinfigures {
	# let's find out which set of files we need to cat in...
	
	if ( !$corpoOnly && ($permissions{$username} ne "all" || $focus) && $permissionSplit != 1 ) {
		$catmonthdir  = "cat ".$monthdir."/subdivdata/".($focus || $permissions{$username}) ;
		$catmonthdir2 = "" ;
	} elsif ($permissionSplit == 1) {
		$catmonthdir  = "ls -1 ".$monthdir."/subdivdata/*" ;
		$catmonthdir2 = " | /usr/xpg4/bin/grep -E \"".$subdivCode{$username}."\" | xargs cat " ;
	} else {
		$catmonthdir = "cat ".$monthdir ;
		$catmonthdir2 = "" ;
	}

	# read general data
	$systemcommand = $catmonthdir."/generaldata".$catmonthdir2 ;
	$DEBUG .= "<!-- SystemCommandGeneralData: $systemcommand -->\n" if $DEBUGlevel >= 3;
	open(LIST, "$systemcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		chomp ;
		@line = split(/\t/,$_) ;
		if ($line[0] !~ /max/) {
			${$line[0]} = ${$line[0]} + $line[1] ;
#			print "<!--Adding $line[1] to \$$line[0]-->\n" ;
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
	$systemcommand = $catmonthdir."/wordlist".$catmonthdir2 ;
	$DEBUG .= "<!-- SystemCommandWordList: $systemcommand -->\n" if $DEBUGlevel >= 3;
	open(LIST, "$systemcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		if ( /^\s*?$/ ) { next }
		$kk++ ; 	chomp ;
		@line = split(/\t/,$_) ;
		if (!$topwords{$line[0]}) {$wordcount++;}
		$topwords{$line[0]} = $topwords{$line[0]} + $line[1] ;
	}
	close(LIST);

	# read phrase list
	$systemcommand = $catmonthdir."/phraselist".$catmonthdir2 ;
	$DEBUG .= "<!-- SystemCommandPhraseList: $systemcommand -->\n" if $DEBUGlevel >= 3;
	open(LIST, "$systemcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		if ( /^\s*?$/ ) { next }
		$kk++ ; 	chomp ;
		@line = split(/\t/,$_) ;
		if (!$topphrases{$line[0]}) {$phrasecount++;}
		$topphrases{$line[0]} = $topphrases{$line[0]} + $line[1] ;
	}
	close(LIST);

	# read client list
	$systemcommand = $catmonthdir."/clients".$catmonthdir2 ;
	$DEBUG .= "<!-- SystemCommandClients: $systemcommand -->\n" if $DEBUGlevel >= 3;
	open(LIST, "$systemcommand | ") || print "Cannot execute" ;
	while (<LIST>) {
		chomp ;
		@line = split(/\t/,$_) ;
		if (!$clients{$line[0]}) {
			$clientcount++ ;
		}
		if ($line[0]) { $clients{$line[0]} = $clients{$line[0]} + $line[1] ; }
	}
	close(LIST);

	# read zerohit list
	%zerohits = "" ;
	$systemcommand = $catmonthdir."/zerohitlist".$catmonthdir2 ;
	$DEBUG .= "<!-- SystemCommandZeroHitList: $systemcommand -->\n" if $DEBUGlevel >= 3;
	open(LIST, "$systemcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		$kk++ ; 	chomp ;
		@line = split(/\t/,$_) ;
		if (!$zerohits{$line[0]}) {$wordcount++;}
		$zerohits{$line[0]} = $zerohits{$line[0]} + $line[1] ;
	}
	close(LIST);

	# read subdivision list
	if ($permissions{$username} eq "all" && !$focus) {
		$systemcommand = "cat $monthdir/subdivisions" ;
	} elsif ($permissionSplit ==1) {
		$systemcommand = "/usr/xpg4/bin/grep -E \"".$subdivCode{$username}."\" $monthdir/subdivisions"
	} else {
		$systemcommand = "grep '".($focus || $permissions{$username})."' $monthdir/subdivisions" ;
	}
	$DEBUG .= "<!-- SystemCommandSubdivs: $systemcommand -->\n" if $DEBUGlevel >= 3;
	open(LIST, "$systemcommand | ") || print "Cannot execute" ;
	$kk = 0 ;
	while (<LIST>) {
		$kk++ ; 	chomp ;
		if ( /\:/ ) {
			($line[0],$line[1]) = /:([^\:\s]*)\s+([\d]*)/ ;
		} else {
			@line = split(/\t/,$_) ;
#			print "<!--HERE subdiv grep = ".$line[0]."-->\n" ;
		}
		if ($line[0] && !$invalidSubdiv{$line[0]}) {
			if (!$subdivsearches{$line[0]}) {
				$subdivisioncount++ ;
			}
			$subdivsearches{$line[0]} = $subdivsearches{$line[0]} + $line[1] ;
		}
	}
	close(LIST);

	# read intraday list
	$systemcommand = $catmonthdir."/intraday".$catmonthdir2 ;
	$DEBUG .= "<!-- SystemCommandIntraday: $systemcommand -->\n" if $DEBUGlevel >= 3;
	open(LIST, "$systemcommand | ") || print "Cannot execute" ;
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

	# read time splits
	$systemcommand = $catmonthdir."/timesplits".$catmonthdir2 ;
	$DEBUG .= "<!-- SystemCommandTimeSplits: $systemcommand -->\n" if $DEBUGlevel >= 3;
	open(LIST, "$systemcommand | ") || print "Cannot execute" ;
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
	$DEBUG .= "<!-- Cat'ing in Data from ".$dayfile." -->\n" if $DEBUGlevel >= 2;
	
	my($year,$month,$day,$subscript) = @_ ;
	my($ii) ;
	if ($dayfile || $compareType eq "days") {
		if ($dayfile) {
			$systemcommand = "cat $dayfile" ;
			$subscript = "" ;
		} else {
			if ($day == $thisday && $month == $thismonth  && $year == $thisyear ) {
				$systemcommand = "cat $logtoday" ;
			} else {
				$systemcommand = "cat ".$logroot."/".$year."/".$month."/".$year."_".$month."_".$day.".log";
			}
		}
		if ($catDates) {
			$systemcommand = "cat $catDates" ;
		}
		$DEBUG .= "<!-- SystemCommandCatRawData: $systemcommand -->\n" if $DEBUGlevel >= 3;
		open(LIST, "$systemcommand | ") || print "Cannot execute" ;
		while (<LIST>) {
			chomp ;
			@line = split(/\t/,$_) ;
			# $DEBUG .= "<!-- Line IP=---|".$line[0]."|---  MAGUSRANGE=---|".$MAGUSRANGE."|--- -->\n" ;
			if ( ( grep($line[0] eq $_,@excludemach) ) || ( $line[0] =~ /^193\.131\.98/i )  ) {
				next
			}

			$_ = $line[2] ;
			my($company) = /\/export\/([^\/]*)\//i ; $company =~ tr/[A-Z]/[a-z]/ ;
			if (!$clients{$company}) {
				$clientcount++ ;
			}
			$clients{$company}++ ;
			
			if ( $servername =~ /ermie/ ) {
				$_ = $line[2] ;
				($line[3]) = /\/export\/demo\/cgi-bin\/([^\/]*)\//i ; $line[3] =~ tr/[A-Z]/[a-z]/ ;
			}
		
			if ($invalidSubdiv{$line[3]}) {
				next ;
			}
			if (  ($permissionSplit == 1 && !grep($line[3] eq $_,@focusList)) ||
			      ($permissionSplit == 2 && $focus ne $line[3]) 
			   ) {
				next
			}
			if ($permissionSplit < 0.5) {
				if ( ( $permissions{$username} ne "all" && $line[3] ne $permissions{$username} )
						||
					 ( length($focus)>0.5 && $line[3] ne $focus )		) {
					next
				}
			}
			
			$allSubDivs{$line[3]} = $line[3] ;
			$kk++ ;

			$line[11] =~ tr/[A-Z]/[a-z]/ ;
			if (!$line[11] || $line[11] !~ /[a-zA-Z][0-9]/i ) {
				$line[11] = "N/A" ;
			}
			$rsboxes{$line[11]}++ ;
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
						if ($jj > 21) {
							$DEBUG .= "<!--Slow: $company: ".$line[10]."s with query ".$line[4]."-->\n" if $DEBUG>=3;
						}
						${'timesplit'.$jj}++ ;
						if (${'timesplit'.$jj} > $maxtimesplit) { $maxtimesplit = ${'timesplit'.$jj} ; }
						break ;
					}
				}
			}

			if (!$IPs{$line[0]}) {
				$distinctIPs++ ;
			}
			$IPs{$line[0]}++ ;
						
			if ($line[6] eq "similarpages") {
				$simpages++ ;
				$simpage{$line[4]}++ ;
			} else {
				@wordgiven = "" ;
				$line[4] =~ tr/[A-Z]/[a-z]/ ;
				# | no longer needed - both in stoplist                |
				# | $line[4] =~ s/\s((and)|(or))\s/$blank/eigs ;       |
				$line[4] =~ s/^\s(.*)$/$1/i ;
				$line[4] =~ s/^(.*)\s$/$1/i ;
				if ($line[4] =~ /\~/ ) {
					$line[4] =~ s/^(.*?)\~.*$/$1/i ;
				}

				if ( ($line[5]*1) < 0.5) {
					${'zeroes'.$subscript}++ ;
					$zerohits{$line[4]}++ ;
				}
				if ( ( $line[4] =~ /\s|\|/i ) || !$line[4] || ( $line[4] eq "" ) ) {
					@wordgiven = split(/[\s|\|]/,$line[4]) ;
					for ($ii = 0 ; $ii <= $#wordgiven ; $ii++) {
						while ($wordgiven[$ii] =~ /([\"\[\]\{\}\|\(\)])|(\^\S*)/i ) {
							$wordgiven[$ii] =~ s/([\"\[\]\{\}\|\(\)])|(\^\S*)/$blank/egs ;
						}
						while ($wordgiven[$ii] =~ /\s\s/i ) {
							$wordgiven[$ii] =~ s/\s\s/$blank/ ;
						}
						if (length($wordgiven[$ii])<0.5) { next }
						if (!$topwords{$wordgiven[$ii]}) {$wordcount++;}
						$topwords{$wordgiven[$ii]}++ if !grep ($wordgiven[$ii] eq $_,@stoplist) ;
					}
					if (!$topphrases{$line[4]}) {$phrasecount++;}
					$topphrases{$line[4]}++ ;
				} else {
					$line[4] =~ s/\"(\S*)\"/$1/egs ;
					$topwords{$line[4]}++ if !grep ($line[4] eq $_,@stoplist) ;
				}
				
			}

			if ($line[3] && !$invalidSubdiv{$line[3]}) {
				if (!$subdivsearches{$line[3]}) {
					$subdivisioncount++ ;
				}
				$subdivsearches{$line[3]}++ ;
			}

			$_ = $line[1] ;
			($searchhour,$searchminute) = /\s([\d]*):([\d]*):/i ;
			if ($searchminute >= 30 ) { $searchminute = 1 ; } else { $searchminute = 0;}
			${'dailysplit'.($searchhour*2+$searchminute)}++ ;
			if (  ${'dailysplit'.($searchhour*2+$searchminute)} > $maxdaily) {
				$maxdaily = ${'dailysplit'.($searchhour*2+$searchminute)} ;
			}
			${'perhour'.$subscript}{$searchhour}++ ;
			
#			if ($line[19]) {
##				print "<!--Found a line with: ".$line[19]." bytes-->\n" ;
#				$bandwidth = $bandwidth + $line[19] ;
#			}
		}
		close(LIST);

		$counttoday = $kk ;
		$focusSearches = ($focusSearches + $kk)*1 ;
		
		if ( ($analyse ne "month") && ($analyse ne "SNAPSHOT") && ($analyse ne "summary") ) {
			$count0 = $count0 + $counttoday ;
		}
		
		foreach $company (keys %goodcount) {
			if ($goodcount{$company} > 0) {
				${'averagespeed'.$company} = (int(($goodtime{$company} / $goodcount{$company})*1000))/1000 ;
			}
		}
	
	}
}

sub getmonthlydata {
	if ($analyse eq "year") {
		if ($permissions{$username} eq "all" && !$focus) {
			$systemcommand = "grep 'total' $logroot/".$yearIN."/*/count" ;
		} elsif ($permissionSplit == 1) {
			$systemcommand = "/usr/xpg4/bin/grep -E \"".$subdivCode{$username}."\" $logroot/".$yearIN."/*/subdivisions" ;
		} else {
			$systemcommand = "grep '".($focus || $permissions{$username})."' $logroot/".$yearIN."/*/subdivisions" ;
		}
	} else {
		if ($permissions{$username} eq "all" && !$focus) {
			$systemcommand = "grep 'total' $logroot/*/*/count" ;
		} elsif ($permissionSplit == 1) {
			$systemcommand = "/usr/xpg4/bin/grep -E \"".$subdivCode{$username}."\" $logroot/*/*/subdivisions" ;
		} else {
			$systemcommand = "grep '".($focus || $permissions{$username})."' $logroot/*/*/subdivisions | grep 'subdivisions:".($focus || $permissions{$username})."\t'" ;
		}
	}
	$DEBUG .= "<!-- getmonthlydataSystemCommand: ".$systemcommand."-->\n" if $DEBUGlevel>=3 ;
	open(LIST, "$systemcommand | ") || print "Cannot execute" ;
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
		if ($monthM < 10 ){ $zero = "0" } else {$zero = ""}

		$monthtotal{$yearM.'-'.$zero.$monthM} = $monthtotal{$yearM.'-'.$zero.$monthM} + $totalM ;
		if ($monthtotal{$yearM.'-'.$zero.$monthM} > $maxmonthly) {
			$maxmonthly = $monthtotal{$yearM.'-'.$zero.$monthM} ; $maxmonthlydate = ${'month'.$monthM}."/".$yearM ;
		}
		$grandtotal = $grandtotal + $monthtotal{$yearM.'-'.$zero.$monthM} ;
		if ($yearM == $thisyear) {
			$totalthisyear = $totalthisyear + $monthtotal{$yearM.'-'.$zero.$monthM} ;
		} elsif ($yearM == ($thisyear-1)) {
			$totallastyear = $totallastyear + $monthtotal{$yearM.'-'.$zero.$monthM} ;
		}
	}

	# Whatever happens, add $count0 to "thisyear/thismonth"
#	if ( ( ( ($analyse eq "year") || ($analyse eq "month") || ($analyse eq "SNAPSHOT" ) ) && ($yearIN == $thisyear) && ($monthIN == $thismonth) ) || ($analyse eq "ALLTIME") || ( $analyse eq "summary" ) ) {
	if ( ($analyse eq "ALLTIME") || ( $analyse eq "summary" ) || ($analyse eq "year" && $yearIN == $thisyear ) || ($analyse eq "month" && $yearIN == $thisyear && $monthIN == $thismonth) ) {
		if ($thismonth < 10 ){ $zero = "0" } else {$zero = ""} ;
		$totalM = $totalM + $count0 ;
		$monthtotal{$thisyear.'-'.$zero.$thismonth} = $monthtotal{$thisyear.'-'.$zero.$thismonth} + $count0 ;
		if ($monthtotal{$thisyear.'-'.$zero.$thismonth} > $maxmonthly) {
			$maxmonthly = $monthtotal{$thisyear.'-'.$zero.$thismonth} ; $maxmonthlydate = ${'month'.$thismonth}."/".$thisyear ;
		}
		$grandtotal = $grandtotal + $count0 ;
		$totalthisyear = $totalthisyear + $count0 ;
	}
	
	
	$mmm= 0 ; $lastmonth = 999; $mmmyearspan = 0 ; $lastyear = 1933 ;
	($EVALUATE_DIVISIONS_MONTH,$scalemonthmax) = &getscale($maxmonthly) ;

	if ($DEBUGlevel>=7) {
		foreach $monthloop (sort keys %monthtotal) {
			$DEBUG .= "<!--Monthloop: $monthloop=$monthtotal{$monthloop}-->\n" ;
		}
	}
	foreach $monthloop (sort keys %monthtotal) {
		$mmm++ ;
		$_ = $monthloop ; ($yearM,$monthM) = /^([\d]*)\-([\d]*)$/i ;
		if ( ($analyse eq "year" || $analyse eq "ALLTIME" ) ) {
			$count0 = $count0 + $monthtotal{$monthloop} ;
		}
		$DEBUG .= "<!--".$yearM."=".$thisyear." and ".$monthM."=".$thismonth." and ".$analyse."=year-->" if $DEBUGlevel >= 7;

		${'monthM'.$mmm} = $monthM * 1 ;
		${'yearM'.$mmm} = $yearM * 1 ;
		$DEBUG .= "<!--Setting yearM$mmm to ".${'yearM'.$mmm}."-->\n" if $DEBUGlevel >= 7;
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

sub getdaycount {
	my($year,$month,$day) = @_ ;
	my($count) ;
	my($date) = $year."_".$month."_".$day;
	if ($year == $thisyear && $month == $thismonth && $day == $thisday) {

		if ($permissions{$username} eq "all" && !$focus && $permissionSplit != 1) {
			$systemcommand = "wc -l $logtoday" ;
		} elsif ($permissionSplit == 1) {
			$systemcommand = "/usr/xpg4/bin/grep -E \"".$subdivCode{$username}."\" $logtoday | wc -l" ;
		} else {
			$systemcommand = "grep \"cgi\t".($focus || $permissions{$username})."\t\" $logtoday | wc -l" ;
		}
		open(LIST, "$systemcommand | ") || print "Cannot execute" ;
		$_ = <LIST> ;
		chomp ;
		close(LIST);
		$count = ($_ * 1) ;
	} else {
		if ($permissions{$username} eq "all" && !$focus) {
			$systemcommand = "grep '$date.log' $logroot/$year/$month/count" ;
			open(LIST, "$systemcommand | ") || print "Cannot execute" ;
			$returnedVal = $_ = <LIST> ; chomp ;
			close(LIST);
			/^\s*([\d]*)\s*.*?$/ ;
			$count = $1 * 1 ;
		} else {
			if ($permissionSplit ==1) {
				$systemcommand = "ls -1 $logroot/$year/$month/subdivdata/*/count | /usr/xpg4/bin/grep -E \"".$subdivCode{$username}."\" | xargs cat | grep $date.log" ;
			} else {
				$systemcommand = "grep '$date.log' $logroot/$year/$month/subdivdata/".($focus || $permissions{$username})."/count" ;
			}
			open(LIST, "$systemcommand | ") || print "Cannot execute" ;
			while(<LIST>) {
				chomp ;
				if ( $_ =~ /count\:/ ) { 
					($thiscT) = /^.*?count\:\s*(\d*).*?$/ ;
				} elsif ( $_ =~ /\s*([\d]*).*?/ ) {
					$thiscT = $1 ;
				} else {
					$thiscT = 0 ;
				}
				$count = $count + $thiscT
			}
			close(LIST) ;
			$count = $count * 1 ;
		}
	}
	$DEBUG .= "<!-- getdaycountSystemCommand: $systemcommand |---|count=".$count."|-- -->\n\n" if $DEBUGlevel>=4 ;
	return $count ;
}

sub errorpages {
	#require('/RSCentral/SearchScripts/RSlibraryConfig.pl') ;
	#require('/RSCentral/SearchScripts/RSlibraryVarious.pl') ;
	require('/RSCentral/SearchScripts/RSlibrarySearchComponents.pl') ;
	use sigtrap;
	use Socket;
	my($includeOtherFiles) = "true";
	my($query) = "errorpage:ErrorPage urlmatch(http://www.shell.com/home/Framework?siteId=".$focus.")";
	#&$sub_load_titles ;
	$siteName = $titles{'http://www.shell.com/home/Framework?siteId='.$focus} ;
	&$sub_do_search(0,1000,$query);
	$score = 0 ;
	foreach $url (sort keys %dtitle) {
		$score++ ;
		${'title'.$score} = $dtitle{$url} ;
		${'url'.$score} = $url ;
	}		
	return $score ;
	print "score=".$score."\n\n" ;
}

sub getDB {
	my(@in) = @_ ;
	my($dbh_main) = DBI   -> connect($DB,$DBusername,$DBpassword) ;
	$SQL = "SELECT ".$in[1]." FROM ".$in[0]." WHERE ".$in[2] ;
	#print $SQL."\n" ;
	my($sth) = $dbh_main  -> prepare($SQL)  ;
	$sth                  -> execute || print $SQL;
	my(@data) = $sth      -> fetchrow_array();
	$sth                  -> finish();
	$dbh_main             -> disconnect();
	return @data ;
}
