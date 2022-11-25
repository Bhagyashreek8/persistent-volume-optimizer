#!/bin/bash
#We need srcMountPath, dstMountPath as inputs
policyADate=$(echo $3 | cut -d ">" -f 2)
#recursevily walk the filesystem
find $1 -print0 | while IFS= read -r -d '' file;
    do  echo "$file";
    if [ -e $file ]
    then
        #Get the Access Time of the file
        aDate=$(stat $file | grep -i Access | tail -1 | awk -F " " '{print $2}')
        #Get the date in above format
        currDate=$(date +%Y-%m-%d)
        diff=$(( ($(date -d $aDate +%s) - $(date -d $currDate +%s)) / 86400))
        if [ $diff>$policyADate ]
        then
            #Move the file to dst
            mv $1/$file $2
            #Make a symlink
            ln -s $file
        fi
    fi
    done;
