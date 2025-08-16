Role Name
=========
This role is designed to help automate the disabling of users in IdM that have remained idle (have no successful logins to any IdM lient systems) for a desiganted number of days, a feature currently missing from IdM as of August 15, 2025. 

Requirements
------------
The playbook utilizes the ldapsearch utility. The designated target in the playbooks hosts directive must be one of the IdM servers in the topology. Those server are considered functionaly equivalent replicas, so it does not matter which of the servers in the topology is used. The LDAP search uses the krblastsuccessfulauth attribute as a search filter. This is not enabled by defualt. To enable the use of this attribute, see [The Red Hat Documentation for enabling tracking of the last successful loging of users](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/linux_domain_identity_authentication_and_policy_guide/enabling-tracking-of-last-successful-kerberos-authentication#enabling-tracking-of-last-successful-kerberos-authentication). This attribute is not populated until users begin to login. The playbook utilizes a bash script to refine the candidate list of users to be disabled, last_login.sh, and is included in the files director of the role. It needs to be downloaded to the target system designated in the hosts directive of the playbook.  You must have the credentials of the users desiganted or searching the IdM LDAP server, and the user designated for disabling users, i.e. the passwords. These credentials should be encrypted with the Ansible Vault mechanism. The playbook iterates through the servers that are in the designated inventory. There should be only one server designated in the hosts directive of the playbook, but that server has to be part of the inventory that specifically references all of the IdM server in the topology, and has a group that contains only the IdM servers, but all of the IdM server. In order to iterate through the servers for specific commands without having to iterate throught them for the entire playbook, the tasks use the loop directive that calls the servers in a group from the inventory. 

Role Variables
--------------
| Variable Name | Variable Description |
| --- | --- |
| basedn | The basedn of the IdM server where the users are stored - by default, this is the set using the domain components of the network where IdM is installed. If the domain were acme.example.com, the basedn of the users would be “cn=users,cn=accounts,dc=acme,dc=example,dc=com” |
| primary_idm_server | Must be the fully qualified domain name of an IdM server in the topology |
| idle_days | number of days set for the search of expired user, e.g. 45 days ago; use only the number - the default value is 60 |
| dm_idm1_passwd | The directory manager password for the underlying LDAP server of IdM - this was set during installation |
| idm_admin_passwd | The admin password for the IdM server |

Dependencies
------------
There are no other roles upon which this role depends, however, it is dependent on a script, last_login.sh, that is included in the files dierctory of this role. 

> [!IMPORTANT]
> It is imperative that the comments of the script are read and all requirements of the script are completed. 

Example Playbook
----------------

```
---
- name: Configure idle user role
  hosts: 192.168.2.199
  become: true
  roles:
    - idle_user_1
  gather_facts: false
  vars:
    dm_idm1_passwd: !vault |
          $ANSIBLE_VAULT;1.2;AES256;dm_idm1_passwd
          33613464366133336535333261613261646163613766656637633064613266653333306330653163
          6464323761343636366630376430663261346366646538640a393763656366353235393864313162
          33643738346636356336323134613138653761373038353462656362323137623365316235303430
          3966666663663536660a656166646437643365386238393161666334646233636232346431663630
          3363
    idm_admin_passwd: !vault |
          $ANSIBLE_VAULT;1.2;AES256;idm_admin
          30366265316161383835323633383233366636633663386363633136653965316633663037303265
          6565303337623933313535623063353665396238656163300a373832356138333931353635316365
          66326635666238626262636330306465653565646130653964626336313633623435316666616534
          3339396136306436630a363539636538646431616336636461663339373666363166343636333131
          6164
```

License
-------

BSD

Author Information
------------------

Albert Roberson aroberso@redhat.com 
