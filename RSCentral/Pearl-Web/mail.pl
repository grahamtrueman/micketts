#!/bin/perl

# Connection to mail queue database
$DBS             = 'DBI:mysql:services:db1'              ;
$DBSusername     = 'operations'                          ;
$DBSpassword     = 'itgeek'                              ;

sub sendmail {
#	print "Input @_\n" ;
#	exit ;
	my($recipients,$subject,$from,$message) = @_ ;
#	split('~',$input) ;
	open(MESSGE,"| /usr/lib/sendmail -t") || die "can`t open pipe";
	print MESSGE "To: ".$recipients."\n" ;
	print MESSGE "From: ".($from||"postmaster\@magus.co.uk")."\n" ;
	print MESSGE "Subject: ".$subject."\n\n" ;
	print MESSGE $message."\n\n\n" ;
	close(MESSGE) ;
}

sub sendmailHTML {
	my($recipients,$subject,$from,$message) = @_ ;
	open(MESSGE,"| /usr/lib/sendmail -t") || die "can`t open pipe";
	print MESSGE "To: ".$recipients."\n" ;
	print MESSGE "From: ".($from||"postmaster\@magus.co.uk")."\n" ;
	print MESSGE "Content-type: text/html\n" ;
	print MESSGE "Subject: ".$subject."\n\n" ;
	print MESSGE $message."\n\n\n" ;
	close(MESSGE) ;
}

sub sendmailHTMLUTF8 {
	my($recipients,$subject,$from,$message) = @_ ;
	open(MESSGE,"| /usr/lib/sendmail -t") || die "can`t open pipe";
	print MESSGE "To: ".$recipients."\n" ;
	print MESSGE "From: ".($from||"postmaster\@magus.co.uk")."\n" ;
	print MESSGE "Content-type: text/html; charset=UTF-8\n" ;
	print MESSGE "Subject: ".$subject."\n\n" ;
	print MESSGE $message."\n\n\n" ;
	close(MESSGE) ;
}

sub queuemail {
	my($recipients,$subject,$from,$message,$reqAp) = @_ ;
	$dbh = DBI      -> connect($DBS,$DBSusername,$DBSpassword) ;
	$SQL = '
		INSERT INTO emailQueue
			(recipients, sender, subject, body, mimetype, requestingAp, dateTime)
		values
			("'.&safeSQL($recipients).'", "'.((&safeSQL($from))||"postmaster\@magus.co.uk").'", "'.$subject.'", "'.&safeSQL($message).'", "TEXT", "'.(&safeSQL($reqAp) || 'Magus Intranet').'", NOW() )	
	' ;
	# print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n".$SQL."\n ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" ;
	$sth = $dbh         -> prepare($SQL)  ;
	$sth                -> execute ;
	my($insertId) = $sth -> {mysql_insertid} ; 
	$sth                -> finish();
	return $insertId ;
	$dbh  -> disconnect();
}

sub queuemailHTML {
	my($recipients,$subject,$from,$message) = @_ ;
	$dbh = DBI      -> connect($DBS,$DBSusername,$DBSpassword) ;
	$SQL = '
		INSERT INTO emailQueue
			(recipients, sender, subject, body, mimetype, requestingAp, dateTime)
		values
			("'.&safeSQL($recipients).'", "'.((&safeSQL($from))||"postmaster\@magus.co.uk").'", "'.$subject.'", "'.&safeSQL($message).'", "HTML", "PearlWebMailer", NOW() )	
	' ;
	# print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n".$SQL."\n ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n" ;
	$sth = $dbh         -> prepare($SQL)  ;
	$sth                -> execute ;
	my($insertId) = $sth -> {mysql_insertid} ; 
	$sth                -> finish();
	return $insertId ;
	$dbh  -> disconnect();
}

sub safeSQL {
	my($in) = $_[0] ;
	$in =~ s/\"/"\\\""/eigs ;
	$in =~ s/\'/"\\\'"/eigs ;
	return $in ;
}

1;

