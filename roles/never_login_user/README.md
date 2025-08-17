Role Name
=========

This role was created to disable Red Hat Identity Management users that have been created but have not logged in a given number of days. 

Requirements
------------

The playbook utilizes the ldapsearch utility. The designated target in the playbooks hosts parameter must be one of the IdM servers in the topology. Those server are considered functionaly equivalent replicas, so it does not matter which of the servers in the topology is used. The LDAP search uses the krblastsuccessfulauth attribute as a search filter. This is not enabled by defualt. To enable the use of this attribute, see The Red Hat Documentation for enabling tracking of the last successful loging of users. This attribute is not populated until users begin to login. The playbook utilizes a bash script, parse.sh, to refine the candidate list of users to be disabled and is included in the files director of the role. It needs to be downloaded to the target system designated in the hosts parameter of the playbook. You must have the credentials of the user desiganted for searching the entire user branch of IdM LDAP server and designated for disabling users, i.e. the password. These credentials should be encrypted with the Ansible Vault mechanism. The playbook iterates through the servers that are in the designated inventory. There should be only one server designated in the hosts parameter of the playbook, but that server has to be part of the inventory that specifically references all of the IdM server in the topology, and has a group that contains only the IdM servers, but all of the IdM server named 'idm_servers'. In order to iterate through the servers for specific commands without having to iterate throught them for the entire playbook, the tasks use the loop directive that calls the servers in a group from the inventory.

Role Variables
--------------
| Variable Name | Variable Description |
| --- | --- |
| basedn | The basedn of the IdM server where the users are stored - by default, this is the set using the domain components of the network where IdM is installed. If the domain were acme.example.com, the basedn of the users would be “cn=users,cn=accounts,dc=acme,dc=example,dc=com” |
| primary_idm_server | Must be the fully qualified domain name of an IdM server in the topology |
| idle_days | number of days set for the search of expired user, e.g. 45 days ago; use only the number - the default value is 60 |
| idle_user_tempFile_directory | the dierectory for storing files used for uer candidate lists, scripts, and oher temporary files |
| logfile_name | user candidate lists are stored in this file and the file is overwritten with each time the playbook is run |
| archive_directory | the candidate list file is copied to another directory where specificied by this attribute |
| dm_idm1_passwd | The directory manager password for the underlying LDAP server of IdM - this was set during installation |
| idm_admin_passwd | The admin password for the IdM server |
>[!IMPORTANT]
>Any variable containing sensitive information, such as passwords, should be encrypted using the Ansible Vault and logging should not report sensitve values!

Dependencies
------------

There are no other roles upon which this role depends, however, it is dependent on a script, last_login.sh, that is included in the files dierctory of this role.
>[!IMPORTANT]
>It is imperative that the comments of the script are read and all requirements of the script are completed.



Example Playbook
----------------
```
---
- hosts: 192.168.2.199
  become: true
  roles:
    - never_login_user
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
>[!NOTE]
>In the above example, the IP address refernces the target IdM server - in the lab environment, I used the primary, but could be any server in the IdM serer topology. If the host name is used, the AAP server must be able to resolve the name. The target system in the host parameter must be in he refernced inventory when running the job that uses this role.



License
-------

BSD

Author Information
------------------

Albert Roberson aroberso@redhat.com
An optional section for the role authors to include contact information, or a website (HTML is not allowed).
