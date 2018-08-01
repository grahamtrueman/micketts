#!/usr/bin/perl -w

require "timelocal.pl" ;

$SIG{TERM} = 'IGNORE';
$SIG{PIPE} = 'IGNORE';

use sigtrap;
use Socket;
use Time::HiRes qw(gettimeofday sleep);
@startTime = gettimeofday;                           

if (!$ARGV[0] && !$ARGV[1] && !$ARGV[2] ) {
	print "usage:\n\n   ./DoSearchNow.pl  Index  Host  Port\n\n" ;
	exit ;
}

print "About to start Search...\n" ;
$indexname = $ARGV[0]  ;
$host      = $ARGV[1]  ;
$port      = $ARGV[2]  ;

$_ = $indexname ;
($term) = /^.*\/([^\.\/]*)\.ss.?$/ ;

print "Term = ".$term."\n" ;

$paddr = sockaddr_in($port,inet_aton($host));
$proto = getprotobyname('tcp');
socket(SOCK,PF_INET,SOCK_STREAM,$proto) || &$sub_searchdown; # &html_error1("socket: $!"); 
connect(SOCK,$paddr) || connect(SOCK,$paddr1) || &$sub_searchdown; # &html_error1("connect: $!");

print SOCK "Search 0 5 $indexname $term\n";
select SOCK;
$| = 1;
while(<SOCK>){
	print STDOUT $_;
}
close(SOCK);
select STDOUT;

exit;


