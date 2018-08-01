#!/usr/bin/perl -w

###############################################
#                                             #
#      Exitscript required for RS Search      #
#                                             #
###############################################


# Subroutine_names in order of appearance in this script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$sub_execute_exitscript   = "execute_exitscript"           ;


# Subroutines...
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub execute_exitscript {

	if ($subdivisionlogging) {
		$exitlog            = $sdlogdirectory."/"."exit_log"            ;
		$rawexitlog         = $sdlogdirectory."/"."exit_log_raw"        ;
	}

#	print "Content-type: text\/html\n\n";
#	print $ENV{'QUERY_STRING'}."<br>\n";
	$_ = $ENV{'QUERY_STRING'};
	
	my($search,$dest) = /Search=(.*?)\&dest=(.*)$/;
#	print "Search=".$search."~~~<br>\n";
#	print "Dest=".$dest."~~~<br>\n";

	
	$search =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
	$dest =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
	
	$hostname = $ENV{"REMOTE_HOST"} || $ENV{"REMOTE_ADDR"};
	$username = $ENV{"REMOTE_USER"} || "-";
	
	$datenow = `date`;
	chomp $datenow;

	# Check to see if user has visited this page in the last 15 minutes
	$beenhere = "No" ;

	#open(DEBUG,">>$debug");
	$dest1 = $dest ; 
	if (-e $rawexitlog) {
		open(LIST, "tail -200 $rawexitlog | grep '$hostname' | grep '$dest1' |") ;
		while(!eof(LIST)){
			$_ = <LIST> ;
			($linedate) = /.*\[(.*?)\].*/i ;
			$_ = $linedate ;
			($hh,$mm,$ss) = /.*\s(.*?)\:(.*?)\:(.*?)\s.*/i ;
			$_ = $datenow ;
			($hhnow,$mmnow,$ssnow) = /.*\s(.*?)\:(.*?)\:(.*?)\s.*/i ;
			$nowtime = (($hhnow * 60 + $mmnow) * 60) + $ssnow ;
			$linetime = (($hh * 60 + $mm) * 60) + $ss ;
			if ($nowtime < $linetime) {
				$nowtime = $nowtime + 86400 ;
			}
			if (($linetime + $visit * 60) > $nowtime) {
#				print DEBUG "[$hostname] HAS VISITED [$dest] before - do NOT write log\n" ;
				$beenhere = "Yes" ;
			} else {
#				print DEBUG "[$hostname] has NOT visited [$dest] before - WRITE log\n" ;
			}
		}
	}
	close(DEBUG);
	
	if ($beenhere eq "No") {
		$dest1 =~ s/http:\/\/.*?\/cgi-bin\/.*?frameset.cgi\?start\=//g ;
		if ($exitlog) {
			open(EL,">>$exitlog");
			print EL "$hostname $username [$datenow] \"$dest1\" {$search}\n";
			close(EL);
		}
		if ($rawexitlog) {
			open(REL,">>$rawexitlog");
			print REL "$hostname $username [$datenow] \"$dest1\" {$search}\n";
			close(REL);
		}
	}
	
	#print "Content-type: text\/html\n\n";
	print "Location: $dest\n\n";
}

1;


