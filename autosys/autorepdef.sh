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

echo "$0 version 1.0"
echo "This script exports the job definitions for the jobs listed in the given file."
echo "The jil file created can be imported using [$ jil < file.jil ] command."

if [ $# -ne 1 ]; then
  echo "Usage: $0 filename"
  exit 101
fi

if [ `which jil | cut -d " " -f1` = "no" ]; then
  echo "ERROR: jil command not found."
  exit 102
fi

jobnames=$1
jil=$1.jil

echo "Using the job names from $jobnames"

#clear the file
>$jil

for job in $(cat $jobnames); do
  echo "Exporting definition for $job"
  autorep -q -J $job >> $jil
done

echo "Job definitions are in $jil"
exit 0
