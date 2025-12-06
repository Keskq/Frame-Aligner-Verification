


vsim -coverage -voptargs="+acc" work.aligner_tb_top +UVM_TESTNAME=aligner_test +UVM_COVERAGE

vsim +access+r;
run -all;
acdb save;
acdb report -db fcover.acdb -txt -o cov.txt -verbose 
exec cat cov.txt;
exit
