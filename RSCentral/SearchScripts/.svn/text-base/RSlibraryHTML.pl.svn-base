#!/usr/bin/perl -w

##############################################
#                                            #
# Various Search subroutines required for RS #
#                                            #
##############################################

# Subroutine_names in order of appearance in this script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$sub_safeHTML            = "safeHTML"           ;
$sub_write_output        = "write_output"       ;
$sub_output              = "output"             ;
$sub_blankNotBlank       = "blankNotBlank"      ;
$sub_notEqual            = "notEqual"           ;
$sub_dopluralcheck       = "dopluralcheck"      ;
$sub_spliceparam         = "spliceparam"        ;
$sub_countresults        = "countresults"       ;
$sub_looparound          = "looparound"         ;
$sub_loadFragments       = "loadFragments"      ;
$sub_read_format         = "read_format"        ;
$sub_loadfile            = "loadfile"           ;
$sub_setvalue            = "setvalue"           ;
$sub_read_format_def     = "read_format_def"    ;
$sub_loadFragments       = "loadFragments"      ;



# Subroutines...
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub safeHTML {
	my($xx) = $_[0];
#	$xx =~ s/([\~\s%&=+\/])/'%'.tohex(ord($1))/eg;
	$xx =~ s/"/'&quot;'/eg ;
	$xx =~ s/>/'&gt;'/eg ;
	$xx =~ s/</'&lt;'/eg ;
	return $xx;
}

sub write_output {
	&$sub_gettime('preoutput');
	$output = $TEMPLATE;
	$errorloop = 0 ;
	$output = &$sub_output($output) ;
	&$sub_gettime('postoutput');
	print $output;
	$lengthOutput = length ($output) ;
	print "\n\n<!-- ~~~~~~~~~DEBUG~~~~~~~~~~~~~~ -->\n\n".$DEBUG if $DEBUGlevel ;
}

sub output {
	$output = $_[0];
	$errorloop = 0 ;
	while (($output =~ /\[\[(.*?)\]\]/) && $errorloop < $maxnestlevel) {
		$errorloop++ ;
#		print "<!--Looping $errorloop--> \n" ;
		$output =~ s/\[\[\\[\d\D]*?\\\]\]//egs ;
		$output =~ s/\[\[VERYHARD\s(.*?)\]\]/${$1}/egs;
		$output =~ s/\[\[LOAD\s+"(.*?)"\]\]/ &$sub_loadFragments($1) /iegs;
		$output =~ s/\[\[LOOP\s+\((.*?)\)\]\]([\d\D]*?)\[\[\/LOOP\]\]/&$sub_looparound($1,$2,'')/iegs;
		$output =~ s/\[\[LOOP2\s+\((.*?)\)\]\]([\d\D]*?)\[\[\/LOOP2\]\]/&$sub_looparound($1,$2,'2')/iegs;
		$output =~ s/\[\[HARD\s(.*?)\]\]/${$1}/egs;
		$output =~ s/\[\[EVAL\s+\((.*?)\)\]\]/ eval $1 /iegs;
		for ($ll=1;$ll<=$MAXIFS;$ll++) {
			$output =~ s/\[\[IFNB$ll\s+(\w+)\]\]([\d\D]*?)\[\[\/IFNB$ll\]\]/ $2 if ${$1} /iegs;	
			$output =~ s/\[\[IFNB$ll([\d\D]*?)\]\]/'{{RSERROR: IFNB not closed}}'/iegs;	
		}
		$output =~ s/\[\[IFNB\s+(.*?)\]\]([\d\D]*?)\[\[\/IFNB\]\]/ &blankNotBlank($1,$2) /iegs;
		for ($ll=1;$ll<=$MAXIFS;$ll++) {
			$output =~ s/\[\[IFB$ll\s+(\w+)\]\]([\d\D]*?)\[\[\/IFB$ll\]\]/ $2 if !${$1} /iegs;	
			$output =~ s/\[\[IFB$ll([\d\D]*?)\]\]/'{{RSERROR: IFB not closed}}'/iegs;	
		}
		$output =~ s/\[\[IFB\s+(.*?)\]\]([\d\D]*?)\[\[\/IFB\]\]/ $2 if !${$1}/iegs;
		$output =~ s/\[\[IFGT\s+(.*?)\|([\d\D]*?)\]\]([\d\D]*?)\[\[\/IFGT\]\]/ $3 if (${$1} > $2)/iegs;
		$output =~ s/\[\[IFLT\s+(.*?)\|([\d\D]*?)\]\]([\d\D]*?)\[\[\/IFLT\]\]/ $3 if (${$1} <= $2)/iegs;
		$output =~ s/\[\[IFEQ\s+(.*?)\=(.*?)\]\](.*?)\[\[\/IFEQ\]\]/ $3 if (${$1} eq ${$2})/iegs;
		$output =~ s/\[\[IFNE\s+(.*?)\=(.*?)\]\](.*?)\[\[\/IFNE\]\]/ $3 if (${$1} ne ${$2})/iegs;
		for ($ll=1;$ll<=$MAXIFS;$ll++) {
			$output =~ s/\[\[IF$ll\s+(\w+)\=(.*?)\]\]([\d\D]*?)\[\[\/IF$ll\]\]/ $3 if (${$1} eq $2)/iegs;	
			$output =~ s/\[\[IF$ll([\d\D]*?)\]\]/'{{RSERROR: IF not closed}}'/iegs;	
		}
		$output =~ s/\[\[IF\s+(\w+)\=(.*?)\]\](.*?)\[\[\/IF\]\]/ $3 if (${$1} eq $2)/iegs;	
		for ($ll=1;$ll<=$MAXIFS;$ll++) {
			$output =~ s/\[\[IF$ll\!\s+(\w+)\=(.*?)\]\](.*?)\[\[\/IF$ll\!\]\]/&$sub_notEqual($1,$2,$3)/iegs;	
			$output =~ s/\[\[IF$ll\!([\d\D]*?)\]\]/'{{RSERROR: IF! not closed}}'/iegs;	
		}
		$output =~ s/\[\[IF\!\s+(\w+)\=(.*?)\]\](.*?)\[\[\/IF\!\]\]/&$sub_notEqual($1,$2,$3)/iegs;	
		$output =~ s/\[\[COUNTER\s+(.*?)\]\](.*?)\[\[\/COUNTER\]\]/&$sub_countresults($1,$2)/iegs;
		$output =~ s/\[\[([A-Z][A-Z])\]\]([\d\D]*?)\[\[\/([A-Z][A-Z])\]\]/ $2 if ( ($1 eq $3) && ($1 eq $DISPLANG) ) /egs;
		$output =~ s/\[\[s\-(\w+)\]\]/ &$sub_dopluralcheck($1) /egs;
		$output =~ s/\[\[NOTs\-(\w+)\]\]/ "" if (${$1} == 1)/egs;
		$output =~ s/\[\[\{(\d+)\,(\d+)(\+)?\}(\w+)\]\]/&spliceparam(${$4},$1,$2,$3)/egs;
		$output =~ s/\[\[(\w+)\]\]/${$1}/egs;
	}
	if ( $output =~ /\[\[(.*?)\]\]/ ) {
		$output =~ s/\[\[(.*?)\]\]/'{{RSERROR: nesting level unsupported}}'/egs;
	}
	return $output;
}

sub blankNotBlank {
	my($param,$code) = @_ ;
#	print "<!--Checking NB on: ".$param." -->" ;
	if ($param !~ /[&\|]/ ) {
#		print "<!--Simple NB on: ".$param." -->" ;
		if (${$param}) {
			return $code ;
		}
	} elsif ( ($param =~ /&/ ) && ($param =~ /\|/ ) ) {
		return "{{RSERROR: Ambiguous use of & and | in IFNB}}";
	} else {
		my(@theseparams) = split(/[&\|]/,$param) ;
#		print "<!--Parameter Count = ~~~|".$#theseparams."|~~~ -->" ;
		my($i,$checks) = 0;
		for ($i=0;$i<=$#theseparams;$i++) {
			if ( ${$theseparams[$i]} ) {
				$checks++ ;
#				print "<!--This parameter NOT Blank: \$".$theseparams[$i]."=~~~|".${$theseparams[$i]}."|~~~  Checks = ".$checks." -->" ;
			} else {
#				print "<!--This parameter blank: \$".$theseparams[$i]."=~~~|".${$theseparams[$i]}."|~~~  Checks = ".$checks." -->" ;
			}
		}
		if (     ( ($param =~ /\|/) && $checks>0 ) || ( ($param =~ /&/) && ($checks > $#theseparams) )     ) {
#			print "<!--OK - returning code-->" ;
			return $code ;
		} else {
			return "" ;
		}
	}
}

sub notEqual {
	my($param,$val,$code) = @_ ;
	if ($val !~ /&/ ) {
		if (${$param} ne $val) {
			return $code ;
		}
	} else {
		my(@thesevalues) = split(/&/,$val) ;
		my($i,$checks) = 0;
		for ($i=0;$i<=$#thesevalues;$i++) {
			if (${$param} ne $thesevalues[$i]) {
				$checks++ ;
			}
		}
		if ($checks == ($#thesevalues+1)) {
			return $code ;
		}	else {
			return "" ;
		}
	}
}

sub dopluralcheck {
	my($t) = $_[0] ;
#	print "<!--Doing plural check.  singlular=\"".$setsingular."\" plural=\"".$setplural."\"<br>-->\n" ;
#	print "<!--checking parameter \"".$t."\" which is \"".${$t}."\"<br>-->\n" ;
	if (${$t} > 1.1 ) {
		return ($setplural || "s") ;
	} else {
		return ($setsingular || "" );
	}
}

sub spliceparam {
	my($output1,$startsplice,$finishsplice,$toEnd) = @_ ;
	$startsplice-- ;
#	print "Splicing ".$output1." in range ".$startsplice." to ".$finishsplice."<br><br>" ;
	if ($startsplice <= 0) {
		$output1 .= "{{RSERROR: start value must be >= 1}}" ;
		$startsplice = 0 ;
	}
	my($mid) = $finishsplice - $startsplice ;
	if ($mid < 1) {
		$output1 .= "{{RSERROR: start value must be >= end value}}" ;
		$mid = 1 ;
	}
	if (!$toEnd) {
		$evaluation = " \$output1 =~ s/^(.{".$startsplice."})(.{".$mid."})(.*)/\$2/ ; " ;
	} else {
		$evaluation = " \$output1 =~ s/^(.{".$startsplice."})(.{".$mid."})(.*?)(\\s)(.*)/\$2\$3/ ; " ;
	}
#	print "Evaluation is: ".$evaluation."<br>" ;
	eval ( $evaluation ) ;
#	print "returned match~~~~".$output1."~~~~~~<br><br><BR>" ;
	return $output1 ;
}

sub countresults {
	my($countquery,$countinsertion) = @_;
	$query = $countquery ;
	&$sub_do_search(0,-1);
	$RETURNval = &$sub_output($countinsertion) ;
	return $RETURNval ;
}

sub looparound {
	my($loopvariables,$loopcode,$loopdash) = @_;
#	my($RETURNloop,$looparray,$maxreturn,$Lstart,$Lfinish,$Lstep,$output) ;
	my($RETURNloop,$looparray,$maxreturn,$ll,$output,$LOOPCOUNTER) = "" ;
#	print "<!--LOOPDASH=".$loopdash."-->\n" ;
	if ($loopvariables =~ /^\%(.*)$/i ) {
		# this is for a loop like: [[LOOP (%array)]] as in a loop of the keys of $array{$keys}
			$looparray = $1 ; $maxreturn = "" ;
			if ($looparray =~ /\|/ ) {
				$_ = $looparray ; ($looparray,$maxreturn) = /(.*)\|(.*)/i ;
#				print "<!--loop: found pipe, split as ~~".$looparray."~~".$maxreturn."-->\n" ;
				foreach $loop (sort { ${$looparray}{$b} <=> ${$looparray}{$a} } keys %{$looparray}){
					$LOOPCOUNTER++ ;
					$ll++ ;
					if ( $maxreturn && ($ll > $maxreturn) ) { next; }
#					print "<!--Loop: array:".$looparray." key:".$loop."-->\n" ;
					$output = $loopcode ;
					$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$loop/egs ;
					$output =~ s/\[\[LOOPCOUNT$loopdash\]\]/$LOOPCOUNTER/egs ;
					$output =~ s/\[\[PARAMVALUE$loopdash\]\]/${$looparray}{$loop}/egs ;
					$RETURNloop .= &$sub_output($output) ;
				}	
			} else {
#				print "<!--loop: found no pipe, split as ~~".$looparray."~~".$maxreturn."-->\n" ;
				foreach $loop (sort keys %{$looparray}){
					$ll++ ;
					if ( $maxreturn && ($ll > $maxreturn) ) { next; }
#					print "<!--Loop: array:".$looparray." key:".$loop."-->\n" ;
					$output = $loopcode ;
					$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$loop/egs ;
					$output =~ s/\[\[LOOPCOUNT$loopdash\]\]/$LOOPCOUNTER/egs ;
					$output =~ s/\[\[PARAMVALUE$loopdash\]\]/${$looparray}{$loop}/egs ;
					$RETURNloop .= &$sub_output($output) ;
				}	
			}
			$ll = 0;
	} elsif ($loopvariables =~ /^\@(.*)$/i ) {
		# this is for a loop like: [[LOOP (@array)]] as in a loop of the keys of @array
		$looparray = $1;
		foreach $loop (@{$looparray}){
			$output = $loopcode ; 
			$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$loop/egs ;
			$RETURNloop .= &$sub_output($output) ;
		}
	} elsif ($loopvariables =~ /^(.*?)\.\.\.(.*?)\|([\d\-\.]*)$/i ) {
		# this is for a loop like: [[LOOP (a...b|c)]] as in a loop from a to b step c
			$Lstart = $1 ; $Lfinish = $2 ; $Lstep = $3 ;
			if ($Lfinish =~ /[a-zA-Z]/) {
#				print "<!--Doing a loop from ".$Lstart." to ".$Lfinish."(".${$Lfinish}.") stepping ".$Lstep."-->\n" ;
				for ($ll = $Lstart ; $ll <= ${$Lfinish} ; $ll = $ll + $Lstep) {
					$LOOPCOUNTER++ ;
					$output = $loopcode ;
					$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$ll/egs ;
					$output =~ s/\[\[LOOPCOUNT$loopdash\]\]/$LOOPCOUNTER/egs ;
					$RETURNloop .= &$sub_output($output) ;
				}
			} elsif ($Lstart =~ /[a-zA-Z]/) {
				for ($ll = ${$Lstart} ; $ll >= $Lfinish ; $ll = $ll + $Lstep) {
					$LOOPCOUNTER++ ;
					$output = $loopcode ;
					$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$ll/egs ;
					$output =~ s/\[\[LOOPCOUNT$loopdash\]\]/$loop/egs ;
					$RETURNloop .= &$sub_output($output) ;
				}
			} else {
				if ($Lfinish >= $Lstart) {
					for ($ll = $Lstart ; $ll <= $Lfinish ; $ll = $ll + $Lstep) {
						$LOOPCOUNTER++ ;
						$output = $loopcode ;
						$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$ll/egs ;
						$output =~ s/\[\[LOOPCOUNT$loopdash\]\]/$loop/egs ;
						$RETURNloop .= &$sub_output($output) ;
					}
				} else {
					for ($ll = $Lstart ; $ll >= $Lfinish ; $ll = $ll + $Lstep) {
						$output = $loopcode ;
						$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$ll/egs ;
						$RETURNloop .= &$sub_output($output) ;
					}
				}
			}
	} else {	
		# this is for a loop like: [[LOOP (a,b,c,d)]] as in a loop through a then b then c then d etc
			foreach $loop (split (/,/,$loopvariables)){
				$output = $loopcode ;
				$output =~ s/\[\[LOOPVALUE$loopdash\]\]/$loop/egs ;
				$RETURNloop .= &$sub_output($output) ;
			}
	}
#	print "<!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n".$RETURNloop."-->\n\n\n\n\n\n\n" ;
	return $RETURNloop ;
}

sub read_format {
	open(FMT,$formatfile);
	$_ = join('',<FMT>);
	close(FMT);
	$_ =~ s/\{\-\{(\w+)\}\-\}/${$1}/egs;
	s/<!--#include\svirtual="?(.*?)"?\s?-->/&loadfile($1)/eig;
	s/<!--([_A-Z0-9]*?)-->([\d\D]*?)<!--\/([_A-Z0-9]*?)-->/&setvalue($1,$2)/iegs;
}

sub loadfile {
	open(LF,$HTMLroot.$_[0]) || return("Cannot open $HTMLroot".$_[0]);
	$xx = join('',<LF>);
	close(LF);
	return $xx;
}

sub setvalue {
	my($paramname,$paramvalue) = @_;
	${$paramname} = $paramvalue ;
	$TEXT{$paramname} = $paramvalue ;
#	print "\n\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n".$paramname." = ".$paramvalue."\n\n" ;
	return "";
#	return $paramvalue ;
}

sub read_format_def {
	open(FMT,$defformatfile);
	$_ = join('',<FMT>);
	close(FMT);
	$_ =~ s/\{\-\{(\w+)\}\-\}/${$1}/egs;
	s/<!--#include\svirtual="?(.*?)"?\s?-->/&loadfile($1)/eig;
	s/<!--([_A-Z0-9]*?)-->([\d\D]*?)<!--\/([_A-Z0-9]*?)-->/&setvalue($1,$2)/iegs;
}

sub loadFragments {
	open(LF,$_[0]) || return("{{RSERROR: Cannot open ".$_[0]." }}");
	my($code) = join('',<LF>);
	close(LF);
	my($start) = 0 ;
	my($param) = "" ;
	while ( ($code =~ /<!--([_A-Z0-9]*?)-->/)  && ( $start < 100 ) ) {
		$start++ ;
		$_ = $code ; $param = $1 ;
		if ($code =~ /<!--$param-->([\d\D]*?)<!--\/$param-->([\d\D]*?)$/i ) {
#			print "correct format found for ".$param."<br>\n" ;
			&setvalue($param,$1) ;
			$code = $2 ;
		} else {
			$code =~ s/<!--$param-->/''/eigs ;
			$RSERROR .= "<pre>{{RSERROR: Error in ".$formatfile." - missing end tag for &lt;!--".$param."--&gt; }}</pre>\n" ;
		}
	}
	while ( $code =~ /<!--\/([A-Z0-9_]*?)-->/ ) {
		$param = $1 ;
		$code =~ s/\<\!\-\-\/$param\-\-\>/''/i ;
		$RSERROR .= "<pre>{{RSERROR: Error in ".$formatfile." - close tag not started: &lt;!--/".$param."--&gt; }}</pre>\n" ;	
	}
	return $TEMPLATE ;
}


1;

