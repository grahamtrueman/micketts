#!/usr/bin/perl -w

##############################################
#                                            #
#       Executes Search for RS Search        #
#                                            #
##############################################

# Subroutine_names in order of appearance in this script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$sub_execute_search      = "execute_search"     ;
$sub_preprocessquery     = "preprocessquery"    ;
$sub_bysite              = "bysite"             ;
$sub_byscore             = "byscore"            ;
$sub_bycategory          = "bycategory"         ;
$sub_byscorewassite      = "byscorewassite"     ;
$sub_globalandthis       = "globalandthis"      ;
$sub_sectionsupport      = "sectionsupport"     ;

# Subroutines...
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub execute_search {
	open(STDERR,">>$errlog");
	
	# Prevent being killed
	$SIG{TERM} = 'IGNORE';
	$SIG{PIPE} = 'IGNORE';

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#    Start the Search timer
	use Time::HiRes qw(gettimeofday sleep);
	@startTime = gettimeofday;                           
	
	# Store variables
	$username = $ENV{"REMOTE_USER"} || "-";
	$hostname = $ENV{"REMOTE_HOST"} || $ENV{"REMOTE_ADDR"};
	$scriptname = $ENV{"SCRIPT_FILENAME"} ;

	#Set default analysis log
	if (!$analysislog) {
		$analysislog        = $dblogdirectory."analysis.log"        ;
	}
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#    Inherit Default Format sections
	if ($inheritFromDef) {
		&read_format_def;       # Read the Default sections from the MAGUS DEFAULT Search_Format file
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#    READ MAIN SEARCH INPUT
	&$sub_read_input                 ;  # Input in POST/GET mode into form Array

	$xlang = $FORM{'language'} ;
	$xlastmod = $FORM{'lastmod'} ;
	$org_method = $FORM{'method'};
	$xsection = $FORM{'section'} ;
	$begin = $FORM{'begin'} || '0';
	$selectionurls = $FORM{'selectionurls'};
	$resultspage = $FORM{'resultspage'};
	$siteId = $FORM{'siteId'} || $FORM{'referrer'} ;
	$referrer = $FORM{'siteId'} || $FORM{'referrer'};
	$subdivision = $FORM{'subdivision'} || $FORM{'siteId'} || $FORM{'referrer'};
	$xresults_option = $Xresults_option;
	$secname = $FORM{'section'} || $section{$siteId};
	$orgsection = $FORM{'orgsection'} || $FORM{'section'} || $section{$subdivision};
	$subdivtitle = $FORM{'subdivtitle'} || $subdivtitle || $subdivtitle{$subdivision};
	$includeOtherFiles = $FORM{'includeOtherFiles'} ;

#	if ($includeOtherFiles) { print "<!--include is SET-->" ; }
	
	if ($orgsection && !$xsection) { $xsection = $orgsection ; }
#	if ($xsection eq "selection" && $orgsection eq "selection") { $orgsection = "" ; }

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Process Cookie or generate new one
	if ($cookiesSwitch) {
		$cookie = $oldcookie = $ENV{'HTTP_COOKIE'} ;
		$_ = $cookie ;
		($cookieSearches,$cookieUId,$cookieIP,$cookieSet) = /trace=searches=([\d]*)\&UId=([\d]*)\&IP=([0-9\.]*)&Set=([^\;]*)/i ;
		if (!$cookieUId) {
			$cookieUId = gettimeofday;
			$cookieUId =~ s/\.//eigs ;
		}
		if (!$cookieIP) {
			$cookieIP = $hostname ;
		}
		if ($cookieSearches < 0.5) {
			$cookieSearches = 0 ;
		}
	}
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#    Initialize special variables
	#  + Allow cookie parameters to be modified
	&$sub_initialize;

	if ($cookiesSwitch) {
		$cookieSearches++ ;
		$cookie = "trace=Searches=".$cookieSearches."&UId=".$cookieUId."&IP=".$cookieIP."&Set=".$cookieSet."; expires=Friday, 31-Mar-2006 12:00:00 GMT" ;
		print "Set-Cookie: ".$cookie."\n" ;
		print "Content-type: text\/html\n\n" ;
#		print "<!--New cookie: ".$cookie."-->\n" ;
#		print "<!--Old cookie: ".$oldcookie."-->\n\n" ;
	} else {
#		print "Content-type: text\/html\n\n" ;
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#    DisplayLanguage support
	if ($Xdisplaylanguage){ 
		&${'sub_'.$Xdisplaylanguage};
	} else {
		if ($defdisp) { &$sub_english ; }   #  Do nothing at the moment if "displaylanguage" is not set
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#    Inherit Corporate information
	if ($subdivision && $inheritFromCorp) {
		$DEBUG .= "<!--Corp Format file: ".$formatfile."-->\n" if $DEBUGlevel > 0.5 ;
		&$sub_read_format               ;  # Read the Default sections from the Corporate Search_Format file
	}
	if ($inheritCorpSuggestions{$subdivision}) {
		&$sub_readsuggestions; # Load corporate suggestions
		$DEBUG .= "<!--Reading corp suggestions file: ~~~|".$suggestionfile."|~~ -->\n"  if $DEBUGlevel > 0.5 ;
	} else {
		$DEBUG .= "<!--NOT reading corp suggestions file: ~~~|".$suggestionfile."|~~ -->\n"  if $DEBUGlevel > 0.5 ;
	}
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#    Subdivision support

	if ($subdivision) { 
		if ($displaylanguage{$subdivision}){ 
			&${'sub_'.$displaylanguage{$subdivision}};
		}
		if ($resultspage) {
			$formatfile = $subdivdir.'/'.$subdivision.'/'.$sdformatfile.$langext.$resultspage;
		} else {
			$formatfile = $subdivdir.'/'.$subdivision.'/'.$sdformatfile.$langext."_".($Xframes || $subdivision);
		}
		if ($generalSubdivFormat) {
			$formatfile = $generalSubdivFormat ;
		}
		if ($logfile) {
			$logfile = $dblogdirectory.'/'.$subdivision.'.log';
		}
		$suggtemp = $subdivdir .'/'.$subdivision.'/'.$sdsuggestionfile.$langext.$resultspage;
		if ($changeSubDivSuggestions{$subdivision}) { $suggtemp = $changeSubDivSuggestions{$subdivision} ; }
		if ($disableSubDivSuggestions ne "true" || $suggestionFlag{$subdivision} eq "true") {
			if (-e $suggtemp) {
				if ($disableCorpSuggestions eq "true") {
	 				$suggestionfile = "";
				} else {
	 				$suggestionfile = $suggtemp;
				}
			} else {
				if ($disableCorpSuggestions eq "true") {
					$suggestionfile = "" ;
				}
			}
		} else {
			if ($disableCorpSuggestions eq "true") {
				$suggestionfile = "" ;
			}
		}
	
		# Set subdivisions specific info...
		if ($changesrc{$subdivision}) {
			if ($subdivision =~ /cuprobraze/ || $subdivision =~ /tomkins_demo/) {
				$src = $changesrc{$subdivision} ; 
			} else {
				$src = $RSroot.$changesrc{$subdivision} ; 
			}
		}
		if ($here{$subdivision}) { $here = $here{$subdivision} ; }
		if ($subdivtitle{$subdivision}) { $subdivtitle = $subdivtitle{$subdivision} ; }
		if ($frameprog{$subdivision}) { $frameprog = $frameprog{$subdivision}; }
		if ($plural{$subdivision}) { $setplural = $plural{$subdivision}; }
		if ($singular{$subdivision}) { $setsingular = $singular{$subdivision}; }
		if ($excludepages{$subdivision}) { $excludepages = $excludepages{$subdivision}; }
		if ($includeOtherFiles{$subdivision}) { $includeOtherFiles = $includeOtherFiles{$subdivision}; }
		if ($sitenames{$subdivision}) { $sitenames = $sitenames{$subdivision}; }

	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   Load Required Data
	$DEBUG .= "<!--Format file: ".$formatfile."-->\n"  if $DEBUGlevel > 0.5 ;
	&$sub_read_format       ; # The format File
	&$sub_readlang          ; # Language Data
	&$sub_load_titles       ; # Load the site_titles file
	&$sub_load_passworddirs ; # Load directories that are password protected
	if (!$inheritCorpSuggestions{$subdivision} || $subdivision) {
		$DEBUG .= "<!--Reading subdiv suggestions file: ~~~|".$suggestionfile."|~~ -->\n" if $DEBUGlevel > 0.5;
		&$sub_readsuggestions   ; # Load suggestions
	} else {
		$DEBUG .= "<!--NOT Reading sub suggestions file: ~~~|".$suggestionfile."|~~ -->\n" if $DEBUGlevel > 0.5;
	}
	if ($PERPAGE) { $perpage = $PERPAGE; }  # $PERPAGE loaded in from Search_format
	if ($Xsimilarto) { $PERPAGE=$maxSimilarPages; $perpage=$maxSimilarPages; print "<!--Setting PERPAGE to ".$maxSimilarPages."-->" ; }	
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   "INDEX" Support
	if ($ENV{'QUERY_STRING'} && $ENV{'QUERY_STRING'} !~ /=/) {
		$indexcheck = "[[".$ENV{'QUERY_STRING'}."]]" ;
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   No Search term or similar page entered  (quit search straight away...)
	if ( !$XSearch && !$Xsimilarto) {
		&$sub_write_output ;
		exit ;
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   Remove illegal characters from search
	if ($FORM{'method'} !~ /Boolean\ssearch/i) {
		$FORM{'Search'} =~ tr/"\,//d;
		$XSearch = $FORM{'Search'} ;
	}
	$newline = "\n" ; $blank = " " ;
	$FORM{'Search'} =~ s/$newline/$blank/ ;

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   Remove Field allocation if set
	if ($removeField) {
		$YSearch = $FORM{'Search'} ;
		$YSearch =~ s/(.*?)\S*\:\((.*?)\)(.*?)/$1.$2.$3/iegs ;
	}
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   SEARCH QUERY
	$query = $org_query = $FORM{'Search'};
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   Common suggestions support
	&$sub_readcommonsug ;
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   URL:  support
	$query =~ s/((URL:)([\S]*))/''/eigs;
	$checklink = $3;
	$query =~ s/\s+/' '/eigs ;
	$query =~ s/^\s+// ;
	$query =~ s/\s+$// ;
	if ($checklink && !$query) { $query = "**"; }
	
	$_ = &$sub_preprocessquery($query) ;
	
	if ($FORM{'method'} =~ /All\smy\swords/i){
		$xmethod = "all" ;
		tr/()"//d;
		$new = '';
		foreach $a (split (/\s/,$_)){
			if ($new){$new .= " AND ";}
			$new .= $a;
		}
		$_ = $new;
	} elsif ($FORM{'method'} =~ /My\sexact\sphrase/i){
		$xmethod = "exact" ;
		tr/()"//d;
		$_ = "\"$_\"";
	} elsif ($FORM{'method'} =~ /Any\sof\smy\swords/i){
		$xmethod = "any" ;
	  tr/()"//d;
	  foreach $a (split (/\s/,$_)){
	    if ($new){$new .= " OR ";}
	    $new .= $a;
	  }
	  $_ = $new;
	} elsif ($FORM{'method'} =~ /Boolean\ssearch/i){
		$xmethod = "boolean" ;
	}
	$query = $_;

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   Set default method
	if ($setdefaultmethod && !$FORM{'method'}) {
		$Xmethod = $FORM{'method'} = $setdefaultmethod;
	}

	#   Set default results option
	if (!$Xresults_option) {
		$Xresults_option = $FORM{'results_option'} = $setdefaultresults ;
	}
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   Sections Support
	&$sub_sectionsupport ;
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   Language Support
	$language = $FORM{"language"};
	if ($language eq "jp"){
		$query = " spacinate(jp,$XSearch) lang:jp";
	} elsif ($language) {
		$query .= " lang:$language";
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   Category Support
	if ($Xcategory){
		$temp = $Xcategory;
		$query .= " category:($Xcategory)";
		$displaycategory = $Xcategory ;
		$displaycategory =~ s/_/ /gs ;
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   Similar pages Support
	if ($FORM{"similarto"}){
#		print "<!--Find pages similar to: ".$FORM{"similarto"}."-->\n\n" ;
		$query = " similarPages(".$FORM{"similarto"}.") ".$similarWordExcludes." " ;
		$Xresults_option = $FORM{"results_option"} = "scores";
		$secscores = 1;
	}
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   Last Mod / "custlastmod" Support 
	if ($FORM{'lastmod'}) {
		$lastmod = $FORM{'lastmod'};
		$lastmodtime = 0;
		$now = time;
		if ($lastmod){
			if ($lastmod eq "lastweek" ) {
				$lastmodtime = 1000*($now-7*24*60*60);
				$lastmod2 = $methodlastweek ;
			} elsif ($lastmod eq "lastmonth" ) {
				$lastmodtime = 1000*($now-31*24*60*60);
				$lastmod2 = $methodlastmonth ;
			} elsif ($lastmod eq "lastyear" ) {
				$lastmodtime = 1000*($now-365*24*60*60);
				$lastmod2 = $methodlastyear ;
			} elsif ($lastmod > 10000000 ) {
				$lastmodtime = 1000*$lastmod ;
			}
		}
		$lastmod = "";
		if ($lastmodtime){ $lastmod = "lastmod>$lastmodtime";}
		$query .= " $lastmod" if $lastmod;
	} elsif ($Xmodfrom || $Xmodto) {
		print "<!--spotted a modfrom modto setting-->" ;
		$query .= " custlastmod>=$Xmodfrom" if $Xmodfrom ;
		$query .= " custlastmod<=$Xmodto" if $Xmodto ;
	}
	
	# Add global limiters to search query
	if ($query !~ /limiterbypass/ ) {
		if ( $limiter{'global_all'} ) {
			$query .= " ".$limiter{'global_all'} ;
		}
		if ( $limiter{$subdivision} ) {
			$query .= " ".$limiter{$subdivision} ;
		}
	} else {
		$query =~ s/limiterbypass//eigs ;
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#   About to do search
	&$sub_gettime('presearch');
	if ($TYPE ne "ADVANCED") {
		if ($Xresults_option eq "scores"){
#			print "<!--Begin=~~|".$begin."|~~ Perpage=~~|".$perpage."|~~ -->\n" ;
			&$sub_do_search($begin,$begin+$perpage);
		} else {
			&$sub_do_search(0,-1);
		}
		&$sub_gettime('postsearch');
		$incharset =~ tr/a-z/A-Z/d ;
		$outputcharset =~ tr/a-z/A-Z/d ;
		if ( ($incharset ne $outputcharset) && $trquery && $multicharsetOn){
			# print "<!--translating query in=$incharset out=$outputcharset-->" ;
			$Xquery = $trquery;
			$Xquery =~ s/\w+:\(\.*?\)//g;  # Remove field queries
			$Xquery =~ s/\w+:\w+//g;       # Remove field queries
			$Xquery =~ s/\w+\(.*?\)//g;    # Remote function modifies;
			$Xquery =~ s/AND//g;
			$Xquery =~ s/OR//g;
			$Xquery =~ s/"//g;
			$Xquery =~ s/lastmod\>\w+//g;
			$Xquery =~ s/custlastmod..\d*//g;
			$Xquery =~ s/$limiter{'global_all'}//;
			$Xquery =~ s/$limiter{$subdivision}//;
			$Xquery =~ s/\s+$//;
			$translateQuery = $XSearch = $org_query = $Xquery ;
		}
		if (!$translateQuery) {
			$translateQuery = $org_query ;
		}
	
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		#   Start evaluating results page HTML
		if ($nresults == -1){
			&$sub_write_output ;
			print "<!--Exit 1-->" ;
			exit;
		}
	
		$EVALUATE_SUGGESTIONS = &$sub_suggestions;

		if ( $Xsimilarto && $nresults>100) { $actualNresults = $nresults ; $nresults = $maxSimilarPages ; }
		$hits = $nresults;
		
		if ($hits == 0 && $nresults==0){
			$EVALUATE_NEAREST = &$sub_spellingsuggestions ;
			$resultsdecision = "noresults" ;
		} else {
#			if ($hits == 1) { $verb = "was" } else { $verb = "were" ; }
			if ($Xresults_option eq "scores"){
				$resultsdecision = "scores" ;
				if ($FORM{"similarto"}){ $resultsdecision = "similarpages" ; }
				&$sub_byscore;
			} elsif ($Xresults_option eq "category"){
				$resultsdecision = "category" ;
				&$sub_bycategory;
			} else {
				if ($Xsection eq "globalandthis" || $Xsection eq "sectionandthis" ){
					$resultsdecision = "globalandthis" ;
					&$sub_globalandthis;
				} else {
					$resultsdecision = "sites" ;
					$Xresults_option = "sites" ;
					&$sub_bysite;
				}
			}
		}
	} else {
		# For an "ADVANCED" search, all the searches are called from the search_format page - so read searches required...
		#  TO BE ADDED IN NEXT FULL RELEASE
	}
	&$sub_write_output ;
	print "<!--This search was completed in ".$timeval{'postoutput'}." seconds by ".$hostlog." (".$portlog.")-->" ;
	
	close(STDOUT);
	
	if ($multicharsetOn && ($outputcharset !~ /utf\-8/i ) && $outputcharset) {
		$tmpFilename = gettimeofday;
		open(OLDCHARSETFILE, ">$transTmpDir/$tmpFilename") ;
		print OLDCHARSETFILE $translateQuery ;
		close(OLDCHARSETFILE) ;
		system("changecharset $outputcharset UTF-8 <$transTmpDir/$tmpFilename >".$transTmpDir."/".$tmpFilename."_new") ;
		print "<!--changecharset $outputcharset UTF-8 <$transTmpDir/$tmpFilename >".$transTmpDir."/".$tmpFilename."_new-->\n\n" ;
		open(NEWCHARSETFILE,$transTmpDir."/".$tmpFilename."_new");
		$org_query = <NEWCHARSETFILE> ; chomp ;
		close(NEWCHARSETFILE) ;
		system("rm -rf $transTmpDir/$tmpFilename ".$transTmpDir."/".$tmpFilename."_new") ;
		open(DEBUG, ">>$transTmpDir/WIBLESTEST") ;
		print DEBUG $org_queryTEMP."\n" ;
		close(DEBUG) ;
	}
	$scriptname =~ s/(.*?)_[^\/]*/$1/eigs;
	&$sub_fulllogging;
	&$sub_dologging;
	&$sub_centrallogging;
	&$sub_analysislogging;
	if ($DB) { &$sub_makeDBchanges ;}
	
}

sub preprocessquery {
	return $_[0] ;
}

sub bysite {
	$siteno = 1;
	$EVALUATE_SITES = "" ;
	foreach $site (sort sitename_ordering keys %invtitles){
		$sitenum = $xntitle{$site};
		$page = &$sub_getpageurlsite($invtitles{$site});
		$number = $persite[$sitenum];
#		print $number."~~~".$sitenum."~~~".$site."~~~<br>\n" ;
		if ($site eq $top){ next; }
		if (!$number) { next; }
		$description = $sitedescr{$invtitles{$site}};
		if ($EVALUATE_SITES) { $EVALUATE_SITES .= $ITEMSEP ; }
		$EVALUATE_SITES .= &$sub_output($SITESITEM);
		$siteno++;
	}
}

sub byscore {
	$hitstotal = $nresults ;
	$pages = int ($nresults/$perpage+0.9999);
	$page = 1;
	if ($begin){ $page = 1+ $begin/$perpage;}
	$hitnofirst = $begin + 1;
	$hitnolast = $hitnofirst + $perpage - 1;
	if ($hitnolast > $nresults) {$hitnolast = $nresults}
	if ($Xwassite) {                      # Search called from per site results 
		$number = $nresults;
		&$sub_byscorewassite;
	} else {
		if ( ($secname ne "selection") && !$secscores && !$Xcategory) {
			$EVALUATE_BYSITE = &$sub_output($SEARCHBYSITE);
		} else {
			$EVALUATE_BYSITE = &$sub_output($NOSEARCHBY);
		}
		$EVALUATE_PAGELINKS = "";
		if ($page > 1.5) {
			$beginagain = $FORM{'begin'} - $perpage  ;
			$prevurllink = &$sub_getpageurlagain ;
		}
		if ($page+0.5 < $pages) {
			$beginagain = $FORM{'begin'}+$perpage;
			$nexturllink = &$sub_getpageurlagain;
		}
		if ($nresults > $perpage){
			$start = 1;
			$end = $perpage;
			$EVALUATE_PAGELINKS .= &$sub_reslinks($page,$sub_getpageurl);
		}
		$EVALUATE_RESULTS = "";
		for($i=0 ; $i<$perpage ; $i++){
			$name = @names[$i];
			if (!$name){ next; }
			
			# Shell hack to remove duplicate 
			if ( $thiscompany eq "Shell" && length($displayCustomMessages[0]) > 0) {
				$returnHere = "no" ;
				if ( $name =~ /siteId/ ) {
					$_ = $name ;
					($thisSiteId) =~ /siteId=([^\&]+)/ ;
					($thisFC3) =~ /FC3=([^\&]+)/ ;
					for($tt=0;$tt<=$#displayCustomMessages;$tt++) {
						# print "<!--".$tt."=".$displayCustomMessages[$tt]."|~~~|".$name."-->\n" ;
						$thisTest = $displayCustomMessages[$tt] ;
						if (	( $thisTest =~ /siteId=$thisSiteId/ && $thisTest =~ /FC3=$FC3/ && length($FC3) > 0) ||
								( $thisTest eq $name )
							) {
							$returnHere = "yes" ;
						}
					}
				} else {
					for($tt=0;$tt<=$#displayCustomMessages;$tt++) {
						# print "<!--".$tt."=".$displayCustomMessages[$tt]."|~~~|".$name."-->\n" ;
						if ( $name eq $displayCustomMessages[$tt]) { $returnHere = "yes" }
					}
				}
				if ($returnHere eq "yes") {
					# print "<!--Removing duplicate ~~|".$name."|~~-->" ;
					$numberCustomMessages--;
					next ;
				}
			}
			
			if ($EVALUATE_RESULTS) { $EVALUATE_RESULTS .= $ITEMSEP ; }
			$EVALUATE_RESULTS .= &$sub_outres($name,$sub_getexiturl);	
		}
	}
}

sub byscorewassite {
	$newsiteUrl = $siteurl = $FORM{'selectionurls'};
	$newsiteUrl =~ s/^http[s]?[^\w\.\*]*//i;
	if ($siteurl =~ /\/$/ && !$titles{$siteurl}){ $siteurl = substr($siteurl,0,-1);}
	if ($newsiteUrl =~ /\/$/ && !$titles{$newsiteUrl}){ $newsiteUrl = substr($newsiteUrl,0,-1);}
	$sitetitle = $titles{$siteurl} || $titles{$newsiteUrl} || $siteurl;
	if ($nresults > $perpage){
		$start = 1;
		$end = $perpage;
		$EVALUATE_PAGELINKS = "";
		if ($page > 1.5) {
			$beginagain = $FORM{'begin'} - $perpage  ;
			$prevurllink = &$sub_getpageurlagain ;
		}
		if ($page+0.5 < $pages) {
			$beginagain = $FORM{'begin'}+$perpage;
			$nexturllink = &$sub_getpageurlagain;
		}
		if ($nresults > $perpage){
			$start = 1;
			$end = $perpage;
			$EVALUATE_PAGELINKS .= &$sub_reslinks($page,$sub_getpageurl);
		}
	}
	$EVALUATE_RESULTS = "";
	for($i=0 ; $i<$perpage ; $i++){
		$name = @names[$i];
		if (!$name){ next; }
		if ($EVALUATE_RESULTS) { $EVALUATE_RESULTS .= $ITEMSEP ; }
		$EVALUATE_RESULTS .= &$sub_outres($name,$sub_getexiturl);	
	}
}

sub bycategory {
	$siteno = 1;
	$EVALUATE_CATEGORIES = "" ;
	foreach $category (sort {$category{$b} <=> $category{$a} } keys %category){
		$number = $category{$category};
		if (!$number) { next; }
		$displaycategory = $category ;
		$displaycategory =~ s/_/ /g;
		$page = &$sub_getpageurlcategory($category);
		$EVALUATE_CATEGORIES .= &$sub_output($CATEGORIESITEM);
	}
}

sub globalandthis {
	$hitstotal = $hits = $nresults;
	$top = $titles{$Xthissite};
	$sitenum = $xntitle{$top};
	$hitsthissite = $persite[$sitenum];
	@persiteold = @persite;
	$hitstotal = $nresults;
	@secallow = ("http://$Xthissite/");
	if ($hitsthissite) { &$sub_do_search(0,$perthissite); }
	$hitsglobal = $hitstotal - $hitsthissite ;
	$nresults = $hitstotal ;
	$morepage = &$sub_getpageurlsite($Xthissite);
#	print "hitsGlobal=".$hitsglobal."~~~<br>\n" ;
#	print "hitsThisSite=".$hitsthissite."~~~<br>\n" ;
#	print "hitsTotal=".$hitstotal."~~~<br>\n" ;
	$EVALUATE_THISSITE = "";
	if ($hitsthissite < $perthissite){
		$EVALUATE_THISSITE .= &$sub_output($GATFIRSTNUM);
	} else {
		$morepage = $page = &$sub_getpageurlsite($Xthissite);
		$EVALUATE_THISSITE .= &$sub_output($GATFIRST);
	}
	&$sub_byscorewassite ;
	if ($hitsthissite > $perthissite){
		$page = &getpageurlsite($thissite);
		&output($thissiterest);
	}
	@persite = @persiteold;
	$begin = 0 ;
	&$sub_bysite ;
}

sub sectionsupport {
	if (!$checklink) {
		if ($secname eq "all") { $secname = ""; }
		if ($secname eq "sectionandthis") {
			$secname = $Xglobalsection ;
		}
		@secallow = ();
		$secscores = 0;
		$DEBUG .= "\n<!--secname=".$secname."-->\n" if $DEBUGlevel>0.5;
		if ($secname eq "selection"){
			@secallow = split(/,/,$FORM{"selectionurls"});
			$results_option = "scores" ;
  			$Xresults_option = "scores" ;
		} elsif ($secname){
			my($sectionfile)=$sections{$subdivision}||$sections ;
			if (length($sectionfile) > 0.5) {
				open(SC,$sectionfile);
				while(<SC>){
					chomp $_;
					@secline = split(/\t/,$_);
					$secnametest = shift(@secline);
					$DEBUG .= "<!--secnametest=".$secnametest."-->\n"  if $DEBUGlevel>0.5 ;
					$sectype = shift(@secline);
					if ($secnametest eq $secname){ 
						@secallow = @secline;
						if ($FORM{"results_option"} eq "category" && $sectype eq "scores") {
							$secresby = "category" ;
						#} elsif ($FORM{"results_option"} eq "scores" && $sectype ne "scores") {
						#	$secresby = $sectype;
						} else {
							$secresby = $sectype;
						}
						last;
					}
				}
				close(SC);
			}
			if ($secresby eq "scores"){ 
				$Xresults_option = $FORM{"results_option"} = "scores";
				$secscores = 1;
			} elsif ($secresby eq "category"){ 
				$Xresults_option = $FORM{"results_option"} = "category";
				#$secscores = 1;
			}
		}
	}
}

1;

