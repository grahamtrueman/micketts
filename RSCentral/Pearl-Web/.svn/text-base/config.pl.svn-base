#!/bin/perl

sub initialise_pw {

	$sub_loadFragments       = "loadFragments"      ;
	$sub_processif           = "processif"          ;
	$sub_mysqlcall           = "mysqlcall"          ;
	$sub_initialize          = "initialize"         ;
	$sub_read_input          = "read_input"         ;
	$sub_readCookie          = "readCookie"         ;
	$sub_readlang            = "readlang"           ;
	$sub_read_format         = "read_format"        ;
	$sub_load_titles         = "load_titles"        ;
	$sub_load_passworddirs   = "load_passworddirs"  ;
	$sub_readsuggestions     = "readsuggestions"    ;
	$sub_write_output        = "write_output"       ;
	$sub_output              = "output"             ;
	$sub_fulllogging         = "fulllogging"        ;
	$sub_dologging           = "dologging"          ;
	$sub_centrallogging      = "centrallogging"     ;
	$sub_analysislogging     = "analysislogging"    ;
	$sub_suggestions         = "suggestions"        ;
	$sub_dopluralcheck       = "dopluralcheck"      ;
	$sub_reslinks            = "reslinks"           ;
	$sub_getindexlocation    = "getindexlocation"   ;
	$sub_docdonetop_hash     = "docdonetop_hash"    ;
	$sub_spellingsuggestions = "spellingsuggestions";
	$sub_getspellingurl      = "getspellingurl"     ;
	$sub_gettime             = "gettime"            ;
	$sub_looparound          = "looparound"         ;
	$sub_countresults        = "countresults"       ;
	$sub_dopluralcheck       = "dopluralcheck"      ;
	$sub_searchcall          = "searchcall"         ;
	$sub_gettime             = "gettime"            ;
	$sub_URLise	             = "URLise"             ;
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   Set default language entries
	$lastmod_blank           = "not indicated"      ;
	$languagecode_blank      = "unknown"            ;
	$title_blank             = "The title for this page is blank"    ;
	$description_blank       = "No description available"      ;
	%renamedate = (
		"Mon" , "Monday",
		"Tue" , "Tuesday",
		"Wed" , "Wednesday",
		"Thu" , "Thursday",
		"Fri" , "Friday",
		"Sat" , "Saturday",
		"Sun" , "Sunday",
		"Jan" , "January",
		"Feb" , "February",
		"Mar" , "March",
		"Apr" , "April",
		"May" , "May",
		"Jun" , "June",
		"Jul" , "July",
		"Aug" , "August",
		"Sep" , "September",
		"Oct" , "October",
		"Nov" , "November",
		"Dec" , "December",
	);
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   Central Logging Function
	$IndexHosts              = "/RSCentral/IndexHosts" ;
	$ServersDown             = "/RSCentral/ServersDown" ;
	$transTmpDir             = "/RSCentral/SearchScripts/tmp" ;
	$centrallog              = "/export/server_status/dblog/analysis.log" ;
	$maxnestlevel            = 50000                   ;
	$MAXIF                   = 3 ;
	$MAXIFS                  = 3 ;
	
	$monthNO{'Jan'}          = 1 ;
	$monthNO{'Feb'}          = 2 ;
	$monthNO{'Mar'}          = 3 ;
	$monthNO{'Apr'}          = 4 ;
	$monthNO{'May'}          = 5 ;
	$monthNO{'Jun'}          = 6 ;
	$monthNO{'Jul'}          = 7 ;
	$monthNO{'Aug'}          = 8 ;
	$monthNO{'Sep'}          = 9 ;
	$monthNO{'Oct'}          = 10 ;
	$monthNO{'Nov'}          = 11 ;
	$monthNO{'Dec'}          = 12 ;
	@monthConv               = ('zeromonth','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec') ;
	@dayConv                 = ('zeroday','Mon','Tue','Wed','Thu','Fri','Sat','Sun') ;
	
	$nextURL                 = 2 ;
	$currentURL              = 1 ;

}	

1;


