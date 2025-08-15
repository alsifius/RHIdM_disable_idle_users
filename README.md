# RHIdM_disable_idle_users
## Descripton
As of August 15, 2025, Red Hat Identity Manager (IdM) is not configured to disable user accounts in a given time frame; expiring the password will prevent user from successfully authenticating, but the user accounts are not actually disabled. Many user of IdM have a policy that mandates the disable of accounts under meeting certain criteria: user has not logged in for a certain number of days, user has never logged in, user account has reached expiration. An attribute, krblastsuccessfulauth, can be enabled to track the login time and date for the last successful authentication, but, due to various issues, the attribute is not replicated, i.e. it could potentially have different values on different IdM servers in the same topology depending on which server was used by a client for authentication. If a user account was created but the user never logged in, the user would not have a krblastsuccessfulauth attribute to check. 
To address this issue, I have created a set of three roles and two scripts that are run by on the Ansible Automation Platform that should provide a stop gap measure until such time as a feature enhancement within IdM itself addresses the issue. Scripts are included to address the more advanced parsing of he data that is needed to address this situation, while AAP allows for the scheduling of the playbooks/scripts, storing and usage of vaulted credentials, iteration through multiple IdM servers, validation and audit logging of outcomes, 
The three roles are:

- idle_user_1
- no_login_user
- expired_user

Each of these roles addresses one of the previous stated scenarios for disabling users. The documentation for each role will be included in the "README" of the role, and the playbooks themselves will have additional documentation and context. I recommend reading all of the documentation as there are a number of requirements for use of the roles, as well as several significant configuration issues to address outside of AAP and the parameters within the playbooks. Any requirements common to the roles will be included in this document under "General Requirements. Each role will also have instructions that are particular to just the running of that role. Each role can be run separately; they are completely independent from one another. They can also be performed as part of a workflow and run in any order. These roles are meant as a workaround to requested feature enhancements to IdM. This is not an official Red Hat solution and is nto likely to be maintained or updated on a regular basis. 

## General Requirements for Every Role

- AAP 2.5 - other version of AAP and standalone Ansible may work, but have not been tested
- Community General ansible galaxy collection - the ipa user module is used to disable the user; this is part of the community general collection, and any execution environment utilized must have access to that module
- The directory manager and admin passwords for IdM  - the admin password could be used throughout, but you must have the admin user distinguished name for successful ldapsearch commands
- The basedn of the IdM server where the users are stored - by default, this is the set using the domain components of the network where IdM is installed. If the domain were acme.example.com, the basedn of the users would be “cn=users,cn=accounts,dc=acme,dc=example,dc=com”




