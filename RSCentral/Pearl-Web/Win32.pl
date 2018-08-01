#!/bin/perl

sub getDiskInfo {
	use Win32::DriveInfo ;
	@drives = Win32::DriveInfo::DrivesInUse() ;
	# print "trying to work on these drives: ~~~~| @drives |~~~~~\n" ;
	foreach $drive (@drives) {
		next if $drive =~ /[az]/i ;
		$thisdrive = $drive.":" ;
		#my($filesystem,$blocks,$used,$available,$percent,$mounted) = split(/\s+/,$_) ;
		($SectorsPerCluster, $BytesPerSector, $NumberOfFreeClusters, $TotalNumberOfClusters, $FreeBytesAvailableToCaller ,$TotalNumberOfBytes, $TotalNumberOfFreeBytes) = Win32::DriveInfo::DriveSpace($drive);				
		$blocks{$thisdrive} = int(($TotalNumberOfBytes)/1024) ;
		$used{$thisdrive} = int(($TotalNumberOfBytes - $TotalNumberOfFreeBytes)/1024) ;
		# print "Working on $drive : ".$used{$thisdrive}." of ".$blocks{$thisdrive}." \n" ;
	}
}

sub getWinLoad {
	use Win32::PerfLib;
	$processor = 238;
	$proctime = 6;
	$perflib = new Win32::PerfLib();
	$proc_ref0 = {};
	$proc_ref1 = {};
	$perflib->GetObjectList($processor, $proc_ref0);
	sleep 2;
	$perflib->GetObjectList($processor, $proc_ref1);
	$perflib->Close();
	$instance_ref0 = $proc_ref0->{Objects}->{$processor}->{Instances};
	$instance_ref1 = $proc_ref1->{Objects}->{$processor}->{Instances};
	foreach $p (keys %{$instance_ref0}) {
		$counter_ref0 = $instance_ref0->{$p}->{Counters};
		$counter_ref1 = $instance_ref1->{$p}->{Counters};
		foreach $i (keys %{$counter_ref0}) {
			next if $instance_ref0->{$p}->{Name} eq "_Total";
			if($counter_ref0->{$i}->{CounterNameTitleIndex} == $proctime) {
				$Numerator0 = $counter_ref0->{$i}->{Counter};
				$Denominator0 = $proc_ref0->{PerfTime100nSec};
				$Numerator1 = $counter_ref1->{$i}->{Counter};
				$Denominator1 = $proc_ref1->{PerfTime100nSec};
				$proc_time{$p} =	(1- (($Numerator1 - $Numerator0) /
									($Denominator1 - $Denominator0 )));
				# printf "Instance $p: %.2f\%\n", $proc_time{$p};
			}
		}
	}
	return (($proc_time{1}+$proc_time{2})/2) || 0 ;
}




1;

