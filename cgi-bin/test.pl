#!/bin/perl


require("/RSCentral/Pearl-Web/library.pl") ;

&initialise_pw;

$HTMLdir        = '/export/micketts/static/HTML/'             ;

$DB             = 'DBI:mysql:www'           ;
$DBusername     = 'root'                         ;
$DBpassword     = '123456'                             ;

$DEBUGlevel     = 7                                    ;


print "content-type: text/html\n\n" ;

&$sub_read_input ;
read(STDIN,$input,$ENV{CONTENT_LENGTH}) ;
&$sub_loadFragments($HTMLdir.'test.html')              ;   #   get starting fragments
&$sub_read_input                                       ;   #   read input parameters

&$sub_write_output ;

