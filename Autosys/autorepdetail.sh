#!/bin/ksh
#
# MIT License
#
# Copyright (c) 2018 Praveen Lobo (praveenlobo.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

echo "$0 version 1.1"
echo "This script exports the job details of the jobs that start with the search string provided."

if [ $# -ne 1 ]; then
  echo "Usage: $0 Search_String"
  exit 101
fi

echo "You may need to set the Autosys environment definitions here."

app=$1
echo "Search_String - ${app}"

# extract a list of matching jobs and put into a normalized CSV
autorep -q -j ${app}% | grep "insert_job:" | cut -f 2 -d: | sort -u -b > tempjoblist

# remove "jobtype from line
sed 's/job_type/ /g' tempjoblist > joblist

# create the CSV header
echo "job name,box name,owner,machine,profile,command,calendar,condition,date_conditions,days_of_week,start_times,exclude_calendar,description,std_out,std_err,maxrun,alarm_if_fail,svcdesk_desc,svcdesk_attr">${app}_jobs.csv

# loop through and populate the CSV with details for each job in the list
for i in $(cat joblist); do 
	echo ${i}
	autorep -q -j $i -L0 > tt
  # get the information needed in a CSV	
	    jn=`grep "insert_job:"       tt | cut -f 2 -d:  | sed 's/job_type/ /g' | sed 's/,/_/g' `
	    bn=`grep "box_name:"         tt | cut -f 2- -d: | sed 's/,/_/g' `
	  ownr=`grep "owner:"            tt | cut -f 2- -d: | sed 's/,/_/g' `
	    mn=`grep "machine:"          tt | cut -f 2- -d: | sed 's/,/_/g' `
	   prf=`grep "profile:"          tt | cut -f 2- -d: | sed 's/,/_/g' `
	   cmd=`grep "command:"          tt | cut -f 2- -d: | sed 's/,/_/g' `
	 clndr=`grep "calendar:"         tt | cut -f 2- -d: | sed 's/,/_/g' `
	  cond=`grep "condition:"        tt | cut -f 2- -d: | sed 's/,/_/g' `
	dtcond=`grep "date_conditions:"  tt | cut -f 2- -d: | sed 's/,/_/g' `
	   dow=`grep "days_of_week:"     tt | cut -f 2- -d: | sed 's/,/_/g' ` 
	    st=`grep "start_times:"      tt | cut -f 2- -d: | sed 's/,/_/g' `     
	 excal=`grep "exclude_calendar:" tt | cut -f 2- -d: | sed 's/,/_/g' `
	  desc=`grep "description:"      tt | cut -f 2- -d: | sed 's/,/_/g' `
	  sout=`grep "std_out_file:"     tt | cut -f 2- -d: | sed 's/,/_/g' `
	  serr=`grep "std_err_file:"     tt | cut -f 2- -d: | sed 's/,/_/g' `
	maxrun=`grep "max_run_alarm:"    tt | cut -f 2- -d: | sed 's/,/_/g' `
	   aif=`grep "alarm_if_fail:"    tt | cut -f 2- -d: | sed 's/,/_/g' `
	 sdesc=`grep "svcdesk_desc:"     tt | cut -f 2- -d: | sed 's/,/_/g' `
	 sattr=`grep "svcdesk_attr:"     tt | cut -f 2- -d: | sed 's/,/_/g' `
	
	print -r $jn,$bn,	$ownr,	$mn,	$prf,	$cmd,	$clndr,	$cond,	$dtcond,	$dow,	$st,	$excal,	$desc,	$sout,	$serr,	$maxrun,	$aif,	$sdesc,	$sattr >> ${app}_jobs.csv
done

# cleanup the temp files 
rm tempjoblist
rm joblist
rm tt

echo "The job details are in ${app}_jobs.csv" 
