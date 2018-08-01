#!/usr/bin/perl -w

require('/RSCentral/Pearl-Web/library.pl') ;

use Time::HiRes qw(gettimeofday sleep);

$DB             = 'DBI:mysql:remotesearch:db1'          ;
$DBusername     = 'remotesearch'                        ;
$DBpassword     = 'findforme'                           ;

@startTime = gettimeofday;                           

$dbh = DBI      -> connect($DB,$DBusername,$DBpassword) ;

$cont = 1 ;

while ($cont>0.5) {
	@line = "" ;
	@line = &getDB('triggers', 'id, hostname, name, script, email, datestamp' ,'status=0') ;
	if ($line[0]) {
#		print "---|@line|---\n" ;
		$timenow = time ;
		$command = $line[3]." >/RSCentral/Logs/trigger.log 2>&1" ;
#		print "$command\n" ;
		
		# Before executing: switch status to 1 to prevent subsequent jobs from executing
		&update('triggers' , 'status=1' , 'id='.$line[0] ) ;
		
		system($command) ;
		if ($line[4]) {
			$mailbody="\nThe triggered task '".$line[2]."' has completed:\n\n" ;
			$mailbody.="Completed at: ".&displayDate(time)." ".&displayTime(time) ;
			&sendmail($line[4],$line[2].": task completed","Magus Research Admin <searchadmin\@magus.co.uk>",$mailbody) ;
		}
	} else {
		$cont=0;
	}
}
#print "Done...\n" ;
$dbh  -> disconnect();
exit ;


# +------------------------------------------------------------------------+
# |          S  U  B  R  O  U  T  I  N  E  S                               |
# +------------------------------------------------------------------------+

sub getDB {
	my(@in) = @_ ;
	$cc++ ;	
	$SQL = "SELECT ".$in[1]." FROM ".$in[0]." WHERE ".$in[2] ;
#	print $SQL."\n" ;
	$sth = $dbh         -> prepare($SQL)  ;
	$sth                -> execute || print $SQL;
	my(@data) = $sth -> fetchrow_array();
	$sth                -> finish();
	return @data ;
}

sub insert {
	my(@in) = @_ ;
	$cc++ ;	
	$SQL = "INSERT INTO ".$in[0]." (".$in[1].") VALUES(".$in[2].")" ;
#	print $SQL."\n" ;
	$sth = $dbh         -> prepare($SQL)  ;
	$sth                -> execute ;
	my($insertId) = $sth -> {mysql_insertid} ; 
	$sth                -> finish();
	return $insertId ;
}

sub update {
	my(@in) = @_ ;
	$cc++ ;	
	$SQL = "UPDATE ".$in[0]." SET ".$in[1]." WHERE ".$in[2] ;
#	print $SQL."\n" ;
	$sth = $dbh         -> prepare($SQL)  ;
	$sth                -> execute ;
	$sth                -> finish();
}

sub del {
	my(@in) = @_ ;
	$cc++ ;	
	$SQL = "DELETE FROM ".$in[0]." WHERE ".$in[1] ;
#	print $SQL."\n" ;
	$sth = $dbh         -> prepare($SQL)  ;
	$sth                -> execute ;
	$sth                -> finish();
}

sub sendmail {
#	print "Input @_\n" ;
#	exit ;
	my($recipients,$subject,$from,$message) = @_ ;
#	print "Recipient: ".$recipients."\n" ;
#	print "From: ".$from."\n" ;
#	print "Subject: ".$subject."\n" ;
#	print "Message: ".$message."\n" ;

	open(MESSGE,"| /usr/lib/sendmail -t") || die "can`t open pipe";
	print MESSGE "To: ".$recipients."\n" ;
	print MESSGE "From: ".$from."\n" ;
	print MESSGE "Subject: ".$subject."\n\n" ;
	print MESSGE $message."\n\n\n" ;
	close(MESSGE) ;
}

