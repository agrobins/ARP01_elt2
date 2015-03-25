##############################################################################
#Author: Adam Robinson
#Date: 08/14/2014
#Purpose: normalize all .wig outputs of 'autoAnalyzeChipseq_v6.sh' per bp
##############################################################################

#!bin/bash/

###step 1: create array containing all files listed in options###
file=($(echo "$@"))
index=0
count=${#file[@]}
last_file=$(echo ${file[@]:(-1)})

#step 2-4 performed through while loop#
###step 2: find .wig file; count lines of clean reads in fastq file, divide by four to find the total number of reads. Output goes to .log file###
###step 3: calculate per base average coverage. Output sent to per-bp_normalization_factor.log file###
###step 4: normalize .wig file; send output to *_norm.wig file###

while [ "$index" -lt "$count" ]
do
	WIG=$(find -name "8_${file[$index]}.wig")
	total_reads=$(find . -name 2_${file[$index]}_clean.fastq -execdir  wc -l {} \; | awk '{print $1/4}')
	AVG=$(echo "scale=25;$total_reads*50/100300000" | bc)
	pre_norm_file=(${WIG%.wig})
	norm_file=(${pre_norm_file}_norm.wig)
	echo $norm_file; echo $AVG
	cat $WIG | awk -v abc=$AVG '{ if($1 == "track"){print $0; next;} else if($1=="fixedStep"){print $0; next;} else {print $1/abc; next;} }' > $norm_file
	index=$(( $index + 1 ))
done > ${file[0]}-${last_file}_perBP_norm_factor.log

	
