#!/usr/bin/perl

# That is the path to PERL just above It MUST be first in the script
# The following accepts the data from the form 

if ($ENV{'REQUEST_METHOD'} eq 'POST') {

    read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

    @pairs = split(/&/, $buffer);

    foreach $pair (@pairs) {
       ($name, $value) = split(/=/, $pair);
       $value =~ tr/+/ /;
       $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

    $FORM{$name} = $value;
    }



# The following sends the email 

    open (MESSAGE,"| /usr/lib/sendmail -t");

    print MESSAGE "To: $FORM{submitaddress}\n";
    print MESSAGE "From: $FORM{name}\n";
    print MESSAGE "Reply-To: $FORM{email}\n";

    print MESSAGE "Subject: Feedback from $FORM{name} at $ENV{'REMOTE_HOST'}\n\n";
    print MESSAGE "The user wrote:\n\n";
    print MESSAGE "$FORM{feedback}\n";
    close (MESSAGE);

    &thank_you;
} 




#The following creates the Thank You page display 

sub thank_you {

    print "Content-type: text/html\n\n";
    print "<HTML>\n";
    print "<HEAD>\n";
    print "<TITLE>Thank You!</TITLE>\n";
    print "</HEAD>\n";
    print "<BODY BGCOLOR=#FFFFCC TEXT=#000000>\n";
    print "<H1>Thank You!</H1>\n";
    print "\n";
    print "<P>\n";
    print "<H3>Your feedback is greatly appreciated.<BR>\n";
    print "<P>\n";
    print "</BODY>\n";
    print "</HTML>\n";
    exit(0);
}

