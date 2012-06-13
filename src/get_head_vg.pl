#!/usr/bin/perl


#&AddID($ARGV[0]);
sub copy_head_vg
{
	my($pos_tag) = $_[0];
	my($sent) = $_[1];
	my $transfer_home = $_[2];
	require "$transfer_home/API/shakti_tree_api.pl";
	require "$transfer_home/API/feature_filter.pl";

	my %hash=();
	if($pos_tag =~ /^NP/)
	{
		$match = "N";
	}
	if($pos_tag =~ /^V/ )
	{
		$match = "V";
	}
	if($pos_tag =~ /^JJP/ )
	{
		$match = "J";
	}
	if($pos_tag =~ /^CCP/ )
	{
		$match = "CC";
	}
	if($pos_tag =~ /^RBP/ )
	{
		$match = "RB";
	}
	

	@np_nodes = &get_nodes(3,$pos_tag,$sent);
	for($i=$#np_nodes; $i>=0; $i--)
	{
		my(@childs) = &get_children($np_nodes[$i],$sent);
		$j = 0;
		while($j <= $#childs)
		{
			my($f0,$f1,$f2,$f3,$f4) = &get_fields($childs[$j],$sent);
			$word=$f2;
			if($f3 =~ /^$match/)
			{
				$new_fs = $f4;
				if($hash{$f2} eq "")
                                {
                                        $hash{$word}=1;
                                }
                                elsif($hash{$f2} ne "")
                                {
                                        $hash{$word}=$hash{$word}+1;
                                }
                                $id=$hash{$word};
                                my ($x,$y)=split(/>/,$f4);
				if($id==1)
                                {
                                        $att_val="$word";
                                }
                                if($id!=1)
                                {
					$att_val="$word"."_"."$id";
				}
				if($x=~/name=/)
				{
					my ($new_x,$new_y)=split("' ",$x);
					$new_fs = $new_x."'"." head=\"$att_val\">";
					my $new_head_fs=$x.">";
				}
				else
				{
					$new_fs = $x." head=\"$att_val\">";
					my $new_head_fs=$x." name=\"$att_val\">";
					&modify_field($childs[$j],4,$new_head_fs,$sent);

				}
				last;
			}
			elsif($j == 0)
			{
				my($f0,$f1,$f2,$f3,$f4) = &get_fields($childs[$#childs],$sent);
				$word=$f2;
				if($hash{$f2} eq "")
                                {
                                        $hash{$word}=1;
                                }
                                elsif($hash{$f2} ne "")
                                {
                                        $hash{$word}=$hash{$word}+1;
                                }
                                $id=$hash{$word};

                                my ($x,$y)=split(/>/,$f4);
				if($id==1)
                                {
                                        $att_val="$word";
                                }
				if($id!=1)
				{
					$att_val="$word"."_"."$id";
				}
				if($x!=~/name/)
				{
					$new_fs = $x." head=\"$att_val\">";
					my $new_head_fs=$x." name=\"$att_val\">";
					&modify_field($childs[$change],4,$new_head_fs,$sent);
				}
				else
				{
					$new_fs = $x.">";
					my $new_head_fs=$x.">";
				}

			
			}
			$j++;
		}
		($f0,$f1,$f2,$f3,$f4) = &get_fields($np_nodes[$i],$sent);
		if($f4 eq '')
		{
			&modify_field($np_nodes[$i],4,$new_fs,$sent);
		}
		else
		{
			$fs_ptr = &read_FS($f4,$sent);
			$new_fs_ptr = &read_FS($new_fs,$sent);
			&merge($fs_ptr,$new_fs_ptr,$sent);
			$fs_string = &make_string($fs_ptr,$sent);
			&modify_field($np_nodes[$i],4,$fs_string,$sent);

		}
	}
}
1;
