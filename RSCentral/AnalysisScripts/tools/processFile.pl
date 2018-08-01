#!/bin/perl

@time = localtime((time - 2 * 60 * 60));
$blank = " " ;
$date = ($time[5]+1900)."_".($time[4]+1)."_".$time[3];
$year = ($time[5]+1900) ;
$month= ($time[4]+1) ;

$file     = $ARGV[0] ;
$company  = $ARGV[1] ;


if (!$company || !$file) {
	print "Usage:\n\n" ;
	print "  ./processLogs.pl  {file}  {company}  \n\n" ;
	print "This script processes a single analysis.log file into its daily breakdown files.\n" ;
	print "The processed file is then renamed to {file}_backup.\n" ;
	exit ;
}

#print $date."\n" ;

&process     ;
exit;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Sub-routines
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub process {
	open(LINES, "cat $file | ") || print "Cannot execute" ;
	while (<LINES>) {
		chomp ;
		$thisday = $thismonth = $thisyear = "" ;
		($thisday,$thismonth,$thisyear) = /^.*?([\d]*)\/([\d]*)\/([\d]*)/ ;
		if ( !$thisday || !$thismonth | !$thisyear ) { next }
		print "~~~".$thisyear."~~~".$thismonth."~~~".$thisday."~~~\n" ;
		if (! -e "/export/$company/dblog/analysis" ) {
			system("mkdir /export/$company/dblog/analysis");
		}
		if (! -e "/export/$company/dblog/analysis/$thisyear" ) {
			system("mkdir /export/$company/dblog/analysis/$thisyear");
		}
		if (! -e "/export/$company/dblog/analysis/$thisyear/$thismonth" ) {
			system("mkdir /export/$company/dblog/analysis/$thisyear/$thismonth");
		}
		open(OUT,">>/export/$company/dblog/analysis/".$thisyear."/".$thismonth."/".$thisyear."_".$thismonth."_".$thisday.".log") ;
		print OUT $_."\n" ;
		close(OUT);
	}
	#system("mv $file $file_backup") ;
}

