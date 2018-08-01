#!/bin/perl

use HTTP::Request::Common qw(GET)  ;
use LWP::UserAgent                 ;
use DBI        ;

if ( -e "/RSCentral/Pearl-Web/config.pl" ) {
	require('/RSCentral/Pearl-Web/config.pl') 

} elsif (-e "/import/share/admin/lib/Pearl-Web/config.pl" ) {
	require('/import/share/admin/lib/Pearl-Web/config.pl') ;

} elsif (-e "/import/admin/lib/Pearl-Web/config.pl" ) {
	require('/import/admin/lib/Pearl-Web/config.pl') ;

} elsif (-e "/admin/lib/Pearl-Web/config.pl" ) {
	require('/admin/lib/Pearl-Web/config.pl') ;

} elsif (-e "/admin/i1/lib/Pearl-Web/config.pl" ) {
	require('/admin/i1/lib/Pearl-Web/config.pl') ;

} else {
	print "Stopping - no Pearl-Web configuration available\n" ;
}

&initialise_pw;

sub read_input {
	$DEBUG .= "\n<!-- About to read input parameters, if available -->\n" ;
	if ($ENV{'REQUEST_METHOD'} eq 'POST'){
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
		# Check to see if it is a multi-encoded form post
		# This is typically used if you are uploading a file from a browser
		if ($buffer =~ /Content-Disposition/i ) {
			# Content is in
			@pairs = split(/-----------------------------/,$buffer) ;
			foreach $pair (@pairs) {
				$paramname = $value = "" ;
				$_ = $pair ;
				($paramname,$value) = /^[\d\D]*\sname="([^"]*)"[\d\D]*?\s\s([\d\D]*)\s{1,}$/ ;
				if (!$paramname) { next ; }
				$FORM{$paramname}= $value;
				${'X'.$paramname}= $value;
				$DEBUG .= "<!--\$X".$paramname."=~~~|".$value."|~~~ -->\n" ;
			}
		} else {
			#Split the Name-Value Pairs on '&'
			@pairs = split(/&/, $buffer);
			foreach $pair (@pairs) {
				($paramname, $value) = split(/=/ ,$pair);
				if ($paramname eq "map.x") { $paramname = "mapx" }
				if ($paramname eq "map.y") { $paramname = "mapy" }
				$value =~ tr/+/ /;
				$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
				$FORM{$paramname}= $value;
				$POSTED{$paramname}= $value;
				${'X'.$paramname} = $value ;
				$DEBUG .= "<!--\$X".$paramname."=~~~|".$value."|~~~ -->\n" ;
			}
		}
	} else {
		if ( $ENV{'QUERY_STRING'} ) {
			@pairs = split(/\~/,$ENV{'QUERY_STRING'});
			foreach $pair (@pairs) {
				$_ = $pair ;
				($name, $value) = /^([^=]*)=(.*)$/i ; #split(/=/ ,$pair);
				$value =~ tr/+/ /;
				$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
				$FORM{$name}= $value ;
				${'X'.$name} = $value ;
				$DEBUG .= "<!--\$X".$name."=~~~|".$value."|~~~ -->\n" ;
			}
		} else {
			# Check whether the scriptname contains usable parameters...
			if ( $ENV{'SCRIPT_NAME'} =~ /^\/$RunName\/([^\/]*)(\/.*)$/ ) {
				$Xaction = $FORM{'action'} = $1 ;
				$DEBUG .= "<!--\$Xaction=~~~|".$Xaction."|~~~ -->\n" ;
				$scriptLine = $2 ;
				my($xx) = 0;
				while ($scriptLine =~ /^\/([^\/]*)(\/.*?)$/  ) {
					$xx++ ;
					$scriptLine = $2;
					${'XPARAM'.$xx} = $FORM{'PARAM'.$xx} = $1 ;
					$FORM{'PARAM'.$xx}= $1 ;
					$DEBUG .= "<!--\$XPARAM".$xx."=~~~|".$value."|~~~ -->\n" ;
				}
			}
		}
	}
	$DEBUG .= "\n" ;
}

sub foundURL {
	my($URL) = $_[0] ;
#	print "I have found this URL".$URL."<br>\n";
}

sub fetchURL {
	my(@URL) = @_ ;
	my($getThisPage) = $URL[0] ;
	my($agent)     = ( $URL[1] || 'Magus Bot 1.0') ;
	my($referrer)  = ( $URL[2] || '') ;
	my($loc)       = ( $URL[3] || '') ;
	my($realm)     = ( $URL[4] || '') ;
	my($username)  = ( $URL[5] || '') ;
	my($password)  = ( $URL[6] || '') ;
	my($again)     = ( $URL[7] || '') ;
	my($getSpider) = new LWP::UserAgent;
	$getSpider -> agent($agent); 
	#print "URLDATA:~~~~ @URL ~~~~\n" ;
#	$getSpider -> referer($referrer); 
	if ($loc && $realm && $username && $password) {
		$getSpider -> credentials($loc,$realm,$username,$password);
	}
	my($req) = GET $getThisPage  ;
	my($response) = $getSpider -> request($req) -> as_string;
	
	# Check to see if it worked, else extract the location and realm from the header and repeat
	$_ = $response ;
	my($servercode) = /HTTP\/[\d]\.[\d]\s+([\d]*)/ ;
	if ($servercode != 200 && !$again) {
		$_ = $response ;
		($realm) = /Basic\s+realm=\"([^\"]*)\"/i ;
		($loc) = /Client\-Peer:\s+([\S]*)/i ;
		$_ = $URL[0] ;
		($loc) = /http\:\/\/([^\/]*)/ ; $loc = $loc.":80" ;
		#now retry!
		$response=&fetchURL($URL[0],$URL[1],$URL[2],$loc,$realm,$URL[5],$URL[6],1) ;
		# If we still can't get in... send the 401 back to the requester
	}
	return $response ;
}

sub getURL {
	my($response)=&fetchURL(@_) ;
	$_ = $response ;
	my($code) = /^[\d\D]*?\n\n([\d\D]*)$/i ;
	return $code ;
}

sub getURLresponse {
	my($response)=&fetchURL(@_) ;
	$_ = $response ;
	my($servercode) = /HTTP\/[\d]\.[\d]\s+([\d]*)/ ;
	my($header,$code) = /^([\d\D]*?)\n\n([\d\D]*)$/i ;
	return ($code,$header,$servercode) ;
}

sub addURL {
	my($newURL) = $_[0]  ;  # THE prospective URL
	my($pageURL) = $_[1] ;  # The URL of the current page
	#	print "Processing new URL... ".$newURL."\n" ;
	my($addURL) = "" ;

	if ($newURL =~ /\#/ ) {
		$newURL =~ s/^(.*)\#.*$/$1/eigs ;
	}
	if (!$newURL) { return }
	
	$_ = $pageURL ;
	my($domain)  = /(http:\/\/[^\/]*)\/[\d\D]*$/i ;
	my($pageDir) = /^([^\?]*)\??[\d\D]*?$/i ;
	$_ = $pageDir ;
	($pageDir) = /^(.*\/)[\d\D]*?$/i ;
	#	print "setting pageDir to:".$pageDir."  prospect=".$newURL."\n" ;
	$_ = $pageDir ;
	($pageDir)     = /^([\d\D]*\/)[\d\D]*?$/i ;
	#	print "setting pageDir to:".$pageDir."  prospect=".$newURL."\n" ;
	if ($newURL =~ /^(http:\/\/[^\/]*\/[\d\D]*?)$/i ) {
		$addURL = $newURL ;
	} elsif ($newURL =~ /^\/.*$/ ) {
		$addURL = $domain.$newURL ;
	#		print "Adding:".$addURL."\n" ;
	} else {
		$addURL = &collapseURL($pageDir.$newURL) ;
	#		print "Adding:".$addURL."\n" ;
	}
	$addURL = &checkAddURL($addURL)  ;
	# CheckURL is not in the list...!
	for ($i=1;$i<=($nextURL-1);$i++) {
		if ($URL[$i] eq $addURL) {
	#			print LOG "    SEEN URL: ".$addURL."\n" ;
	#			print "    SEEN URL: ".$addURL."\n" ;
			$addURL = "" ;
		}
	}
	if ($addURL) {
	#		print LOG "    FOUND URL: ".$addURL."\n" ;
	#		print "    FOUND URL: ".$addURL."\n" ;
		$URL[$nextURL] = $addURL ;
		$nextURL++ ;
	}
}

sub collapseURL {
	my($collapse) = $_[0] ;
	return $collapse ;
}

sub deHTML {
	my($xx) = $_[0] ;

	$xx =~ s/\&Aacute\;/A/g;
	$xx =~ s/\&aacute\;/a/g;
	$xx =~ s/\&acirc\;/a/g;
	$xx =~ s/\&Acirc\;/A/g;
	$xx =~ s/\&aelig\;/ae/g;
	$xx =~ s/\&AElig\;/AE/g;
	$xx =~ s/\&agrave\;/a/g;
	$xx =~ s/\&Agrave\;/A/g;
	$xx =~ s/\&Aring\;/A/g;
	$xx =~ s/\&aring\;/a/g;
	$xx =~ s/\&Atilde\;/A/g;
	$xx =~ s/\&atilde\;/a/g;
	$xx =~ s/\&auml\;/a/g;
	$xx =~ s/\&Auml\;/A/g;
	$xx =~ s/\&Ccedil\;/C/g;
	$xx =~ s/\&ccedil\;/c/g;
	$xx =~ s/\&Eacute\;/E/g;
	$xx =~ s/\&eacute\;/e/g;
	$xx =~ s/\&ecirc\;/e/g;
	$xx =~ s/\&Ecirc\;/E/g;
	$xx =~ s/\&egrave\;/e/g;
	$xx =~ s/\&Egrave\;/E/g;
	$xx =~ s/\&Euml\;/E/g;
	$xx =~ s/\&euml\;/e/g;
	$xx =~ s/\&Iacute\;/I/g;
	$xx =~ s/\&iacute\;/i/g;
	$xx =~ s/\&icirc\;/i/g;
	$xx =~ s/\&Icirc\;/I/g;
	$xx =~ s/\&igrave\;/i/g;
	$xx =~ s/\&Igrave\;/I/g;
	$xx =~ s/\&Iuml\;/I/g;
	$xx =~ s/\&iuml\;/i/g;
	$xx =~ s/\&Ntilde\;/N/g;
	$xx =~ s/\&ntilde\;/n/g;
	$xx =~ s/\&Oacute\;/O/g;
	$xx =~ s/\&oacute\;/o/g;
	$xx =~ s/\&ocirc\;/o/g;
	$xx =~ s/\&Ocirc\;/O/g;
	$xx =~ s/\&Ocirc\;/O/g;
	$xx =~ s/\&ograve\;/o/g;
	$xx =~ s/\&Ograve\;/O/g;
	$xx =~ s/\&oslash\;/o/g;
	$xx =~ s/\&Oslash\;/O/g;
	$xx =~ s/\&Otilde\;/O/g;
	$xx =~ s/\&otilde\;/o/g;
	$xx =~ s/\&ouml\;/o/g;
	$xx =~ s/\&Ouml\;/O/g;
	$xx =~ s/\&szlig\;/sz/g;
	$xx =~ s/\&uacute\;/u/g;
	$xx =~ s/\&Uacute\;/U/g;
	$xx =~ s/\&Ucirc\;/U/g;
	$xx =~ s/\&ucirc\;/u/g;
	$xx =~ s/\&Ugrave\;/U/g;
	$xx =~ s/\&ugrave\;/u/g;
	$xx =~ s/\&uuml\;/u/g;
	$xx =~ s/\&Uuml\;/U/g;
	$xx =~ s/\&Yacute\;/Y/g;
	$xx =~ s/\&yacute\;/y/g;
	$xx =~ s/\&yuml\;/y/g;

	$xx =~ s/<[sS][tT][yY][lL][eE]>[\d\D]*?<\/[sT][tT][yY][lL][eE]>/' '/eigs ;
	$xx =~ s/<[sS][cC][rR][iI][pP][tT][^>]*?>[\d\D]*?<\/[sS][cC][rR][iI][pP][tT]>/' '/eigs ;
	$xx =~ s/\&[#\w]*\;/' '/eigs ;
	$xx =~ s/<[\d\D]*?>/' '/eigs ;
	$xx =~ s/[\"\.\,_\(\)\[\]\,]/' '/eigs ;
	while ($xx =~ /\s\s/) {
		$xx =~ s/\s\s/' '/eigs ;
	}
	return $xx ;
}

sub round {
	my($posn) = int($_[1]) || 2 ;
	$posn = 0 if $posn < 0 ;
	my($valIn) = $_[0] ;
	my($factor) = 1 ;
	my($p) = $posn ;
	while ($p--) { $factor = $factor * 10 }
#	print "Value=".$valIn."~Round=".$posn."~Factor=".$factor."~" ;
	my($xx) = int($valIn*$factor) ;
	my($rest) = ($valIn*$factor) - int($valIn*$factor) ;
#	print "~rest=".$rest."~" ;
	if ($rest >= 0.5) { $xx = int($xx + 1.000000001) }
	my($xx) = $xx/$factor ;
	if ($posn > 0) {
		if ($xx !~ /\./) {
			$factor =~ s/1// ;
			$xx = $xx.".".$factor if $posn>=1 ;
		} else {
			$_ = $xx ;
			($afterDot) = /^.*\.(.*)$/i ;
			for ($w=$posn;$w>length($afterDot);$w--) {
				$xx = $xx."0" ;
			}
		}
	}
#	print "<br>\n" ;
	return ($xx) ;
}

sub gettime {
	@finishTime = gettimeofday;                                                                                                  
	for ($finishTime[1], $startTime[1]) { $_ /= 1_000_000 }                          
	$duration = ($finishTime[0]-$startTime[0])+($finishTime[1]-$startTime[1]) ;         
	$timeval{$_[0]} = int($duration*10000)/10000;
}

sub getTime {
	@time        = localtime(time);
	$thisyear    = $time[5]+1900 ;
	$thismonth   = $time[4]+1 ;
	$thisday     = $time[3] ;
	$thishour    = $time[2] ;
	$thismin     = $time[1] ;
	$thissec     = $time[0] ;
	$timestamp   = $thisyear."/".$thismonth."/".$thisday." ".$thishour.":".$thismin.":".$thissec ;
	$securetime  = $thisday.":".$thishour.":".$thismin.":".$thissec ;
}

sub displayTime {
	@displayTime = localtime($_[0]);
	my($flag)=$_[1] ;
	my($returntime) ;
	if ($flag == 1) {
		$returntime .= $displayTime[2]."h" ;
	} else {
		if ($displayTime[1]<10) {$displayTime[1]="0".$displayTime[1]}
		$returntime = $displayTime[2].":".$displayTime[1] ;
		$returntime .= ":" if $_[1] =~ /s/ ;
		$returntime .= "0" if ($_[1] =~ /s/ && $displayTime[0]<10);
		$returntime .= $displayTime[0] if $_[1] =~ /s/ ;
	}
	return $returntime ;
}

sub displayDate {
	@displayTime = localtime($_[0]);
	@timeNow = localtime(time);
	if ($_[1] == 2) {
		$weekday = $displayTime[6] ; if ($weekday == 0) { $weekday = 7 }
		return $dayConv[($weekday)]." ".$displayTime[3]." ".$monthConv[($displayTime[4]+1)] ;
	} elsif ($_[1] == 3) {
		if ( $displayTime[3] == $timeNow[3] && $displayTime[4] == $timeNow[4] && $displayTime[5] == $timeNow[5] ) {
			return -1 ;
		}
		if ( int(($displayTime[4]+1)/2) == (($displayTime[4]+1)/2) ) {
			return 1  ;
		} else {
			return 0  ;
		}
	} elsif ($_[1] == 4) {
		my($yr)=$displayTime[5]+1900; $yr =~ s/\d\d(\d\d)/$1/eigs ;
		return $displayTime[3]."/".($displayTime[4]+1)."/".$yr ;
	} elsif ($_[1] == 5) {
		$displayTime[3] = "0".$displayTime[3] if $displayTime[3]<10 ;
		my($month) = ($displayTime[4]+1) ; $month = "0".$month if $month<10 ;
		return ($displayTime[5]+1900)."-".$month."-".$displayTime[3] ;
	} elsif ($_[1] == 6) {
		return $displayTime[3]."/".($displayTime[4]+1) ;
	} else {
		return $displayTime[3]." ".$monthConv[($displayTime[4]+1)]." ".($displayTime[5]+1900) ;
	}
}

sub makesafetext {
  my($x) = $_[0];  $LT = "&lt;" ; $GT = "&gt;" ; $QUOT = "&quot;" ;
  $x =~ s/([\n'])/'%'.tohex(ord($1))/eg;
  $x =~ s/</$LT/eigs ;
  $x =~ s/>/$GT/eigs ;
  $x =~ s/\"/$QUOT/eigs ;
  return $x;
}

sub makeinputsafetext {
  my($x) = $_[0];  $LT = "&lt;" ; $GT = "&gt;" ; $QUOT = "&quot;" ;
  $x =~ s/</$LT/eigs ;
  $x =~ s/>/$GT/eigs ;
  $x =~ s/\"/$QUOT/eigs ;
  return $x;
}

sub makeJSsafetext {
  my($x) = $_[0];
  $x =~ s/'/$blank/eg;
  return $x;
}

sub URLise {
  my($x) = $_[0];
  $x =~ s/([\s=\?'"\&])/'%'.tohex(ord($1))/eg;
  return $x;
}

sub converttohex {
  my($x) = $_[0];
  $x =~ s/([\d\D])/tohex(ord($1))/eg;
  return $x;
}

sub tohex {
  $xx = sprintf '%x',$_[0];
  if (length($xx) < 1.5) {$xx = "0".$xx ;}
  return $xx ;
}

sub unpackhex {
	$xx = $_[0] ;
	$xx =~ s/([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
	return $xx ;
}

sub unpackhexText {
	$xx = $_[0] ;
	$xx =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
	return $xx ;
}

sub capitalise {
	my($phrase) = $_[0] ;
	my($word,$Xphrase,$start,$rest) = "" ;
	$_ = $phrase ;
	foreach $wordsplit (split(/\s/,$_)) {
#		print "capitalising word ".$wordsplit."\n" ;
		$_ = $wordsplit;
		($start,$rest) = /^(.)(.*?)$/ ;
		$start =~ tr/[a-z]/[A-Z]/ ;
		$rest  =~ tr/[A-Z]/[a-z]/ ;
		if ($Xphrase) {$Xphrase .= " "}
		$Xphrase .= $start.$rest ;
	}
	return $Xphrase ;
}

sub cleanUpText {
	my($x) = $_[0] ;
	$x =~ s/&nbsp\;/$space/eigs ;
	while ($x =~ /\s\s/ ) {
		$x =~ s/\s\s/$space/eigs ;
	}
	$x =~ s/\s/$space/eigs ;
	$x =~ s/^\s+([\d\D]*?)$/$1/eigs ;
	$x =~ s/^([\d\D]*?)\s+$/$1/eigs ;
	$x = &makesafetext($x) ;
	if ($x eq " ") {$x = "" }
	return $x ;
}

sub commarise {
	my($commarise) = $_[0] ;
	$commarise =~ s/(.*?)(\d{3})?(\d{3})?(\d{3})?$/$1,$2,$3,$4/i;
	$commarise =~ s/^(,)?(,)?(,)?(.*?)(,)?(,)?(,)?$/$4/i;
	$commarise =~ s/\-\,/-/i;
	return $commarise ;
}

sub readCookie {
	my($cookieName) ;
	my($cookies) = $ENV{'HTTP_COOKIE'};
	if ($_[0]) {
		$cookieName = $_[0];
		$_ = $cookies ; ($cookieVal) = /$cookieName\s*=\s*([\w]*)/;
		${$cookieName} = $cookieVal ;
	} else {
		$cookies =~ s/([\w]*)(\s*=\s*)([^;]*)/&evalcookie($1,$2,$3)/eigs ;
	}
}

sub evalcookie {
	my(@in) = @_ ;
	${'COOKIE'.$in[0]} = $in[2] ;
	$in[0] =~ s/^\s*(.*?)\s*$/$1/i ;
	$in[1] =~ s/^\s*(.*?)\s*$/$1/i ;
	$DEBUG .= "<!--Found cookie: ".$in[0]."=".$in[2]."-->\n" ;
	return $in[0].$in[1].$in[2] ;
}

sub SQLdelete {
	if ($XPARAM1) {
		$Xtable = $FORM{'table'} = $XPARAM1 ;
	}
	if ($XPARAM2) {
		$Xwhere = $XPARAM2 || $FORM{'id'};
		if ($Xwhere !~ /=/) {
			$Xwhere = " id=".$Xwhere ;
		}
	}
	$SQL = "DELETE FROM ".$FORM{'table'}." WHERE ".$Xwhere." AND visitor=".$visitorCHECK ;
#	print "<!--".$SQL."-->" ;
#	exit ;
	$SQLcounttotal++ ;
	my $dbh_sqldel = DBI->connect($DB,$DBusername,$DBpassword)  	or return (0,"Could not create database handler - please contact us to resolve this error") ;
	my $sth_sqldel = $dbh_sqldel -> prepare($SQL) 	or return (0,"Could not create database handler - please contact us to resolve this error") ;
	$sth_sqldel -> execute        	or return (0,"Could not delete this entry: " . $sth_sqlupdate -> errstr) ;
	$sth_sqldel -> finish();
	$dbh_sqldel -> disconnect();
	return (1,"Successfully deleted this record") ;
}

sub write_output {
	&$sub_gettime('preoutput');
	$output = $TEMPLATE;
	$errorloop = 0 ;
	$output = &$sub_output($output) ;
# 	$output =~ s/\s/' '/eigs ;
#	while ($output =~ /\s\s/) {
#		$output =~ s/\s\s/' '/eigs ;
#	}
	$output =~ s/\\([\[\]])/$1/eigs ;
	&$sub_gettime('postoutput');
	
	# +------------------------+
		 print $output;      # | Main print statement to visitor
	# +------------------------+
	
	print "\n\n\n<!-- Generated with Pearl-Web (c)1999-2005 Magus Research Limited -->\n\n" if (!$NOSTAMP && !$NOCOMMENTS);
	$lengthOutput = length ($output) ;
	
	print "\n\n<!--~~~~~~~~~~~DEBUG~~~~~~~~~~~~-->\n\n".$DEBUG if $DEBUGlevel >=0.5 ;
}

sub output {
	my($output) = $_[0];
	my($ll) = 0 ;
	#$errorloop = 0 ;
	while (($output =~ /\[\[(.*?)\]\]/) && $errorloop < $maxnestlevel) {
		$errorloop++ ;
#		print "<!--Doing Loop: ".$errorloop."-->\n" ;
		$output =~ s/\[\[\\[\d\D]*?\\\]\]/""/egs ;
		
		if ( $output =~ /\[\[SQLSET\s\(([^\)]*)\)\]\]/ ) {
			$output =~ s/\[\[SQLSET\s\(([^\)]*)\)\]\]/ &setSQLserver($1) /egs;
			
		} elsif ( $output =~ /\[\[VHIF\s+\([\d\D]*?\)\]\]/ ) {
			$output = &$sub_processif($output,'VHIF') ;
			$output =~ s/\[\[VHIF([\d\D]*?)\]\]/'{{PearlWebError: Incorrect use of VHIF statement: ---|'.$1.'|---}}'/egs;

		} elsif ( $output =~ /\[\[VERYHARDEVAL\s+\((.*?)\)\]\]/i ) {
			$output =~ s/\[\[VERYHARDEVAL\s+\((.*?)\)\]\]/ eval $1 /iegs;
			$output =~ s/\[\[VERYHARDEVAL([\d\D]*?)\]\]/'{{PearlWebError: Incorrect use of VERYHARDEVAL statement: ---|'.$1.'|---}}'/egs;

		} elsif ($output =~ /\[\[VERYHARD\s+[^\s\]]*\]\]/ ) {
			$output =~ s/\[\[VERYHARD\s+([^\s\]]*)\]\]/${$1}/egs;

		} elsif ( $output =~ /\[\[LOOP[1-4]?\s+\((.*?)\)\]\]/i ) {
			$output =~ s/\[\[LOOP\s+\((.*?)\)\]\]([\d\D]*?)\[\[\/LOOP\]\]/&$sub_looparound($1,$2,'')/iegs;
			$output =~ s/\[\[LOOP1\s+\((.*?)\)\]\]([\d\D]*?)\[\[\/LOOP1\]\]/&$sub_looparound($1,$2,1)/iegs;
			$output =~ s/\[\[LOOP2\s+\((.*?)\)\]\]([\d\D]*?)\[\[\/LOOP2\]\]/&$sub_looparound($1,$2,2)/iegs;
			$output =~ s/\[\[LOOP3\s+\((.*?)\)\]\]([\d\D]*?)\[\[\/LOOP3\]\]/&$sub_looparound($1,$2,3)/iegs;
			$output =~ s/\[\[LOOP4\s+\((.*?)\)\]\]([\d\D]*?)\[\[\/LOOP4\]\]/&$sub_looparound($1,$2,4)/iegs;
			$output =~ s/\[\[(LOOP[1-4]?)\s+\((.*?)\)\]\]/'{{PearlWebError: Incorrect use of '.$1.' statement or cannot find closing tag: ---|'.$2.'|---}}'/iegs;

		} elsif ( $output =~ /\[\[HIF\s+\([\d\D]*?\)\]\]/i ) {
			$output = &$sub_processif($output,'HIF') ;
			$output =~ s/\[\[HIF\s+([\d\D]*?)\]\]/'{{PearlWebError: Incorrect use of HIF statement: ---|'.$1.'|---}}'/iegs;

		} elsif ( $output =~ /\[\[HARDEVAL\s+\((.*?)\)\]\]/i ) {
			$output =~ s/\[\[HARDEVAL\s+\((.*?)\)\]\]/ eval $1 /iegs;

		} elsif ( $output =~ /\[\[HARD\s(.*?)\]\]/i ) {
			$output =~ s/\[\[HARD\s(.*?)\]\]/${$1}/egs;

		} elsif ( $output =~ /\[\[SEARCH\s+\(([^\)]*)\)\]\]([\d\D]*?)\[\[\/SEARCH\/\]\]([\d\D]*?)\[\[\/SEARCH\]\]/i ) {
			$output =~ s/\[\[SEARCH\s+\(([^\)]*)\)\]\]([\d\D]*?)\[\[\/SEARCH\/\]\]([\d\D]*?)\[\[\/SEARCH\]\]/&$sub_searchcall($1,$2,$3)/iegs;

		} elsif ( $output =~ /\[\[SQLMOD([\d\D]*?)\]\]/i ) {
			$output =~ s/\[\[SQLMOD\s+~([^~]*)~([^~]*)~([^~\]]*?)~?\]\]([\d\D]*?)\[\[\/SQLMOD\/\]\]([\d\D]*?)\[\[\/SQLMOD\]\]/ &sqlcall($1,$2,$3,$4,$5,1) /iegs;
			$output =~ s/\[\[SQLMOD([\d\D]*?)\]\]/'{{PearlWebError: Incorrect use of SQLMOD function: '.$1.'}}'/iegs;	

		} elsif ( $output =~ /\[\[SQL3\s+~([^~]*)~([^~\]]*)~([^~\]]*?)~?\]\]([\d\D]*?)\[\[\/SQL3\]\]/i ) {
			$output =~ s/\[\[SQL3\s+~([^~]*)~([^~\]]*)~([^~\]]*?)~?\]\]([\d\D]*?)\[\[\/SQL3\]\]/&sqlcall($1,$2,$3,$4,'Found Nothing')/iegs;

		} elsif ( $output =~ /\[\[SQL2\s+~([^~]*)~([^~\]]*)~([^~\]]*?)~?\]\]([\d\D]*?)\[\[\/SQL2\]\]/i ) {
			$output =~ s/\[\[SQL2\s+~([^~]*)~([^~\]]*)~([^~\]]*?)~?\]\]([\d\D]*?)\[\[\/SQL2\]\]/&sqlcall($1,$2,$3,$4,'Found Nothing')/iegs;

		} elsif ( $output =~ /\[\[SQL\s+~([^~]*)~([^~\]]*)~([^~\]]*?)~?\]\]([\d\D]*?)\[\[\/SQL\]\]/i ) {
			$output =~ s/\[\[SQL\s+~([^~]*)~([^~\]]*)~([^~\]]*?)~?\]\]([\d\D]*?)\[\[\/SQL\]\]/&sqlcall($1,$2,$3,$4,'Found Nothing')/iegs;

		} elsif ( $output =~ /\[\[SQLE\s+~([^~]*)~([^~\]]*)~([^~\]]*?)~?\]\]([\d\D]*?)\[\[\/SQLE\/\]\]([\d\D]*?)\[\[\/SQLE\]\]/i ) {
			$output =~ s/\[\[SQLE\s+~([^~]*)~([^~\]]*)~([^~\]]*?)~?\]\]([\d\D]*?)\[\[\/SQLE\/\]\]([\d\D]*?)\[\[\/SQLE\]\]/&sqlcall($1,$2,$3,$4,$5)/iegs;

		} elsif ( $output =~ /\[\[EVAL\s+\((.*?)\)\]\]/i ) {
			$output =~ s/\[\[EVAL\s+\((.*?)\)\]\]/ eval $1 /iegs;

		} elsif ( $output =~ /\[\[IF\s+\([\d\D]*?\)\]\]/i ) {
			$output = &$sub_processif($output,'IF') ;
			
#			$output =~ s/\[\[IF\s+\(\s*([^\!\=\<\>\s]*)((?:[\s\!\=\<\>~]*)|(?:\seq\s)|(?:\sne\s))([^\s\!\=\<\>\]]*)\s*\)\]\]([\d\D]*?)\[\[\/IF\]\]/&boolean($1,$2,$3,$4)/iegs;
#			$output =~ s/\[\[IF\s+([\d\D]*?)\]\]/'{{PearlWebError: Incorrect use of IF statement: ---|'.$1.'|---}}'/iegs;

		} elsif ( $output =~ /\[\[IFNB\s+(.*?)\]\]([\d\D]*?)\[\[\/IFNB\]\]/i ) {
			$output =~ s/\[\[IFNB\s+(.*?)\]\]([\d\D]*?)\[\[\/IFNB\]\]/ $2 if ${$1} /iegs;

		} elsif ( $output =~ /\[\[IFB\s+(.*?)\]\]([\d\D]*?)\[\[\/IFB\]\]/i ) {
			$output =~ s/\[\[IFB\s+(.*?)\]\]([\d\D]*?)\[\[\/IFB\]\]/ $2 if !${$1}/iegs;

		} elsif ( $output =~ /\[\[IFGTE\s+(.*?)\|([\d\D]*?)\]\]([\d\D]*?)\[\[\/IFGTE\]\]/i ) {
			$output =~ s/\[\[IFGTE\s+(.*?)\|([\d\D]*?)\]\]([\d\D]*?)\[\[\/IFGTE\]\]/ $3 if (${$1} >= $2)/iegs;

		} elsif ( $output =~ /\[\[IFGT\s+(.*?)\|([\d\D]*?)\]\]([\d\D]*?)\[\[\/IFGT\]\]/i ) {
			$output =~ s/\[\[IFGT\s+(.*?)\|([\d\D]*?)\]\]([\d\D]*?)\[\[\/IFGT\]\]/ $3 if (${$1} > $2)/iegs;

		} elsif ( $output =~ /\[\[IFLT\s+(.*?)\|([\d\D]*?)\]\]([\d\D]*?)\[\[\/IFLT\]\]/i ) {
			$output =~ s/\[\[IFLT\s+(.*?)\|([\d\D]*?)\]\]([\d\D]*?)\[\[\/IFLT\]\]/ $3 if (${$1} <= $2)/iegs;

		} elsif ( $output =~ /\[\[IFEQ\s+(.*?)\=(.*?)\]\](.*?)\[\[\/IFEQ\]\]/i ) {
			$output =~ s/\[\[IFEQ\s+(.*?)\=(.*?)\]\](.*?)\[\[\/IFEQ\]\]/ $3 if (${$1} eq ${$2})/iegs;

		} elsif ( $output =~ /\[\[IFNE\s+(.*?)\=(.*?)\]\](.*?)\[\[\/IFNE\]\]/i ) {
			$output =~ s/\[\[IFNE\s+(.*?)\=(.*?)\]\](.*?)\[\[\/IFNE\]\]/ $3 if (${$1} ne ${$2})/iegs;

		} elsif ( $output =~ /\[\[IF[1-3]?\s+(\w+)\=([^\]]*)\]\]/i ) {
			for ($ll=1;$ll<=$MAXIF;$ll++) {
				$output =~ s/\[\[IF$ll\s+(\w+)\=([^\]]*)\]\]([\d\D]*?)\[\[\/IF$ll\]\]/ $3 if (${$1} eq $2)/iegs;	
				$output =~ s/\[\[IF$ll([\d\D]*?)\]\]/'{{PearlWebError: IF not closed}}'/iegs;	
			}
			$output =~ s/\[\[IF\s+(\w+)\=([^\]]*)\]\](.*?)\[\[\/IF\]\]/ $3 if (${$1} eq $2)/iegs;	

		} elsif ( $output =~ /\[\[IFC\s+([^~]*)\~([^\]]*)\]\]([\d\D]*?)\[\[\/IFC\]\]/i ) {
			$output =~ s/\[\[IFC\s+([^~]*)\~([^\]]*)\]\]([\d\D]*?)\[\[\/IFC\]\]/ &contains($1,$2,$3) /iegs;	

		} elsif ( $output =~ /\[\[IF\d?\!([\d\D]*?)\]\]/i ) {
			for ($ll=1;$ll<=$MAXIFS;$ll++) {
				$output =~ s/\[\[IF$ll\!\s+(\w+)\=(.*?)\]\](.*?)\[\[\/IF$ll\!\]\]/&notEqual($1,$2,$3)/iegs;	
				$output =~ s/\[\[IF$ll\!([\d\D]*?)\]\]/'{{PearlWebError: IF! not closed}}'/iegs;	
			}
			$output =~ s/\[\[IF\!\s+(\w+)\=(.*?)\]\](.*?)\[\[\/IF\!\]\]/&notEqual($1,$2,$3)/iegs;	

		} elsif ( $output =~ /\[\[COUNTER\s+(.*?)\]\](.*?)\[\[\/COUNTER\]\]/i ) {
			$output =~ s/\[\[COUNTER\s+~([^\]]*)\,([0-9]*)~\]\](.*?)\[\[\/COUNTER\]\]/&$sub_countresults($1,$3,$2)/iegs;
			$output =~ s/\[\[\/?COUNTER[^\]]*\]\]/'{{PearlWebError: incorrect use of COUNTER}}'/iegs;

		} elsif ( $output =~ /\[\[([A-Z][A-Z])\]\]([\d\D]*?)\[\[\/([A-Z][A-Z])\]\]/ ) {
			$output =~ s/\[\[([A-Z][A-Z])\]\]([\d\D]*?)\[\[\/([A-Z][A-Z])\]\]/ $2 if ( ($1 eq $3) && ($1 eq $DISPLANG) ) /egs;

		} elsif ( $output =~ /\[\[CALC\s+([\d\D]*?)\]\]/i ) {
			$output =~ s/\[\[CALC\s+\(([^\,]*)\,([^\,]*)\,([^\]]*)\)\]\]/ &calc($1,$2,$3) /eigs;
			$output =~ s/\[\[CALC\s+([\d\D]*?)\]\]/'{{PearlWebError: Incorrect use of CALC function: '.$1.'}}'/iegs;	

		} elsif ( $output =~ /\[\[HASH([\d\D]*?)\]\]/i ) {
			$output =~ s/\[\[HASH\s+\(([\w]*)\,([\w]*)\,([^\]]*)\)\]\]/ &hash($1,$2,$3) /eigs;
			$output =~ s/\[\[HASH\s+([\d\D]*?)\]\]/'{{PearlWebError: Incorrect use of HASH function: '.$1.'}}'/iegs;	

		} elsif ( $output =~ /\[\[\{(\d+)\,(\d+)(\+)?\}(\w+)\]\]/ ) {
			$output =~ s/\[\[\{(\d+)\,(\d+)(\+)?\}(\w+)\]\]/&spliceparam(${$4},$1,$2,$3)/egs;

		} elsif ( $output =~ /\[\[s\-(\w+)\]\]/ ) {
			$output =~ s/\[\[s\-(\w+)\]\]/ &$sub_dopluralcheck($1) /egs;

		} elsif ( $output =~ /\[\[([\w_\-\.\+]+)\]\]/ ) {
			$output =~ s/\[\[([\w_\-\.\+]+)\]\]/${$1}/egs;

		} elsif ( $output =~ /\[\[NOTs\-(\w+)\]\]/ ) {
			$output =~ s/\[\[NOTs\-(\w+)\]\]/ "" if (${$1} == 1)/egs;

		} elsif ( $output =~ /\[\[MAIL\s+~([^~]*)~([^~]*)~([^~]*)~\]\]([\d\D]*?)\[\[\/MAIL\]\]/i ) {
			$output =~ s/\[\[MAIL\s+~([^~]*)~([^~]*)~([^~]*)~\]\]([\d\D]*?)\[\[\/MAIL\]\]/&mailcall($1,$2,$3,$4)/iegs;
			$output =~ s/\[\[MAIL\s+(.*?)\]\]/'{{PearlWebError: Incorrect use of MAIL function: '.$1.'}}'/iegs;
			$output =~ s/\[\[\/MAIL\]\]/'{{PearlWebError: Incorrect use of MAIL function}}'/iegs;
			
		} elsif ( $output =~ /\[\[MAILHTML\s+~([^~]*)~([^~]*)~([^~]*)~\]\]([\d\D]*?)\[\[\/MAILHTML\]\]/i ) {
			$output =~ s/\[\[MAILHTML\s+~([^~]*)~([^~]*)~([^~]*)~\]\]([\d\D]*?)\[\[\/MAILHTML\]\]/&mailcallHTML($1,$2,$3,$4)/iegs;
			$output =~ s/\[\[MAILHTML\s+(.*?)\]\]/'{{PearlWebError: Incorrect use of MAIL function: '.$1.'}}'/iegs;
			$output =~ s/\[\[\/MAILHTML\]\]/'{{PearlWebError: Incorrect use of MAIL function}}'/iegs;

#	[[MAIL ~[[RECIPIENTS]]~Local event form received from [[hostname]]~[[XEmail]]~]]
#		Local event form:
#		[[LOOP (%FORM|100)]][[LOOPVALUE]]: [[PARAMVALUE]][[/LOOP]]
#	[[/MAIL]]
			
		} elsif ( $output =~ /\[\[LOAD\s([\d\D]*?)\]\]/i ) {
			while ($output =~ /\[\[LOAD\s+"(.*?)"\]\]/) {
				$output =~ s/\[\[LOAD\s+"([^"]*)"\]\]/ &$sub_loadFragments($1) /iegs;
			}
			$output =~ s/\[\[LOAD\s([\d\D]*?)\]\]/'{{PearlWebError: Incorrect use of LOAD function: '.$1.'}}'/iegs;	

		} elsif ( $output =~ /\[\[LAST\s([\d\D]*?)\]\]/i ) {
			while ($output =~ /\[\[LAST\s([\d\D]*?)\]\]/) {
				$output =~ s/\[\[LAST\s+([\w\-\.\+\/\\]+)\]\]/${$1}/egs;
			}
			$output =~ s/\[\[LAST\s([\d\D]*?)\]\]/'{{PearlWebError: Incorrect use of LAST function: '.$1.'}}'/egs;

		} else {
		
			$output =~ s/\[\[([^\]]*)\]\]/'{{PearlWebError: command or format not recognised --|'.$1.'|--}}'/eigs ;
		
		}
#		$output =~ s/\\\[/'['/eigs ;
#		$output =~ s/\\\]/']'/eigs ;

#		&$sub_gettime('End of output loop '.$errorloop) ;

#		$bracketsRemaining = 0 ;
#		$output =~ s/\[\[(.*?)\]\]/ &countBrackets($1) /eigs ;
#		print "Brackets left: ".$bracketsRemaining."\n"		 ;
		
	}

#	print "<!--Errorloop value here=".$errorloop."-->\n" ;

	if ( $output =~ /\[\[(.*?)\]\]/ ) {
		$output =~ s/\[\[(.*?)\]\]/'{{PearlWebError: nesting level unsupported for ----|'.$1.'|---- }}'/egs;
	}

# +-------------------------------------+
# |     remove spaces and comments      |
# +-------------------------------------+
#	$output =~ s/\<\!\-\-[\d\D]*?\-\-\>//eigs ;
# 	$output =~ s/\s/' '/eigs ;
#	while ($output =~ /\s\s/) {
#		$output =~ s/\s\s/' '/eigs ;
#	}

	return $output;
}

sub hash {
	my(@hash) = @_ ;
	${$hash[0]}{${$hash[1]}} = ${$hash[2]} ;
	return "" ;
}

sub mailcall {
	if (!$sub_whichmail) {
		$sub_whichmail = "sendmail" ;
	}
	&$sub_whichmail(&$sub_output($_[0]),&$sub_output($_[1]),&$sub_output($_[2]),&$sub_output($_[3])) ;
	return "" ;
}

sub mailcallHTML {
	if (!$sub_whichmail) {
		$sub_whichmail = "sendmailHTML" ;
	}
	&sendmailHTML(&$sub_output($_[0]),&$sub_output($_[1]),&$sub_output($_[2]),&$sub_output($_[3])) ;
	return "" ;
}

sub dopluralcheck {
	my($t) = $_[0] ;
#	print "<!--Doing plural check.  singular=\"".$setsingular."\" plural=\"".$setplural."\"<br>-->\n" ;
#	print "<!--checking parameter \"".$t."\" which is \"".${$t}."\"<br>-->\n" ;
	if (${$t} > 1.001 ) {
		return ($setplural || "s") ;
	} else {
		return ($setsingular || "" );
	}
}

sub searchcall {
	my(@pairs) = split(/\~\~/,$_[0]) ;
	my($loopcode) = $_[1] ;
	my($nullcode) = $_[2] ;
	my($pair,$param,$value) ; 
	my(%SP,$RETURNcode) = "" ;

#	print "<!-- LOOPCODE ~~~~~~~~~~~~~~~~~~~~~~\n ".$loopcode." \n ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->\n" ;
	# calculate params...
	foreach $pair (@pairs) {
		$_ = $pair ;
		my($param,$value) = /^\s*(\S+)\s*=\s*([\d\D]*?)\s*$/ ;
		$value =~ s/\s+/' '/eigs ;
		if (length($param)>0) {
#			print "<!--".$param."|".$value."-->\n" ;
			$SP{$param} = $value ;
		}
	}
	foreach $searchParam (keys %SP) {
		if (!$searchParam) { next; }
#		print "<!-- Found pair: ~~~|".$searchParam."|~~~ ~~~|".$SP{$searchParam}."|~~~ -->\n\n" ;
	}

	$query = $SP{'query'} ;
	my($offset) = $SP{'offset'} || 0 ;
	my($count) = $SP{'count'} || 10 ;
	$FORM{"results_option"} = $SP{'type'} ;
	$searchId = $SP{'id'} || 1 ;
	@secallow = ($SP{'sites'}) ;
	$FORM{'selectionurls'} = $SP{'selectionurls'} ;
	if ($secname = $SP{'section'}) {  # this is an assignment not an equality test
		&$sub_sectionsupport ;
	}
	if ($SP{'src'}) { $src = $SP{'src'} }
	if ($SP{'ss'}) { $src = $RSroot.$SP{'ss'} }

	&$sub_do_search($offset,$count);
	
	%SP = "" ;
	if (${'nresults'.$searchId} > 0 ) {
		$LISTITEM = $loopcode ;
		for($i=0 ; $i<$count ; $i++){
			$name = ${'names'.$searchId}[$i];
#			print "<!--Loop: ".$i." name=~~~|".$name."|~~~ -->\n" ;
			if (!$name){ next; }
			$RETURNcode .= &$sub_outres($name,$sub_getexiturl);	
#			print "<!-- ~~~~ThisRETURNcode~~~~~~~\n".$RETURNcode."\n~~~~~~~~~~~~~~~~~~~~~ -->\n" ;
		}
	} else {
		$RETURNcode = $nullcode ;
	}

	return $RETURNcode ;
}


sub countBrackets {
	$bracketsRemaining++ ;
#	print "    Found Bracket: [[".$_[0]."]]\n" ;
	return '[['.$_[0].']]' ;
}

sub setSQLserver {
	my($SQLdatabase,$SQLusername,$SQLpassword,$SQLhost,$SQLport) = split(/\,/,$_[0]) ;
#	print "<!--SQL information:~~".$SQLdatabase."~~".$SQLusername."~~".$SQLpassword."~~".$SQLhost."~~".$SQLport."-->\n\n" ;

	$DB = 'DBI:mysql:'.$SQLdatabase            ;
	if ($SQLhost) { $DB .= ':'.$SQLhost }
	if ($SQLport) { $DB .= ':'.$SQLport }
	$DBusername = $SQLusername          ;
	$DBpassword = $SQLpassword          ;
#	$dbh = DBI->connect("DBI:mysql:$database:$hostname:$port",$username,$password); 
	return "" ;
}

sub sqlcall {
	my($SQL,$paramlist,$SQLlist,$loopcode,$elsecode,$SQLtype) = @_ ;
	my($returncode,$i,$EXECError) ;
	my(@params) = split(/\,/,$paramlist) ;

	my($SQLdatabase,$SQLusername,$SQLpassword,$SQLhost,$SQLport) = split(/\,/,$SQLlist) ;
	
	$DEBUG .= "<!--SQL information:~~".$SQLdatabase."~~".$SQLusername."~~".$SQLpassword."~~".$SQLhost."~~".$SQLport."-->\n" if $DEBUGlevel>9.5 ;
	
	my($thisDB,$thisDBusername,$thisDBpassword) ;
	if ($SQLdatabase)	{ $thisDB = 'DBI:mysql:'.$SQLdatabase } else { $thisDB = $DB }
	if ($SQLhost) { $thisDB .= ':'.$SQLhost }
	if ($SQLport) { $thisDB .= ':'.$SQLport }

	if ($SQLusername && length($SQLusername)>1 )	{ $thisDBusername = $SQLusername } else { $thisDBusername = $DBusername }
	if ($SQLpassword && length($SQLpassword)>1 )	{ $thisDBpassword = $SQLpassword } else { $thisDBpassword = $DBpassword }

	$DEBUG.= "<!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\nSQL Query:\n$SQL\n" if $DEBUGlevel>4.5 ;
	if (!$SQLtype) {
		$DEBUG .= "SQL Parameters:\n$paramlist\n" if $DEBUGlevel>4.5 ;
	}
	$DEBUG .= "SQL Settings:~~~|".$thisDB."|~~~|".$thisDBusername."|~~~|".$thisDBpassword."|~~~ -->\n\n\n" if $DEBUGlevel>9.5 ;
#		print "<!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" ;
#		print $loopcode."\n";
#		print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n-->" ;
	
	$SQLcounttotal++ ;
	my $dbh = DBI -> connect($thisDB,$thisDBusername,$thisDBpassword) or return "{{PearlWebError: Could not connect to database: <font color=Red>".($dbh->errstr)."</font>}}" ;
	my $sth = $dbh -> prepare($SQL) or return "{{PearlWebError: Could not create stub handler for SQL statement \"".$SQL."\" : <font color=Red>".($dbh->errstr)."</font> }}" ;
	my (@data) = "";
	$sth -> execute       or $EXECError = "{{PearlWebError: Bad SQL statement: \"".$SQL."\" : <font color=Red>".($sth->errstr)."</font> }}" ;
	if ($EXECError && !$SQLtype) { return $EXECError ; }
	if ($EXECError && $SQLtype)  { return $elsecode  ; }

	my($SQLCOUNT) = 0 ;
	while (!$SQLtype && (@data = $sth->fetchrow_array())  ) {
		$SQLCOUNT++ ;
		my($thisloop) = $loopcode ;
		for ($i=0;$i<=$#params;$i++) {
			${$params[$i]} = $data[$i] ;
			if (${$params[$i]} =~ /%/) {
				${$params[$i]} = &unpackhexText(${$params[$i]}) ; #######################
			}
			my($a) = $params[$i] ; my($b) = ${$params[$i]} ;
			$thisloop =~ s/\[\[$a\]\]/$b/egs ;
		}
		$thisloop =~ s/\[\[SQLCOUNT\]\]/$SQLCOUNT/egs ;
#		if ($HTMLDebug){
#			print "<!--\n\n~~~~BIT OF LOOP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n" ;
#			print $thisloop ;
#			print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~END \n\n\n\n\n\n-->" ;
#		}
		$returncode .= &$sub_output($thisloop) ;
	}
	if ($SQLtype) {
		${$params[0]} = $sth -> {mysql_insertid} ;
		$returncode = $loopcode ;
	}
	if ($sth->rows == 0) {
		$returncode = $elsecode ;
	}
	$sth -> finish;
	$dbh -> disconnect;
	$returncode =~ s/\\\[/'['/eigs ;
	$returncode =~ s/\\\]/']'/eigs ;
#	print "<!--\n\n~~~~RETURNCODE~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n" ;
#	print $returncode ;
#	print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~END \n\n\n\n\n\n-->" ;
	return $returncode ;
}

sub spliceparam {
	my($output1,$startsplice,$finishsplice,$toEnd) = @_ ;
#	print "\n\n\n<!--".$output1.":".(length($output1)).":".$finishsplice."-->\n" ;
	my($thisending) = ($DOTDOTDOT||"...") ;
	if ($finishsplice >= length($output1)) { $finishsplice = length($output1) ; $toEnd = "" ; $thisending = "" ;}
	$startsplice-- ;
#	print "<!--Splicing ".$output1." in range ".$startsplice." to ".$finishsplice."-->\n" ;
	if ($startsplice < 0) {
		$output1 .= "{{PearlWebError: start value must be >= 1}}" ;
		$startsplice = 0 ;
	}
	my($mid) = $finishsplice - $startsplice ;
	if ($mid < 1) {
		$output1 .= "{{PearlWebError: start value must be <= end value}}" ;
		$mid = 1 ;
	}
	$_ = $output1 ;
	if (!$toEnd) {
		$evaluation = " (\$returncode) = /^.{".$startsplice."}(.{".$mid."}).*/ ; " ;
	} else {
		$evaluation = " (\$returncode) = /^.{".$startsplice."}((.{".$mid."})([^\\s]*)).*?/ ; " ;
	}
#	print "<!--Evaluation is: ".$evaluation."-->\n" ;
#	print "<!--".$1."~".$2."~".$3."~".$4."-->\n" ;
	eval ( $evaluation ) ;
#	print "<!--returned match~~~~".$returncode."~~~~~~-->\n\n\n" ;
	return $returncode.$thisending ;
}

sub countresults {
	my($countquery,$countinsertion,$sId) = @_;
	$searchId = $sId || '' ;
	$query = $countquery ;
	&$sub_do_search(0,-1);
	$RETURNval = &$sub_output($countinsertion) ;
	return $RETURNval ;
}

sub looparound {
	my($loopvariables,$loopcode,$loopdash) = @_;
	my($RETURNloop,$looparray,$maxreturn,$Lstart,$Lfinish,$Lstep) ;
	my($RETURNloop,$looparray,$maxreturn,$ll,$output) = "" ;
	if ($loopvariables =~ /^\%(.*)$/i ) {
		# this is for a loop like: [[LOOP (%array)]] as in a loop of the keys of $array{$keys}
		$looparray = $1 ; $maxreturn = "" ;
		if ($looparray =~ /\|/ ) {
			$_ = $looparray ; ($looparray,$maxreturn) = /^(.*)\|(.*)$/i ;
	#		print "<!--loop: found pipe, split as ~~".$looparray."~~".$maxreturn."-->\n" ;
			if ($maxreturn > 0) {
				foreach $loop (sort { ${$looparray}{$b} <=> ${$looparray}{$a} } keys %{$looparray}){
					$ll++ ;
					if (  ($maxreturn && ($ll > $maxreturn))   ||  (length($loop)<0.5)  ) { next; }
	#				print "<!--Loop: array:".$looparray." key:".$loop."-->\n" ;
					$output = $loopcode ;
					$output =~ s/\[\[LOOPCOUNT$loopdash\]\]/$ll/egs ;
					$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$loop/egs ;
					$output =~ s/\[\[PARAMVALUE$loopdash\]\]/${$looparray}{$loop}/egs ;
					$RETURNloop .= &$sub_output($output) ;
				}	
			} else {
				$maxreturn = $maxreturn * -1 ;
				foreach $loop (sort { ${$looparray}{$a} <=> ${$looparray}{$b} } keys %{$looparray}){
					$ll++ ;
					if (   ($maxreturn && ($ll > $maxreturn))   ||  (length($loop)<0.5)   ) { next; }
	#				print "<!--Loop: array:".$looparray." key:".$loop."-->\n" ;
					$output = $loopcode ;
					$output =~ s/\[\[LOOPCOUNT$loopdash\]\]/$ll/egs ;
					$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$loop/egs ;
					$output =~ s/\[\[PARAMVALUE$loopdash\]\]/${$looparray}{$loop}/egs ;
					$output =~ s/\[\[SAFEPARAMVALUE$loopdash\]\]/&makesafetext(${$looparray}{$loop})/egs ;
					$RETURNloop .= &$sub_output($output) ;
				}	
			}
		} else {
	#		print "<!--loop: found no pipe, split as ~~".$looparray."~~".$maxreturn."-->\n" ;
			foreach $loop (sort keys %{$looparray}){
				$ll++ ;
				if ( $maxreturn && ($ll > $maxreturn) ) { next; }
	#			print "<!--Loop: array:".$looparray." key:".$loop."-->\n" ;
				$output = $loopcode ;
				$output =~ s/\[\[LOOPCOUNT$loopdash\]\]/$ll/egs ;
				$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$loop/egs ;
				$output =~ s/\[\[PARAMVALUE$loopdash\]\]/${$looparray}{$loop}/egs ;
				$output =~ s/\[\[SAFEPARAMVALUE$loopdash\]\]/&makesafetext(${$looparray}{$loop})/egs ;
				$RETURNloop .= &$sub_output($output) ;
			}	
		}
		$ll = 0;
	} elsif ($loopvariables =~ /^(.*?)\.\.\.(.*?)\|([\d\-\.]*)$/i ) {
		$Ls = $Lstart = $1 ; $Lf = $Lfinish = $2 ; $Lstep = $3 ;
		$DEBUG .= "<!-- ~~~~~~~~~~~~~~Looping on.... ~~~~~~~~~~~~~~~~~~~~~~~~\n".$loopcode."\n~~~~~~~~~~~~~~~~~~~~~~~ for loop:-->\n" if $DEBUGlevel>=5 ;
		if ($Lfinish =~ /[a-zA-Z]/) { $Lfinish = ${$Lfinish} }
		if ($Lstart =~ /[a-zA-Z]/) { $Lstart = ${$Lstart} }
		$DEBUG .= "<!-- Found numeric LOOP from --|".$Ls."(".$Lstart.")|--to--|".$Lf."(".$Lfinish.")|--step--|".$Lstep."|-- -->\n" if $DEBUGlevel>=2 ;
		if ( ($Lfinish >= $Lstart) && ($Lstep > 0) ) {
			for ($ll=$Lstart;$ll<=$Lfinish;$ll=$ll+$Lstep) {
				$output = $loopcode ;
				$output =~ s/\[\[LOOPCOUNT$loopdash\]\]/$ll/egs ;
				$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$ll/egs ;
				$DEBUG .= "<!-- fragment of loop: ~~~~~~~~~\n".$output."\n~~~~~~~~~~~~~~~~~~-->\n\n\n" if $DEBUGlevel>=8 ;
				my($pooh) = &$sub_output($output) ;
				$RETURNloop .= $pooh ;
			}
		} elsif ( ($Lfinish > $Lstart) && ($Lstep < 0) ) {
			#$RETURNloop = "<!--{{PearlWebError: invalid loop: step -ve(".$Lstep.") and finish(".$Lfinish.") > start(".$Lstart.")}}-->"
			$RETURNloop = "" ;
		} elsif ( ($Lfinish <= $Lstart) && ($Lstep < 0) ) {
			# correct loop like  5...1 step -1
			for ($ll=$Lstart;$ll>=$Lfinish;$ll=$ll+$Lstep) {
				$output = $loopcode ;
				$output =~ s/\[\[LOOPCOUNT$loopdash\]\]/$ll/egs ;
				$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$ll/egs ;
				$DEBUG .= "<!-- fragment of loop: ~~~~~~~~~\n".$output."\n~~~~~~~~~~~~~~~~~~-->\n\n\n" if $DEBUGlevel>=8 ;
				my($pooh) = &$sub_output($output) ;
				$RETURNloop .= $pooh ;
			}
		} elsif ( ($Lfinish < $Lstart) && ($Lstep >= 0) ) {
			# incorrect loop like  5...1 step +1
			#$RETURNloop = "<!--{{PearlWebError: invalid loop: step +ve(".$Lstep.") and finish(".$Lfinish.") < start(".$Lstart.")}}-->"
			$RETURNloop = "" ;
		} else {
			#$RETURNloop = "{{PearlWebError: invalid loop}}"
			$RETURNloop = "" ;
		}
	} elsif ($loopvariables =~ /^\@(.*)$/i ) {
		# this is for a loop like: [[LOOP (@array)]] as in a loop of the keys of @array
		$looparray = $1;
		foreach $loop (@{$looparray}){
			$output = $loopcode ; 
			$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$loop/egs ;
			$RETURNloop .= &$sub_output($output) ;
		}
	} else {	
		# this is for a loop like: [[LOOP (a,b,c,d)]] as in a loop through a then b then c then d etc
		$ll = 0;
		foreach $loop (split (/,/,$loopvariables)){
			$ll++ ;
			$output = $loopcode ;
			$output =~ s/\[\[LOOPCOUNT$loopdash\]\]/$ll/egs ;
			$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$loop/egs ;
			$RETURNloop .= &$sub_output($output) ;
		}	
	}
#	print "<!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n".$RETURNloop."-->\n\n\n\n\n\n\n" ;
	$RETURNloop =~ s/\\\[/'['/eigs ;
	$RETURNloop =~ s/\\\]/']'/eigs ;
	&subroutineend('looparound') ;
	return $RETURNloop ;
}

sub processif {
#	&subroutinestart('processif') ;
	my($output,$IFtype,$BIGCOUNT,$IFbefore,$IFparam1,$IFsign,$IFparam2,$IFafter,$IFcode,$thisBefore,$thisIF,$thisAfter) ;
	$BIGCOUNT++ ;
	($output,$IFtype) = @_ ;
#	$DEBUG .= "<!-- ~~~~~~~~~~~~~~~~~ processing output containing IF ~~~~~~~~~~~~~~~~~~~#\n".$output."\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->\n"  ;
	while ( $output =~ /(\[\[$IFtype\s+\([\d\D]*?\)\]\])/i ) {
		# $DEBUG .= $1 if $DEBUGlevel>7 ;
		$_ = $output ;
		($IFbefore,$IFparam1,$IFsign,$IFparam2,$IFafter) = /^([\d\D]*?)\[\[$IFtype\s+\(\s*([^\!\=\<\>\s]*)((?:\s*[\!\=\<\>~]+\s*)|(?:\seq\s)|(?:\sne\s)|(?:\sis\s)|(?:\snot\s))([^\!\=\<\>\]]*)\)\]\]([\d\D]*)$/ig ;
		$DEBUG .= "<!--Found IF: ~~|".$IFparam1."|~~    ~~|".$IFsign."|~~   ~~|".$IFparam2."|~~~ -->\n" if $DEBUGlevel>7 ;
		$IFcount = 1 ;
		$IFcode = "" ;
		while ($IFcount>0 && $BIGCOUNT<502) {
			$BIGCOUNT++ ;
			#print "\n\n".$BIGCOUNT.":\n" ;
			$_ = $IFafter ;
			($thisBefore,$thisIF,$thisAfter) = /^([\d\D]*?)((?:\[\[\/$IFtype\]\])|(?:\[\[$IFtype\s+\(.*?\)\]\]))([\d\D]*)$/ig ;
			if ($thisIF eq "" ) {
				# error in nesting - report error
				#print "545454 nesting error" ; exit ;
			} elsif ($thisIF =~ /\[\[\/$IFtype\]\]/ ) {
				$IFcount-- ;
				if ($IFcount < 0.5) {
					# got a closing match - process boolean
					$IFcode .= $thisBefore ;
					#print "~~~~~~~~~~~~~~~~~~~~ IF CODE: ~~~~~~~~~~~~~~~~~~~~~~\n".$IFcode."\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" ;
					$output = $IFbefore.&$sub_output(&boolean($IFparam1,$IFsign,$IFparam2,$IFcode)).$thisAfter ;
				} else {
					# add up parameters and process next "while"
					$IFcode .= $thisBefore.$thisIF ;
					$IFafter = $thisAfter ;
				}
			} else {
				$IFcount++ ;
				# add up parameters and process next "while"
				$IFcode .= $thisBefore.$thisIF ;
				$IFafter = $thisAfter ;
			}
		
		}
		if ( $BIGCOUNT > 5000 ) { print "{{PearlWebError: BIGCOUNT in IF loop too big, got to exit.  Check your [[IF]] nesting near |".$IFparam1."~".$IFsign."~".$IFparam2."|}}" ; print $output."\n\n\n".$DEBUG ; exit ; }
	}
#	&subroutineend('processif') ;
	return $output ;
}

sub boolean {
	my($param1,$sign,$param2,$code) = @_ ;
	my($testP1,$testP2,$returncode) ;

	$sign =~ s/^\s*([^\s]*?)\s*$/$1/ ;
	if (length($sign) < 0.5) { return "{{PearlWebError: Incorrect use of IF statement: no operand detected  p1--|".$param1."|-- --|".$param2."|--}}" }
	
	$param2 =~ s/^\s*(.*?)$/$1/eg ;
	$param2 =~ s/^(.*?)\s*$/$1/eg ;
	if ($param2 =~ /^\s*["']([^'"]*)['"]\s*$/ ) {
		$param2 = $1 ;
	}
	if ( $param2 =~ /['"]/ ) { return "{{PearlWebError: Incorrect use of IF statement: unbalanced \' or \", or not permitted inside scalar}}" }
	
	# $returncode = "<!-- IF  ---|".$param1."|---  ---|".$sign."|---  ---|".$param2."|---  /IF -->" ;
	
	# Set compare parameters:
	if ($param1 =~ /^\$(.*)$/) {
		$testP1 = ${$1} ;
	} else {
		$testP1 = $param1 ;
	}
	if ($param2 =~ /^\$(.*)$/) {
		$testP2 = ${$1} ;
	} else {
		$testP2 = $param2 ;
	}
	
	if ($sign eq "==") {
		if ($testP1 == $testP2) {
			#$returncode .= "<!--IF ($param1=$testP1) == ($param2=$testP2) TRUE -->".$code ;
			$returncode .= $code ;
		} else {
			#$returncode .= "<!--IF ($param1=$testP1) == ($param2=$testP2) FALSE -->" ;
		}
	} elsif ($sign eq "!=") {
		if ($testP1 != $testP2) {
			$returncode .= $code ;
		}
	} elsif ($sign eq ">") {
		if ($testP1 > $testP2) {
			$returncode .= $code ;
		}
	} elsif ($sign eq ">=") {
		if ($testP1 >= $testP2) {
			$returncode .= $code ;
		}
	} elsif ($sign eq "<") {
		if ($testP1 < $testP2) {
			$returncode .= $code ;
		}
	} elsif ($sign eq "<=") {
		if ($testP1 <= $testP2) {
			$returncode .= $code ;
		}
	} elsif ($sign eq "eq") {
		if ($testP1 eq $testP2) {
			$returncode .= $code ;
		}
	} elsif ($sign eq "ne") {
		if ($testP1 ne $testP2) {
			$returncode .= $code ;
		}
	} elsif ($sign =~ /^is$/i ) {
		if ($testP2 eq "EMAIL") {
			if ( $testP1 =~ /^([A-Z0-9]+[\._]?){1,}[A-Z0-9]+\@(([A-Z0-9]+[-]?){1,}[A-Z0-9]+\.){1,}[A-Z]{2,4}$/i  ) {
				$returncode .= $code ;
			} else {
				$returncode .= "<!--IS: Not a valid email address-->" ;
			}
		} else {
			$returncode .= "{{PearlWebError: Incorrect use of IF statement: IS function '".$param2."' not recognised in --|$param1$sign$param2|-- }}"
		}
	} elsif ($sign =~ /^not$/i ) {
		if ($testP2 eq "EMAIL") {
			if ( $testP1 !~ /^([A-Z0-9]+[\._]?){1,}[A-Z0-9]+\@(([A-Z0-9]+[-]?){1,}[A-Z0-9]+\.){1,}[A-Z]{2,4}$/i  ) {
				$returncode .= $code ;
			} else {
				$returncode .= "<!--NOT: Is a valid email address-->" ;
			}
		} else {
			$returncode .= "{{PearlWebError: Incorrect use of IF statement: IS function '".$param2."' not recognised in --|$param1$sign$param2|-- }}"
		}
	} elsif ($sign eq "=~") {
		if ($testP1 =~ /$testP2/ ) {
			$returncode .= $code ;
		}
	} elsif ($sign eq "!~") {
		if ($testP1 !~ /$testP2/ ) {
			$returncode .= $code ;
		}
	} elsif ($sign eq "<>") {
		if ($testP1 != $testP2 ) {
			$returncode .= $code ;
		}
	} else {
		$returncode .= "{{PearlWebError: Incorrect use of IF statement: function '".$sign."' not recognised in --|$param1$sign$param2|-- }}" ;
	}
	
	return $returncode ;
}

sub calc {
	my($param,$function,$value) = @_ ;
	if ($function eq "+") {
#		print "Adding ".$value." to \$".$param."<br>\n" ;
		if ($value =~ /[a-zA-Z_]/ ) {
			${$param} = ${$param} + ${$value} ;
		} else {
			${$param} = ${$param} + $value ;
		}
	} elsif ($function eq "-") {
		if ($value =~ /[a-zA-Z_]/ ) {
			${$param} = ${$param} - ${$value} ;
		} else {
			${$param} = ${$param} - $value ;
		}
	} elsif ($function eq "*") {
		if ($value =~ /[a-zA-Z_]/ ) {
			${$param} = ${$param} * ${$value} ;
		} else {
			${$param} = ${$param} * $value ;
		}
	} elsif ($function eq "/") {
		if ($value =~ /[a-zA-Z_]/ ) {
			if (${$value} != 0 && ${$value} && length(${$value}) > 0.5) {
				${$param} = ${$param} / ${$value} ;
			}
		} else {
			if (${$value} != 0 && ${$value} && length(${$value}) > 0.5) {
				${$param} = ${$param} / $value ;
			}
		}
	} elsif ($function eq "." || $function eq "&") {
		${$param} .= $value ;
		$DEBUG .= "<!-- [[CALC]] found: Setting \$".$param." to ~~~|".$value."|~~~ -->\n" if $DEBUGlevel > 0.5 ;
	} elsif ($function eq "=") {
		${$param} = $value ;
		$DEBUG .= "<!-- [[CALC]] found: Setting \$".$param." to ~~~|".$value."|~~~ -->\n" if $DEBUGlevel > 0.5 ;
	}
	return "" ;
}

sub contains {
	my($param,$val,$code) = @_ ;
	my($xx) = "" ;
	if ( ${$param} =~ /$val/ ) {
#		print "\$".$param."(".${$param}.") does contain ".$val."<br>\n\n" ;
		$xx = $code ;
	}
	return $xx ;
}

sub notEqual {
	my($param,$val,$code) = @_ ;
	if ($val !~ /&/ ) {
		if (${$param} ne $val) {
			return $code ;
		}
	} else {
#		print "param=\$".$param."<br>\n" ;
#		print "val=".$val."<br>\n" ;
		my(@thesevalues) = split(/&/,$val) ;
		my($i,$checks) = 0;
		for ($i=0;$i<=$#thesevalues;$i++) {
#			print "param".$i."=".$thesevalues[$i];
			if (${$param} ne $thesevalues[$i]) {
#				print " &nbsp; &nbsp; &nbsp; (\$action does not equal ".$thesevalues[$i].")<br>\n"  ;
				$checks++ ;
			} else {
#				print " &nbsp; &nbsp; &nbsp; (\$action DOES equal ".$thesevalues[$i].")<br>\n"  ;
			}
		}
#		print "checks=".$checks."---Values=".($#thesevalues+1)."<br>\n" ;
		if ($checks == ($#thesevalues+1)) {
			return $code ;
		}	else {
			return "" ;
		}
	}
}

sub setvalue {
	my($paramname,$paramvalue) = @_;
	${$paramname} = $paramvalue ;
	$DEBUG .= "<!--".$paramname." = ".length($paramvalue)."-->\n" if $DEBUGlevel >= 4 ;
	return "";
}

sub loadFragments {
	my($mainTEMPLATEblock) ;
	my($file) = $_[0] ;
	if ($file !~ /^\//) {
		$file = $HTMLdir.$file ;
		if (   ($DEBUGlevel > 1.5)   ) {
			$DEBUG .= "<!-- Adding HTML path to source file -->\n" if $DEBUGlevel >= 2;
		}
	}
	open(LF,"$file") || return("<!-- {{PearlWebError: Cannot open file(s): ".$file." }} -->");
	my($code) = join('',<LF>);
	close(LF);
	my($fragCount) = 0 ;
	my($param) = "" ;
	$DEBUG .= "<!-- Loading blocks found in file: ".$file." -->\n"  if $DEBUGlevel >= 1 ;
	while ( ($code =~ /<!--([_A-Za-z0-9]*?)-->/)  && ( $fragCount < 200 ) ) {
		$fragCount++ ;
		$_ = $code ; $param = $1 ;
		if ($code =~ /<!--$param-->([\d\D]*?)<!--\/$param-->([\d\D]*?)$/i ) {
#			print "correct format found for ".$param."<br>\n" ;
			&setvalue($param,$1) ;
			if ($param eq "TEMPLATE") {
				$mainTEMPLATEblock = $1 ;
			}
			$code = $2 ;
		} else {
			$code =~ s/<!--$param-->/''/eigs ;
			$DEBUG .= "<pre>{{PearlWebError: Error in ".$formatfile." - missing end tag for &lt;!--".$param."--&gt; }}</pre>\n" ;
		}
	}
	$DEBUG .= "<!--Loading fragments has finished-->\n\n" if $DEBUGlevel >= 4 ;
	while ( $code =~ /<!--\/([A-Za-z0-9_]*?)-->/ ) {
		$param = $1 ;
		$code =~ s/\<\!\-\-\/$param\-\-\>/''/i ;
		$DEBUG .= "<pre>{{PearlWebError: Error in ".$formatfile." - close tag not started: &lt;!--/".$param."--&gt; }}</pre>\n" ;	
	}
	if ($fragCount >0.5 && !$mainTEMPLATEblock) {
		return "" ;
	} else {
		return $mainTEMPLATEblock || $code ;
	}
}

# LEGACY SUPPORT for RS only - try to remove at your earliest convenience
sub read_format {
	open(FMT,$formatfile);
	$_ = join('',<FMT>);
	close(FMT);
	$_ =~ s/\{\-\{(\w+)\}\-\}/${$1}/egs;
	s/<!--#include\svirtual="?(.*?)"?\s?-->/&loadfile($1)/eig;
	s/<!--([_A-Z0-9]*?)-->([\d\D]*?)<!--\/([_A-Z0-9]*?)-->/&setvalue($1,$2)/iegs;
}

sub loadfile {
	open(LF,$HTMLroot.$_[0]) || return("Cannot open $HTMLroot".$_[0]);
	$xx = join("\n",<LF>);
	close(LF);
	return $xx;
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub gettime {
	@finishTime = gettimeofday;                                                                                                  
	for ($finishTime[1], $startTime[1]) { $_ /= 1_000_000 }                          
	$duration = ($finishTime[0]-$startTime[0])+($finishTime[1]-$startTime[1]) ;         
	$timeval{$_[0]} = int($duration*10000)/10000;
#	print "<!--Time at ".$_[0]." is ".$timeval{$_[0]}."-->\n" ;
}

sub subroutinestart {
	@{'startTime'.$_[0]} = gettimeofday;
}

sub subroutineend {
	@{'finishTime'.$_[0]} = gettimeofday; 
	for (${'finishTime'.$_[0]}[1], ${'startTime'.$_[0]}[1]) { $_ /= 1_000_000 } 
	$duration = (${'finishTime'.$_[0]}[0]-${'startTime'.$_[0]}[0])+(${'finishTime'.$_[0]}[1]-${'startTime'.$_[0]}[1]) ;         
	$subtimeval{$_[0]} = $subtimeval{$_[0]} + int($duration*10000)/10000;
#	print "<!--Time at ".$_[0]." is ".$timeval{$_[0]}."-->\n" ;
}

sub alerterror {
	my(@in) = @_ ;
	open(MESSGE,"| /usr/lib/sendmail -t") || die "can`t open pipe" ;
	print MESSGE "To: "   .  ($in[0] || "Operations <ops\@magus.co.uk>") . "\n" ;
	print MESSGE "From: " .  ($in[1] || "Pearl-Web script alert <ops\@magus.co.uk>") . "\n" ;
	print MESSGE "Subject: ".($in[2] || "Pearl-Web automated alert error")."\n\n" ;
	print MESSGE $in[3]."\n\n\n" ;
	close(MESSGE) ;
}

1;


