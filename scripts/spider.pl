#!/bin/perl

use HTTP::Request::Common qw(GET);
use LWP::UserAgent;

$page = "http://www.shephard.co.uk/Rotorhub/" ;      # Starting URL goes here  #
$match = "Rotorhub/Default.aspx" ;                   # Match pattern goes here #
$line = "http://www.shephard.co.uk/"  ;              # Default URL goes here   #

$ua = new LWP::UserAgent;

my $req = GET $page;

my $data = $ua->request($req)->as_string;

print "Content-type:text/html\n\n" ;

@lines = split(/ /,$data);

print "Processing:<b>  ", $page, "<\/b><p>\n" ;

$count = 0 ;

foreach $nline (@lines) {
        $_ = $nline ;
        ($up) =/Rotorhub\/Default\.aspx([\d\D]*?)\"/ ;          # Regex Pattern Match her
e  #
        if ($up) { $line = $match . $up ;
        print "<A HREF = \"http:\/\/www.shephard.co.uk/$line\">LINK<\/A><p>\n" ; 
        }
   print OUT $_ . "STOP!!\n";
$count++ 
}
close(OUT);

