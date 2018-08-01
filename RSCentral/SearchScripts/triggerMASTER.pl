#!/usr/bin/perl -u

print "content-type: text\/html\n\n"                    ;
	
use DBI                                                 ;
use Time::HiRes qw(gettimeofday sleep)                  ;
require "timelocal.pl"                                  ;

@startTime = gettimeofday                               ;

require('/RSCentral/Pearl-Web/library.pl')              ;

$HTMLdir        = '/RSCentral/SearchScripts/'           ;
$RunName        = 'trigger'                             ;
$DB             = 'DBI:mysql:remotesearch:db1'          ;
$DBusername     = 'remotesearch'                        ;
$DBpassword     = 'findforme'                           ;

$hostname       = $ENV{'REMOTE_ADDR'}                   ;
$space          = " "                                   ;

&$sub_read_input                                        ; # read input parameters

$email = $FORM{'action'}                                ;

sub executeTrigger {

	&$sub_loadFragments($HTMLdir.'trigger.html')        ;   #   get starting fragments
	if ($localformat) {
		&$sub_loadFragments($localformat)               ;   #   get local fragments
	}
	
	&$sub_write_output                                  ;
	
	print "\n\n<!--".$lengthOutput." bytes generated in ".$timeval{'postoutput'}." seconds using ".($SQLcounttotal*1)." database calls-->\n\n\n"                                ;

}

1;

