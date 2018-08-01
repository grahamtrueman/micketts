#!/usr/bin/perl -w

require('/RSCentral/Pearl-Web/library.pl') ;

use Time::HiRes qw(gettimeofday sleep);

$DB             = 'DBI:mysql:remotesearch:db1'          ;
$DBusername     = 'remotesearch'                        ;
$DBpassword     = 'findforme'                           ;

@startTime = gettimeofday;                           

if ( $ARGV[0] !~ /(daily)|(weekly)|(monthly)/i ) {
	print "Usage\n\n   Emailer.pl {type}\n\nwhere {type} is {daily|weekly|monthly}\n\n" ;
	exit ;
}
$thisCompany=$ARGV[0] ;

my(@data) ;
$cc++ ;	
$SQL =	"SELECT ".
		"E.monthly,E.weekly,E.daily,E.email,S.subdivision,C.client".
		" FROM "."emailers AS E, subdivisions AS S, clients AS C".
		" WHERE "."C.id=S.client AND S.id=E.subdivision" ;
print $SQL."\n" ;
$dbh_loop = DBI      -> connect($DB,$DBusername,$DBpassword) ;
$sth_loop = $dbh_loop         -> prepare($SQL)  ;
$sth_loop                -> execute || print $SQL;
while (@data = $sth_loop -> fetchrow_array()) {
	print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n@data\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
	
	
	
	
}
$sth_loop  -> finish();
$dbh_loop  -> disconnect();
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

