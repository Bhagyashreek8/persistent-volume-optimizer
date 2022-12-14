#!/bin/bash
#read srcvolpath, destvolpath, policy from file
sleep 20
svolpath=$(cat /app/pvc-optimizer-01.txt | cut -d$'\n' -f1)
dvolpath=$(cat /app/pvc-optimizer-01.txt | cut -d$'\n' -f2)
policyADate=$(cat /app/pvc-optimizer-01.txt | cut -d$'\n' -f3)
echo $svolpath
echo $dvolpath
echo $policyADate
#recursevily walk the filesystem
find $svolpath -print0 | while IFS= read -r -d '' file;
    do  echo "file: $file";
    if [ -f $file ] && [ ! -L $file ]
    then
	    echo "file exists"
	    file1=$(echo $file | rev | cut -d "/" -f 1 | rev)
	    echo "file1 $file1"
        #Get the Access Time of the file
        aDate=$(stat $file | grep -i Access | tail -1 | awk -F " " '{print $2}')
        echo "aDate: $aDate"
        #Get the date in above format
        currDate=$(date +%Y-%m-%d)
        echo "currDate: $currDate"
        diff=$(( ($(date -d $aDate +%s) - $(date -d $currDate +%s)) / 86400))
        echo "diff $diff"
        if [ "$diff" > "$policyADate" ]
        then
            echo "file to move: $file"
            #Move the file to dst
            mv $file $dvolpath
            #Make a symlink
            ln -s $dvolpath/$file1 $file
            echo "symlink created successfully"
            ls -l $svolpath
        fi
    fi
    done;
