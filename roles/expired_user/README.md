Role Name
=========
This role performs an LDAP search on the underlying directory server for the Red Hat Identity Manager (IdM) to identify user that have an expiration date set in their user entry (krbPrincipal expiration attribute value) that is older than the designated time interval (the default value is 60 days). Once a candidate list of users is identified, the playbook user the ipa_user module to disable the user. 

Requirements
------------

- AAP 2.5 (may work with other versions, but was developed using 2.5)
- IdM 4.12.2+ 
- Community General Collection enabled in the execution environment

Role Variables
--------------

**basedn**:  If the domain were acme.example.com, the basedn of the users would be “cn=users,cn=accounts,dc=acme,dc=example,dc=com”
**primary_idm_server**: Must be the fully qualified domain name of an IdM server in the topology.
**dm_idm1_passwd**: The directory manager password for the underlying LDAP server of IdM - this was set  during installation
**idm_admin_passwd**: the admin password for the IdM server
**days**: number of days set for the search of expired user, e.g. 45 days ago; use only the number - the default value is 60

Dependencies
------------
N/A


Example Playbook
----------------
```
---
- name: Disable temporary user accounts that have reach their expiration date but are still enabled
  hosts: 192.168.2.199
  become: true
  roles:
    - expired_user
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
