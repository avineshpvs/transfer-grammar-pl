#!/usr/bin/perl
use Getopt::Long;
use Log::Log4perl;

GetOptions("help!"=>\$help,
	   "version"=>\$version,
	   "path=s"=>\$transfer_home,
	   "log=s"=>\$logFile,
	   "resource=s"=>\$rule_file,
	   "input=s"=>\$input,
	   "output=s",\$output);

print "Unprocessed by Getopt::Long\n" if $ARGV[0];
foreach (@ARGV) {
        print "$_\n";
        exit(0);
}

if($help eq 1)
{
        print "Transfer Grammar Engine  - Transfer Grammar Engine 2.4.3\n(6 Mar 2009)\n\n";
        print "usage : ./transfergrammar.pl --path=/home/transfergrammar-2.4.3 --log=logfile --resource=Rules [-i inputfile|--input=\"input_file\"] [-o outputfile|--output=\"output_file\"] \n";
        print "\tIf the output file is not mentioned then the output will be printed to STDOUT\n";
        exit(0);
}
if($version eq 1)
{
	print "Transfer Grammar Engine , VERSION - 2.4.3\n(Last Updated 6th Mar 2009)\n\n";
	exit(0);
}

if($transfer_home eq "")
{
        print "Please Specify the Path as defined in --help\n";
        exit(0);

}
if(! -e $rule_file)
{
	 print "The RULE FILE doesn't exist Please check the path\n";
	 exit(0);
}
if($rule_file eq "")
{
        print "Please Specify the Path of the RULE FILE as in --help\n";
        exit(0);

}

my $logfile = "$transfer_home/common/log.conf";

Log::Log4perl->init($logfile);

sub logfile {
	if($logFile ne "")
	{

		if (-e "$transfer_home/$logFile") {
			system("rm -f $transfer_home/$logFile");
		}
	}
	else
	{

		$logFile="transfer.log";
		if (-e "$transfer_home/$logFile") {
			system("rm -f $transfer_home/$logFile");
		}
	}
	my $myLog = "$transfer_home/$logFile" || "$transfer_home/transfer.log";
	return $myLog;
}
$log = Log::Log4perl->get_logger;


my $src=$transfer_home . "/src";
require "$src/load.pl";
require "$src/rule_match.pl";
require "$src/copy_np_head.pl";
require "$src/copy_vg_head.pl";
require "$src/modify.pl";
require "$transfer_home/API/shakti_tree_api.pl";
require "$transfer_home/API/feature_filter.pl";


sub main
{
	undef  (@_RULE_TREE_);

	$log->info("##ENTERING LOAD RULE FUNC\n\n");
	print STDERR "$rule_file\n";
	my $ref_RULE_TREE_=&load($rule_file,\@_RULE_TREE_);
	$log->info("##OUT OF LOAD RULE FUNC\n");
	
	if ($input eq "")
	{
	  $input="/dev/stdin";
	}

	&read_story($input);

	$numBody = &get_bodycount();
	for(my($bodyNum)=1;$bodyNum<=$numBody;$bodyNum++)
	{

		$body = &get_body($bodyNum,$body);
		# Count the number of Paragraphs in the story
		my($numPara) = &get_paracount($body);
		#print STDERR "Paras : $numPara\n";
		# Iterate through paragraphs in the story
		for(my($i)=1;$i<=$numPara;$i++)
		{
			my($para);
			# Read Paragraph
			$para = &get_para($i);
			# Count the number of sentences in this paragraph
			my($numSent) = &get_sentcount($para);
			# print STDERR "\n $i no.of sent $numSent";
			#print STDERR "Para Number $i, Num Sentences $numSent\n";
			#print $numSent."\n";
			# Iterate through sentences in the paragraph
			for(my($j)=1;$j<=$numSent;$j++)
			{
				#print " ... Processing sent $j\n";
				# Read the sentence which is in SSF format
				my($sent) = &get_sent($para,$j);
				#print STDERR "$sent";
#				
				$log->info("##ENTERING RULE MATCH func\n\n");
				&rule_match($sent,$ref_RULE_TREE_);
				$log->info("##OUT of RULE MATCH func\n\n");
#				&copy_np_head($sent,$transfer_home);
#				&copy_vg_head($sent,$transfer_home);
			}
		}
	}

	if($output eq "")
	{
		#&print_tree();
		&printstory();
	}
	if($output ne "")
	{
		#&print_tree_file("$output1");
		&printstory_file("$output");
	}

}
&main;
