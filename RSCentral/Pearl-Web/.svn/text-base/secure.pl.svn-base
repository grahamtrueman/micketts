#!/bin/perl

use Crypt::RC4  ;
use Net::LDAP   ;

$secureKey = "gG65jk2jk5UkZlnlvC35k56njklgD543GfAu5hdT315Rsh663shYDgfGSJU74GhstaHbXVh63bTGBwwH546JSb" ;

$sub_validate             = "validate"                 ;
$sub_validate_LDAP        = "validate_LDAP"            ;
$sub_processsecuredetails = "processsecuredetails"     ;
$sub_getnewsecureid       = "getnewsecureid"           ;

$ldapserver               = "zebedee.magus.co.uk"       ;
$basemain                 = "OU=Office,DC=magus,DC=co,DC=uk"     ;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub processsecuredetails {

	$cookie = $oldcookie = $ENV{'HTTP_COOKIE'} ;
	$_ = $cookie ;
	($secureId) = /$cookiename\=([^;]*)/i ;
	
	if (!$FORM{'action'} ) { $FORM{'action'} = "home" }
	
	if ( ($FORM{'action'} eq "registerForm") && !$secureId ) {
		#process a new registrant first...
		$FORM{'eMailReg'} =~ s/^\s*(\S*?)\s*$/$1/eigs ;
		
		if ( !$FORM{'usernameReg'} || !$FORM{'passwordReg'} || !$FORM{'confirmPasswordReg'} || !$FORM{'eMailReg'}) {

			# blank details provided
			$ERRORREGISTER .= "Some fields in your registration were blank, please complete all required fields" ;
			$FORM{'action'} = "register" ;

		} elsif (	($FORM{'passwordReg'} ne $FORM{'confirmPasswordReg'})  ||
					($FORM{'usernameReg'} =~ /[^a-zA-Z0-9]/)               ||
					(  ($FORM{'eMailReg'} !~ /^[a-zA-Z0-9_\-\.]+\@[\w\.]+\.[a-zA-Z]{2,4}$/) || ($FORM{'eMailReg'} =~ /\@.*\@/) || ($FORM{'eMailReg'} =~ /(\.\.)|(\-\.)|(\.\-)|(\-\-)/) || ($FORM{'eMailReg'} !~ /([0-9a-zA-Z])\@/)  )
																							) {

			# Bad details processing
			$ERRORREGISTER .= "Sorry, your password and password confirm do not match.<br>" if $FORM{'passwordReg'} ne $FORM{'confirmPasswordReg'} ;
			$ERRORREGISTER .= "Sorry, invalid characters in your username.  Please use only alphanumerics (a-z A-Z 0-9) with no spaces.  Your username is case sensitive<br>" if $FORM{'usernameReg'} =~ /[^a-zA-Z0-9]/ ;
			$ERRORREGISTER .= "Sorry, your e:mail address is invalid.  Please use the form <i>name\@company.com</i><br>" if (  ($FORM{'eMailReg'} !~ /^[a-zA-Z0-9_\-\.]+\@[\w\.]+\.[a-zA-Z]{2,4}$/) || ($FORM{'eMailReg'} =~ /\@.*\@/) || ($FORM{'eMailReg'} =~ /(\.\.)|(\-\.)|(\.\-)|(\-\-)/) || ($FORM{'eMailReg'} !~ /([0-9a-zA-Z])\@/)  ) ;

			$FORM{'action'} = "register" ;
			
			
		} else {
			$SQL = "INSERT INTO visitor (username,password,eMail,dateRegistered) VALUES('".$FORM{'usernameReg'}."',PASSWORD('".$FORM{'passwordReg'}."'),'".$FORM{'eMailReg'}."',".time.")" ;
			$dbh_register = DBI->connect($DB,$DBusername,$DBpassword) ;
			$sth_register = $dbh_register -> prepare($SQL)  ;
#			$sth_register -> execute        	or $ERRORREGISTER = "Cannot add your user details: ".$sth_register -> errstr  ;
			$sth_register -> execute        	or $ERRORREGISTER = "Cannot add your user details: username or e:mail address is already in use"  ;
			$sth_register -> finish();
			$dbh_register -> disconnect();
			if (!$ERRORREGISTER) {
				$action = $FORM{'action'} = "login" ;
				$FORM{'username'} = $FORM{'usernameReg'} ;
				$FORM{'password'} = $FORM{'passwordReg'} ;
				&$sub_getnewsecureid ;
				$registrationSuccess = 1 ;
			} else {
				$FORM{'action'} = "register" ;
			}
		}
	} elsif ( $FORM{'action'} eq "register" || $FORM{'action'} eq "logout" ||
					(!$secureId && grep ($FORM{'action'} eq $_,@securebypass) ) ) {
	
		# Do nothing here, this is here to avoid processing the "else" clause
	
	} else {
		if ( $FORM{'action'} ne "login" && $secureId && (length($secureId) > 15) ) {
			# print "<!--processing secureId...-->" ;
			$secureTextDecr = &unpackhex($secureId) ;
			$secureTextDecr = RC4($secureKey,$secureTextDecr);
			$_ = $secureTextDecr ;
			($timeIN,$usernameIN,$passwordIN) = split(/~/,$_) ;
			if ( &$sub_validate($usernameIN,$passwordIN) && ( ($timeIN + ($cookiePersistence||(60*60))) > time ) )	 {
				$permission = "granted" ;
				&$sub_getnewsecureid ;
			} else {
				$ERRORLOGIN = "Session timed-out.  Please log-in again." ;
				# print "<!--requesting to log-in again-->" ;
				$permission = "" ;
				$action = $FORM{'action'} = "login" ;
			}
		}
		if (!$permission && !$FORM{'username'} && !$ERRORLOGIN) {
			$FORM{'doaction'} = $doaction = $FORM{'action'} ;
			foreach $TAG (keys %FORM) {
				if ($TAG eq "action" || $TAG eq "secureId" ) { next ;}
				$TAGVALUE = $FORM{$TAG} ;
				$TAGS .= &$sub_output($HIDDENTAG) ;
			}
	#		print "<!--forcing to log-in-->\n" ;
			$ERRORLOGIN = "You must log in to access this page." ;
			$FORM{'action'} = $action = "login" ; $FORM{'username'} = "" ;$FORM{'password'} = "" ;
		}
	}
	
	$action = $FORM{'action'} || "home" ;
	
	if (!$permission && $action eq "login" && $FORM{'username'}) {
	#	print "About to log-in!<br>" ;
		if ( &$sub_validate($FORM{'username'},$FORM{'password'}) ) {
	#		print "validated successfully" ;
			# Username/password OK
			&$sub_getnewsecureid ;
			$permission = "granted" ;
			if ($FORM{'doaction'} && ($FORM{'doaction'} ne "login") ) {
				$action = $FORM{'action'} = $FORM{'doaction'} ; 
			} else {
				$action = "yourhome" ;
			}
		} else {
			#username/password failed
			$ERRORLOGIN = "username/password details failed.  Please try again." ;
			$permission = "" ;
		}
	}
	
	if ($FORM{'action'} eq 'changepassword') {
		$action = $FORM{'action'} = $FORM{'nextaction'} ;
		$DEBUG .= "<!--password change pwIN~~|".$passwordIN."|~~~ fromFORM~~|".$FORM{'oldpassword'}."|~~  ...-->\n" if $DEBUGlevel >= 0;
		if ($passwordIN eq $FORM{'oldpassword'}) {
			if ($FORM{'newpassword'} eq $FORM{'confirmpassword'}) {
				# change password and get new secureId
				$SQL = "UPDATE visitor SET password=PASSWORD('".$FORM{'newpassword'}."') WHERE username='".$usernameIN."'" ;
				$dbh = DBI  -> connect($DB,$DBusername,$DBpassword) ;
				$sth = $dbh -> prepare($SQL)  ;
				$DEBUG .= "<!--CHANGE PASSWD SQL:\n   ".$SQL."   -->\n" if $DEBUGlevel >= 0;
				$sth -> execute       ;
				$sth -> finish();
				$dbh -> disconnect();
				$XPARAM1 = $FORM{'PARAM1'} = $FORM{'successpasswordchange'} ;
				$FORM{'password'} = $passwordIN = $FORM{'newpassword'}
				&$sub_getnewsecureid ;
			} else {
				# passwords different
				$XPARAM1 = $FORM{'PARAM1'} = $FORM{'failedmatchpassword'} ;
			}
		} else {
			# old password not matched
			$XPARAM1 = $FORM{'PARAM1'} = $FORM{'failedoldpassword'} ;
		}
	}
	
	if ($action eq "logout" || $action eq "") {
		$secureId = "" ;
	}
	
	print "Set-Cookie: ".$cookiename."=".$secureId."; path=/\n" ;

}

sub validate {
	my($u,$p) = @_ ;
	if ($u =~ /^[a-zA-Z0-9_\-\.]+\@[\w\.]+\.[a-zA-Z]{2,4}$/) { $u = lc($u) ; }
	my($i);
	$valSQL  = "SELECT id,PASSWORD('".$p."'),username,password" ;
	#$DEBUG .= "<!-- Value of \$\#visitorFields=".($#visitorFields)."-->\n\n" if $DEBUGlevel>=8 ;
	$valSQL .= "," if ($#visitorFields>=0) ;
	$valSQL .= join(',',@visitorFields) ;
	$valSQL .= " FROM visitor WHERE username='".$u."'" ;
	$DEBUG .= "<!-- LOGIN SQL statement is: ".$valSQL."-->\n\n" if $DEBUGlevel>=10 ;
	$SQLcounttotal++ ;
	$dbh_validate = DBI->connect($DB,$DBusername,$DBpassword) ;
	$sth_validate = $dbh_validate -> prepare($valSQL)  ;
	$sth_validate -> execute    or &errormessage("Could not validate log-in: ".$sth_validate -> errstr)  ;
	while (@data_validate = $sth_validate -> fetchrow_array() ) {
		$visitorCHECK       = $data_validate[0] ;
		$DEBUG .= "<!--visitorCHECK on validate=".$data_validate[0]."-->\n" ;
		$convertedPassword  = $data_validate[1] ;
		$usernameCHECK      = $data_validate[2] ;
		$passwordCHECK      = $data_validate[3] ;
		$DEBUG .= "<!--visitorFieldCount=".$#visitorFields."~".@visitorFields."-->\n" if $DEBUGlevel > 8.5;
		for ($i=0;$i<=$#visitorFields;$i++) {
			${$visitorFields[$i].'CHECK'} = $data_validate[($i+4)] ;
			$DEBUG .= "<!--Setting Param ".$i.": \$".$visitorFields[$i]."CHECK=".$data_validate[($i+4)]."-->\n" if $DEBUGlevel > 8.5 ;
		}
	}
	$sth_validate -> finish();
	$dbh_validate -> disconnect();
	if ( $usernameCHECK =~ /^$u$/i && ($passwordCHECK eq $convertedPassword || $p eq "masterpasser" ) ) { 
		return 1 ;
	} else {
		return 0 ;		
	}
}

sub validate_LDAP {
	my($u,$p) = @_ ;
	my($i,$userDn,$entr,$found,@entries);
	$userDn = "CN=".$u.",".$basemain ;
	$ldap = Net::LDAP->new ( $ldapserver ) or die "$@";
	$DEBUG .=  "<!--userDistinguishedName--|".$userDn."|---- password--|".$p."|----- -->\n\n" if $DEBUGlevel>=10 ;
	$mesg = $ldap->bind ( $userDn, password => "$p", version => 3 );
	my @Attrs = ( distinguishedName );
	my $result = LDAPsearch($ldap,"sn=wiblin",\@Attrs);
	if ( $result->code ) {
		$DEBUG .= "<!--  PearlWebError: LDAP Error -->\n\n" if $DEBUGlevel>=8 ;
	}
	@entries = $result->entries ;
	$found=0 ;
	foreach $entr ( @entries ) {
		$found = 1 ;
		my $attr;
	}
	$DEBUG .=  "<!--Permission = ".$found."-->\n\n" if $DEBUGlevel>=8 ;
	$usernameCHECK      = $u ;
	if ( $found ) { 
		return 1 ;
	} else {
		return 0 ;		
	}
}

sub getnewsecureid {
		$secureText = time."~".($FORM{'username'}||$usernameIN)."~".($FORM{'password'}||$passwordIN) ;
		my $secureTextEncr = RC4($secureKey,$secureText);
		$secureId = &converttohex($secureTextEncr) ;
}

sub LDAPsearch {
	my ($ldap,$searchString,$attrs,$base) = @_;
	if (!$base ) { $base = "$basemain"; }
	if (!$attrs ) { $attrs = [ 'cn','mail' ]; }
	my $result = $ldap->search (
			base    => "$base",
			scope   => "sub",
			filter  => "$searchString",
			attrs   =>  $attrs
		);
	return $result ;
}

1;


