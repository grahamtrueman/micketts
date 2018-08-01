#!/usr/bin/perl -w

require('/RSCentral/SearchScripts/RSlibraryConfig.pl') ;
require('/RSCentral/SearchScripts/RSlibraryVarious.pl') ;
require('/RSCentral/SearchScripts/RSlibrarySearchComponents.pl') ;
require('/RSCentral/Pearl-Web/library.pl')  ;
use Fcntl ;

$formatfile = "/RSCentral/AdminScripts/main.html" ;

sub doadmin{
	#Various variables to set
	use Time::HiRes qw(gettimeofday sleep);
	@startTime = gettimeofday;     
	&getthistime('start');

	$DB             = 'DBI:mysql:remotesearch:db1'            ;
	$DBusername     = 'remotesearch'                          ;
	$DBpassword     = 'findforme'                             ;

	$username = $ENV{'REMOTE_USER'} || "-";
	$hostname = $ENV{"REMOTE_HOST"} || $ENV{"REMOTE_ADDR"};
	$scriptname = $ENV{"SCRIPT_FILENAME"} ;
	if (!$permissions{'magadmin'}) {
		$permissions{'magadmin'} = "all";
	}
	$permission = $permissions{$username} ;
	
	@time = localtime(time);
	$thisdate    = ($time[5]+1900)."_".($time[4]+1)."_".$time[3];
	$thisyear    = ($time[5]+1900) ;
	$thismonth   = ($time[4]+1) ;
	$thismonthW  = ${'month'.($time[4]+1)} ;
	$thisday     = $time[3] ;
	$thishour    = $time[2] ;
	$thisweekday = $time[6] ; if ($thisweekday == 0) { $thisweekday = 7 }
	$datestamp   = $time[3]."/".$thismonthW."/".($time[5]+1900)." ".$time[2].":" ;
	if ($time[1] < 10) {
		$datestamp   .= "0" ;
	}
	$datestamp  .= $time[1];
	$lastmonthY = $thisyear ;
	$lastmonth = ($time[4]); if ($lastmonth < 0.5) { $lastmonth = 12 ; $lastmonthY-- }
	$lastmonthW  = ${'month'.$lastmonth} ;
	
	#If the script names are not set in local script, it sets the default here
	if (!$adminName){
		$adminName = "searchAdmin.cgi";
	}
	if (!$analysisName){
		$analysisName = "searchAnalysis.cgi";
	}
	if (!$searchName){
		$searchName = "/cgi-bin/RS.cgi";
	}
	
	#Reading the format file and the local one if it exists
	&$sub_read_format ;
	
	# Reading the input from the form
	&read_input ;
	
	#Doing the job
	$tool = $FORM{'tool'} || $deftool;
	$focus = $FORM{'focus'};
	$langcm = $FORM{'langcm'};
	$displang = $FORM{'displang'};
	$ep = $FORM{'ep'}	|| 'bysite' ;

	if ($permissions{$username} =~ /\,/ ) {
		$permissionSplit = 1 ;
		@focusList = split(/\,/,$permissions{$username}) ;
	} else {
		$permissionSplit = 0 ;
	}
	
	#Then Reading Language file
	if (!$displang) { &readCookie("displang"); }
	if (!$displang) { $displang = "en"; }
	$DISPLANG = $displang ;
	$DISPLANG =~ tr/a-z/A-Z/ ;
	
	$formatfile = "/RSCentral/AdminScripts/formatlang_".$displang;
	&$sub_read_format;

	if ($localformatfile){
		$formatfile = $localformatfile;
		&$sub_read_format ;
	}

	# Print the content type depending on tool used
	if ($tool ne "getrawstats" && $tool ne "groupcustommessages" ){   # 
			print "Content-type: text\/html\n\n";
	} else {
			print "Content-type: text\/tab-separated-values\n\n";
	}
	
	# Work out the focus if not existing and also make sure that the focus is allowed for the username
	&workoutFocus;

	if ($tool eq "groupcustommessages"){
		&readGroupCMs;
	}
	if ($tool eq "profile"){
		&readProfileFile;
	}
	if ($tool eq "pages404"){
		&get404pages;
	}
	if ($tool eq "loc404"){
		&localise404;
	}
	if ($tool eq 'cur' && $company eq 'Shell') {
		$DB             = 'DBI:mysql:shelltools:db1'            ;
		$DBusername     = 'shelladmin'                          ;
		$DBpassword     = 'olivertwist'                         ;
	}
	if ($tool eq "cm"){
		if (!$advancedCM){
			&customessaging;
		} elsif ($advancedCM && ($focus eq "corporate" || $focus eq "home") ) {
			&advancedcustomessaging;
		} else {
			&customessaging;
			undef $advancedCM;
		}
	}
	if ($tool eq "errorpages"){
		&errorpages;
	}
	if ($tool eq "getrawstats"){
		&getrawstats;
	}
	
	#Create drop-down menu
	&doDropDownMenu;
	
	# Writing the output unless the tool is getrawstats for which it is not required
	if ($tool ne "getrawstats" && $tool ne "groupcustommessages"){
		&$sub_write_output ;
		&getthistime('End of HTML processing');
		print "\n\n\n<!--This process took ".$timeval{'postoutput'}." seconds to complete-->" ;
		if ($tool eq "pages404"){ $extrainf = $url404;}
		elsif ($tool eq "loc404"){ $extrainf = $locurl;}
		elsif ($tool eq "cm" && $langcm){ $extrainf = $langcm;}
		elsif ($tool eq "errorpages"){ $extrainf = $FORM{'epsite'};}
		elsif ($tool eq "getrawstats"){ $extrainf = "$day/$month/$year";}
	}
	
	#Pre-processing
	if ($hostname !~ /193\.131\.98/){
		open(ANALYSISLOGGING,">>/RSCentral/Logs/log_SearchAdmin");
		$datenow =`date`;
		chop $datenow;
		#print ANALYSISLOGGING $hostname."\t".$username."\t".$datestamp."\t".$scriptname."\t".$analyse."\t".$timeval{'postoutput'}."\t".($buffer || $ENV{'QUERY_STRING'})."\n" ;
		if (!$tool){
		print ANALYSISLOGGING $hostname."\t".$username."\t".$datestamp."\t".$company."\t".$timeval{'postoutput'}."\t".$focus."\tindex\t".$extrainf."\n";
		} else {
		print ANALYSISLOGGING $hostname."\t".$username."\t".$datestamp."\t".$company."\t".$timeval{'postoutput'}."\t".$focus."\t".$tool."\t".$extrainf."\n";
		}
		close(ANALYSISLOGGING);
	}
}

sub workoutFocus {
	if ($permission eq "all"){
		if (!$focus){ $focus = "corporate";	}
		push @focuslist,"corporate";
		$multifocus = "1";
		foreach $key (sort keys %permissions){
			if ($permissions{$key} eq 'all'){
				next;
			} elsif ($permissions{$key} !~ /\,/){
				push @focuslist,$permissions{$key};
			} else {
				$_ = $permissions{$key};
				push (@focuslist, /(.*?)\,/);
			}
		}
	} elsif ($permission =~ /\,/){
		@focuslist = split(/\,/,$permission);
		$multifocus = "1";
		if (!$focus){
			#$focus = $focuslist[0];
		} elsif ($focus && ($permission !~ /$focus/)){
			$focus = $focuslist[0];
		}
	} else {
		$multifocus = "";
		$focus = $permission;
	}
}

sub doDropDownMenu{
	if ($displang eq "en"){
		$fullname{'en'} = "English";
		$fullname{'fr'} = "French";
		$fullname{'de'} = "German";
		$fullname{'es'} = "Spanish";
		$fullname{'nl'} = "Dutch";
		$fullname{'pt'} = "Portuguese";
		$fullname{'it'} = "Italian";
		$titletext = "[[IF ($company ne 'Shell')]]Custom Messages[[/IF]][[IF ($company eq 'Shell')]]Recommended Links[[/IF]]";
		$profiletext = "Group website status";
		$rawstatext = "Raw statistics";
		$analtext = "Search Analysis";
		foreach $extra (keys %extraTool){
			${$extra."text"} = $text_en{$extra};
		}
	} elsif ($displang eq "fr"){
		$fullname{'en'} = "Anglais";
		$fullname{'fr'} = "Fran&ccedil;ais";
		$fullname{'de'} = "Allemand";
		$fullname{'es'} = "Espagnol";
		$fullname{'nl'} = "Hollandais";
		$fullname{'pt'} = "Portuguais";
		$fullname{'it'} = "Italien";
		$titletext = "[[IF ($company ne 'Shell')]]Messagerie[[/IF]][[IF ($company eq 'Shell')]]Liens Recommand&eacute;s[[/IF]]";
		$profiletext = "Status des sites";
		$rawstatext = "Statistiques brutes";
		$analtext = "Analyse des recherches";
		foreach $extra (keys %extraTool){
			${$extra."text"} = $text_fr{$extra};
		}
	} elsif ($displang eq "de"){
		$fullname{'en'} = "Englisch";
		$fullname{'fr'} = "Franz&ouml;sisch";
		$fullname{'de'} = "Deutsch";
		$fullname{'es'} = "Spanisch";
		$fullname{'nl'} = "Holl&auml;ndisch";
		$fullname{'pt'} = "Portugiesisch";
		$fullname{'it'} = "Italienisch";
		$titletext = "[[IF ($company ne 'Shell')]]Direktverweise[[/IF]][[IF ($company eq 'Shell')]]Empfohlene Links[[/IF]]";
		$profiletext = "Status aller Websites";
		$rawstatext = "Rohstatistiken";
		$analtext = "Suchanalyse";
		foreach $extra (keys %extraTool){
			${$extra."text"} = $text_de{$extra};
		}
	} elsif ($displang eq "es"){
		$fullname{'en'} = "Ingl&eacute;s";
		$fullname{'fr'} = "Franc&eacute;s";
		$fullname{'de'} = "Allem&aacute;n";
		$fullname{'es'} = "Espa&ntilde;ol";
		$fullname{'nl'} = "Holland&eacute;s";
		$fullname{'pt'} = "Portugu&eacute;s";
		$fullname{'it'} = "Italiano";
		$titletext = "[[IF ($company ne 'Shell')]]Mensajera[[/IF]][[IF ($company eq 'Shell')]]Enlaces Recomendados[[/IF]]";
		$profiletext = "Estatus de los sitios";
		$rawstatext = "Estad&iacute;sticas en bruto";
		$analtext = "An&aacute;lisis de b&uacute;squedas";
		foreach $extra (keys %extraTool){
			${$extra."text"} = $text_es{$extra};
		}
	}
	# Will basically push values in two different arrays > printable when using the indices
	# We are starting with CM for the various language
	if ($defdisp){
		foreach ${langcm_.$focus} (@{langcm_.$focus}) {
		push @displayCMTitle,"$titletext - $fullname{${langcm_.$focus}}";
		push @displayCMUrl,"$adminName?tool=cm~langcm=${langcm_.$focus}~focus=$focus";
		}
	} else {
		push @displayCMTitle,"$titletext";
		push @displayCMUrl,"$adminName?tool=cm~focus=$focus";
	}
	# This pushes the Index Profile for Corporate only
	if ($focus eq 'corporate'){
		push @displayTitle,"$profiletext";
		push @displayUrl,"$adminName?tool=profile~focus=$focus";
	}
	# This pushes the Raw Stats for Corporate only
	if ($focus eq 'corporate'){
		push @displayTitle,"$rawstatext";
		push @displayUrl,"$adminName?tool=rawstats~focus=$focus";
	}
	# This pushes the Raw Stats for Corporate only
	if ($CSTON > 0.5){
		push @displayTitle,"[[CST_MENUTITLE]]";
		push @displayUrl,"[[adminName]]?tool=commonsug~focus=[[focus]]";
	}
	# This is the search analysis, for all focus
	push @displayTitle,"$analtext";
	push @displayUrl,"$analysisName";
	
	# Here we are pushing the extras in the menu depending on the permission
	foreach $extra (keys %extraTool){
		if ($focallowed{$extra} eq "all"){
			push @displayTitle,${$extra."text"};
			push @displayUrl,"$adminName?tool=$extra~focus=$focus"
		} elsif ($focallowed{$extra} ne "all" && $focus eq 'corporate'){#print $focallowed{$extra}." ".$extra;
			push @displayTitle,${$extra."text"};
			push @displayUrl,"$adminName?tool=$extra~focus=$focus";
		}
	}
	
	$longueurCM = @displayCMUrl - 1;
	$longueurMENU = @displayUrl - 1;
	#for ($i = 0; $i <= $longueurCM; $i++){
	#	print $langcm_corporate[$i]."\t".$displayCMTitle[$i]."\t".$displayCMUrl[$i]."\n";
	#}
	#print $longueurCM;
}

sub readProfileFile{
	$i = 0;
	open(READFILE, "$profileFile") ;
	while(!eof(READFILE)) {
		$_ = <READFILE> ;
		chomp;
    	($url,$title,$page,$p404,$otherinf) = split(/\t/,$_);
		if ($url){
			push @url,$url; push @title,$title; push @page,$page; push @p404,$p404; push @otherinf,$otherinf; 
			$pagetot = $pagetot + $page;
			$p404tot = $p404tot + $p404;
		}
		#print "$url-$title-$page-$p404-$otherinf\n";
	}
	close (READFILE);
	$numsites = @url;
	$longueur = @url - 1;
}

sub get404pages {
	$i = 1;
	$url404 = $FORM{'url404'};
	$p404 = $FORM{'p404'};
	$pagenumb = $FORM{'pagenumb'};
	$command = "fgrep 'code 404' $logfile | grep '$url404'";
	$DEBUG .= "<!-- command: ".$command."-->\n\n" ;
	open(LOGFILE, " $command |");
	while (!eof(LOGFILE)){
		$_ = <LOGFILE>;
		chomp;
		(${'broken'.$i}) = /^(.*)\s*Failed\s*code.*$/;
		${'displaybroken'.$i} = ${'broken'.$i} ;
		${'broken'.$i} =~ s/\%20/'*'/eigs ;
		${'broken'.$i} =~ s/\s+/'*'/eigs ;
		$i++;
		$DEBUG .= "<!--Broken: ".${'broken'.$i}."-->\n" ;
	}
	close (LOGFILE);
	$numbroken = $i;
	$DEBUG .= "\n\n" ;
}

sub localise404 {
	use sigtrap;
	use Socket;
	$includeOtherFiles = "true";
	$locurl = $FORM{'locurl'};
	$query = "link:".$locurl;
	&$sub_do_search(0,1000);
}

sub customessaging {
	# You can specify $suggesName in local script if different from "suggestions"
	if (!$suggesName){
		$suggesName = "suggestions";
	}
	
	# Check for an $overridecharset{...}
	if ( $overridecharset{$Xfocus} )  {
		$charset = $overridecharset{$Xfocus} ;
	}
	
	# Set $suggestionfile depending on the $focus
	if ($focus eq "corporate"){
		$suggestionfile = $HTMLroot."/".$suggesName;
	} else {
		$suggestionfile = $HTMLroot."/subdivisions/".$focus."/".$suggesName;
	}
	# Append the language if necessary ($defdisp has been set to 1 in local script)
	if ($defdisp){
		$suggestionfile .= "_".$langcm;
	}
	if ($ENV{"REQUEST_METHOD"} eq "GET"){ 
	  &readsugg;
	} elsif ($ENV{"REQUEST_METHOD"} eq "POST") {
	  &writesugg;
	  &readsugg;
	}
	$longueur = @word - 1; # This isn't the real length but length - 1 because array indices start at 0
	#for ($i = 0; $i < $longueur; $i++){
	#	print $i." ".$word[$i]." ".$url[$i]." ".$title[$i]."\n";
	#}
}

sub readsugg {
	print "<!--".$suggestionfile."-->\n" ;
	open(SG, $suggestionfile) || die("can't open $suggestionfile");
	$i = 0;
	while(<SG>){
		chomp;
		($hword,$hurl,$htitle) = split(/\t/,$_);
		$hword =~ tr/A-Z/a-z/;
		$hurl{'mess'.$hword.$i} = $hurl;
		$htitle{'mess'.$hword.$i} = $htitle;
		$hword{'mess'.$hword.$i} = $hword;
	$i++;
	}
	foreach $mess (sort keys %hword){
		if (!$hword{$mess}){
			next;
		} else {
			push (@word,$hword{$mess});
			push (@url,$hurl{$mess});
			push (@title,$htitle{$mess});
		}
	}
}

sub writesugg{
	open(SG,">$suggestionfile") || die;
	for ($i = 1; $i < 4; $i++){
		if (${XwordNew.$i}){
			print SG "${XwordNew.$i}\t${XurlNew.$i}\t${XtitleNew.$i}\n";
		} else {
			next;
		}
	}
	for ($j = 0; $j < $Xlongueur + 1; $j++){
		if (${Xword.$j}){
			print SG "${Xword.$j}\t${Xurl.$j}\t${Xtitle.$j}\n";
		}
	}
	close (SG);
}

sub advancedcustomessaging{
	# You can precise $suggesName in local script if different from "suggestions"
	if (!$suggesName){
		$suggesName = "suggestions";
	}
	#Set $suggestionfile depending on the $focus
	if ($focus eq "corporate"){
		$suggestionfile = $HTMLroot."/".$suggesName;
	} else {
		$suggestionfile = $HTMLroot."/subdivisions/".$focus."/".$suggesName;
	}
	#Append the language if necessary ($defdisp has been set to 1 in local script)
	if ($defdisp){
		$suggestionfile .= "_".$langcm;
	}
	#print $suggestionfile;
	if ($ENV{"REQUEST_METHOD"} eq "GET"){ 
	  &advancedreadsugg;
	} elsif ($ENV{"REQUEST_METHOD"} eq "POST") {
	  &advancedwritesugg;
	  &advancedreadsugg;
	}
	$longueur = @word - 1; # This isn't the real length but length - 1 because array indices start at 0
	#for ($i = 0; $i < $longueur; $i++){
	#	print $i." ".$word[$i]." ".$url[$i]." ".$title[$i]."\n";
	#}
}

sub advancedreadsugg {
	open(SG, $suggestionfile) || die;
	$i = 0;
	while(<SG>){
		chomp;
		($hword,$hurl,$htitle,$hwhen,$hsite,$hmode) = split(/\t/,$_);
		$hword =~ tr/A-Z/a-z/;
		$hwhenx = scalar(gmtime($hwhen));
    	$hwhenx =~ s/\d\d\:\d\d\:\d\d//;
		
		$hurl{'mess'.$hword.$i} = $hurl;
		$htitle{'mess'.$hword.$i} = $htitle;
		$hwhen{'mess'.$hword.$i} = $hwhen;
		$hwhenx{'mess'.$hword.$i} = $hwhenx;
		$hsite{'mess'.$hword.$i} = $hsite;
		$hmode{'mess'.$hword.$i} = $hmode;
		$hword{'mess'.$hword.$i} = $hword;
	$i++;
	}
	foreach $mess (sort keys %hword){
		if (!$hword{$mess}){
			next;
		} else {
			push (@word,$hword{$mess});
			push (@url,$hurl{$mess});
			push (@title,$htitle{$mess});
			push (@whenx,$hwhenx{$mess});
			push (@when,$hwhen{$mess});
			push (@site,$hsite{$mess});
			push (@mode,$hmode{$mess});
		}
	}
}

sub advancedwritesugg {
	$todayDate = time;
	open(SG,">$suggestionfile") || die;
	for ($i = 1; $i < 4; $i++){
		if (${XwordNew.$i}){
			print SG "${XwordNew.$i}\t${XurlNew.$i}\t${XtitleNew.$i}\t$todayDate\t${XsiteNew.$i}\t${XmodeNew.$i}\n";
		} else {
			next;
		}
	}
	for ($j = 0; $j < $Xlongueur + 1; $j++){
		if (${Xword.$j}){
			#print "${Xword.$j}\t${Xurl.$j}\t${Xtitle.$j}\t${Xwhen.$i}\t${Xsite.$i}\t${Xmode.$i}<BR>";
			print SG "${Xword.$j}\t${Xurl.$j}\t${Xtitle.$j}\t${Xwhen.$j}\t${Xsite.$j}\t${Xmode.$j}\n";
		}
	}
	close (SG);
}

sub getrawstats{
	$day = $FORM{'day'};
	$month = $FORM{'month'};
	$year = $FORM{'year'};
	$span = $FORM{'span'};
	if ($day eq $thisday && $month eq $thismonth && $year eq $thisyear){
		$analfile = "/export/".$company."/dblog/analysis.log";
	} else {
		$analfile = "/export/".$company."/dblog/analysis/".$year."/".$month."/".$year."_".$month."_".$day.".log";
	}
	
	print "IP\tDate\tSubdivision\tSearch Term\tNumber of hits\tLanguage\tMethod\tSection\tURL selected\tLast modification\n";
	open(SG, $analfile) || die;
	while(<SG>){
		chomp;
		($ip,$date,$script,$subdiv,$term,$hits,$listby,$time1,$time2,$time3,$time4,$rsbox,$port,$lang,$method,$section,$selecturl,$lastmod,$what1,$what2 ) = split(/\t/,$_);
		if ($focus eq "corporate"){
			print "$ip\t$date\t$subdiv\t$term\t$hits\t$lang\t$method\t$section\t$selecturl\t$lastmod\n";
		} elsif ($focus ne "corporate" && $focus eq $subdiv) {
			print "$ip\t$date\t$subdiv\t$term\t$hits\t$lang\t$method\t$section\t$selecturl\t$lastmod\n";
		} else { next;}
	}
}

sub getthistime {
	@finishTime = gettimeofday;                                                                                                  
	for ($finishTime[1], $startTime[1]) { $_ /= 1_000_000 }                          
	$duration = ($finishTime[0]-$startTime[0])+($finishTime[1]-$startTime[1]) ;         
	$timeval{$_[0]} = int($duration*10000)/10000;
#	print "<!--Time at ".$_[0]." is ".$timeval{$_[0]}."-->\n" ;
}

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

sub errorpages {
	use sigtrap;
	use Socket;
	$includeOtherFiles = "true";
	if ($ep eq "bysite" ) {
		$query = "errorpage:ErrorPage";
		&$sub_load_titles ;
		&$sub_do_search(0,-1);
		$siteno = 0;
		foreach $site (sort sitename_ordering keys %invtitles) {
			if ($invtitles{$site} !~ /siteId=\w*/ ) { next ;}
			#get siteId for this title
			$_ = $invtitles{$site} ;
			($thisSiteId) = /^.*siteId=([^=\&]*).*$/i ;
			#print "<!-- ThissiteId = ".$thisSiteId."-->\n" ;
			if ( $permissions{$username} eq "all" || ( $invtitles{$site} =~ /siteId=$permissions{$username}/ ) || (($permissionSplit == 1 && grep($thisSiteId eq $_,@focusList))) ) {
				$sitenum = $xntitle{$site};
#				if (($persite[$sitenum]*1) < 0.2) { next ; }
				if (($persite[$sitenum]*1) > 0) { $siteCount++ ; }
				$siteno++ ;
				$siteerrorcount{$siteno} = $persite[$sitenum];
				$totalerrors = $totalerrors + $persite[$sitenum] ;
				${'siteerrorcount'.$siteno} = $persite[$sitenum];
				${'sitename'.$siteno} = $site ;
				${'siteurl'.$siteno} = $invtitles{$site} ;
			}
		}
		$totalerrors = $totalerrors * 1 ;
	} elsif ($ep eq "byscore" ) {
		$query = "errorpage:ErrorPage urlmatch(http://".$FORM{'epsite'}.")";
		&$sub_load_titles ;
		$siteName = $titles{$FORM{'epsite'}} ;
		&$sub_do_search(0,1000);
		$score = 0 ;
		foreach $url (sort keys %dtitle) {
			$score++ ;
			${'title'.$score} = $dtitle{$url} ;
			${'url'.$score} = $url ;
		}		
	} elsif ($ep eq "locate") {
		$includeOtherFiles = "true";
		$locateurl = $FORM{'locateurl'} ;
		$query = "link:".$locateurl ;
		&$sub_do_search(0,1000);
	}
}

sub readGroupCMs {
	$cmdir = "/export/".$company."/www/subdivisions/*/suggestions" ;
#	print $cmdir."<br>" ;
	open(FILES,"ls -1 $cmdir | ") ;
	print "siteId\tWord/Phrase\tURL\tTitle\tOriginal date\tOwner\tModerator\n" ;
	while (<FILES>) {
		chomp ;
		$cmfile = $_ ;
		($cmsubdiv) = /subdivisions\/([^\/]*)\// ;
#		print $cmsubdiv." ".$_."<br>\n" ;
		open(SG,$cmfile) ;
		while(<SG>){
			chomp;
			($word,$url,$title,$col1,$col2,$col3) = split(/\t/,$_);
			$word =~ tr/A-Z/a-z/;
			if (!$word){ next; }
			print $cmsubdiv."\t".$word."\t".$url."\t".$title."\t" ;
			if ($col1) {
				print &displayDate($col1,1) ;
			} else {
				print "no date" ;
			}
			print "\t".$col2."\t".$col3."\n" ;
		}
	}
		
}


1;

