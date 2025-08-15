#!/bin/bash
#LIST=`cat /mnt/idm_plugin/results.txt | sort | uniq`
LIST=`cat /mnt/idm_plugin/idle_user_tempFile | sort | uniq`
total_servers=3
for i in $LIST
do 
	NUMBER=`grep $i /mnt/idm_plugin/idle_user_tempFile | wc -l` 
	echo "$i appears in the file $NUMBER of $total_servers times"
		if [ "$NUMBER" == "3" ]; then
			echo "User $i will be disabled; createTimeStamp exceeds number of idle days and user has no logins registerd with any listed IdM servers" >> /mnt/idm_plugin/results
		else 
			echo "User $i needs no further action taken"
		fi
done
