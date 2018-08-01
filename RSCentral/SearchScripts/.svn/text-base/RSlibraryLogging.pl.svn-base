#!/usr/bin/perl -w

##############################################
#                                            #
# Logging components required for RS Search  #
#                                            #
##############################################


# Subroutine_names in order of appearance in this script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$sub_centrallogging      = "centrallogging"     ;
$sub_analysislogging     = "analysislogging"    ;
$sub_fulllogging         = "fulllogging"        ;
$sub_dologging           = "dologging"          ;
$sub_makeDBchanges       = "makeDBchanges"      ;

# Subroutines...
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub centrallogging {
	if ($org_query =~ /\~/ ) {	$org_query =~ s/^([^\~]*)~.*$/$1/es ;	}
	if ($centrallog && ($hostname !~ /193\.131\.98\.17/i) && ($hostname !~ /vader\.magus\.co\.uk/i) && ($hostname !~ /listserv\.magus\.co\.uk/i) && ($hostname !~ /213\.86\.178/i)) {
		open(CENTLOG,">>$centrallog");
		$datenow =`date`;
		chop $datenow;
		@time = localtime(time);
		$date = "" ;
		if ($time[2] < 10) {$date .= "0" ;}
		$date .= $time[2].":";
		if ($time[1] < 10) {$date .= "0" ;}
		$date .= $time[1].":";
		if ($time[0] < 10) {$date .= "0" ;}
		$date .= $time[0];
		print CENTLOG "$hostname\t".($time[3])."/".($time[4]+1)."/".($time[5]+1900)." ".$date."\t$scriptname\t" ;
		if ($subdivision) { print CENTLOG $subdivision } else { print CENTLOG $thiscompany."_corporate" }
		print CENTLOG "\t".($org_query || $FORM{'similarto'})."\t".($actualNresults || $nresults)."\t$resultsdecision\t" ;
		print CENTLOG $timeval{'presearch'}."\t".$timeval{'postsearch'}."\t".$timeval{'preoutput'}."\t".$timeval{'postoutput'} ;
		print CENTLOG "\t".$hostlog."\t".$portlog."\t".$xlang."\t".$xmethod."\t".$xsection."\t".$FORM{"selectionurls"}."\t".$xlastmod."\t".$begin."\t".$lengthOutput."\n";
		close(CENTLOG);
	}
}

sub analysislogging {
	if ($org_query =~ /\~/ ) {	$org_query =~ s/^([^\~]*)~.*$/$1/es ;	}
	if ($analysislog && ($hostname !~ /193\.131\.98/i) && ($hostname !~ /213\.86\.178/i) && ($hostname !~ /magus\.co\.uk/i) ) {
		open(ANALLOG,">>$analysislog");
		$datenow =`date`;
		chop $datenow;
		@time = localtime(time);
		$date = "" ;
		if ($time[2] < 10) {$date .= "0" ;}
		$date .= $time[2].":";
		if ($time[1] < 10) {$date .= "0" ;}
		$date .= $time[1].":";
		if ($time[0] < 10) {$date .= "0" ;}
		$date .= $time[0];
		print ANALLOG "$hostname\t".($time[3])."/".($time[4]+1)."/".($time[5]+1900)." ".$date."\t$scriptname\t" ;
		if ($subdivision) { print ANALLOG $subdivision } else { print ANALLOG "corporate" }
		print ANALLOG "\t".($org_query || $FORM{'similarto'})."\t".($actualNresults || $nresults)."\t$resultsdecision\t" ;
		print ANALLOG $timeval{'presearch'}."\t".$timeval{'postsearch'}."\t".$timeval{'preoutput'}."\t".$timeval{'postoutput'} ;
		print ANALLOG "\t".$hostlog."\t".$portlog."\t".$xlang."\t".$xmethod."\t".$xsection."\t".$FORM{"selectionurls"}."\t".$xlastmod."\t".$begin."\t".$lengthOutput."\n";
		close(ANALLOG);
	}
}

sub dologging {
}

sub fulllogging {
}

sub makeDBchanges {
	&$sub_loadFragments("/RSCentral/SearchScripts/general.html") ;
	$doMods = &$sub_output($MODIFICATIONS) ;
}



1;
