#!/usr/bin/env bash
# This file is ment to run in conjunction with the idle_user_1
# Ansible role. Some of the parameters in this script must have
# identiical values to the coresponding variables in the role's
# playbook.
# ====== CONFIGURATION ======
USERNAME_FILE="/mnt/idm_plugin/user_list.txt"

# Space-separated list of LDAP servers
# This must list all IdM servers in the tolopology.
LDAP_SERVERS=("ldap://192.168.2.199" "ldap://192.168.2.104" "ldap://192.168.2.50")

# Bind DN and password
# Any user specified must use its full DN and must have read
# access for the entire user branch of he DIT, and must have
# read access for the krblastsuccessfulauth attribute. The
# script does require the use of the bind password for the
# user specified. It is recommend to place the password in
# a file, in a secure directory, readable only by the root user.
#
BIND_DN="cn=Directory Manager"
BIND_PW="`cat /root/vault`"
#
# Change the BASE_DN variable to match your environment.
BASE_DN="cn=users,cn=accounts,dc=bna,dc=plugin,dc=alsifius,dc=com"
ATTR="krblastSuccessfulAuth"
DAYS_THRESHOLD=60
#
# Set the DAYS_THRESHOLD to the expiration limit for idle users.
# ====== FUNCTIONS ======
#
# The following functions allow for the search of users using the
# ldapsearch utility to iterate through all of the lsited IdM servers
# and compares them the krblastsuccessfulauth attribute timestamp
# to eliminate the users from the candidate list. A list of users
# that should be deleted is then printed to stdout.
#
# Convert LDAP generalized time (YYYYmmddHHMMSSZ) to epoch
ldap_time_to_epoch() {
    local ts="$1"
    date -u -d "${ts:0:4}-${ts:4:2}-${ts:6:2} ${ts:8:2}:${ts:10:2}:${ts:12:2}" +"%s"
}

# Check if user is inactive on all servers
user_inactive_on_all_servers() {
    local username="$1"
    local now_epoch
    now_epoch=$(date +%s)
    local threshold_epoch=$(( now_epoch - DAYS_THRESHOLD*24*3600 ))

    for server in "${LDAP_SERVERS[@]}"; do
        # Query the server
        ts=$(ldapsearch -x -H "$server" -D "$BIND_DN" -w "$BIND_PW" \
            -b "$BASE_DN" "(uid=$username)" $ATTR 2>/dev/null | \
            awk -v attr="$ATTR" '$1==attr":" {print $2; exit}')

        if [[ -n "$ts" ]]; then
            ts_epoch=$(ldap_time_to_epoch "$ts")
            if (( ts_epoch >= threshold_epoch )); then
                # Found recent login, user is active somewhere
                return 1
            fi
        fi
    done

    # No recent login found on any server
    return 0
}

# ====== MAIN ======
inactive_users=()

while IFS= read -r username; do
    [[ -z "$username" ]] && continue
    if user_inactive_on_all_servers "$username"; then
        inactive_users+=("$username")
    fi
done < "$USERNAME_FILE"

echo "=== Inactive Users (no login in last $DAYS_THRESHOLD days on all servers) ==="
for u in "${inactive_users[@]}"; do
    echo "$u"
done

