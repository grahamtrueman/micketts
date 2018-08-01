#!/bin/perl

@time = localtime((time - 6 * 60 * 60));
$blank = " " ;
$date = ($time[5]+1900)."_".($time[4]+1)."_".$time[3];
$year = ($time[5]+1900) ;
$month= ($time[4]+1) ;
print $date."\n" ;

@time = localtime(time);
$timestamp = "";
if ($time[2] < 10) { $timestamp .= "0" ; }
$timestamp .= $time[2].":" ;
if ($time[1] < 10) { $timestamp .= "0" ; }
$timestamp .= $time[1];

#if ( (($time[2] == 0) && ($time[1] < 2)) || (($time[2] == 23) && ($time[1] > 58)) ) {
#	print "The time is good.  Archiving old analysis.log files\n" ;
#} else {
#	print "This file must be executed between 23:59 and 00:02.  Time=".$timestamp."\n" ;
#	exit ;
#}

&moveall     ;
#&countall    ;

exit;


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Sub-routines
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


sub moveall {
	open(LIST, "ls -1 /export/*/dblog/analysis.log | ") || print "Cannot execute" ;
	while (<LIST>) {
		chomp $_ ;
		($company) = /\/export\/(.*?)\/dblog\/analysis\.log/ ;
		if (-e "/export/$company/dblog/analysis" ) {
		} else {
			system("mkdir /export/$company/dblog/analysis");
		}
		if (-e "/export/$company/dblog/analysis/$year" ) {
		} else {
			system("mkdir /export/$company/dblog/analysis/$year");
		}
		if (-e "/export/$company/dblog/analysis/$year/$month" ) {
		} else {
			system("mkdir /export/$company/dblog/analysis/$year/$month");
		}

		#grep out all previous days and archive
		system ("cp /export/$company/dblog/analysis.log /export/$company/dblog/analysis.log_majorBU") ;
		system ("grep '1\/8\/2003' /export/$company/dblog/analysis.log > /export/$company/dblog/analysis/$year/$month/2003_8_1.log");
		system ("grep '2\/8\/2003' /export/$company/dblog/analysis.log > /export/$company/dblog/analysis/$year/$month/2003_8_2.log");
		system ("grep '3\/8\/2003' /export/$company/dblog/analysis.log > /export/$company/dblog/analysis/$year/$month/2003_8_3.log");
		system ("grep '4\/8\/2003' /export/$company/dblog/analysis.log > /export/$company/dblog/TEMP_shift") ;
		system ("mv /export/$company/dblog/TEMP_shift /export/$company/dblog/analysis.log") ;
		
	}
	close(LIST) ;
}

sub countall {
	open(COUNT, "ls -1d /export/*/dblog/analysis | ") || print "Cannot execute" ;
	while (<COUNT>) {
		chomp $_ ;
		($company) = /^\/export\/(.*?)\/dblog\/analysis$/ ;
		print "=================\n" ;
		print "Counting $company\n" ;
		print "=================\n" ;
		system("/RSCentral/AnalysisScripts/countAll.pl $company");
	}
	close(COUNT) ;
}

