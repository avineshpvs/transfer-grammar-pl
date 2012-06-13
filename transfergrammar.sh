perl $setu/bin/sys/common/printinput.pl $1 > transferinput
perl $setu/bin/sl_tl/transfergrammar/transfergrammar.pl --path=$setu/bin/sl_tl/transfergrammar --resource=$setu/data_bin/sl_tl/transfergrammar/Rules --input=transferinput
