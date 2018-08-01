#!/bin/perl

require "timelocal.pl" ;
require "/RSCentral/Pearl-Web/library.pl" ;

# Read $TEMPLATE from the $formatfile given in the local set up file.
&$sub_loadFragments($formatfile) ;

# Read the default structures of the HTML blocks
$formatfile = "/RSCentral/AnalysisScripts/analysis.html" ;
&$sub_loadFragments($formatfile) ;

# Read any local variations
$formatfile = $localformatfile ;
&$sub_loadFragments($formatfile) ;

@excludemach = (
	'193.131.98.'      ,
	'193.195.79.81'      ,
	'193.195.79.82'      ,
	'193.195.79.83'      ,
	'193.195.79.84'      ,
	'82.69.15.203'     ,
	'194.112.48.220'   ,
	'194.112.44.51'    ,
	'82.69.0.68'       ,
	'212.135.200.224'  ,
	'217.155.33.181'   ,
	'195.44.1.1'       ,
	'212.23.31.237'    ,
	'62.3.64.138'      ,
	'62.3.70.70'       ,
	'217.169.5.151'    ,
	'62.3.69.40'       ,
	'217.155.34.32'    ,
	'217.155.32.174'   ,
	'193.128.255.228'  ,
	'217.155.36.125'   ,
	'82.68.122.160'    ,
	'82.68.122.161'    ,
	'82.68.122.162'    ,
	'82.68.122.163'    ,
	'82.68.122.164'    ,
	'82.68.122.165'    ,
	'82.68.122.166'    ,
	'82.68.122.167'    ,
	'82.68.66.80'      ,
	'82.69.22.79'      ,
	'82.69.29.6'       ,
	'82.69.3.206'      ,
	'82.69.5.157'      ,
	'81.6.215.105'     ,
	'82.68.82.48'      ,
	'82.68.116.104'    ,
	'62.49.143.35'     ,
	'82.69.41.35'   
);

# month lookup
$month1 = "Jan" ;
$month2 = "Feb" ;
$month3 = "Mar" ;
$month4 = "Apr" ;
$month5 = "May" ;
$month6 = "Jun" ;
$month7 = "Jul" ;
$month8 = "Aug" ;
$month9 = "Sep" ;
$month10 = "Oct" ;
$month11 = "Nov" ;
$month12 = "Dec" ;

$monthEN1 = "Jan" ;
$monthEN2 = "Feb" ;
$monthEN3 = "Mar" ;
$monthEN4 = "Apr" ;
$monthEN5 = "May" ;
$monthEN6 = "Jun" ;
$monthEN7 = "Jul" ;
$monthEN8 = "Aug" ;
$monthEN9 = "Sep" ;
$monthEN10 = "Oct" ;
$monthEN11 = "Nov" ;
$monthEN12 = "Dec" ;

$monthFR1 = "Jan" ;
$monthFR2 = "F&eacute;v" ;
$monthFR3 = "Mar" ;
$monthFR4 = "Avr" ;
$monthFR5 = "Mai" ;
$monthFR6 = "Jun" ;
$monthFR7 = "Jul" ;
$monthFR8 = "A&ocirc;u" ;
$monthFR9 = "Sep" ;
$monthFR10 = "Oct" ;
$monthFR11 = "Nov" ;
$monthFR12 = "D&eacute;c" ;


$monthNO{'Jan'} = 1 ;
$monthNO{'Feb'} = 2 ;
$monthNO{'Mar'} = 3 ;
$monthNO{'Apr'} = 4 ;
$monthNO{'May'} = 5 ;
$monthNO{'Jun'} = 6 ;
$monthNO{'Jul'} = 7 ;
$monthNO{'Aug'} = 8 ;
$monthNO{'Sep'} = 9 ;
$monthNO{'Oct'} = 10 ;
$monthNO{'Nov'} = 11 ;
$monthNO{'Dec'} = 12 ;

$weekdayEN1 = "M" ;
$weekdayEN2 = "T" ;
$weekdayEN3 = "W" ;
$weekdayEN4 = "T" ;
$weekdayEN5 = "F" ;
$weekdayEN6 = "S" ;
$weekdayEN7 = "S" ;
$weekdayFR1 = "L" ;
$weekdayFR2 = "M" ;
$weekdayFR3 = "M" ;
$weekdayFR4 = "J" ;
$weekdayFR5 = "V" ;
$weekdayFR6 = "S" ;
$weekdayFR7 = "D" ;

$weekdayName1 = "Monday" ;
$weekdayName2 = "Tuesday" ;
$weekdayName3 = "Wednesday" ;
$weekdayName4 = "Thursday" ;
$weekdayName5 = "Friday" ;
$weekdayName6 = "Saturday" ;
$weekdayName7 = "Sunday" ;

@searchmarkers = (
0,    
0.1,
0.2,
0.3,
0.4,
0.5,
0.6,
0.7,
0.8,
0.9,
1.0,
1.1,
1.2,
1.3,
1.4,
1.5,
1.7,
1.9,
2.1,
2.3,
2.5,
3.0,
3.5,
4.0,
5.0,
7.5,
10,
15,
20,
25,
30, 
40,
50,
60,
999
);

$periodVisibility1 = "visible" ;
$periodVisibility2 = "visible" ;
$periodVisibility3 = "hidden" ;
$periodVisibility4 = "hidden" ;
$periodVisibility5 = "hidden" ;

$compareDemark5 = "yes" ;
$compareDemark11 = "yes" ;
$compareDemark17 = "yes" ;
$compareDemark23 = "yes" ;

$blank = " " ;

&gethostname ;

# Set Scales

$scalearray{240}{1000000} = 10 ;
$scalearray{240}{ 800000} = 8  ;
$scalearray{240}{ 750000} = 15  ;
$scalearray{240}{ 600000} = 12  ;
$scalearray{240}{ 500000} = 10 ;
$scalearray{240}{ 400000} = 10  ;
$scalearray{240}{ 320000} = 16  ;
$scalearray{240}{ 300000} = 15  ;
$scalearray{240}{ 250000} = 10 ;
$scalearray{240}{ 240000} = 12 ;
$scalearray{240}{ 200000} = 10 ;
$scalearray{240}{ 160000} = 16 ;
$scalearray{240}{ 150000} = 15 ;
$scalearray{240}{ 120000} = 12 ;
$scalearray{240}{ 100000} = 10 ;
$scalearray{240}{  80000} = 8  ;
$scalearray{240}{  60000} = 12  ;
$scalearray{240}{  50000} = 10  ;
$scalearray{240}{  40000} = 8  ;
$scalearray{240}{  36000} = 12  ;
$scalearray{240}{  32000} = 8  ;
$scalearray{240}{  30000} = 15  ;
$scalearray{240}{  25000} = 10  ;
$scalearray{240}{  24000} = 12  ;
$scalearray{240}{  20000} = 10  ;
$scalearray{240}{  16000} = 16  ;
$scalearray{240}{  15000} = 15  ;
$scalearray{240}{  12000} = 12  ;
$scalearray{240}{  10000} = 10 ;
$scalearray{240}{   9000} = 6  ;
$scalearray{240}{   8000} = 8  ;
$scalearray{240}{   7500} = 15  ;
$scalearray{240}{   6000} = 12  ;
$scalearray{240}{   5000} = 10  ;
$scalearray{240}{   4000} = 8  ;
$scalearray{240}{   3000} = 15  ;
$scalearray{240}{   2500} = 10  ;
$scalearray{240}{   2000} = 10  ;
$scalearray{240}{   1600} = 16  ;
$scalearray{240}{   1500} = 15  ;
$scalearray{240}{   1200} = 12 ;
$scalearray{240}{   1000} = 10 ;
$scalearray{240}{    800} = 16  ;
$scalearray{240}{    600} = 12  ;
$scalearray{240}{    500} = 10  ;
$scalearray{240}{    400} = 10 ;
$scalearray{240}{    300} = 15  ;
$scalearray{240}{    240} = 12  ;
$scalearray{240}{    200} = 10  ;
$scalearray{240}{    150} = 15  ;
$scalearray{240}{    120} = 12 ;
$scalearray{240}{    100} = 10 ;
$scalearray{240}{     80} = 16  ;
$scalearray{240}{     60} = 12  ;
$scalearray{240}{     50} = 10  ;
$scalearray{240}{     40} = 8  ;
$scalearray{240}{     30} = 15  ;
$scalearray{240}{     24} = 12  ;
$scalearray{240}{     20} = 10  ;
$scalearray{240}{     16} = 16 ;
$scalearray{240}{     15} = 15 ;
$scalearray{240}{     12} = 12 ;
$scalearray{240}{     10} = 10 ;
$scalearray{240}{      8} = 8  ;
$scalearray{240}{      6} = 6  ;
$scalearray{240}{      5} = 5  ;
$scalearray{240}{      4} = 4  ;
$scalearray{240}{      3} = 3  ;

$scalearray{360}{1000000} = 10 ;
$scalearray{360}{ 800000} = 8  ;
$scalearray{360}{ 750000} = 15 ;
$scalearray{360}{ 600000} = 12 ;
$scalearray{360}{ 500000} = 10 ;
$scalearray{360}{ 450000} = 9  ;
$scalearray{360}{ 400000} = 10  ;
$scalearray{360}{ 360000} = 18  ;
$scalearray{360}{ 300000} = 12  ;
$scalearray{360}{ 240000} = 12 ;
$scalearray{360}{ 180000} = 18 ;
$scalearray{360}{ 150000} = 15  ;
$scalearray{360}{ 120000} = 12 ;
$scalearray{360}{ 100000} = 10 ;
$scalearray{360}{  80000} = 8  ;
$scalearray{360}{  60000} = 12  ;
$scalearray{360}{  50000} = 10  ;
$scalearray{360}{  45000} = 18  ;
$scalearray{360}{  40000} = 10  ;
$scalearray{360}{  36000} = 18  ;
$scalearray{360}{  30000} = 15  ;
$scalearray{360}{  25000} = 10  ;
$scalearray{360}{  24000} = 12  ;
$scalearray{360}{  18000} = 18  ;
$scalearray{360}{  15000} = 15  ;
$scalearray{360}{  12000} = 12  ;
$scalearray{360}{  10000} = 10 ;
$scalearray{360}{   9000} = 9  ;
$scalearray{360}{   8000} = 8  ;
$scalearray{360}{   7500} = 15  ;
$scalearray{360}{   6000} = 6  ;
$scalearray{360}{   5000} = 10  ;
$scalearray{360}{   4000} = 8  ;
$scalearray{360}{   3000} = 12  ;
$scalearray{360}{   2400} = 12  ;
$scalearray{360}{   1800} = 18  ;
$scalearray{360}{   1500} = 15  ;
$scalearray{360}{   1200} = 12 ;
$scalearray{360}{   1000} = 10 ;
$scalearray{360}{    800} = 8  ;
$scalearray{360}{    600} = 12  ;
$scalearray{360}{    500} = 10  ;
$scalearray{360}{    400} = 8  ;
$scalearray{360}{    300} = 12  ;
$scalearray{360}{    250} = 10  ;
$scalearray{360}{    200} = 10  ;
$scalearray{360}{    180} = 18  ;
$scalearray{360}{    150} = 15  ;
$scalearray{360}{    100} = 10 ;
$scalearray{360}{     90} = 18  ;
$scalearray{360}{     80} = 8  ;
$scalearray{360}{     60} = 12  ;
$scalearray{360}{     50} = 10  ;
$scalearray{360}{     40} = 8  ;
$scalearray{360}{     36} = 18  ;
$scalearray{360}{     30} = 15  ;
$scalearray{360}{     24} = 12  ;
$scalearray{360}{     18} = 18 ;
$scalearray{360}{     15} = 15 ;
$scalearray{360}{     12} = 12 ;
$scalearray{360}{     10} = 10  ;
$scalearray{360}{      8} = 8  ;
$scalearray{360}{      6} = 6  ;
$scalearray{360}{      5} = 5  ;
$scalearray{360}{      4} = 4  ;
$scalearray{360}{      3} = 3  ;

$scalearray{480}{1000000} = 20  ;
$scalearray{480}{ 800000} = 16   ;
$scalearray{480}{ 750000} = 15  ;
$scalearray{480}{ 600000} = 12  ;
$scalearray{480}{ 500000} = 10  ;
$scalearray{480}{ 400000} = 20  ;
$scalearray{480}{ 300000} = 15  ;
$scalearray{480}{ 250000} = 20  ;
$scalearray{480}{ 240000} = 24  ;
$scalearray{480}{ 200000} = 20  ;
$scalearray{480}{ 150000} = 15   ;
$scalearray{480}{ 120000} = 24  ;
$scalearray{480}{ 100000} = 20  ;
$scalearray{480}{  80000} = 16   ;
$scalearray{480}{  60000} = 24   ;
$scalearray{480}{  50000} = 20   ;
$scalearray{480}{  48000} = 24   ;
$scalearray{480}{  40000} = 20  ;
$scalearray{480}{  30000} = 15  ;
$scalearray{480}{  25000} = 10  ;
$scalearray{480}{  24000} = 24  ;
$scalearray{480}{  20000} = 20   ;
$scalearray{480}{  16000} = 16   ;
$scalearray{480}{  15000} = 15   ;
$scalearray{480}{  12000} = 24  ;
$scalearray{480}{  10000} = 20  ;
$scalearray{480}{   8000} = 20   ;
$scalearray{480}{   7500} = 15   ;
$scalearray{480}{   6000} = 24   ;
$scalearray{480}{   5000} = 10  ;
$scalearray{480}{   4800} = 24  ;
$scalearray{480}{   4000} = 20   ;
$scalearray{480}{   3000} = 15  ;
$scalearray{480}{   2400} = 24  ;
$scalearray{480}{   2000} = 20  ;
$scalearray{480}{   1500} = 15  ;
$scalearray{480}{   1200} = 24  ;
$scalearray{480}{   1000} = 20  ;
$scalearray{480}{    800} = 16   ;
$scalearray{480}{    600} = 24   ;
$scalearray{480}{    480} = 24   ;
$scalearray{480}{    400} = 20  ;
$scalearray{480}{    300} = 15   ;
$scalearray{480}{    240} = 24  ;
$scalearray{480}{    200} = 20   ;
$scalearray{480}{    150} = 15   ;
$scalearray{480}{    100} = 10  ;
$scalearray{480}{     80} = 16   ;
$scalearray{480}{     60} = 15  ;
$scalearray{480}{     48} = 24  ;
$scalearray{480}{     40} = 20  ;
$scalearray{480}{     30} = 15  ;
$scalearray{480}{     24} = 24  ;
$scalearray{480}{     10} = 10  ;
$scalearray{480}{      5} = 5   ;
$scalearray{480}{      4} = 4   ;
$scalearray{480}{      3} = 3   ;
 
$scalearray{720}{1000000} = 40  ;
$scalearray{720}{ 800000} = 40  ;
$scalearray{720}{ 720000} = 36  ;
$scalearray{720}{ 600000} = 30  ;
$scalearray{720}{ 480000} = 24  ;
$scalearray{720}{ 400000} = 40  ;
$scalearray{720}{ 300000} = 30  ;
$scalearray{720}{ 240000} = 24  ;
$scalearray{720}{ 200000} = 40  ;
$scalearray{720}{ 150000} = 30   ;
$scalearray{720}{ 120000} = 24   ;
$scalearray{720}{ 100000} = 40   ;
$scalearray{720}{  80000} = 40   ;
$scalearray{720}{  72000} = 36   ;
$scalearray{720}{  60000} = 30   ;
$scalearray{720}{  50000} = 40   ;
$scalearray{720}{  40000} = 40   ;
$scalearray{720}{  30000} = 15   ;
$scalearray{720}{  24000} = 24   ;
$scalearray{720}{  20000} = 40   ;
$scalearray{720}{  18000} = 36   ;
$scalearray{720}{  15000} = 30   ;
$scalearray{720}{  12000} = 24  ;
$scalearray{720}{  10000} = 40  ;
$scalearray{720}{   9000} = 36   ;
$scalearray{720}{   8000} = 40   ;
$scalearray{720}{   7200} = 36   ;
$scalearray{720}{   6000} = 30   ;
$scalearray{720}{   5000} = 40  ;
$scalearray{720}{   4800} = 24  ;
$scalearray{720}{   4000} = 40   ;
$scalearray{720}{   3000} = 30  ;
$scalearray{720}{   2400} = 24  ;
$scalearray{720}{   1800} = 36  ;
$scalearray{720}{   1500} = 30  ;
$scalearray{720}{   1200} = 24  ;
$scalearray{720}{   1000} = 40  ;
$scalearray{720}{    800} = 16   ;
$scalearray{720}{    600} = 24   ;
$scalearray{720}{    480} = 24   ;
$scalearray{720}{    400} = 12  ;
$scalearray{720}{    300} = 15   ;
$scalearray{720}{    240} = 24  ;
$scalearray{720}{    200} = 40   ;
$scalearray{720}{    150} = 30   ;
$scalearray{720}{    100} = 20  ;
$scalearray{720}{     80} = 40   ;
$scalearray{720}{     72} = 36  ;
$scalearray{720}{     60} = 30  ;
$scalearray{720}{     48} = 24  ;
$scalearray{720}{     40} = 40  ;
$scalearray{720}{     30} = 30  ;
$scalearray{720}{     24} = 24  ;
$scalearray{720}{     20} = 20  ;
$scalearray{720}{     15} = 15  ;
$scalearray{720}{     10} = 10  ;
$scalearray{720}{      5} = 5   ;
$scalearray{720}{      4} = 4   ;
$scalearray{720}{      3} = 3   ;

$scalearray{600}{1000000} = 40  ;
$scalearray{600}{ 800000} = 40  ;
$scalearray{600}{ 720000} = 30  ;
$scalearray{600}{ 600000} = 30  ;
$scalearray{600}{ 480000} = 40  ;
$scalearray{600}{ 400000} = 40  ;
$scalearray{600}{ 300000} = 40  ;
$scalearray{600}{ 240000} = 40  ;
$scalearray{600}{ 200000} = 40  ;
$scalearray{600}{ 150000} = 40   ;
$scalearray{600}{ 120000} = 30   ;
$scalearray{600}{ 100000} = 40   ;
$scalearray{600}{  80000} = 40   ;
$scalearray{600}{  72000} = 30   ;
$scalearray{600}{  60000} = 30   ;
$scalearray{600}{  50000} = 40   ;
$scalearray{600}{  40000} = 40   ;
$scalearray{600}{  30000} = 30   ;
$scalearray{600}{  24000} = 24   ;
$scalearray{600}{  20000} = 40   ;
$scalearray{600}{  18000} = 30   ;
$scalearray{600}{  15000} = 30   ;
$scalearray{600}{  12000} = 24  ;
$scalearray{600}{  10000} = 40  ;
$scalearray{600}{   9000} = 30  ;
$scalearray{600}{   8000} = 40  ;
$scalearray{600}{   7200} = 30  ;
$scalearray{600}{   6000} = 30  ;
$scalearray{600}{   5000} = 40  ;
$scalearray{600}{   4800} = 24  ;
$scalearray{600}{   4000} = 40  ;
$scalearray{600}{   3000} = 30  ;
$scalearray{600}{   2400} = 24  ;
$scalearray{600}{   2000} = 20  ;
$scalearray{600}{   1500} = 30  ;
$scalearray{600}{   1500} = 30  ;
$scalearray{600}{   1200} = 24  ;
$scalearray{600}{   1000} = 40  ;
$scalearray{600}{    800} = 40  ;
$scalearray{600}{    600} = 24  ;
$scalearray{600}{    480} = 24  ;
$scalearray{600}{    400} = 40  ;
$scalearray{600}{    300} = 30   ;
$scalearray{600}{    240} = 24  ;
$scalearray{600}{    200} = 40   ;
$scalearray{600}{    150} = 30   ;
$scalearray{600}{    100} = 20  ;
$scalearray{600}{     80} = 40   ;
$scalearray{600}{     75} = 25  ;
$scalearray{600}{     60} = 30  ;
$scalearray{600}{     48} = 24  ;
$scalearray{600}{     40} = 40  ;
$scalearray{600}{     30} = 30  ;
$scalearray{600}{     24} = 24  ;
$scalearray{600}{     20} = 20  ;
$scalearray{600}{     15} = 15  ;
$scalearray{600}{     10} = 10  ;
$scalearray{600}{      5} = 5   ;
$scalearray{600}{      4} = 4   ;
$scalearray{600}{      3} = 3   ;

# +-------------------------------------------------------------------+
# |           S U B - R O U T I N E S                                 |
# +-------------------------------------------------------------------+


sub readinput {
	if (length ($ENV{'QUERY_STRING'}) > 0){
		$buffer = $ENV{'QUERY_STRING'};
		@pairs = split(/&/, $buffer);
		foreach $pair (@pairs){
			($name, $value) = split(/=/, $pair);
			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
			$in{$name} = $value; 
#			print "~~~".$pair."~~~".$name."~~~".$value."~~~\n" ;
		}
	}
}

sub readFORMinput {
	if ($ENV{'REQUEST_METHOD'} eq 'POST'){
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
		@pairs = split(/&/, $buffer);
		foreach $pair (@pairs) {
			($name, $value) = split(/=/ ,$pair);
			$value =~ tr/+/ /;
			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
			$name =~ tr/+/ /;
			$name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
#			print "Pair=".$pair."~~~Name=".$name."~~~Value=".$value."~~~<br>\n";
			$FORM{$name}= $value;
			
		}
	} else {
		@pairs = split(/\&/, $ENV{'QUERY_STRING'});
		foreach $pair (@pairs) {
			($name, $value) = split(/=/ ,$pair);
#			print "Pair=".$pair."~~~Name=".$name."~~~Value=".$value."~~~<br>\n";
			$value =~ tr/+/ /;
			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
			$FORM{$name}= $value;
		}
	}
}

sub readspecialFORMinput {
	if ($ENV{'REQUEST_METHOD'} eq 'POST'){
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
		@pairs = split(/&&/, $buffer);
		foreach $pair (@pairs) {
			($name, $value) = split(/==/ ,$pair);
			$value =~ tr/+/ /;
#			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
			$FORM{$name}= $value;
		}
	} else {
		@pairs = split(/&&/, $ENV{'QUERY_STRING'});
		foreach $pair (@pairs) {
			($name, $value) = split(/==/ ,$pair);
			$value =~ tr/+/ /;
#			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
			$FORM{$name}= $value;
		}
	}
}

sub securitycheck {
	if ($ENV{"REMOTE_ADDR"} && $ENV{"REMOTE_ADDR"} !~ /193\.130\.109/ ){
		if (!grep ($ENV{"REMOTE_ADDR"} eq $_,@excludemach) && !grep ($ENV{"REMOTE_HOST"} eq $_,@excludemach)){
			$title = "Magus Intranet: Unauthorised Access";
			&printfile($header) ;
			print "<title>UNAUTHORISED ACCESS</TITLE>";
			print "<p class=Title align=center>&nbsp;<br>&nbsp;<br>";
			print $ENV{"REMOTE_ADDR"};
			print "<br>is not authorised to access this site</p>";
			print "<p class=Main align=center><br><br>If you are an employee of <B>Magus Research Limited</B>,<br>contact us for details of how to access the site</p><p>&nbsp;</p>";
			&printfile($footer) ;
			exit;
		}
	}
}

sub alphasort
	{ $a cmp $b ; }

sub numsort
	{ $a <=> $b ; }

sub gethostname {
	open(HOSTNAME, "hostname |") || &cannotexecute;
	while(<HOSTNAME>){ 
		$hostname = $_;
		chomp $hostname;
	}
	close HOSTNAME;
	$hostname{'borg'} = "Borg" ;
	$hostname{'jabba.magus.co.uk'} = "Jabba" ;
	$hostname{'jabba'} = "Jabba" ;
	$hostname{'bach'} = "Bach" ;
}

sub read_preferences {
	if (-e "$logroot/preferences/$username.tab") {
		open(PREFS,"$logroot/preferences/$username.tab");
		while(<PREFS>){
			chomp ;
			($paramname,$paramvalue) = split(/=/,$_) ;
			${$paramname} = $paramvalue ;
#			print "<!--Setting ".$paramname." to ~~~".$paramvalue."-->\n" ;
		}
		close(PREFS) ;
	}
}

sub write_preferences {
	&read_preferences ;
	open(PREFS,">$logroot/preferences/$username.tab");
	print PREFS "GRAPHHEIGHT=".$XGRAPHHEIGHT."\n" ;
	if ($XWIDTH < 400 ) {
		$XWIDTH = 400 ;
	}
	if ($XWIDTH != $WIDTH) {
		$XSNAPSHOTDAYS = int($XWIDTH/15) ;
	}
	print PREFS "WIDTH=".$XWIDTH."\n" ;
	print PREFS "SNAPSHOTDAYS=".$XSNAPSHOTDAYS."\n" ;
	print PREFS "PRINTFORMAT=".$XPRINTFORMAT."\n" ;
	print PREFS "COLOR1=".$XCOLOR1."\n" ;
	print PREFS "COLOR2=".$XCOLOR2."\n" ;
	print PREFS "COLOR3=".$XCOLOR3."\n" ;
	print PREFS "COLOR4=".$XCOLOR4."\n" ;
	print PREFS "COLOR5=".$XCOLOR5."\n" ;
	print PREFS "DISPLANG=".$XDISPLANG."\n" ;
	close(PREFS) ;
}

sub getindexlocation {
	my($src) = $_[0];
	my($src1,$host,$port,$host1,$port1,$line);
	open(RSC,"grep $src /usr/RemoteSearch/RSCentral/IndexHosts |") || &error("Cannot open IndexHost file for $src");
	$line = <RSC>;
	chomp $line;
	if (!$line){ &error("Cannot find ".$src." in IndexHosts file"); }
	($src1,$host,$port,$host1,$port1) = split(/\t/,$line);
	return ($host,$port,$host1,$port1);
}

sub error {
	$error = $_[0] ;
	print $error ;
	&printfile($footer) ;
	exit ;
}

sub flipstyle {
	if ($style eq "TableDark") {
		$style = "TableLight";
	} else {
		$style = "TableDark";
	}
}

sub commarise {
	my($commarise) = $_[0] ;
	$commarise =~ s/(.*?)(\d{3})?(\d{3})?(\d{3})?$/$1,$2,$3,$4/i;
	$commarise =~ s/^(,)?(,)?(,)?(.*?)(,)?(,)?(,)?$/$4/i;
	$commarise =~ s/\-\,/-/i;
	return $commarise ;
}

sub getscale {
	my($thisscale) = $_[0] ;
	my($scalemax) ;

	foreach $setmax ( sort { $b <=> $a } keys %{ $scalearray{$GRAPHHEIGHT} } ) {
		if ($thisscale <= $setmax) {
			$scalemax  = $setmax ;
			$divisions = $scalearray{$GRAPHHEIGHT}{$setmax} ;
#			print "<!--Checking graph max = ".$setmax." when Height = ".$GRAPHHEIGHT."-->\n" ;
		}
	}

	# $divisions = 36   >   must set all up to 36 else ""   
	
	for ($ssc = 40 ; $ssc >= 1 ; $ssc--) {
		if ($divisions >= $ssc ) {
			${'scale'.$ssc} =  ($scalemax * $ssc) / $divisions ;
		} else {
			${'scale'.$ssc} = "" ;
		}
	}

	if ( (!$divisions) || ($divisions < 0.0001) || ($divisions eq "") ) {
		$scaleheight = "49" ;
	} else {
		$scaleheight = ($GRAPHHEIGHT / $divisions) - 1 ;
	}	
	
	return ($divisions,$scalemax) ;
}

sub readstoplist {
	my $file=$_[0] ;
	open(STP,$file) || print "Can't read stop listed words!" ;
	while(<STP>) {
		chomp; push(@stoplist, $_) ; 

	}
	close(STP) ;
}

1;
