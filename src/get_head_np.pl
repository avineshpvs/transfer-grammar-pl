#!/usr/bin/perl

sub copy_head_np
{
	
	my ($pos_tag)=$_[0];
	my ($sent)=$_[1];
	my $transfer_home = $_[2];
	my %hash=();

	if($pos_tag =~ /^NP/)
	{
		$match = "NN"; #Modified in version 1.4
			       #For NST
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

	my @np_nodes = &get_nodes(3,$pos_tag,$sent);
	
	for($i=$#np_nodes;$i>=0;$i--)
	{
		my (@childs)=&get_children($np_nodes[$i],$sent);
		$j = $#childs;
		while($j >= 0)
		{
			my($f0,$f1,$f2,$f3,$f4)=&get_fields($childs[$j],$sent);
			$word=$f2;
			
			if($f3=~/^$match/)
			{
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
			
				my($f0,$f1,$f2,$f3,$f4)=&get_fields($childs[$#childs],$sent);
				#-----------------modifications to handle PRP and PSP case------------------
				$change=$#childs;	

				while(1)
				{
					if($f3 eq "PSP" or $f3 eq "PRP")
					{
						$change=$change-1;
						if($childs[$change] eq "") 	##Modifications per Version 1.3
						{				##To handle NP chunks with single PSP
							$change=$change+1;	##
							last;			##
						}
						($f0,$f1,$f2,$f3,$f4)=&get_fields($childs[$change],$sent);
					}
					else
					{
						last;
					}
				}
				
				$new_fs = $f4;
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
				#--------------------------------------------------------------------------------
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
			$j--;
		}
		($f0,$f1,$f2,$f3,$f4) = &get_fields($np_nodes[$i],$sent);
		if($f4 eq '')
		{
			##print "1check ---$new_fs\n";
#	print "f4--check1 $f4,$head_att_val,new_fs $new_fs\n";
			&modify_field($np_nodes[$i],4,$new_fs,$sent);

			($f0,$f1,$f2,$f3,$f4) = &get_fields($np_nodes[$i],$sent);
			$fs_ptr = &read_FS($f4,$sent);
			&add_attr_val("name",$head_att_val,$fs_ptr,$sent);
		}
		else
		{
#			print "CHECK--f4--check1 $f4,new_fs=$new_fs-\n";
			$fs_ptr = &read_FS($f4,$sent);
			$new_fs_ptr = &read_FS($new_fs,$sent);
			&merge($fs_ptr,$new_fs_ptr,$sent);
			$fs_string = &make_string($fs_ptr);
			&modify_field($np_nodes[$i],4,$fs_string,$sent);
			#($f0,$f1,$f2,$f3,$f4) = &get_fields($np_nodes[$i],$sent);
			#$fs_ptr = &read_FS($f4,$sent);
			#&add_attr_val("name",$head_att_val,$fs_ptr,$sent);

			#&modify_field($np_nodes[$i], 4, $head_att_val,$sent);
		}
	}
	#&print_tree();
}
1;
