#!/bin/bash

#
# Wrapper script
# 
# 1. Get data file from S3
# 2. Run Perl mapper script
# 3. Run Reducer script
# 4. Clean Up
# 

# Setup stuff
SCRIPTDIR=~/CommonCrawlResearch/hadoop/
BASEDIR=/tmp/CCData
LOGFILENAME=$BASEDIR/logfile.txt

function log {
   echo "`date -u` $1"  >> $LOGFILENAME
   # echo $1 >> NULL
}

### 1. Get data file from S3
mkdir $BASEDIR
cd $BASEDIR

# The name of the S3 file is provided via STDIN
S3FILENAME=`cat` 

# download the  file
log "Starting download of file $S3FILENAME"
aws s3 cp s3://aws-publicdatasets/$S3FILENAME ./ >> $LOGFILENAME
# wget https://aws-publicdatasets.s3.amazonaws.com/$1   # wget is the slower option

# get the file name we work on
BASENAME=`basename $S3FILENAME`


### 2. Run Perl mapper script

log "Start mapping of $1" 
zcat $BASENAME |  perl $SCRIPTDIR/mapper.pl | uniq | gzip > result.txt.gz

### 3. Run Reducer script

log "Start reducing of $1" 
zcat result.txt.gz | awk 'BEGIN{IFS=" ";}{ print $3 "\t1" }' |sort |  perl $SCRIPTDIR/reducer.pl | awk 'BEGIN{IFS="\t";}{print $2 " " $1}' | sort -n 


### 4. Clean Up
log "Start cleanup of $1" 
rm result.txt.gz
rm $BASENAME


