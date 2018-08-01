


if ($ENV{'REQUEST_METHOD'} eq 'POST') {

    read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

    @pairs = split(/&/, $buffer);

    foreach $pair (@pairs) {
       ($name, $value) = split(/=/, $pair);
       $value =~ tr/+/ /;
       $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

    $FORM{$name} = $value;
    }
}
	
# Full path for 'require' /export/RSCentral/Modules/form_grab.pl