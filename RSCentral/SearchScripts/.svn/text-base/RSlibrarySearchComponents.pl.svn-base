#!/usr/bin/perl -w

##############################################
#                                            #
#  Search components required for RS Search  #
#                                            #
##############################################


# Subroutine_names in order of appearance in this script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$sub_do_search           = "do_search"          ;
$sub_docdonetop_hash     = "docdonetop_hash"    ;
$sub_do_connect_charset  = "do_connect_charset" ;
$sub_do_connect          = "do_connect"         ;
$sub_getRefererCharSet   = "getRefererCharSet"  ;
$sub_getAuxPort          = "getAuxPort"         ;
$sub_excludehack         = "excludehack"        ;
$sub_excludeotherpages   = "excludeotherpages"  ;
$sub_excludepages        = "excludepages"       ;
$sub_sectionexcludesites = "sectionexcludesites";
$sub_manualexclude       = "manualexclude"      ;
$sub_getsorturl          = "getsorturl"         ;
$sub_getindexlocation    = "getindexlocation"   ;
$sub_searchdown          = "searchdown"         ;

# Subroutines...
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub do_search {
#	$searchId++ ;
	my($begin,$end,$thisquery) = @_;
	my($cfail) = 0;
	if (!$thisquery) { $thisquery = $query }
	if ($multicharsetOn){
		&$sub_do_connect_charset  ;  # Open SOCK to RS box
	} else {
		&$sub_do_connect          ;  # Open SOCK to RS box
	}
	if ($checklink) {
		$secallow = "urlmatch(".$checklink.")";
	} else {
		if (@secallow){
			$joinstuff = join(',',@secallow) ;
			$joinstuff =~ s/\s+//eigs ;
			$secallow = "urlmatch(".$joinstuff.")".&$sub_excludehack(@secallow);
		} else {
			if ($includeOtherFiles ne "true") {
				$DEBUG .= "<!--Running excludeotherpages-->\n" if $DEBUGlevel > 0.5 ;
				$secallow = " urlexclude(".&$sub_excludeotherpages.")";
			} else {
				$DEBUG .= "<!--Running excludepages-->\n" if $DEBUGlevel > 0.5 ;
				$secallow = " urlexclude(".&$sub_excludepages.")";
			}
		}
	}
	$DEBUG .= "\n<!--Using source: $src-->\n\n" if $DEBUGlevel>7;
	if ($FORM{"results_option"} eq "scores"){
		print SOCK "Search $begin $end $src $thisquery $secallow\n";
	} elsif ($FORM{"results_option"} eq "category"){
		print SOCK "Search $begin $end $src $thisquery $secallow sortbyfield(category)\n";
	} else {
		print SOCK "Search $begin $end $src $thisquery $secallow ",&$sub_getsorturl(),"\n";
	}
	local($firstline, $score, $title, $descr, $bytes, $words, $name);
	${'firstline'.$searchId} = "";
	${'hits'.$searchId} = 0;
	${'hitsx'.$searchId} = 0;
	${'nresults'.$searchId} = 0;
	@{'persite'.$searchId} = 0;
	select SOCK;
	$| = 1;
	while(<SOCK>){
#		print STDOUT $_;  # Debugging line
		if (!${'firstline'.$searchId} ){ ${'firstline'.$searchId} = $_;
			if (${'firstline'.$searchId} =~ /Query:\s(.*)$/){
				${'firstline'.$searchId} = "";
				${'trquery'.$searchId} = $1;
			}
		}
		if (/^NResults:\s(\S+)/ ){ ${'nresults'.$searchId} = $1 if ($1 > ${'nresults'.$searchId}) ; }
		elsif (/^NumberInSite:\s(\d+)\s(\d+)\s/ ){ 
			${'persite'.$searchId}[$1] = $2; 
			if ($2) {${'resultsitescounter'.$searchId}++;}
		}
		elsif (/^All\srecords\sreturne(.*)?/ ){ ${'allRecords'.$searchId} = "YES" ; }
		elsif (/^Name:\s(.+)/ ){ $name = $1; }
		elsif (/^Spelling:\s(.*)/ ){ $spellingsug = $1; }
		elsif (/^Title:\s(.*)$/ ){ $title = $1; }
		elsif (/^Category:\s(\d+)\s(\d+)\s(.*?)$/ ) { $category{$3} = $2; }
		elsif (/^Description:\s(.*)$/ ) { $descr = $1; }
		elsif (/^Bytes:\s(\d+)/ ){ $bytes = $1; }
		elsif (/^Words:\s(\d+)/ ){ $words = $1; }
		elsif (/^LastModified:\s(\d+)/ ){ $lastmod = $1; }
		elsif (/^Language:\s(\w+)/ ){ $language = $1; }
		elsif (/^FrameParent:\s(.*)/ ){ $frpar = $1; }
		elsif (/^FrameTarget:\s(.*)/ ){ $frtar = $1; }
		elsif (/^SiteNumber:\s(\d+)/ ){ $sitenum = $1; }
		elsif (/^Score:\s(\d+)/ ){ $score = $1, &$sub_docdonetop_hash; }
		foreach $f (@displayedfields){
			if (/^$f:\s(.*)/ ){ $fieldstemp{$f} = $1; }
		}
		if ($spellingsug) {
			$spellingcount++;
			$spelling[$spellingcount] = $spellingsug;
			$spellingsug = "";
      }
	}
	close(SOCK);
	select STDOUT;
	if ( ${'allRecords'.$searchId} ) { ${'nresults'.$searchId} = -1 }
	$DEBUG .= "<!--Allrecords=".${'allRecords'.$searchId}."-->\n" if $DEBUGlevel >= 3 ;
}

sub docdonetop_hash {
	push(@{'names'.$searchId},$name);
	${'dtitle'.$searchId}{$name}=$title;
	${'ddescr'.$searchId}{$name}=$descr;
	${'dscores'.$searchId}{$name}=$score;
	${'dbytes'.$searchId}{$name}=$bytes;
	${'dwords'.$searchId}{$name}=$words;
	${'language'.$searchId}{$name} = $language;
	${'lastmod'.$searchId}{$name} = $lastmod;
	${'sitenum'.$searchId}{$name} = $sitenum;
	${'frparent'.$searchId}{$name} = $frpar;
	${'frtarget'.$searchId}{$name} = $frtar;
	foreach $f (keys %fieldstemp){
		${'dfields'.$searchId}{$name}{$f} = $fieldstemp{$f}; 
	}
	${'hits'.$searchId}++;
	$lastmod = 0;
	$language = "";
	%fieldstemp = ();
}

sub do_connect_charset {
	my ($host,$port,$host1,$port1) = &$sub_getindexlocation($src);
	$hostlog = $host ; $portlog = $port ;
	$proto = getprotobyname('tcp');
	if ($outputcharset{$subdivision} && $inputcharset{$subdivision} ) {
		$auxport = &$sub_getAuxPort($incharset=$inputcharset{$subdivision},$outputcharset=$outputcharset{$subdivision},$port);
	} else {
		$auxport = &$sub_getAuxPort($incharset=&getRefererCharSet,$outputcharset,$port);
	}
#	print "<!--inputCharSet=".$incharset."~~~Hostname=$host~~~OutputCharSet=".$outputcharset."~~~Auxport=".$auxport."-->\n" ;
	if (!$auxport || $auxport == $port){ &$sub_do_connect; return;} # Use main port
	socket(SOCK,PF_INET,SOCK_STREAM,$proto) || &$sub_searchdown; 
	$paddr = sockaddr_in($auxport,inet_aton($host));
	if ( connect(SOCK,$paddr) ){ return; }  # Connected OK to Aux port
	$paddr = sockaddr_in($port,inet_aton($host)); 
	socket(SOCK,PF_INET,SOCK_STREAM,$proto) || &$sub_searchdown; 
	if ( connect(SOCK,$paddr) ){      # Connected to Main port
		print "<!--$port $host: OPEN $auxport $incharset $outputcharset-->\n";
		print SOCK "OPEN $auxport $incharset $outputcharset\n";
		select SOCK;
		$| = 1;
		$reply = <SOCK>;
		select STDOUT;
		chomp $reply;
		if ($reply eq "OK"){
			close(SOCK);
			sleep 1;
			socket(SOCK,PF_INET,SOCK_STREAM,$proto) || &$sub_searchdown; 
			$paddr = sockaddr_in($auxport,inet_aton($host));
			if ( connect(SOCK,$paddr) ){
				return;  # Connected OK to Aux port
			}
			$RSERROR = "Error connecting to new aux port" ; return
		} else {
			$RSERROR = "Reply $reply while opening new port" ; return
		}
	} else {
#		Main RS box down, connect to secondary RS box
		$auxport = &$sub_getAuxPort( $incharset=&$sub_getRefererCharSet , $outputcharset , $port1 );
		$paddr = sockaddr_in($auxport,inet_aton($host1));
		if ( connect(SOCK,$paddr) ){ return; }  # Connected OK to Aux port
		socket(SOCK,PF_INET,SOCK_STREAM,$proto) || &$sub_searchdown; 
		$paddr = sockaddr_in($port,inet_aton($host1)); 
		connect(SOCK,$paddr) || &$sub_searchdown;
#		Connected to Secondary main port
#		print SOCK "OPEN $auxport $incharset $outcharset\n";
		$reply = <SOCK>;
		chomp $reply;
		if ($reply eq "OK"){
			close(SOCK);
			sleep 1;
			$paddr = sockaddr_in($auxport,inet_aton($host));
			socket(SOCK,PF_INET,SOCK_STREAM,$proto) || &$sub_searchdown; 
			if ( connect(SOCK,$paddr) ){ return; }  # Connected OK to Aux port
			$RSERROR = "Error connecting to new aux port" ; return
		} else {
			$RSERROR = "Reply $reply while opening new port" ; return
		}     
	}
#  Unreachable
}

sub do_connect {
    if ( $XhostSET && $XportSET ) {
		$host = $XhostSET ;
		$port = $XportSET ;
	} else {
		($host,$port,$host1,$port1) = &getindexlocation($src);
	}
	$hostlog = $host ; $portlog = $port ;
#    print "$host $port\n"
    $paddr = sockaddr_in($port,inet_aton($host));
    $paddr1 = sockaddr_in($port1,inet_aton($host1));
    $proto = getprotobyname('tcp');
    socket(SOCK,PF_INET,SOCK_STREAM,$proto) || &$sub_searchdown; 
    connect(SOCK,$paddr) || connect(SOCK,$paddr1) || &$sub_searchdown; 
}

sub getRefererCharSet {
	$referer = $ENV{"HTTP_REFERER"};
	$foundcharset = "" ;
	if ($refererCharsetTable) {
		open(RCT,$refererCharsetTable) ;
		$defcharset = $outputcharset ;
		$foundcharset = "";
		while(<RCT>){
			chomp;
			($match,$charset) = split(/\t/,$_);
			if (!$match || !$charset){ next;}
			if ($match =~ /default/){ 
				$defcharset = $charset;
			} else {
				if ($referer =~ /$match/i && !$foundcharset){ $foundcharset = $charset; }
			}
		}
		close(RCT);
	}
	$DEBUG .= "<!--Referer charset, using: --|".($foundcharset || $defcharset). "|-- -->\n" if $DEBUGlevel > 3;
	return $foundcharset || $defcharset;
}

sub getAuxPort {
	my($inputCharset,$outputCharset,$mainport) = @_;
	$inputCharset =~ tr/A-Z/a-z/;
	$outputCharset =~ tr/A-Z/a-z/;
	my($port);  
	if ($auxporttable) {
		open(AP,$auxporttable) ;
		while(<AP>){
			chomp;
	#		print "<!--".$_."-->\n" ;
			($mport,$port,$inc,$outc) = split(/\t/,$_);
	#		print "<!--".$inc." eq ".$inputCharset." ~~ ".$outc." eq ".$outputCharset."-->\n";
			if ( $inc eq $inputCharset && $outc eq $outputCharset && $mainport == $mport ){ 
	#			print "<!--INPUT=$inputCharset | OUTPUT=$outputCharset | MAINPORT=$mainport | Use port $port-->\n";
				return $port;
			}
		}
	}
	$RSERROR = "Cannot find port for $inputCharset -> $outputCharset" ;
	# use default port
	return;
}

sub excludehack {
	# Fixes subdirectory searches
	my(@matchurl) = @_;
	my($url,$urlx,$urlthis,$urlhere);
	my(@exurls) = ();
	my(%surls);
	foreach $urlthis (@matchurl){
		#($url) = /http:\/\/(.*?)$/;
		$surls{$urlthis}++;
	}
	if (!$noExcludeHack) {
		foreach $a (keys %titles){
			$urlhere = $a ;
			$urlhere = "http:\/\/".$urlhere if $urlhere !~ /^http\:\/\// ;
			if (!$surls{$urlhere}){
				foreach $urlx (keys %surls){
					if ($urlx eq substr($urlhere,0,length($urlx)) ){
						push(@exurls, "$urlhere");
					}
				}
			}
		}
	}
#	if ($excludepages) { $excludepagesTMP = &$sub_excludepages ; }
	if (@exurls){
		if ($includeOtherFiles ne "true") {
			return(" urlexclude(".join(',',@exurls).",".&$sub_excludeotherpages.")");
		} else {
			return(" urlexclude(".join(',',@exurls).",".&$sub_excludepages.")");
		}
	} else {
		if ($includeOtherFiles ne "true") {
			return(" urlexclude(".&$sub_excludeotherpages.")");
		} else {
			return(" urlexclude(".&$sub_excludepages.")");
		}
	}
}

sub excludeotherpages {
	# This subroutine automatically adds in "excludepages.txt" where appropriate
	my $exclude = "";
	if ($otherpages) {
		open(EF,$otherpages) || return;
		$donesome = 0;
		while(<EF>){
			chomp;
			if ($_){
				$exclude .= "," if $donesome++ ;
				$exclude .= $_;
			}
		}
	}
	$DEBUG .= "<!--Exclude other pages is ".$exclude."-->\n\n" if $DEBUGlevel > 0.5 ;
	if ($siteExclude) { $exclude = &$sub_sectionexcludesites($exclude) ; }
	$extraexcludes = &$sub_excludepages ;
	if ( !$extraexcludes ) { return $exclude ; }
	if ($exclude) {
		return $exclude.",".$extraexcludes ;
	} else {
		return $extraexcludes;
	}
}

sub excludepages {
	open(EF,$excludepages) || return;
	my($exclude) = "";
	$donesome = 0;
	while(<EF>){
		chomp;
		if ($_){
			$exclude .= "," if $donesome++ ;
			$exclude .= $_;
		}
	}
	$DEBUG .= "<!--Exclude pages is ".$exclude."-->\n\n" if $DEBUGlevel > 0.5 ;
	if ($siteExclude) { $exclude = &$sub_sectionexcludesites($exclude) ; }
	$exclude = &$sub_manualexclude($exclude) ;
	return $exclude;
}

sub sectionexcludesites {
	my($exclude) = $_[0] ;
	my($exc,@ex,@in,@set) ;
	open(ES,$siteExclude) || return;
	$DEBUG .= "\n\n\n<!--Setting excludes now: starting with: ".($exclude||'"blank"')."-->\n\n" if $DEBUGlevel >=5 ;
	while(<ES>){
		chomp; if ( !$_ || $_ =~ /^\s*$/ ) {next}
		my(@splitL) = split(/\t/,$_) ;
		$DEBUG .= "<!--subdivision=".$subdivision."|~~  siteExcludesubdiv=".$splitL[0]."-->\n" if $DEBUGlevel >=9 ;
		for (my($i)=1;$i<=$#splitL;$i++) {
			if ($splitL[$i] !~ /^\s*$/ ) {
				if ( $subdivision ne $splitL[0]){
					$DEBUG .= "<!--Adding   $splitL[$i]   to \@ex -->\n" if $DEBUGlevel >= 5 ;
					push(@ex,$splitL[$i]) ;
				} else {
					$DEBUG .= "<!--Adding   $splitL[$i]   to \@in -->\n" if $DEBUGlevel >= 5 ;
					push(@in,$splitL[$i]) ;
				}
			}
		}
	}
	close(ES);
	foreach $exc (@ex) { push (@set,$exc) if !grep { $exc =~ /^$_$/ } @in }
	$exclude .= "," if ($exclude && @set) ;
	$exclude .= join(',',@set) if @set ;
	$DEBUG .= "\n<!--Returning: ~~~~|".$exclude."|~~~~ -->\n\n\n" if $DEBUGlevel >= 5 ;
	return $exclude;
}

sub sectionexcludesites_old {
	my($exclude) = $_[0] ;
	open(ES,$siteExclude) || return;
	$DEBUG .= "<!--setting excludes now-->\n" if $DEBUGlevel > 0.5 ;
	while(<ES>){
		chomp; 
		my(@splitL) = split(/\t/,$_) ;
		$DEBUG .= "<!--subdivision=".$subdivision."|~~  siteExcludesubdiv=".$splitL[0]."-->\n" if $DEBUGlevel > 0.5 ;
		if ( $subdivision ne $splitL[0]){
			for (my($i)=1;$i<=$#splitL;$i++) {
				if ($splitL[$i]) {
					$DEBUG .= "<!--Adding   $splitL[$i]   to urlexclude() -->\n" if $DEBUGlevel > 0.5 ;
					$exclude .= "," if $exclude ;
					$exclude .= $splitL[$i];
				}
			}
		}
	}
	close(ES);
	return $exclude;
}

sub manualexclude {
	#blank - fill in subroutine in local RS.cgi if required
	return $_[0] ;
}

sub getsorturl {
#	load_titles has already been called
	$ret = "urlsort(";
	$a = 0;
#	$top = $titles{$thissite};
#	if (!$top && $thisite){
#		&html_error("The selectionurl $thissite must match the sitetitles file");
#	}
	foreach $title (sort { length $invtitles{$b} <=> length $invtitles{$a}} keys %invtitles){
		$DEBUG .= "<!-- Sort Url ".$a." Found: ".$invtitles{$title}." -->\n" ;
		if ($a) { $ret .= "," ; }
		if ( $invtitles{$title} !~ /^http/ ) {
			$ret .= "http://" ;
		}
		$ret .= $invtitles{$title};
		$xntitle{$title} = $a;
		$ntitle[$a++] = $title;
	}
	$ret .= ") ";
	return $ret;
}

sub getindexlocation {
	my($src) = $_[0];
	my($src1,$host,$port,$host1,$port1,$line);
	if (!$XportSET && !$XportSET) {
		open(RSC,"grep $src $IndexHosts |") ;
		$line = <RSC>;
		close RSC;
		chomp $line;
		if (!$line){
			$RSERROR = "Cannot find $src in IndexHosts file, or cannot open IndexHosts" ;
			print "Cannot find $src in IndexHosts file, or cannot open IndexHosts" ;
			exit ;
		} else {
			($src1,$host,$port,$host1,$port1) = split(/\t/,$line);
			
			open(DOWN, $ServersDown) || '';
			while(<DOWN>){
				chomp;
				if (!$_) { next;}
				($hostBAD,$portBAD,$failures) = split(/\t/,$_) ;
		#		$Down{$hostBAD.'-'.$portBAD} = $failures ;
				if ( ($host eq $hostBAD ) && ( $port eq $portBAD ) && ( $failures >= 2.5 ) ) {
					$DEBUG .= "<!-- Delivered from HIC-UP search server -->\n" if $DEBUGlevel>7 ;
					$host = $host1 ;
					$port = $port1 ;
				}
			}
			close(DOWN) ;
		}
	}
	# Check if forced to a different box
	if ($XhostSET) { $host = $XhostSET }
	if ($XportSET) { $port = $XportSET }
	return ($host,$port,$host1,$port1);
}

sub searchdown {
	$RSERROR .= "The search is down temporarily, please try again in a few minutes.<br>\n\n" ;
	print "The search is down temporarily, please try again in a few minutes.<br>\n\n" ;
	exit ;
}



1;

