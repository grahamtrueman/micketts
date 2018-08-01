#!/bin/perl

sub logging {
	$hostname = $ENV{"REMOTE_HOST"} || $ENV{"REMOTE_ADDR"} || $ENV{'SERVER_NAME'} || $ENV{'HTTP_HOST'};
	if ( !$hostname ) { $hostname=`hostname`; chomp $hostname }
	my($logfile) = $_[0] ;

	@time = localtime(time);
	my($date) = "" ;
	if ($time[2] < 10) {$date .= "0" ;}
	$date .= $time[2].":";
	if ($time[1] < 10) {$date .= "0" ;}
	$date .= $time[1].":";
	if ($time[0] < 10) {$date .= "0" ;}
	$date .= $time[0];
	$date = ($time[3])."/".($time[4]+1)."/".($time[5]+1900)." ".$date ;

	&$sub_gettime('end');
	open(LOG,">>$logfile") ;
	print LOG $hostname."\t".$date."\t".$_[1]."\t".$timeval{'end'}."\n" ;
	close(LOG) ;
}

1;