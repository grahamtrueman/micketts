#!/usr/bin/perl -w

##############################################
#                                            #
# Various Search subroutines required for RS #
#                                            #
##############################################

# Subroutine_names in order of appearance in this script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$sub_initialize          = "initialize"         ;
$sub_read_input          = "read_input"         ;
$sub_readlang            = "readlang"           ;
$sub_read_format         = "read_format"        ;
$sub_load_titles         = "load_titles"        ;
$sub_load_passworddirs   = "load_passworddirs"  ;
$sub_readsuggestions     = "readsuggestions"    ;
$sub_readcommonsug       = "readcommonsug"      ;
$sub_html_header         = "html_header"        ;
$sub_html_trailer        = "html_trailer"       ;
$sub_html_error          = "html_error"         ;
$sub_suggestions         = "suggestions"        ;
$sub_geturldefault       = "geturldefault"      ;
$sub_getpageurl          = "getpageurl"         ;
$sub_getpageurlsite      = "getpageurlsite"     ;
$sub_getexiturl          = "getexiturl"         ;
$sub_getpageurlagain     = "getpageurlagain"    ;
$sub_getpageurlcategory  = "getpageurlcategory" ;
$sub_reslinks            = "reslinks"           ;
$sub_outres              = "outres"             ;
$sub_reslinks            = "reslinks"           ;
$sub_excludefile         = "excludefile"        ;
$sub_spellingsuggestions = "spellingsuggestions";
$sub_getspellingurl      = "getspellingurl"     ;
$sub_URLise	             = "URLise"             ;
$sub_english             = "english"            ;
$sub_french              = "french"             ;
$sub_german              = "german"             ;
$sub_swedish             = "swedish"            ;
$sub_japanese            = "japanese"           ;
$sub_chinese             = "chinese"            ;
$sub_spanish             = "spanish"            ;
$sub_italian             = "italian"            ;
$sub_dutch               = "dutch"              ;
$sub_portuguese          = "portuguese"         ;
$sub_polish          	 = "polish"         	;
$sub_languageenglish     = "languageenglish"    ;
$sub_languagefrench      = "languagefrench"     ;
$sub_languagegerman      = "languagegerman"     ;
$sub_languageswedish     = "languageswedish"    ;
$sub_languagejapanese    = "languagejapanese"   ;
$sub_languagechinese     = "languagechinese"    ;
$sub_languagespanish     = "languagespanish"    ;
$sub_languageportuguese  = "languageportuguese" ;
$sub_languagepolish  	 = "languagepolish" 	;
$sub_languagedutch       = "languagedutch"      ;
$sub_languageitalian     = "languageitalian"    ;
$sub_gettime             = "gettime"            ;


# Subroutines...
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub initialize {
	# to be overridden in RSlocal
}

sub geturldefault {
	$RETURNString .= "~siteId=".$siteId if $siteId ;
	$RETURNString .= "~resultpage=".&esp($Xresultpage) if $Xresultpage ;
	$RETURNString .= "~resultspage=".&esp($Xresultspage) if $Xresultspage ;
	$RETURNString .= "~subdivision=".&esp($Xsubdivision) if $Xsubdivision ;
	$RETURNString .= "~method=".&esp($Xmethod) if $Xmethod ;
	$RETURNString .= "~orgsection=".&esp($orgsection || $secname) if ($orgsection || $secname) ;
	$RETURNString .= "~language=".$Xlanguage if $Xlanguage ;
	$RETURNString .= "~lastmod=".&esp($Xlastmod) if $lastmod ;
	$RETURNString .= "~includeOtherFiles=".$XincludeOtherFiles if $XincludeOtherFiles ;
	$RETURNString .= "~displaylanguage=".&esp($Xdisplaylanguage) if $Xdisplaylanguage ;
	foreach $FORMkey (keys %FORM) { 
		if ($FORM{$FORMkey} && $RETURNString !~ /$FORMkey/ && $FORMkey ne "results_option" ) {
			$RETURNString .= "~".$FORMkey."=".$FORM{$FORMkey};
		}
	}
}

sub getpageurlsite {
	$RETURNString = "" ;
	my($incoming) = $_[0];
	if ( $incoming =~ /^http/i ) {
		$thisselectionurl = $_[0] ;
	} else {
		$thisselectionurl = "http://".$_[0] ;
	}
	if ( $incoming !~ /\?/i && $incoming !~ /\/$/i && $incoming !~ /\.html?$/i ) {
		$thisselectionurl .= "/" ;
	}
	$RETURNString .= "~Search=".&$sub_URLise($XSearch) if $XSearch ;
	$RETURNString .= "~section=selection" ;
	$RETURNString .= "~selectionurls=".$thisselectionurl ;
	$RETURNString .= "~results_option=scores" ;
	$RETURNString .= "~begin=".$begin;
	$RETURNString .= "~wassite=1" ;
	&$sub_geturldefault ;
	$RETURNString =~ s/~(.*?)/$1/ ;
	return $here."?".$RETURNString ;
}

sub getpageurl {
	$RETURNString = "" ;
	$RETURNString .= "~Search=".&$sub_URLise($XSearch) if $XSearch ;
	$RETURNString .= "~section=".$FORM{'section'} if $FORM{'section'} ;
	$RETURNString .= "~selectionurls=".&esp($Xselectionurls) if $Xselectionurls ;
	$RETURNString .= "~results_option=scores" ;
	$RETURNString .= "~begin=".$begin;
	$RETURNString .= "~wassite=".$Xwassite if $Xwassite ;
	&$sub_geturldefault ;
	$RETURNString =~ s/~(.*?)/$1/ ;
	return $here."?".$RETURNString ;
}

sub getpageurlcategory {
	$RETURNString = "" ;
	$_ = $_[0];
        $cattemp = $category;
        $cattemp =~ s/\s/_/g;
	$RETURNString .= "~Search=".&$sub_URLise($XSearch) if $XSearch ;
	$RETURNString .= "~category=".$cattemp if $category;
	$RETURNString .= "~section=".$FORM{'section'} if $FORM{'section'} ;
	$RETURNString .= "~selectionurls=".&esp($Xselectionurls) if $Xselectionurls ;
	$RETURNString .= "~results_option=scores" ;
	$RETURNString .= "~begin=".$begin;
	$RETURNString .= "~wassite=".$Xwassite if $Xwassite ;
	&$sub_geturldefault ;
	$RETURNString =~ s/~(.*?)/$1/ ;
	return $here."?".$RETURNString ;
}

sub getpageurlagain {
	$RETURNString = "" ;
	$RETURNString .= "~Search=".&$sub_URLise($XSearch) if $XSearch ;
	$RETURNString .= "~section=".$FORM{'section'} if $FORM{'section'} ;
	$RETURNString .= "~selectionurls=".&esp($Xselectionurls) if $Xselectionurls ;
	$RETURNString .= "~results_option=scores" ;
	$RETURNString .= "~begin=".$beginagain ;
	$RETURNString .= "~wassite=".$Xwassite if $Xwassite ;
	&$sub_geturldefault ;
	$RETURNString =~ s/~(.*?)/$1/ ;
	return $here."?".$RETURNString ;
}

sub getspellingurl {
	$RETURNString = "" ;
	$RETURNString .= "~Search=".&$sub_URLise($spellingcorrect) if $spellingcorrect ;
	$RETURNString .= "~section=".$FORM{'section'} if $FORM{'section'} ;
	$RETURNString .= "~selectionurls=".&esp($Xselectionurls) if $Xselectionurls ;
	$RETURNString .= "~results_option=".$setdefaultresults if $setdefaultresults ;
	$RETURNString .= "~begin=".$beginagain if $beginagain ;
	$RETURNString .= "~spelling=YES";
	if ($subdivision) { $spellingsection = $FORM{'section'}; }
	&$sub_geturldefault ;
	$RETURNString =~ s/~(.*?)/$1/ ;
	return $here."?".$RETURNString ;
}

sub getexiturl {
	if ($exitscript) {
		return $exitscript.'?Search='.&$sub_URLise($XSearch).'&dest='.$_[0] ;
	} else {
		return $_[0] ;
	}
}

sub esp {
  my($x) = $_[0];
  $x =~ s/([\~\s%&=+\/])/'%'.tohex(ord($1))/eg;
  return $x;
}

sub tohex {
  return sprintf '%x',$_[0];
}

sub URLise {
  my($x) = $_[0];
  $x =~ s/([\s'"\&])/'%'.tohex(ord($1))/eg;
  return $x;
}

sub english {
	$langext = "_en" ;
	$formatfile .= "_en";
	$suggestionfile .= "_en";
	$sitenames .= "_en";
	&$sub_languageenglish;
}

sub languageenglish {
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
		
	$lastmod_blank = "not indicated";
	$languagecode_blank = "unknown";
	$title_blank = "The title for this page is blank";
	$description_blank = "No description available";
}

sub japanese {
	$langext = "_jp" ;
	$formatfile .= "_jp";
	$suggestionfile .= "_jp";
	$sitenames .= "_jp";
	&$sub_languagejapanese;
}

sub languagejapanese{
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
		
	$lastmod_blank = "not indicated";
	$languagecode_blank = "unknown";
	$title_blank = "The title for this page is blank";
	$description_blank = "No description available";
}

sub chinese {
	$langext = "_zh" ;
	$formatfile .= "_zh";
	$suggestionfile .= "_zh";
	$sitenames .= "_zh";
	&$sub_languagechinese;
}

sub languagechinese{
	%renamedate = (
		"Mon" , "&#26143;&#26399;&#19968;",
		"Tue" , "&#26143;&#26399;&#20108;",
		"Wed" , "&#26143;&#26399;&#19977;",
		"Thu" , "&#26143;&#26399;&#22235;",
		"Fri" , "&#26143;&#26399;&#20116;",
		"Sat" , "&#26143;&#26399;&#20845;",
		"Sun" , "&#26143;&#26399;&#26085;",
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
		
	$lastmod_blank = "&#26410;&#36755;&#20837;";
	$languagecode_blank = "&#26410;&#36755;&#20837;";
	$title_blank = "&#26412;&#39029;&#26631;&#39064;&#31354;&#30333;";
	$description_blank = "&#27809;&#26377;&#25552;&#20379;&#35828;&#26126;";
	$language_table = "/usr/RemoteSearch/Corpora/lang_zh.tab";
}

sub french {
	$langext = "_fr" ;
	$formatfile .= "_fr";
	$suggestionfile .= "_fr";
	$sitenames .= "_fr";
	&$sub_languagefrench;
}

sub languagefrench {
	$lastmod_blank = "non indiqu&eacute;";
	$languagecode_blank = "un language non identifi&eacute;";
	$title_blank = "Le titre de cette page est absent";
	$description_blank = "Pas de description disponible";
	$language_table = "/usr/RemoteSearch/Corpora/lang_fr.tab";
   
	%renamedate = (
		"Mon" , "Lundi",
		"Tue" , "Mardi",
		"Wed" , "Mercredi",
		"Thu" , "Jeudi",
		"Fri" , "Vendredi",
		"Sat" , "Samedi",
		"Sun" , "Dimanche",
		"Jan" , "Janvier",
		"Feb" , "F&eacute;vrier",
		"Mar" , "Mars",
		"Apr" , "Avril",
		"May" , "Mai",
		"Jun" , "Juin",
		"Jul" , "Juillet",
		"Aug" , "A&ocirc;ut",
		"Sep" , "Septembre",
		"Oct" , "Octobre",
		"Nov" , "Novembre",
		"Dec" , "D&eacute;cembre",
	);
}

sub german {
	$langext = "_de" ;
	$formatfile .= "_de";
	$suggestionfile .= "_de";
	$sitenames .= "_de";
	&$sub_languagegerman;
}

sub languagegerman{
   $lastmod_blank = "- leider keine Angabe vorhanden -";
   $languagecode_blank = "mehreren Sprachen";
   $title_blank = "Es konnte keine Seitenbeschreibung gefunden werden.";
   $description_blank = "Leider keine Beschreibung verf&uuml;gbar.";
   $language_table = "/usr/RemoteSearch/Corpora/lang_de.tab";
   $setplural = "n";
     
	%renamedate = (
		"Mon" , "Montag",
		"Tue" , "Dienstag",
		"Wed" , "Mittwoch",
		"Thu" , "Donnerstag",
		"Fri" , "Freitag",
		"Sat" , "Samstag",
		"Sun" , "Sonntag",
		"Jan" , "Januar",
		"Feb" , "Februar",
		"Mar" , "M&auml;rz",
		"Apr" , "April",
		"May" , "Mai",
		"Jun" , "Juni",
		"Jul" , "Juli",
		"Aug" , "August",
		"Sep" , "September",
		"Oct" , "Oktober",
		"Nov" , "November",
		"Dec" , "Dezember",
	);

}

sub spanish {
	$langext = "_es" ;
	$formatfile .= "_es";
	$suggestionfile .= "_es";
	$sitenames .= "_es";
	&$sub_languagespanish;
}

sub languagespanish {
	$lastmod_blank = "no indicado";
	$languagecode_blank = "un lenguaje desconocido";
	$title_blank = "Esta p&aacute;gina no tiene t&iacute;tulo";
	$description_blank = "No tiene descripci&oacute;n";
	$language_table = "/usr/RemoteSearch/Corpora/lang_es.tab";
   
	%renamedate = (
		"Mon" , "Lunes",
		"Tue" , "Martes",
		"Wed" , "Miercoles",
		"Thu" , "Jueves",
		"Fri" , "Viernes",
		"Sat" , "S&aacute;bado",
		"Sun" , "Domingo",
		"Jan" , "Enero",
		"Feb" , "Febrero",
		"Mar" , "Marzo",
		"Apr" , "Abril",
		"May" , "Mayo",
		"Jun" , "Junio",
		"Jul" , "Julio",
		"Aug" , "Agosto",
		"Sep" , "Septiembre",
		"Oct" , "Octubre",
		"Nov" , "Noviembre",
		"Dec" , "Diciembre",
	);
}

sub italian {
	$langext = "_it" ;
	$formatfile .= "_it";
	$suggestionfile .= "_it";
	$sitenames .= "_it";
	&$sub_languageitalian;
	$setsingular = "o";
	$setplural = "i";
}

sub languageitalian {
	%renamedate = (
		"Mon" , "Lunedi",
		"Tue" , "Martedi",
		"Wed" , "Mercoledi",
		"Thu" , "Giovedi",
		"Fri" , "Venerdi",
		"Sat" , "Sabato",
		"Sun" , "Domenica",
		"Jan" , "Gennaio",
		"Feb" , "Febbraio",
		"Mar" , "Marzo",
		"Apr" , "Aprile",
		"May" , "Maggio",
		"Jun" , "Giugno",
		"Jul" , "Luglio",
		"Aug" , "Agosto",
		"Sep" , "Settembre",
		"Oct" , "Ottobre",
		"Nov" , "Novembre",
		"Dec" , "Dicembre",
		);
		
	$lastmod_blank = "non indicato";
	$languagecode_blank = "un linguaggio sconoscioto";
	$title_blank = "questa pagina non ha titolo";
	$description_blank = "non ha descrizione";
	$language_table = "/usr/RemoteSearch/Corpora/lang_it.tab";
}

sub dutch {
	$langext = "_nl" ;
	$formatfile .= "_nl";
	$suggestionfile .= "_nl";
	$sitenames .= "_nl";
	&$sub_languagedutch;
#	$setplural = "'s";		# Plural for pagina; different plural: resultaat, resultaten
}

sub languagedutch {
	%renamedate = (
		"Mon" , "maandag",
		"Tue" , "dinsdag",
		"Wed" , "woensdag",
		"Thu" , "donderdag",
		"Fri" , "vrijdag",
		"Sat" , "zaterdag",
		"Sun" , "zondag",
		"Jan" , "januari",
		"Feb" , "februari",
		"Mar" , "maart",
		"Apr" , "april",
		"May" , "mei",
		"Jun" , "juni",
		"Jul" , "juli",
		"Aug" , "augustus",
		"Sep" , "september",
		"Oct" , "oktober",
		"Nov" , "november",
		"Dec" , "december",
		);
		
	$lastmod_blank = "niet aangeduid";
	$languagecode_blank = "onbekend";
	$title_blank = "Blanco titel voor deze pagina";
	$description_blank = "Geen beschrijving beschikbaar";
	$language_table = "/usr/RemoteSearch/Corpora/lang_nl.tab";
}

sub portuguese {
	$langext = "_pt" ;
	$formatfile .= "_pt";
	$suggestionfile .= "_pt";
	$sitenames .= "_pt";
	&$sub_languageportuguese;
}

sub languageportuguese {
	%renamedate = (
		"Mon" , "Segunda",
		"Tue" , "Ter&ccedil;a",
		"Wed" , "Quarta",
		"Thu" , "Quinta",
		"Fri" , "Sexta",
		"Sat" , "S&aacute;bado",
		"Sun" , "Domingo",
		"Jan" , "Janeiro",
		"Feb" , "Fevereiro",
		"Mar" , "Mar&ccedil;o",
		"Apr" , "April",
		"May" , "Pode",
		"Jun" , "Junho",
		"Jul" , "Julho",
		"Aug" , "Agosto",
		"Sep" , "Setembro",
		"Oct" , "Outubro",
		"Nov" , "Novembro",
		"Dec" , "Dezembro",
		);
		
	$lastmod_blank = "n&atilde;o indicado";
	$languagecode_blank = "desconhecido";
	$title_blank = "O t&iacute;tulo para esta p&aacute;gina &eacute; em branco";
	$description_blank = "Nenhuma descri&ccedil;&atilde;o dispon&iacute;vel";
	$language_table = "/usr/RemoteSearch/Corpora/lang_pt.tab";	
}

sub swedish {
	$langext = "_sv" ;
	$formatfile .= "_sv";
	$suggestionfile .= "_sv";
	$sitenames .= "_sv";
	&$sub_languageswedish;
}

sub languageswedish {
   $lastmod_blank = "information saknas";
   $languagecode_blank = "ej identifierat språk";
   $title_blank = "Sidan har ingen titel";
   $description_blank = "Sidan har ingen beskrivning";
   $language_table = "/usr/RemoteSearch/Corpora/lang_sv.tab";
}

sub polish {
	$langext = "_pl" ;
	$formatfile .= "_pl";
	$suggestionfile .= "_pl";
	$sitenames .= "_pl";
	&$sub_languagepolish;
}

sub languagepolish{
	$lastmod_blank = "nie jest okreslona";
	$languagecode_blank = "nieznanym j&#281;zyku";
	$title_blank = "Ta strona nie posiada tytu&#322;u";
	$description_blank = "Bez opisu";
	$language_table = "/usr/RemoteSearch/Corpora/lang_pl.tab";
#	$setplural = "y";
#	$setsingular = "a";
     
	%renamedate = (
		"Mon" , "Poniedzia&#322;ek",
		"Tue" , "Wtorek",
		"Wed" , "&#346;roda",
		"Thu" , "Czwartek",
		"Fri" , "Pi&#261;tek",
		"Sat" , "Sobota",
		"Sun" , "Niedziela",
		"Jan" , "Stycze&#324;",
		"Feb" , "Luty",
		"Mar" , "Marzec",
		"Apr" , "Kwiecie&#324;",
		"May" , "Maj",
		"Jun" , "Czerwiec",
		"Jul" , "Lipiec",
		"Aug" , "Sierpie&#324;",
		"Sep" , "Wrzesie&#324;",
		"Oct" , "Pa&#378;dziernik",
		"Nov" , "Listopad",
		"Dec" , "Grudzie&#324;",
	);

}

sub read_input {
	if ($ENV{'REQUEST_METHOD'} eq 'POST'){
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
		#Split the Name-Value Pairs on '&'
		@pairs = split(/&/, $buffer);
		foreach $pair (@pairs) {
			($name, $value) = split(/=/ ,$pair);
			$value =~ tr/+/ /;
			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
			$FORM{$name}= $value;
			$POSTED{$name}= $value;
			${'X'.$name} = $value ;
#			print $name."=".$value."~~~<br>\n";
		}
	} else {
		@pairs = split(/\~/, $ENV{'QUERY_STRING'});
		foreach $pair (@pairs) {
			$_ = $pair ;
			($name, $value) = /(.*?)=(.*)/i ; #split(/=/ ,$pair);
			$value =~ tr/+/ /;
			$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
			$FORM{$name}= $value ;
			${'X'.$name} = $value ;
#			print $name."=".$value."~~~<br>\n";
		}
	}
}

sub outres {
	my($name,$exitsubname) = @_;
#	$title = $dtitle{$name};
	$title = "" ;
	$descr = ${'ddescr'.$searchId}{$name} || $description_blank;
#	print "<!--Setting 'ddesc' for searchId=".$searchId." to ".${'ddescr'.$searchId}{$name}."-->\n\n" ;
	$score = ${'dscores'.$searchId}{$name};
	$percent = int ($score/10);
	$bytes = ${'dbytes'.$searchId}{$name};
	$words = ${'dwords'.$searchId}{$name};
	$frameparent = ${'frparent'.$searchId}{$name};
	$frametarget = ${'frtarget'.$searchId}{$name};
	$lastmod = ${'lastmod'.$searchId}{$name};
	$lastmodified = $lastmod? scalar(localtime($lastmod)) : $lastmod_blank;
	##### START CHANGE DATE LANGUAGE #####
	$lastmodified =~ s/(.*?)\s(.*?)\s\s?(.*?)\s(.*?)\s(.*)/$1\s$2\s$3\s$4\s$5/i ;
	foreach $pat (keys %renamedate){
		if ($1 eq $pat){
			$new1 = $renamedate{$pat};
		}
		if ($2 eq $pat){ 
			$new2 = $renamedate{$pat};
		}
	}
	$lastmodified = $new1." ".$3." ".$new2." ".$5." - ".$4;
	if (!$lastmod) {$lastmodified = $lastmod_blank};
	##### END CHANGE DATE LANGUAGE #####
	$language = $languagecode{${'language'.$searchId}{$name}} || $languagecode_blank;
	foreach $f (@displayedfields){
		${$f} = ${'dfields'.$searchId}{$name}{$f};
	}

	$headline=$name;
	$title = ${'dtitle'.$searchId}{$name} ;
	$title =~ s/^\s*//i ;
	$title =~ s/\s*$//i ;
#	$title =~ s/^(.{100})((.*?)(\s)(.*))/$1$3.../i;
	$ispasswordprotected = 0;
	foreach $passworddir (@passworddir){
		if ($headline =~ /$passworddir/){
			$ispasswordprotected = 1; break ;
		}
	}

	if (!$title) { $title = $title_blank ; }
	if ($exitsubname) { $headline = &$exitsubname($headline) ; }
	if ($headline =~ /\.pdf$/i){
		$output = $LISTITEM;
		$output =~ s/\[\[ICON\]\]/$PDFICON/gs;
		if ($ispasswordprotected){
			$output =~ s/\[\[PASSWDICON\]\]/$PASSWORDICON/gs;
		} else {      
			$output =~ s/\[\[PASSWDICON\]\]/$PASSWORDICONBLANK/gs;
		}
		$output = &$sub_output($output) ;
	} elsif ($frameparent && $frametarget){
		$headline1 = $frameprog."?start=".$name ;
		if ($exitsubname) { $headline = &$exitsubname($headline1) ; } 
		if ($exitsubname) { $noframeheadline = &$exitsubname($name) ; } 
		$output = $LISTITEMNOFRAMES;
		if ($ispasswordprotected){
			$output =~ s/\[\[PASSWDICON\]\]/$PASSWORDICON/gs;
		} else {      
			$output =~ s/\[\[PASSWDICON\]\]/$PASSWORDICONBLANK/gs;
		}
		$output =~ s/\[\[ICON\]\]/$HTMLICON/gs;
		$output = &$sub_output($output) ;
	} elsif ($headline =~ /\.doc$/i){
		$output = $LISTITEM;
		if ($ispasswordprotected){
			$output =~ s/\[\[PASSWDICON\]\]/$PASSWORDICON/gs;
		} else {      
			$output =~ s/\[\[PASSWDICON\]\]/$PASSWORDICONBLANK/gs;
		}
		$output =~ s/\[\[ICON\]\]/$DOCICON/gs;
		$output = &$sub_output($output) ;
	} else {
		$output = $LISTITEM;
		if ($ispasswordprotected){
			$output =~ s/\[\[PASSWDICON\]\]/$PASSWORDICON/gs;
		} else {      
			$output =~ s/\[\[PASSWDICON\]\]/$PASSWORDICONBLANK/gs;
		}
		$output =~ s/\[\[ICON\]\]/$HTMLICON/gs;
		$output = &$sub_output($output) ;
	}
	$DOCTYPE = '';
	$output =~ s/\\\[\\\[/'[['/eigs ;
	$output =~ s/\\\]\\\]/']]'/eigs ;
	return $output;
}

sub reslinks {
	$pagelinksoutput = "" ;
	my($tpage,$getlinksub) = @_;
#	my($tpage) = $_[0]-1;
	my($i,$j,$k);
	my($oldbegin) = $begin;
	$tpage--;
	if ($nresults <= $PERPAGE){ return;}
	$ii=0;
	$jj=0;
	$kk=0;
	if ($tpage>4) {
		$xpage = $tpage;
		$last = int(0.999+$nresults/$PERPAGE);
		if ($xpage + $MAXPAGES > $last) {
			$xxpage = 4 + $last - $MAXPAGES;
			if ($xxpage > 3){ $xpage = $xxpage ; } else { $xpage = 4 ; }
		}
		$ii = $PERPAGE * ($xpage - 4) ;
		$jj = $xpage - 4 ;
	}
	$nresultsextra = $nresults;
	if ($nresultsextra > $ii + $PERPAGE * $MAXPAGES){
		$nresultsextra = $ii + $PERPAGE * $MAXPAGES;
	}

#   First Page
	if ($tpage > 4){
		if ($jj > 0){
			$begin = 0;
			$pageno = "1";
			$reslink = &$getlinksub();
			$output = &$sub_output($PAGELINK);
			$pagelinksoutput .= $output;          
		}
		if ($jj>1){
			$pagelinksoutput .= $PAGEGAP;
		} else {
			$pagelinksoutput .= $PAGESEP;
		}
	}
#   Middle pages;
	for($i=$ii,$j=$jj;$i<$nresultsextra;$i+= $perpage,$j++){
		if ($j != $jj){
			$pagelinksoutput .= $PAGESEP;
		}
		$k = $j+1;
		if ($j != $tpage){
			$begin = $i;
#			$reslink = &getpageurl();
			$reslink = &$getlinksub();
			$pageno = $k;
			$output = &$sub_output($PAGELINK);
			$pagelinksoutput .= $output;  
		} else {
			$reslink = "";
			$pageno = $k;
			$output = &$sub_output($THISPAGE);
			$pagelinksoutput .= $output;
		}
	}
	$begin = $oldbegin;
#   Last Page
  
	if ($nresultsextra < $nresults){
		$pagelinksoutput .= $PAGEGAP;
	}
	if ($nresultsextra < $nresults){
		$pageno = int (0.999+$nresults/$perpage);
		$begin = ($pageno-1)*$perpage; 
#		$reslink = &getpageurl();
		$reslink = &$getlinksub();       
		$output = &$sub_output($PAGELINK);
		$pagelinksoutput .= $output;  
	}
	return $pagelinksoutput ;
}


sub suggestions {
	$sug_output = "";
	local($word,$suggest,$qx,$donesome);
	$suggest = "";
	$sugdone = "";
	$qx = $org_query;
	$qx =~ s/\w+://g;
	$qx =~ tr/\(\)//d;
	$qx =~ tr/A-Z/a-z/;
	
	foreach $sug_phrase (keys %suggestion) {
		@sug_phrase_list = split(/\s/,$sug_phrase);
		foreach $sug_word (split(/\s/,$sug_phrase)) {
			if ($qx =~ /^$sug_word$/i || $qx =~ /\s$sug_word\s/i || $qx =~ /^$sug_word\s/i || $qx =~ /\s$sug_word$/i) {
				shift @sug_phrase_list;
			}
		}
		if (!@sug_phrase_list) {
			# append suggestion to output
			# $suggesturl = &$sub_getexiturl($url);
			$donesome = "" ;
			foreach $url ( @{ $suggestion{$sug_phrase} } ){
				if ($donesome) {
					$suggest .= $SUGGESTIONSEP ;
				} else {
					$donesome = "yes" ;
				}
				$suggesturl = &$sub_getexiturl($url);
				$suggestbefore = $suggestafter = "";
				$title = shift ( @{ $suggestiontitle{$sug_phrase} });
				$temp = $SUGGESTIONITEM;
				$numberCustomMessages++ ;
				push(@displayCustomMessages,$url) ;
				$_ = $title;
				if ( /\^(.*?)\^/i ) {
					$_ = $title;
					($suggestbefore,$title,$suggestafter) = /^(.*?)\^(.*?)\^(.*?)$/i ;
				}
				$temp =~ s/\[\[(\w+)\]\]/${$1}/seg;
				$suggest .= $temp;
			}
			# $suggest .= $sugguestion{$sug_phrase};
			$suggbegin = &$sub_output($SUGGESTIONBEGIN) ;
			$sug_output .= $suggbegin;
			$sug_output .= $suggest;
			$sug_output .= &$sub_output($SUGGESTIONEND) ;
			$sug_output .= $SUGGESTIONSEPERATOR;
			$suggest = "";
			@sug_phrase_list = "";
		}
	}
	if ($sug_output) {
		# $temp = $SUGGESTIONTOP;
		# $temp =~ s/\[\[(\w+)\]\]/${$1}/seg;
		# $suggest .= $temp;
		$sug_output = &$sub_output($SUGGESTIONTOP.$sug_output.$SUGGESTIONBOT);
	}
	return $sug_output ;	
}

sub spellingsuggestions {
	$RETURNsp = "" ;
	if ($spellingcount && (!$disablespelling || $disablespelling ne "true" )) {
		$RETURNsp .= $SPELLINGBEGIN ;
		$spellingfullview = $XSearch;
		$spellingfull = $XSearch;
		for ($spsug = 1 ; $spsug <= $spellingcount ; $spsug++) {
			$_ = $spelling[$spsug] ;
			($spellingincorrect,$spellingcorrect) = /(.*?)\s\=\>\s(.*)/i;
			$spellingurl = &$sub_getspellingurl;
			$RETURNsp .= &$sub_output($SPELLINGCORRECTION);
			$spellingview = "<i>".$spellingcorrect."</I>" ;
			$spellingfullview =~ s/$spellingincorrect/$spellingview/;
			$spellingfull =~ s/$spellingincorrect/$spellingcorrect/;
		}
		if ($spellingcount >= 2 || $spellingcorrect ne $spellingfull || $spellingDispFullQuery) {
			$spellingcorrect = $spellingfull ;
			$spellingfullurl = &$sub_getspellingurl;
			$RETURNsp .= &$sub_output($SPELLINGFULLQUERY) ;
		}
		$RETURNsp .= $SPELLINGEND ;
	}
	$RETURNsp =~ s/\\\[\\\[/'[['/eigs ;
	$RETURNsp =~ s/\\\]\\\]/']]'/eigs ;
	return $RETURNsp ;
}

sub readsuggestions {
	local($word,$suggest);
	open(SG,$suggestionfile) || return ;
	while(<SG>){
		chomp;
		($word,$url,$title,$null1,$null2,$null3) = split(/\t/,$_);
		if (!$title || $title =~ /^\s+$/) {next}
		$word =~ tr/A-Z/a-z/;
		if (!$word){next;}
		if ($suggestion{$word}){
			push @{ $suggestion{$word} },$url;
			push @{ $suggestiontitle{$word} },$title;
		} else {
			@ts = ();
			push(@ts,$url);
			$suggestion{$word} = [ @ts ];
			@ts1 = ();
			push(@ts1,$title);
			$suggestiontitle{$word} = [ @ts1 ];
		}
	}
}

sub readcommonsug {
	my($word);
	if ($DB) {
		$dbh = DBI      -> connect($DB,$DBusername,$DBpassword)  || print "<!--FAILED to connect to database: readcommonsug-->";
		foreach $word (split(/\s/,$FORM{'Search'})) {
			@data = "" ;
			#print "<!--$word-->" ;
			$SQL = "SELECT CS.goodword FROM clients,subdivisions,commonsuggestions AS CS WHERE clients.client='".$thiscompany."' AND (subdivisions.subdivision='".($subdivision || 'corporate')."' OR subdivisions.subdivision='global') AND CS.subdivision=subdivisions.id AND CS.badword LIKE '".$word."' LIMIT 0,1" ;
			$DEBUG .= "<!--".$SQL."-->\n\n" if $DEBUGlevel>0.5 ;
			$sth = $dbh         -> prepare($SQL) || print "<!--FAILED to open stub handler: readcommonsug-->";
			$sth                -> execute || print "<!--FAILED: $SQL-->";
			@data = $sth->fetchrow_array() ;
			if ( $data[0] && length($data[0])>0 ) {
				my($goodword) = &unpackhexText($data[0]) ;
				$CSquerydisplay .= " " if $CSquerydisplay ;
				$CSquerydisplay .= "<i>".$goodword."</i>" ;
				$CSquery .= " " if $CSquery ;
				$CSquery .= $goodword ; 
				$CSkey = 1 ;
			} else {
				$CSquerydisplay .= " " if $CSquerydisplay ;
				$CSquerydisplay .= $word ;
				$CSquery .= " " if $CSquery ;
				$CSquery .= $word ; 
			}
			$sth                -> finish();
		}
		$dbh  -> disconnect();
	}
	#print "<!--$CSquerydisplay-->" ;
	#print "<!--$CSquery-->" ;
	$spellingcorrect = $CSquery ;
	$spellingfullurl = &$sub_getspellingurl;
	$CSurl = $spellingfullurl ;
}

sub load_titles {
#	print "SITE NAMES:<br>\n" ;
	open(TI,$sitenames);
	while(<TI>){
		chomp ;
		($url,$title,$sdescr) = split(/\t/);
		$titles{$url} = $title;
		$invtitles{$title} = $url;
		$sdescr =~ s/^\s*// ;
		$sitedescr{$url} = $sdescr;
#		print $title."~~~~".$url."~~~~".$sdescr."~~~~<br>\n";
	}
}

sub load_passworddirs {
	open(PW, $passworddirfile) || return;
	while(<PW>){
		chomp;
		if (!$_){ next;}
		push @passworddir, $_;
	}
}

sub sitename_ordering {
	if ($defaultsiteordering eq "bypagecount") {
		return $persite[$xntitle{$b}] <=> $persite[$xntitle{$a}] ;
	} else {
		if ($a =~ /^$subdivtitle$/){ return -1;}
		if ($b =~ /^$subdivtitle$/){ return 1;}
		return $a cmp $b;
	}
}

sub getservername {
	open(HOSTNAME, "hostname |") || &cannotexecute;
	while(<HOSTNAME>){ 
		$servername = $_;
		chomp $servername;
	}
	close(HOSTNAME);
}

sub html_error {
	$error = $_[0];
	print $error;
	exit;
}

sub gettime {
	@finishTime = gettimeofday;                                                                                                  
	for ($finishTime[1], $startTime[1]) { $_ /= 1_000_000 }                          
	$duration = ($finishTime[0]-$startTime[0])+($finishTime[1]-$startTime[1]) ;         
	$timeval{$_[0]} = int($duration*10000)/10000;
}

sub readlang {
	open(LTA,$language_table) || print "Language table not found";
	while(<LTA>){
		($code,$rest) = /(\w\w)\s(.*)/;
		$languagecode{$code} = $rest if $code;
	}
}

sub readCookie{
	$cookieName = $_[0];
	$cookie = $ENV{'HTTP_COOKIE'};
	$_ = $cookie ; ($cookieVal) = /$cookieName=\s*?([\w]*)/;
	${$cookieName} = $cookieVal ;
}

1;

