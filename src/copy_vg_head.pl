#!/usr/bin/perl

#for details please check get_head.pl
sub copy_vg_head
{
	my $sent=@_[0];
	my $transfer_home = @_[1];
	my $src=$transfer_home . "/src";
	require "$transfer_home/API/shakti_tree_api.pl";
	require "$transfer_home/API/feature_filter.pl";
	require "$src/get_head_vg.pl";


	&copy_head_vg("VGF",$sent,$transfer_home);
	&copy_head_vg("VGNF",$sent,$transfer_home);
	&copy_head_vg("VGINF",$sent,$transfer_home);
	&copy_head_vg("VGNN",$sent,$transfer_home);
}
1;

