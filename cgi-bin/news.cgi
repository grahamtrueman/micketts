#!/bin/perl


require("/RSCentral/Pearl-Web/library.pl") ;

&initialise_pw;

$HTMLdir        = '/export/test/static/HTML/'             ;

$DB             = 'DBI:mysql:www'           ;
$DBusername     = 'root'                         ;
$DBpassword     = '123456'                             ;

$DEBUGlevel     = 0                                    ;


print "content-type: text/html\n\n" ;

&$sub_read_input ;
&$sub_loadFragments($HTMLdir.'news.html')              ;   #   get starting fragments
&$sub_read_input                                       ;   #   read input parameters

&$sub_write_output ;

