#!/usr/bin/perl
sub main
{
	open(Fp,@ARGV[0]);
	%fs_array=();
	while(<Fp>)
	{
		if($_=~/^\#/ or $_=~/^\s*\n/)
		{
		#	print "nahin ",$_;
			next;
		}
		if($_=~/^\s*R\s*([0-9][0-9]*)\s*:\s*(.*)=>\s*(.*)\s*\n/)
	        {
			@array=split(/\s+/,$2);
		#	print "array ",@array," ",$#array,"\n";
			my $ss=$_;
			$fs_array{$ss}=$#array

		}
	}
	sub hash_sort
	{
	$fs_array{$b} <=> $fs_arary{$a};
	}
	open(file,">".@ARGV[0]."-modified");
	foreach $key (sort hash_sort (keys(%fs_array)))
	{
		print file $key;
	}
	close(file);


}
&main
