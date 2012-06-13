#!usr/bin/perl

sub modify_tree_rhs
{
	my $ref_nodes=$_[0];
	my $index=$_[1];
	my $sent=$_[2];
	my $ref_rule=$_[3];

	my @nodes=@$ref_nodes;
	my @_rule_=($$ref_rule);
	my @_lhs_= @_rule_->[0]->[0];
	my @_rhs_= @_rule_->[0]->[1];
	my $i=$index;
	my $k=0;
	my $delete=0;
	$log->info("#######DELETION OF THE CHUNKS######\n");
	########### DELETION Of CHUNKS #######################
	for($k=0;@_lhs_->[0]->[$k]->{"chunk"} ne "";$k++)
	{
		if(@_lhs_->[0]->[$k]->{"drop"}==1)
		{
			$log->info("Deletion Of @_lhs->[0]->[$k]->{\"chunk\"}\n");
			my @children=&get_children($nodes[$i]-$delete,$sent);
			my $num_childs=@children+2;	
			print ERR $nodes[$i],"-delete-",$delete,"\n";
			&delete_node($nodes[$i]-$delete,$sent);
			$delete=$delete+$num_childs;
		}
		$i++;
	}
	
	$log->info("#######REORDER OF THE NODES######\n");	
	######################################################
	@nodes=&get_children(0,$sent);
	######################################################
	##### REORDER OF THE NODES ###########################
	my $l=0;
	my $i=$index;
	my $cflag=0;
	my $add_count=0;
	my $drop_count=0;
	my @address_nodes;
	my $add_ind=0;
	my @mod_nodes=&get_children(0,$sent);
	my @move_lhs;
	my @move_rhs;
	for($k=0;@_lhs_->[0]->[$k]->{"chunk"} ne "";$k++)
	{
		if(@_lhs_->[0]->[$k]->{"drop"}==1)
		{
			$drop_count++;
			next;
		}
		else
		{
			@move_lhs[$add_ind]=$lhs_node=@_lhs_->[0]->[$k]->{"chunk"}."~".@_lhs_->[0]->[$k]->{"token_id"};
			@address_nodes[$add_ind]=$mod_nodes[$i];			
			$add_ind++;
			$i++;
		}
	}
	my $add_ind=0;
	for($l=0;@_rhs_->[0]->[$l]->{"chunk"} ne "";$l++)
	{
		if(@_rhs_->[0]->[$l]->{"add"} eq 1)
		{
			$add_count++;
			next;
		}
		else
		{
			@move_rhs[$add_ind]=@_rhs_->[0]->[$l]->{"chunk"}."~".@_rhs_->[0]->[$l]->{"token_id"};
			$add_ind++;
		}
	}
	
	################

	my $i=$index;
	my $pos_count=0;
	my $shift_count=0;
	my $l=0;
	my $pcount=0;
	my $prev_l=0;
	for($k=0;@move_lhs[$k] ne "";)
	{
		$pos_count=0;	
		$prev_l=$l;
		for(;$l<@move_rhs;$l++)
		{
			$log->info("Comparing: @move_lhs[$k]--@move_rhs[$l]\n");
			if(@move_lhs[$k] eq @move_rhs[$l])
			{
				if($pos_count==0)
				{
					$log->info("Done: @move_lhs[$k] Next\n");
					$k++;
					$l++;
					$pcount++;
					last;
				}
				else
				{
					&move_node(@address_nodes[$k-$shift_count],@address_nodes[$k-$shift_count+$pos_count],1,$sent);

					push(@move_lhs,"dummy");
					for($shift=@move_lhs-1;($shift)!=($k+$pos_count);$shift--)
					{
						$log->info("Shifting:--$move_lhs[$shift-1]-to-$move_lhs[$shift]\n");
						$move_lhs[$shift]=$move_lhs[$shift-1];
					}
					$move_lhs[$shift+1]=$move_lhs[$k];
					my @mod_nodes=&get_children(0,$sent);	
					$add_ind=0;
					$i=$index;
					while($add_ind<=@move_rhs)
					{
						@address_nodes[$add_ind]=$mod_nodes[$i];			
						$add_ind++;
						$i++;
					}
					$k++;
					$l=$prev_l;
					$shift_count++;
					last;
				}
			}
			else
			{
				$pos_count++;
			}
		}
	}

	$log->info("####DELETION OF WORDS#####\n");
	#############Deletion of Words#######################
	####################################################
	@nodes=&get_children(0,$sent);

	my $i=$index;
	for($k=0;@_rhs_->[0]->[$k]->{"chunk"} ne "";$k++)
	{
		$log->info("Node:$nodes[$i] Chunk:@_rhs_->[0]->[$k]->{\"chunk\"}\n");
		if($nodes[$i] eq "")
		{
			last;
		}
		my ($f0,$f1,$f2,$f3,$f4)=&get_fields($nodes[$i],$sent);

		if(@_rhs_->[0]->[$k]->{"head_val"} eq 1)
		{
		}
		if(@_rhs_->[0]->[$k]->{"add"} eq 1)
		{
			next;
		}
		else
		{
			if(@_rhs_->[0]->[$k]->{"drop_childs"}->[0] ne "")
			{
				$sent=&delete_children($nodes[$i],$sent,\@_rhs_->[0]->[$k]->{"drop_childs"});
				@nodes=&get_children(0,$sent);
			}
		}
		$i++;
	}


	#############################
	#############################
	@nodes=&get_children(0,$sent);
	###############################################################
	############REORDERING OF WORDS ###############################

	$log->info("####REORDERING OF WORDS#####\n");
	my $i=$index;

	my @rhs_pos;
	my @lhs_pos;
	for($l=0;@_rhs_->[0]->[$l]->{"chunk"} ne "";$l++)
	{
		my $rhs_chunk=@_rhs_->[0]->[$l]->{"chunk"}."~".@_rhs_->[0]->[$l]->{"token_id"};
		$i=$index+$l;
		my @lhs_words;
		my @rhs_words;
		if(@_rhs_->[0]->[$l]->{"add"}==1)
		{
			next;
		}
		for($k=0;@_lhs_->[0]->[$k]->{"chunk"} ne "";$k++)
		{
			my $lhs_chunk=@_lhs_->[0]->[$k]->{"chunk"}."~".@_lhs_->[0]->[$k]->{"token_id"};
			if(@_lhs_->[0]->[$k]->{"drop"}==1)
			{
				next;
			}
			if($lhs_chunk eq $rhs_chunk)
			{
				$log->info("Checking in $rhs_chunk\n");
				my $ref_rhs=@_rhs_->[0]->[$l]->{"fs"};
				my @check_rhs=@$ref_rhs;
				my $ref_lhs=@_lhs_->[0]->[$k]->{"fs"};
				my @check_lhs=@$ref_lhs;
				
				my $ref_drop_arr=@_rhs_->[0]->[$l]->{"drop_childs"};
				my $ref_add_arr=@_rhs_->[0]->[$l]->{"add_childs"};
				my @drop_arr=@$ref_drop_arr;
				my @add_arr=@$ref_add_arr;
				$log->info("Rhs -",$#check_rhs,"\n");
				$log->info("Lhs -",$#check_lhs,"\n");
				my $drop_flag=0;

				for($m=0;$m<=$#check_lhs;$m++)
				{
					
					$log->info("$m---",@_lhs_->[0]->[$k]->{"fs"}->[$m]->{"word_var"},"\n");
					if(@_lhs_->[0]->[$k]->{"fs"}->[$m]->{"word_var"} ne "")
					{
						$drop_flag=0;
						foreach (@drop_arr)
						{
							if($m==($_-1))
							{$drop_flag=1;}
						}
						if($drop_flag!=1)
						{	$log->info("Lhs Array---",@_lhs_->[0]->[$k]->{"fs"}->[$m]->{"word_var"},"\n");
							push(@lhs_words,@_lhs_->[0]->[$k]->{"fs"}->[$m]->{"word_var"});
						}
					}
					else{last;}
				}

				my $add_flag=0;
				for($m=0;$m<=$#check_rhs;$m++)
				{
					$log->info("$m---",@_rhs_->[0]->[$l]->{"fs"}->[$m]->{"word_var"},"\n");
					if(@_rhs_->[0]->[$l]->{"fs"}->[$m]->{"word_var"} ne "")
					{
						$add_flag=0;
						foreach (@add_arr)
						{
							if($m==($_-1))
							{
								$add_flag=1;
							}
						}
						if($add_flag!=1)
						{
							$log->info("Rhs Array ---",@_rhs_->[0]->[$l]->{"fs"}->[$m]->{"word_var"},"\n");
							push(@rhs_words,@_rhs_->[0]->[$l]->{"fs"}->[$m]->{"word_var"});
						}

					}
					else{last;}
				}
				$log->info("LHS WORDS\n");
				foreach (@lhs_words)
				{
					$log->info("$_-");
				}
				$log->info("\n");
				$log->info("RHS WORDS\n");
				foreach (@rhs_words)
				{
					$log->info("$_-");
				}
				$log->info("\n");
				last;
			}
		}
		my $n=0;
		my $pos_count_word=0;
		my $prev_n=0;
		my $pcount=0;
		my $shift_count=0;
		for($m=0;@lhs_words[$m] ne "";)
		{
			$pos_count_word=0;
			$prev_n=$n;
			$log->info("LHS WORDS--",@lhs_words[$m],"\n");
			$log->info("RHS WORDS-",@rhs_words,"\n");
			for(;$n<=$#rhs_words;$n++)
			{
				$log->info("Comparing--",@lhs_words[$m],"--",@rhs_words[$n],"--","\n");
				if($lhs_words[$m] eq $rhs_words[$n])
				{
					if($pos_count_word==0)
					{
						$m++;
						$n++;
						$pcount++;
						last;
					}
					else
					{
						$log->info("Moving Words ",@nodes[$i]+$m-$shift_count,"--",@nodes[$i]+$m-$shift_count+$pos_count_word,"\n");
						&move_node(@nodes[$i]+$m+1-$shift_count,@nodes[$i]+$m+1-$shift_count+$pos_count_word,1,$sent);
						push(@lhs_words,"dummy");
						for($shift=@lhs_words-1;($shift)!=$m+$pos_count_word;$shift--)
						{
							$log->info("Shifting $lhs_words[$shift-1] to $lhs_words[$shift]\n");
							$lhs_words[$shift]=$lhs_words[$shift-1];
						}
						$lhs_words[$shift+1]=$lhs_words[$m];
						$log->info("LHS array is @lhs_words\n");
						$log->info("RHS array is @rhs_words\n");
						$m++;
						$n=$prev_n;
						$shift_count++;
						last;
					}
				}
				else
				{
					$pos_count_word++;
				}
			}	
		}
		
	}

	#####Modifying the RHS#################################
	
	$log->info("####Modifying RHS Children\n");

	my $i=$index;
	@nodes=&get_children(0,$sent);
	for($k=0;@_rhs_->[0]->[$k]->{"chunk"} ne "";$k++)
	{
		$log->info("Node:$nodes[$i] Chunk:@_rhs_->[0]->[$k]->{\"chunk\"}\n");
		if($nodes[$i] eq "")
		{
			last;
		}
		my ($f0,$f1,$f2,$f3,$f4)=&get_fields($nodes[$i],$sent);

		if(@_rhs_->[0]->[$k]->{"head_val"} eq 1)
		{
			$sent=&head_modify($nodes[$i],$sent,\@_rhs_->[0]->[$k]->{"head_fs"});
		}
		if(@_rhs_->[0]->[$k]->{"add"} eq 1)
		{
			$log->info("Add Node::$nodes[$i]::@_rhs->[0]->[$k]->{\"chunk\"}\n");
			$sent=&add_function($nodes[$i],$sent,\@_rhs_->[0]->[$k]);
			@nodes=&get_children(0,$sent);
			$i=$i+@_rhs_->[0]->[$k]->{"add_val"};
			next;
		}
		else
		{
			if(@_rhs_->[0]->[$k]->{"add_childs"}->[0] ne "")
			{
				$sent=&add_children($nodes[$i],$sent,\@_rhs_->[0]->[$k]->{"add_childs"},\@_rhs->[0]->[$k]);
				@nodes=&get_children(0,$sent);
			}
			$log->info("Modifying Children\n");
			$sent=&children_modify($nodes[$i],$sent,\@_rhs_->[0]->[$k]->{"fs"});
			$i++;
			
		}
	}
}

sub add_function
{
	my $index=@_[0];
	my $sent=@_[1];
	my $ref_rhs_chunk=@_[2];
	my @temp_array_rhs1=($$ref_rhs_chunk);

	(undef my @_small_TREE_);
	
	my $k;

	$_small_TREE_[0][1]="0";
	$_small_TREE_[0][2]="((";
	$_small_TREE_[0][3]=$$ref_rhs_chunk->{"chunk"};
	my @array_fs;
	for($k=0;@temp_array_rhs1->[0]->{"fs"}->[$k]->{"word"} ne "";$k++)
	{
		$_small_TREE_[$k+1][1]=$k+1;
		push(@array_fs,@temp_array_rhs1->[0]->{"fs"}->[$k]->{"word"});
		push(@array_fs,@temp_array_rhs1->[0]->{"fs"}->[$k]->{"pos"});
		push(@array_fs,@temp_array_rhs1->[0]->{"fs"}->[$k]->{"root"});
		push(@array_fs,@temp_array_rhs1->[0]->{"fs"}->[$k]->{"lcat"});
		push(@array_fs,@temp_array_rhs1->[0]->{"fs"}->[$k]->{"num"});
		push(@array_fs,@temp_array_rhs1->[0]->{"fs"}->[$k]->{"gend"});
		push(@array_fs,@temp_array_rhs1->[0]->{"fs"}->[$k]->{"pers"});
		push(@array_fs,@temp_array_rhs1->[0]->{"fs"}->[$k]->{"case"});
		push(@array_fs,@temp_array_rhs1->[0]->{"fs"}->[$k]->{"cm"});
		push(@array_fs,@temp_array_rhs1->[0]->{"fs"}->[$k]->{"tam"});
		my $l=0;
		$num=@array_fs;
		while($l<$num)
		{

			if($array_fs[$l]=~/\$/)
			{
				if($array_fs[$l]=~/(\$[a-zA-Z]+)$/)
				{
					$array_fs[$l]="$var_hash{$1}";
				}
				elsif($array_fs[$l]=~/([^\$]*\.)?(\$[a-zA-Z])\.(.*)?/)
				{
					my $temp1=$1;
					my $var1=$2;
					my $temp2=$3;
					$array_fs[$l]=$temp1."$var_hash{$var1}".$temp2;
				}
			}
			$l++;
		}
		$_small_TREE_[$k+1][2]=$array_fs[0],"\n";
		$_small_TREE_[$k+1][3]=$array_fs[1],"\n";
		$_small_TREE_[$k+1][4]="<fs af='$array_fs[2],$array_fs[3],$array_fs[4],$array_fs[5],$array_fs[6],$array_fs[7],$array_fs[8],$array_fs[9]'>";
	}
	$_small_TREE_[$k+1][2]="))";
	$_small_TREE_[0][0]=$k+2;

	&add_node(\@_small_TREE_,$index,0,$sent);
	return ($sent);
}


sub head_modify
{
	my $node=@_[0];
	my $sent=@_[1];
	my $ref_temp_fs_hash=@_[2];
	my $ref_temp_hash=$$ref_temp_fs_hash;
	my %temp_hash=%$ref_temp_hash;
	my ($f0,$f1,$f2,$f3,$f4)=&get_fields($node,$sent);
	my $fs_head_array = &read_FS($f4,$sent);
	$sent=&modify_fs(\%temp_hash,$node,$sent);
	return $sent;
}

sub add_children
{
	my $node=@_[0];
	my $sent=@_[1];
	my $ref_temp_children_array=@_[2];
	my $ref_temp_array=$$ref_temp_children_array;
	my @temp_array=@$ref_temp_array;

	my $ref_rhs_chunk=@_[3];
	$log->info("ADDING CHILDREN\n");
	my @temp_array_rhs1=($$ref_rhs_chunk);
	my $add=0;
	foreach (@temp_array)
	{
		my @array;
		push(@array,@temp_array_rhs1->[0]->{"fs"}->[$_]->{"word"});
		push(@array,@temp_array_rhs1->[0]->{"fs"}->[$_]->{"pos"});
		push(@array,@temp_array_rhs1->[0]->{"fs"}->[$_]->{"root"});
		push(@array,@temp_array_rhs1->[0]->{"fs"}->[$_]->{"lcat"});
		push(@array,@temp_array_rhs1->[0]->{"fs"}->[$_]->{"gend"});
		push(@array,@temp_array_rhs1->[0]->{"fs"}->[$_]->{"num"});
		push(@array,@temp_array_rhs1->[0]->{"fs"}->[$_]->{"pers"});
		push(@array,@temp_array_rhs1->[0]->{"fs"}->[$_]->{"case"});
		push(@array,@temp_array_rhs1->[0]->{"fs"}->[$_]->{"cm"});
		push(@array,@temp_array_rhs1->[0]->{"fs"}->[$_]->{"tam"});
		my $l=0;
		my $num=@array;
		while($l<$num)
		{
			if($array[$l]=~/\$/)
			{
				if($array[$l]=~/(\$[a-zA-Z]+)$/)
				{
					$array[$l]="$var_hash{$1}";
				}
				elsif($array[$l]=~/([^\$]*\.)?(\$[a-zA-Z])\.(.*)?/)
				{
					my $temp1=$1;
					my $var1=$2;
					my $temp2=$3;
					$array[$l]=$temp1."$var_hash{$var1}".$temp2;
				}
			}
			$l++;
		}
		my $fs="<fs af=\'$array[2],$array[3],$array[4],$array[5],$array[6],$array[7],$array[8],$array[9]\'>";
		&add_leaf($node+$_+$add,0,$array[0],$array[1],$fs,$sent);
		$log->info("@array[0],@array[1],$fs,\n");
		$add++;
	}
	return ($sent);
}


sub delete_children
{
	my $node=@_[0];
	my $sent=@_[1];
	my $ref_temp_children_array=@_[2];
	my $ref_temp_array=$$ref_temp_children_array;
	my @temp_array=@$ref_temp_array;
	my $delete=0;
	my @sort_remove=sort{$a <=> $b} @temp_array;

	my $delete=0;
	foreach (@sort_remove)
	{
		&delete_node($node+$_-$delete,$sent);
		$delete++;
	}
	return ($sent);
}

sub modify_fs
{
	my $ref_hash=@_[0];
	my %temp_hash=%$ref_hash;
	 
	my $node=@_[1];
	my $sent=@_[2];

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
	my @array;
	while($l<$num)
	{

		if($array_fs[$l] eq "")
		{
			$array[$l]="NULL";
		}
		else
		{
			$log->info("$l $array_fs[$l]\n");
			if($array_fs[$l] eq "NULL")
			{
				$array[$l]="";
			}
			if($array_fs[$l]=~/(\$[a-zA-Z]+)$/)
			{
				$array[$l]="$var_hash{$1}";
			}
			elsif($array_fs[$l]=~/([^\$]*\.)?(\$[a-zA-Z])\.(.*)?/)
			{
				my $temp1=$1;
				my $var1=$2;
				my $temp2=$3;
				$array[$l]=$temp1."$var_hash{$var1}".$temp2;
			}
			else
			{
				$array[$l]=$array_fs[$l];
				$log->info("Val $l - $array[$l]\n");
			}
		}
		$l++;
	}

	@lex[0]=@array[2];
	@cat[0]=@array[3];
	@gen[0]=@array[4];
	@num[0]=@array[5];
	@per[0]=@array[6];
	@cas[0]=@array[7];
	@tam[0]=@array[8];
	@suff[0]=@array[9];
	$l=0;
        my ($f0,$f1,$f2,$f3,$f4)=&get_fields($node,$sent);
        my $fs_head_array = &read_FS($f4,$sent);
	while($l<$num)
	{
		if($array[$l] ne "NULL")
		{
			if($l==0){&modify_field($node,2,$array[$l],$sent);}
			if($l==1){&modify_field($node,3,$array[$l],$sent);}
			if($l==2){&update_attr_val("lex", \@lex,$fs_head_array,$sent);}
			if($l==3){&update_attr_val("cat", \@cat,$fs_head_array,$sent);}
			if($l==4){&update_attr_val("gen", \@gen,$fs_head_array,$sent);}
			if($l==5){&update_attr_val("num", \@num,$fs_head_array,$sent);}
			if($l==6){&update_attr_val("per", \@per,$fs_head_array,$sent);}
			if($l==7){&update_attr_val("cas", \@cas,$fs_head_array,$sent);}
			if($l==8){&update_attr_val("vib", \@tam,$fs_head_array,$sent);}
			if($l==9){&update_attr_val("tam", \@suff,$fs_head_array,$sent);}
		}
		$l++;
	}

	my $string=&make_string($fs_head_array,$sent);
	&modify_field($node,4,$string,$sent);
	return $sent;
}

sub children_modify
{
	my $node=@_[0];
	my $sent=@_[1];
	my $ref_temp_fs_array=@_[2];
	my $ref_temp_array=$$ref_temp_fs_array;
	my @temp_array=@$ref_temp_array;
	my @children=&get_children($node,$sent);
	for($l=0;$l<=$#children;$l++)
	{
		$log->info("Modifying FS of Child $l+1 \n");
		my ($f0,$f1,$f2,$f3,$f4)=&get_fields($children[$l],$sent);
		my $fs_head_array = &read_FS($f4,$sent);

		my $ref_temp_hash=$temp_array[$l];
		my %temp_hash=%$ref_temp_hash;
		$sent=&modify_fs(\%temp_hash,$children[$l],$sent);
	}
	return $sent;
}
1;
