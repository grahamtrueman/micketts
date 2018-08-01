#!/usr/bin/perl

require('/RSCentral/AnalysisScripts/analysisConfig.pl') ;

@time = localtime((time - 2 * 60 * 60));
$blank = " " ;
$date = ($time[5]+1900)."_".($time[4]+1)."_".$time[3];
$day  = $time[3] ;
$year = ($time[5]+1900) ;
$month= ($time[4]+1) ;

$todo           = $ARGV[0];
$allorthismonth = $ARGV[1];

if (!$todo || ($allorthismonth ne "all" && $allorthismonth ne "this" && $allorthismonth !~ /[\d]{6}/ ) ) {
	print "Usage:\n\n" ;
	print "  ./countAll.pl  company  type\n\n" ;
	print "company = export directory name or \"all\" for all companies\n" ;
	print "type    = \"all\" for all months data or \"this\" for this month \n" ;
	print "          or {yyyymm} for year yyyy and month mm  \n\n" ;
	exit ;
}

$dblog      = "/export/".$todo."/dblog";
$outdir     = $dblog."/analysis";
#$inputFile  = $dblog."/".$filename ;
#$debug      = $dblog."/analysis/".$filename."_debug" ;

# cat /export/Shell/dblog/analysis/2004/7/2004_7_25.log | egrep -v '(216.76.210.230)|(217.85.119.97)' | wc -l

$exclude = "egrep -v '(".join(")|(",@excludemach).")'" ;
#print "~~~~>".$exclude."<~~~~\n\n" ;

if ($allorthismonth eq "all" ) {
	$lscommand = "ls -1d $outdir/*/*" ;
} elsif ($allorthismonth eq "this" ) {
	$lscommand = "ls -1d $outdir/$year/$month" ;
} elsif ($allorthismonth =~ /^[\d]{6}$/ ) {
	$_ = $allorthismonth  ;
	($yyyy,$mm) = /^([\d]{4})([\d]{2})$/ ;
	$lscommand = "ls -1d $outdir/$yyyy/".($mm*1) ;
} else {
	exit ;
}

open(LS, "$lscommand |") ;
while (<LS>) {
	chomp ;
	$line = $_ ;
	if ($line !~ /prefer/) {
		# touching if the first day of the month
		if ($day < 1.5 && ($line =~ /$year\/$month/) ) {
			system("touch $line/blank.log");
		}
		# remove if the second!
		if ($day > 1.5 && $day < 2.5 && ($line =~ /$year\/$month/) ) {
			system("rm -rf $line/blank.log");
		}
		#print "Removing file: $line/count \n" ;
		system("rm -rf $line/count ") ;
		#print "Counting $line\nFiles:\n" ;
		open(FILES, "ls -1 $line/*.log |") ;
		while (<FILES>) {
			chomp;
			my($thisfile) = $_ ;
			#print $thisfile."\n" ;
			system("cat $thisfile | $exclude | wc -l | xargs -I {} echo '   {}  $thisfile' >> $line/count ") ;
		}
		close(FILES) ;
		system("cat $line/*.log | $exclude | wc -l | xargs -I {} echo '   {}  total' >> $line/count ") ;
		
		#print "wc -l $line/*.log > $line/count\n\n";
		#system("wc -l $line/*.log > $line/count");
	}
}
close(LS) ;


# cat 2004_7_15.log | grep -v '193.131.98' | wc -l | xargs -I {} echo '   {} 2004_7_15.log'
