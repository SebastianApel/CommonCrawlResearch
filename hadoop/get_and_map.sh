#!/bin/bash
#
# Wrapper script for the mapper and reducer
# 
# 1. Get data file from S3
# 2. Run Perl mapper script
# 3. Run Reducer script
# 4. Clean Up
# 
# Assumes 
# - you have added AWS credentials that allow S3 reads via "aws configure"
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
BASENAME=`basename $S3FILENAME`

# download the  file
log "Starting download of file $BASENAME"
aws s3 cp s3://aws-publicdatasets/$S3FILENAME ./ > /dev/null
# wget https://aws-publicdatasets.s3.amazonaws.com/$1   # wget is the slower option

### 2. Run Perl mapper script

log "Start mapping of $BASENAME" 
zcat $BASENAME |  perl $SCRIPTDIR/mapper.pl | uniq | gzip > mapper.result.txt.gz

### 3. Run Reducer script

log "Start reducing of $BASENAME" 
zcat mapper.result.txt.gz | awk 'BEGIN{IFS=" ";}{ print $1$2$3 "\t1" }' | uniq | sort |  perl $SCRIPTDIR/reducer.pl 

# get top 30 in human readable form
# awk 'BEGIN{IFS="\t";}{print $2 " " $1}' | sort -n -r | head 10

### 4. Clean Up
log "Cleanup of $BASENAME" 
# rm result.txt.gz
# rm $BASENAME


