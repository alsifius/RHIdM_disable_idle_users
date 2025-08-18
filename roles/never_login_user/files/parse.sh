#!/bin/bash
#LIST=`cat /mnt/idm_plugin/results.txt | sort | uniq`
# This script is designed to run in conjunction with the 
# never_login_user ansible role. That role was created to
# address functionality missing from the IdM server, 
# disabling users that have never logged in. 
#
# In a previous task in the role, the idle_user_tempFile
# file is populated with usernames from ldapsearches 
# that are concatenated from all IdM servers, filtering
# on both the user creation timestamp and the 
# krbLastSuccessfulAuth attribute value. The script
# counts the number of times that a user name appears
# in the file. If the number of time the user name appears
# in the file equals the value set in the 'total_servers'
# variable, it indicates that the user has no 
# krbLastSuccessfulAuth attribute on any IdM server, and
# the user should be disabled. Any user matching the 
# criteria will be added to the 'results' file. 
# 
# The 'rusults' file is used in a subsequent task in the 
# the role to disable the users using the ipa_user module.
#
# The LIST variable must contain the full path and file name
# where the role stores the results of the LDAP searches
# to identify candidates for being disabled. The 'total_servers'
# variable must be equal to the total number of servers in the
# topology. Incorrectly setting this value can falsely identify 
# users, and result in user being incorrectly disabled, preventing
# them from successfully authenticating to IdM servers.

LIST=`cat /mnt/idm_plugin/idle_user_tempFile | sort | uniq`
total_servers=3
for i in $LIST
do 
	NUMBER=`grep $i /mnt/idm_plugin/idle_user_tempFile | wc -l` 
	echo "$i appears in the file $NUMBER of $total_servers times"
		if [ "$NUMBER" == "$total_servers" ]; then
			echo "User $i will be disabled; createTimeStamp exceeds number of idle days and user has no logins registerd with any listed IdM servers" >> /mnt/idm_plugin/results
		else 
			echo "User $i needs no further action taken"
		fi
done
