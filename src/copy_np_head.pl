##!/usr/bin/perl

# For the details please see get_head.pl
sub copy_np_head
{
	my $sent=@_[0];
	my $transfer_home=@_[1];
	my $src=$transfer_home . "/src";
	require "$transfer_home/API/shakti_tree_api.pl";
	require "$transfer_home/API/feature_filter.pl";
	require "$src/get_head_np.pl";


	&copy_head_np("NP",$sent,$transfer_home);
	&copy_head_np("JJP",$sent,$transfer_home);
	&copy_head_np("CCP",$sent,$transfer_home);
	&copy_head_np("RBP",$sent,$transfer_home);
	&copy_head_np("BLK",$sent,$transfer_home);
	&copy_head_np("NEGP",$sent,$transfer_home);
	#&print_tree();
}	#End of Sub
1;
