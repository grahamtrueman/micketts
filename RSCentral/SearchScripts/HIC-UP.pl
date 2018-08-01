#!/usr/bin/perl -w

$recipients='graham@micketts.co.uk' ;
#$recipients='graham.trueman@magus.co.uk' ;

use Time::HiRes qw(gettimeofday sleep);
@startTime = gettimeofday;                           

use Fcntl ;

#Open a logging file...
open(LOG,">>/RSCentral/Logs/log_HIC-UP")|| print "cannot open /RSCentral/Logs/log_HIC-UP\n";

# Print write a temporary file to prevent new jobs from executing...
if (-e "/RSCentral/SearchScripts/working-ExaminingSearchServers") {
	print "A previous Examination job is running, quitting now\n" ;
	$datenow =`date`;
	chop $datenow;
	print LOG $datenow."    job is in progress - quitting\n" ;
	print LOG "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" ;
	exit ;
} else {
	open(WRITETMP,">/RSCentral/SearchScripts/working-ExaminingSearchServers")|| print "cannot open /RSCentral/SearchScripts/working-ExaminingSearchServers\n";
	$datenow =`date`;
	chop $datenow;
	print WRITETMP "Job started at $datenow\n" ;
	close(WRITETMP) ;
}

$IHfile       = "/RSCentral/IndexHosts" ;
$ServersDown  = "/RSCentral/ServersDown" ;
&readIHfile ;
&readServersDown ;

$numberOfIndexes ;
foreach $combmod (sort alphasort keys %combined) {
	foreach $indexname (keys %info) {
		if ($info{$indexname} eq $combined{$combmod}) {
			$numberOfIndexes++ ;
#			print "Going to check... ".$indexname{$indexname}{$combmod}." ".$host1{$indexname}{$combmod}." ".$port1{$indexname}{$combmod}." ".$host2{$indexname}{$combmod}." ".$port2{$indexname}{$combmod}." ".$preload{$indexname}{$combmod}."\n" ;
			# calculate outputfile from unique timestamp
			$outfile = gettimeofday ;
			$CHECKED{$indexname}{$combmod} = "" ; 
			$outputfile{$indexname}{$combmod} = "/RSCentral/Logs/errors/".$outfile ;
			system("/RSCentral/SearchScripts/DoSearchNow.pl   $indexname{$indexname}{$combmod}   $host1{$indexname}{$combmod} $port1{$indexname}{$combmod}   >   $outputfile{$indexname}{$combmod}  &") ;
#			print "/RSCentral/SearchScripts/DoSearchNow.pl   $indexname{$indexname}{$combmod}   $host1{$indexname}{$combmod} $port1{$indexname}{$combmod}   >   $outputfile{$indexname}{$combmod}  &  \n\n" ;
		}
	}
}

print "All jobs started, waiting to start collection...\n" ;
sleep 4 ;

print "Now Searching for results...\n" ;
$timeOK = 10 ;
while ($numberOfIndexes && $timeOK < 30) {
	sleep 1 ;
	$cycle++ ;
	print "     ~~~~~ Cycle=".$cycle." ~~~~~\n" ;
	foreach $combmod (sort alphasort keys %combined) {
		foreach $indexname (keys %info) {
			if ( ( $CHECKED{$indexname}{$combmod} )  ) { next ; }
			$xx = "" ;
			open(TEST, "$outputfile{$indexname}{$combmod}") || '';
			while(<TEST>){
				$xx = join('',<TEST>);
			}
			if ( ( $xx =~ /NResults\:/ )  ){
				print "Index... ".$indexname{$indexname}{$combmod}." on ".$host1{$indexname}{$combmod}." ".$port1{$indexname}{$combmod}." is OK \n" ;
				$datenow =`date`;
				chop $datenow;
#				print LOG $datenow."\tIndex... ".$indexname{$indexname}{$combmod}." on ".$host1{$indexname}{$combmod}." ".$port1{$indexname}{$combmod}." is OK \n" ;
				$numberOfIndexes-- ;
				$CHECKED{$indexname}{$combmod} = "Yes" ;
				$indexname{$indexname}{$combmod} = "" ;
#				system("rm -rf $outputfile{$indexname}{$combmod}") ;
			} elsif ( $xx =~ /The\ssearch\sis\sdown\stemporarily/ ) {
				$CHECKED{$indexname}{$combmod} = "Yes" ;
				$numberOfIndexes-- ;
			}
		}
	}
	@finishTime = gettimeofday;                                                                                                  
	for ($finishTime[1], $startTime[1]) { $_ /= 1_000_000 }                          
	$duration = ($finishTime[0]-$startTime[0])+($finishTime[1]-$startTime[1]) ;         
	$timeOK = int($duration*10000)/10000;
}

foreach $combmod (sort alphasort keys %combined) {
	foreach $indexname (keys %info) {
		if ( $indexname{$indexname}{$combmod} ) {
			$host = $host1{$indexname}{$combmod} ;
			$port = $port1{$indexname}{$combmod} ;
			print "Index... ".$indexname{$indexname}{$combmod}." on ".$host." ".$port." is NOT WORKING \n" ;
			$datenow =`date`;
			chop $datenow;
			print LOG $datenow."\tIndex... ".$indexname{$indexname}{$combmod}." on ".$host." ".$port." is NOT WORKING \n" ;
			$Failed{$host.'-'.$port} = "yes" ;
		}
	}
}

# check for each failed box
foreach $failed (keys %Failed) {
	$_ = $failed ;
	($host,$port) = /(.*)\-(.*)/ ;
	$Down{$host.'-'.$port}++ ;
	print "*** Ticking ".$host." ".$port." up 1 failure to ".$Down{$host.'-'.$port}."\n" ;
	print LOG "*** Ticking ".$host." ".$port." up 1 failure to ".$Down{$host.'-'.$port}."\n" ;
	if ( ( $Down{$host.'-'.$port} >= 2.5 ) && ( $Down{$host.'-'.$port} <= 3.5 ) ) {
		print "Send e:mail notification\n" ;
		
		open(EMAIL,"| /usr/lib/sendmail -t") || die "can`t open mail pipe";
		print EMAIL "To: $recipients\n" ;
		print EMAIL "From: HIC-UP <support\@magus.co.uk>\n" ;
		print EMAIL "Reply-To: support\@magus.co.uk\n" ;
		print EMAIL "Subject: HIC-UP: ".$host." (".$port.") has delivered 3 failed searches\n\n" ;
		print EMAIL "\nThree consecutive errors have occurred whilst testing ".$host." (".$port.").\n";
		print EMAIL "Using backup host and port from now on... (until further notice).\n\n";
		print EMAIL "    HIC-UP: Hendrix Index Checker for UP time\n";
		print EMAIL "    ================== x x ==================\n";
	}
}
		
# Check for boxes that are back up
open(DOWN,">$ServersDown") || '';
foreach $down (keys %Down) {
	$_ = $down ;
	($host,$port) = /(.*)\-(.*)/ ;
	if ( ($Down{$host.'-'.$port} > 3) && (!$Failed{$host.'-'.$port})) {
		print "Send e:mail recovery\n" ;
		$datenow =`date`;
		chop $datenow;
		print LOG $datenow."\tSend e:mail recovery: $down recovered\n" ;

		open(EMAIL,"| /usr/lib/sendmail -t") || die "can`t open mail pipe";
		print EMAIL "To: $recipients\n" ;
		print EMAIL "From: HIC-UP <support\@magus.co.uk>\n" ;
		print EMAIL "Reply-To: support\@magus.co.uk\n" ;
		print EMAIL "Subject: HIC-UP: The host ".$host." (".$port.") has recovered\n\n" ;
		print EMAIL "\nAn error was previously reported on ".$host." (".$port.").\n\n";
		print EMAIL "This error was not reproduced during the last Search Server Check.  This could mean that the box is back up and running as normal - or that ".$host." (".$port.") has been removed from the IndexHosts File\n\nPlease get a member of the RSTeam to confirm\n\n";
		print EMAIL "    HIC-UP: Hendrix Index Checker for UP time\n";
		print EMAIL "    ================== x x ==================\n";
	}
	if ( $Down{$down} && $Failed{$down} ) {
		print DOWN $host."\t".$port."\t".$Down{$host.'-'.$port}."\n" ;
	}
}
close (DOWN) ;

$datenow =`date`;
chop $datenow;
print LOG $datenow."\tFinished checking\n" ;
print LOG "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" ;
close(LOG) ;

system("rm -rf /RSCentral/SearchScripts/working-ExaminingSearchServers") ;
system("rm -rf /RSCentral/Logs/errors/*") ;

#~~~~~~~~~~~~S U B S~~~~~~~~~~~~~~~~~~

sub readServersDown {
	if (-e "$ServersDown" ) {
		open(DOWN, $ServersDown) || return;
		while(<DOWN>){
			chomp;
			if (!$_) { next;}
			($host,$port,$failures) = split(/\t/,$_) ;
			$Down{$host.'-'.$port} = $failures ;
		}
	}
}

sub readIHfile {
	sysopen(IndexHosts, $IHfile, O_RDONLY) ;
	my @index = <IndexHosts> ;
	close(IndexHosts) ;
	
	for ($i = 0 ; $i <= $#index ; $i++) {
		@array = "";
		@array = split(/\t/,$index[$i]) ;
		$indexname = $array[0] ;
		$host1 = $array[1] ;
		$port1 = $array[2];
		$host2 = $array[3];
		$port2 = $array[4];
		$preload = $array[5];
		chomp $indexname ;
		chomp $host1 ;
		chomp $port1 ;
		chomp $host2 ;
		chomp $port2 ;
		chomp $preload ;
		
	#	print "~~~".$indexname."~~~<br>\n" ;
		if (!$indexname || !$host1 || !$port1 || ( $indexname =~ /^\#/ )  ) { next ; }
		
		$combined = $host1." &nbsp; (port ".$port1.")" ;
		$combmod = $combined ;
		$combmod =~ s/rs([0-9])\s/'rs0'.$1.' '/eigs ;
	#	print $combmod."<br>\n" ;
		$combined{$combmod} = $combined ;
		
	#	$hostTitle{$combmod} = $host1 ;
	#	$portTitle{$combmod} = $port1 ;
		
		$indexname{$indexname}{$combmod} = $indexname;
		$host1{$indexname}{$combmod} = $host1 ;
		$port1{$indexname}{$combmod} = $port1 ;
		$host2{$indexname}{$combmod} = $host2 ;
		$port2{$indexname}{$combmod} = $port2 ;
		$preload{$indexname}{$combmod} = $preload ;
	
		$info{$indexname} = $combined{$combmod};
	}
}

sub alphasort
	{ $a cmp $b ; }
