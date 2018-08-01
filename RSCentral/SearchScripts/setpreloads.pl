#!/usr/bin/perl -w

use Socket;

$indexhosts = "/export/RemoteSearch/RSCentral/IndexHosts";

%preloads = ();

open(IH,$indexhosts);
while(<IH>){
  chomp;
  ($index,$host,$port,$fo_host,$fo_port,$preload) = split(/\t/,$_);
  chomp $preload;
  if ($preload eq "yes" || $preload eq "YES" || $preload eq "Yes"){
    if ($preloads{$host.'@'.$port}){
	$preloads{$host.'@'.$port} .= ','.$index;
    } else {
 	$preloads{$host.'@'.$port}  = $index;
    }
  }
}

foreach $server (sort keys %preloads){
  ($host,$port) = split(/\@/,$server);
  $size = 0;
  $fail = 0;
  $paddr = sockaddr_in($port,inet_aton($host));
  $proto = getprotobyname('tcp');  
  socket(SOCK,PF_INET,SOCK_STREAM,$proto) || ($fail=1);
  if (!$fail){ connect(SOCK,$paddr) || ($fail=1); }
  if ($fail){
    print "Couldn't connect to ",$host," port ",$port," ",$!,"\n";
    next;
  }
  select SOCK;
  $|=1;
  print SOCK "SetPreloads ",$preloads{$server}," -\n";
  print "seting preload list for ",$host," port $port\n";
  $return = <SOCK>;
  close(SOCK);
  select STDOUT;
  print $host, " - ", $return;
}
