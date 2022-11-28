#!/bin/sh
#We need srcMountPath, dstMountPath as inputs
#policyADate=$(echo $3 | cut -d ">" -f 2)
policyADate=$3
#recursevily walk the filesystem
find $1 -print0 | while IFS= read -r -d '' file;
    do  echo "file: $file";
    if [ -f $file ] && [ ! -L $file ]
    then
	    echo "file exists"
	    file1=$(echo $file | rev | cut -d "/" -f 1 | rev)
	    echo "file1 $file1"
        #Get the Access Time of the file
        aDate=$(stat $file | grep -i Access | tail -1 | awk -F " " '{print $2}')
        #Get the date in above format
        currDate=$(date +%Y-%m-%d)
        diff=$(( ($(date -d $aDate +%s) - $(date -d $currDate +%s)) / 86400))
        if [ "$diff" > "$policyADate" ]
        then
            echo "file to move: $file"
            #Move the file to dst
            mv $file $2
            #Make a symlink
            ln -s $2/$file1 $file
            echo "symlink created"
            ls -l $1
        fi
    fi
    done;
