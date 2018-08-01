#!/bin/perl

###############################################
#                                             #
# Frameset components required for RS Search  #
#                                             #
###############################################

require("/RSCentral/SearchScripts/RSlibraryConfig.pl") ;
require("/RSCentral/SearchScripts/RSlibrarySearchComponents.pl") ;

# Subroutine_names in order of appearance in this script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$sub_execute_frameset     = "execute_frameset"             ;
$sub_frameinfo            = "frameinfo"                    ;
$sub_framebody            = "framebody"                    ;
$sub_addbase              = "addbase"                      ; 
$sub_changeframe          = "changeframe"                  ;
$sub_addname              = "addname"                      ;
$sub_repname              = "repname"                      ;
$sub_html_error           = "html_error"                   ;
$sub_bodymod              = "def_bodymod"                  ;
$sub_setframecount        = "setframecount"                ;
# Subroutines...
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


sub execute_frameset {
	($host,$port,$host1,$port1) = &$sub_getindexlocation($src);
	$command = $ENV{"QUERY_STRING"};
	
#	print "Content-type: text/html\n\n" ; 
	
	if ($command =~ /^start=(.*)/) { 
		$starturl = $1;
#		print $1 ;
		@urls = ();
		@targets = ();
		@linkurls = ();
		$parent = "";
		$url = $starturl;
		($newparent,$target)= &$sub_frameinfo($url);
		while($newparent){
#			print "$newparent<BR>$target<P>" ;
			push(@linkurls,$url);
			push(@targets,$target);
			push(@urls,$newparent);
			$url = $newparent;
			($newparent,$target)=&$sub_frameinfo($url);
		}
		if (!@targets){
			print "location: ".$starturl."\n\n" ;
			print "Not a frame, redirecting..." ;
			exit ;
		}
		$frameseturl = pop(@urls);
		$linkurl = pop(@linkurls);
		push (@linkurls,$linkurl);
		$target = pop(@targets);
		$body = &$sub_framebody($frameseturl);
#		print "$frameseturl : BODY = <P>" ;
#		print $body ;
		if (!$body){
			print "Frameset not stored";
		}
		$newcommand = "targets=[".join("][",@targets)."]+linkurls=[".
		join("][",@linkurls)."]";
		if (@targets==0){
			$body = &$sub_changeframe($body,$target,$frameseturl,$linkurl);
		} else {
			$body = &$sub_changeframe($body,$target,$frameseturl,"$frameprog?$newcommand");
		}
		print "Content-type: text/html\n";
		print "Window-target: _top\n\n";
		print $body;
		print "\n\n\n\n\n\n\n\n\n\n\n\n".$DEBUG ;
		exit(0);
	} elsif ($command =~ /targets=\[(.*)\]\+linkurls=\[(.*)\]/){
		$targets = $1;
		$linkurls = $2;
		@targets = split(/\]\[/, $targets);
		@linkurls = split(/\]\[/,$linkurls);
		$target = pop(@targets);
		$currurl = $linkurl = pop(@linkurls);
		$body = &$sub_framebody($linkurl);
		$newcommand = "targets=[".join("][",@targets)."]+linkurls=[".join("][",@linkurls)."]";
#		$target = shift(@targets);
		$linkurl = pop(@linkurls);
		push(@linkurls,$linkurl);
		if (@targets==0){
			$body = &$sub_changeframe($body,$target,$currurl,$linkurl);
		} else {
			$body = &$sub_changeframe($body,$target,$currurl,"$frameprog?$newcommand");
		}
		print "Content-type: text/html\n\n";
		print $body;
		print "\n\n\n\n\n\n\n\n\n\n\n\n".$DEBUG ;
		exit(0);   
	} else {
		print "Error 400: Bad Command" ;
	}
}

sub frameinfo {
    my($query) = $_[0];
    $paddr = sockaddr_in($port,inet_aton($host));
    $paddr1 = sockaddr_in($port1,inet_aton($host1));
    $proto = getprotobyname('tcp');
    socket(SOCK,PF_INET,SOCK_STREAM,$proto) || &$sub_html_error("socket: $!"); 
    connect(SOCK,$paddr) || connect(SOCK,$paddr1) || &$sub_html_error("connect: $!");
    select SOCK;
    $| = 1;
    print SOCK "frameInfo $src $query\n";
    my($a,$frameparent,$frametarget,@a);
    $a = <SOCK>;
    @a = ();
    if ($a eq "NONE"){ return @a;}
    $a =~ /^FrameParent:\s(.*)/ && ($frameparent = $1);
    $a = <SOCK>;
    $a =~ /^FrameTarget:\s(.*)/ && ($frametarget = $1);
    close(SOCK);
    select STDOUT;
    return ($frameparent,$frametarget);
}

sub framebody {
    my($query) = $_[0];
    $paddr = sockaddr_in($port,inet_aton($host));
    $paddr1 = sockaddr_in($port1,inet_aton($host1));
    $proto = getprotobyname('tcp');
    socket(SOCK,PF_INET,SOCK_STREAM,$proto) || &$sub_html_error("socket: $!"); 
    connect(SOCK,$paddr) || connect(SOCK,$paddr1) || &$sub_html_error("connect: $!");
    select SOCK;
    $| = 1;
    print SOCK "GETBODY $src $query\n";
    my($a,$body,$length);
    $a = <SOCK>;
    $a =~ /^Length:\s(\d+)/ && ($length = $1);
    if (!$length){
      close(SOCK);
      return "";     
    }
    read(SOCK,$body,$length);
    close(SOCK);
    select STDOUT;
	
	# manipulate body to remove extra spaces and stuff
	$body =~ s/(src=["'])\s*([^\s'">]*)\s*(['"])/$1.$2.$3/eigs ;
	
    return $body;
}

sub addbase {
	my($body,$currenturl) = @_;
	$body =~ s/<HEAD>/"<HEAD><BASE HREF=$currenturl>"/iesg ;
	if ($body !~ /<HEAD>/i ){
		$body = "<BASE HREF=\"$currenturl\">".$body;
	}
	return $body;
}

sub changeframe {
	my($body,$target,$currenturl,$url) = @_;
	if ($bodymod) {
		$body = &$sub_bodymod($body) ;
	}
	$body =~ s/<HEAD>/"<HEAD><BASE HREF=$currenturl>"/iesg ;
	if ($body !~ /<HEAD>/i ){
		$body = "<BASE HREF=\"$currenturl\">".$body;
	}
#	if ($body !~ s/<HEAD>/<HEAD><BASE HREF="$currenturl">/is){
#		$body = "<BASE HREF=\"$currenturl\">".$body;
#	}
	if ($target =~ /^_RS_/){
		$body =~ s/<frame\s([^>]*)>/ "<frame ".&$sub_addname($1).">"/seig;
	}
	#get <frame> count
	$body =~ s/(\<frame\s[^>]*>)/&$sub_setframecount($1)/egis ;
	$body =~ s/\<frame\s([^>]*)>/ "<frame ".&$sub_repname($1,$target,$url).">"/seig;
	return $body;
}

sub addname {
  my($a) = $_[0];
  if ($a !~ /name=(\S+)/i){
    $a = $a . " name=\"_RS_$framenumber\"";
    $framenumber++;
  }
}

sub repname {
	my($a,$target,$url) = @_;
	my($name);
	$thisframe++ ;
	#$a =~ /name=(\S+)/i && ($name = $1);
	$a =~ /name\s*=\s*(\S+)/i && ($name = $1);
	$name =~ s/["']//seig;
#	$DEBUG .= "<!-- \n ~~~|$a|~~~ \n ~~~|$name|~~~ \n ~~~|$target|~~~ \n ~~~|$url|~~~ \n -->\n" ;
	if ($name eq $target || ( ($thisframe==$framecount) && !$framefound) ) {
		if ($name ne $target) {
#			$DEBUG .= "<!--Found the last target frame so inserting whole source into here-->\n\n\n" ;
			$a =~ s/src\s*=\s*([\S]+)/src="$starturl"/i;
		} else {
#			$DEBUG .= "<!--Found the right target-->\n\n\n" ;
			$a =~ s/src\s*=\s*([\S]+)/src="$url"/i;
		}
		$framefound = "yes" ;
	}
	return $a;
}

sub html_error {
	my($error) = $_[0];
#	print "Content-type: text\/html\n\n" ;
	print "Location: ".$starturl."\n\n" ; #$error ;
	exit;
}

sub def_bodymod {
	return $_[0] ;
}

sub setframecount {
	$framecount++ ;
	return $_[0] ;
}

1;
