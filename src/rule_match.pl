#!/usr/bin/perl

%var_hash=();

sub rule_match 
{
	my $sent=@_[0];
	my $ref_RULE_TREE_=@_[1];
	
	@_RULE_TREE_=@$ref_RULE_TREE_;

	my $count=0;
		
	## Handling SSF 
	my @tree=&get_children(0,$sent);		
	my $ssf_string=&get_field($tree[0],3,$sent);
	if($ssf_string eq "SSF")
	{
		@nodes=&get_children(1,$sent);
	}
	else
	{
		@nodes=@tree
	}


	my $flag=0;
	for(my $i=0;$i<=$#nodes;)
	{
		for(my $j=0;$j<=$#_RULE_TREE_;$j++)
		{
			my ($f0,$f1,$f2,$f3,$f4)=&get_fields($nodes[$i],$sent);
			my $temp_i=$i;
			my $old_i=$i;
			my @array_lhs1=$_RULE_TREE_[$j]->[0];
			for(my $k=0;$_RULE_TREE_[$j]->[0]->[$k]->{"chunk"} ne "";)
			{
				$log->info("RULE AT-$f3\n");
				$log->info("Rule No--$_RULE_TREE_[$j]->[2]->[0]\n");
				$log->info("Pos in Rule--,",$k+1,"\n");
				$log->info("Rule Chunk Tag:,",$_RULE_TREE_[$j]->[0]->[$k]->{"chunk"},"\n");
				if($f3 eq $_RULE_TREE_[$j]->[0]->[$k]->{"chunk"})
				{
					if($_RULE_TREE_[$j]->[0]->[$k]->{"drop"}==1)
					{
						$log->info("DROP ",$_RULE_TREE_[$j]->[0]->[$k]->{"chunk"},"\n");
					}	
					if($_RULE_TREE_[$j]->[0]->[$k]->{"head_val"} eq 0)
					{
						$ref_check=$_RULE_TREE_[$j]->[0]->[$k]->{"fs"};
						my @new_array=@$ref_check;
						$flag=&children_fs_match($nodes[$temp_i],$sent,\$_RULE_TREE_[$j]->[0]->[$k]->{"fs"});
					}
					if($_RULE_TREE_[$j]->[0]->[$k]->{"head_val"} eq 1)
					{
						$flag=&head_fs_match($nodes[$temp_i],$sent,\$_RULE_TREE_[$j]->[0]->[$k]->{"head_fs"});
					}
					if($flag ne "1")
					{
						$i=$old_i;
						last;
					}
					else
					{
						$temp_i++;
						$k++;
						if($temp_i>$#nodes and $_RULE_TREE_[$j]->[0]->[$k]->{"chunk"} eq "")
						{
							$i=$old_i;
							last;	
						}
						if($temp_i>$#nodes)
						{
							$flag=0;
							$i=$old_i;
							last;	
						}

						($f0,$f1,$f2,$f3,$f4)=&get_fields($nodes[$temp_i],$sent);

						next;
					}
				}
				else
				{
					$flag=0;
					$i=$old_i;
					last;
				}
			}
			if($flag eq 1)
			{
				my %temp_array_rhs=$_RULE_TREE_[$j]->[1]->[0];
				($f0,$f1,$f2,$f3,$f4)=&get_fields($nodes[$i],$sent);
				$log->info("Applying Rule number:$_RULE_TREE_[$j]->[2]->[0],\@ $f0\n");
				$log->info("MODIFY USING RULE\n");				
				&modify_tree_rhs(\@nodes,$i,$sent,\$_RULE_TREE_[$j]);
				@nodes=&get_children(0,$sent);
				$flag=0;
				next;
			}
		}
		$i++;
	}
}

sub match_fs
{
	my $word1=@_[0];
	my $pos1=@_[1];
	my $fs1=@_[2];
	my $ref_hash=@_[3];
	my $sent=@_[4];
	my %temp_hash=%$ref_hash;

	my $fs_array = &read_FS($fs1,$sent);
	my @lex = &get_values("lex", $fs_array);my @cat = &get_values("cat", $fs_array);
	my @gen = &get_values("gen", $fs_array);my @num = &get_values("num", $fs_array);
	my @per = &get_values("per", $fs_array);my @cas = &get_values("cas", $fs_array);
	my @tam = &get_values("vib", $fs_array);my @suff = &get_values("tam", $fs_array);

	my @array;
	push(@array,$word1);push(@array,$pos1);push(@array,$lex[0]);push(@array,$cat[0]);push(@array,$gen[0]);
	push(@array,$num[0]);push(@array,$per[0]);push(@array,$cas[0]);push(@array,$tam[0]);push(@array,$suff[0]);

	my $flag=1;
	my $att;
	my @array_fs;
	push(@array_fs,$temp_hash{"word"});push(@array_fs,$temp_hash{"pos"});push(@array_fs,$temp_hash{"root"});
	push(@array_fs,$temp_hash{"lcat"});push(@array_fs,$temp_hash{"gend"});push(@array_fs,$temp_hash{"num"});
	push(@array_fs,$temp_hash{"pers"});push(@array_fs,$temp_hash{"cas"});
	if($temp_hash{"tam"} ne ""){
		push(@array_fs,$temp_hash{"tam"});
	}
	else{
		push(@array_fs,$temp_hash{"cm"});
	}
	push(@array_fs,$temp_hash{"suff"});

	my $l=0;
	my $num=@array_fs;
	while($l<$num)
	{
		if($array_fs[$l] ne "")
		{
			if($array[$l] eq "" and $array_fs[$l] eq "NULL"){
				$l++;
				next;
			}
			if($array_fs[$l]=~/(\$[a-zA-Z]+)$/){
				$var_hash{$1}=$array[$l];
				$log->info("Variable:$1 Value:$array[$l]\n");
				$l++;
				next;
			}
			if($array_fs[$l]=~/([^\$]*\.)?(\$[a-zA-Z])\.(.*)?$/){
				my $temp1=$1;
				my $var1=$2;
				my $temp2=$3;
				if($array[$l]=~/$temp1(.*)$temp2$/){
					$log->info("Variable:$var1 Value:$1\n");
					$var_hash{$var1}=$1;
					$l++;
					next;
				}
				else{	
					$flag=0;
					return $flag;
				}
			}
			elsif($array_fs[$l] ne $array[$l]){
				$flag=0;
				$log->info("Input Value and Rule Value :$array_fs[$l] and $array[$l] Don't Match\n");
				return $flag;
			}
		}
		$l++;
	}
	return $flag;
}

sub head_fs_match
{
	my $node=@_[0];
	my $sent=@_[1];
	my $ref_temp_fs_hash=@_[2];
	my $ref_temp_hash=$$ref_temp_fs_hash;
	my %temp_hash=%$ref_temp_hash;
	my $flag=1;
	my ($f0,$f1,$f2,$f3,$f4)=&get_fields($node,$sent);
	$flag=&match_fs($f2,$f3,$f4,\%temp_hash,$sent);
	$log->info("Head Flag Val=$flag\n");
	return $flag;
}

sub children_fs_match
{
	my $node=@_[0];
	my $sent=@_[1];
	my $ref_temp_fs_array=@_[2];
	my $ref_temp_array=$$ref_temp_fs_array;
	my @temp_array=@$ref_temp_array;
	my @children=&get_children($node,$sent);
	my $num=@children;

	for($l=0;$l<$num;$l++)
	{
		my ($f0,$f1,$f2,$f3,$f4)=&get_fields($children[$l],$sent);
		my $ref_temp_hash=$temp_array[$l];
		my %temp_hash=%$ref_temp_hash;
		$log->info("Word::$f2 ::Pos::$f3 ::Fs::$f4::\n");
		$flag=&match_fs($f2,$f3,$f4,\%temp_hash,$sent);
		$log->info("Part Flag Val=$flag\n");
		if($flag==0)
		{
			return $flag;
		}
	}
	$ref_temp_hash=$temp_array[3];
	$num=@temp_array;
	%temp_hash=%$ref_temp_hash;
	if($#children<$#temp_array)
	{
		return 0;
	}
	$log->info("Flag Val=$flag\n");
	return $flag;
}
1;
