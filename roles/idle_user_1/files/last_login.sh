#!/usr/bin/env bash

# ====== CONFIGURATION ======
USERNAME_FILE="/mnt/idm_plugin/user_list.txt"

# Space-separated list of LDAP servers
LDAP_SERVERS=("ldap://192.168.2.199" "ldap://192.168.2.104" "ldap://192.168.2.50")

# Bind DN and password
BIND_DN="cn=Directory Manager"
BIND_PW="password"

BASE_DN="cn=users,cn=accounts,dc=bna,dc=plugin,dc=alsifius,dc=com"
ATTR="krblastSuccessfulAuth"
DAYS_THRESHOLD=60

# ====== FUNCTIONS ======

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

