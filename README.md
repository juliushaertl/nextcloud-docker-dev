# nextcloud-dev-docker-compose

Nextcloud development environment using docker-compose 

## Features


## TODO

- [ ] Add S3 storage service
- [ ] Add SMB storage service
- [ ] blackfire
- [ ] Postgres
- [ ] LDAP: Auto config
- [ ] SAML: Auto config

## Reverse Proxy

Used for SSL termination

## Mail

Sending/receiving mails can be tested with mailhog which is available on ports 1025 (SMTP) and 8025 (HTTP).

## LDAP

Example ldif is generated using http://ldapwiki.com/wiki/LDIF%20Generator


occ ldap:show-config
+-------------------------------+--------------------------------------------------------------------+
| Configuration                 |                                                                    |
+-------------------------------+--------------------------------------------------------------------+
| hasMemberOfFilterSupport      | 0                                                                  |
| hasPagedResultSupport         |                                                                    |
| homeFolderNamingRule          |                                                                    |
| lastJpegPhotoLookup           | 0                                                                  |
| ldapAgentName                 | cn=admin,dc=example,dc=org                                         |
| ldapAgentPassword             | ***                                                                |
| ldapAttributesForGroupSearch  |                                                                    |
| ldapAttributesForUserSearch   |                                                                    |
| ldapBackupHost                | ldap2.example.org                                                  |
| ldapBackupPort                | 389                                                                |
| ldapBase                      | dc=example,dc=org                                                  |
| ldapBaseGroups                |                                                                    |
| ldapBaseUsers                 |                                                                    |
| ldapCacheTTL                  | 600                                                                |
| ldapConfigurationActive       | 1                                                                  |
| ldapDefaultPPolicyDN          |                                                                    |
| ldapDynamicGroupMemberURL     |                                                                    |
| ldapEmailAttribute            | mail                                                               |
| ldapExperiencedAdmin          | 0                                                                  |
| ldapExpertUUIDGroupAttr       |                                                                    |
| ldapExpertUUIDUserAttr        |                                                                    |
| ldapExpertUsernameAttr        |                                                                    |
| ldapGidNumber                 | gidNumber                                                          |
| ldapGroupDisplayName          | cn                                                                 |
| ldapGroupFilter               | (&(|(objectclass=organizationalUnit)))                             |
| ldapGroupFilterGroups         |                                                                    |
| ldapGroupFilterMode           | 0                                                                  |
| ldapGroupFilterObjectclass    | organizationalUnit                                                 |
| ldapGroupMemberAssocAttr      | uniqueMember                                                       |
| ldapHost                      | ldap.example.org                                                   |
| ldapIgnoreNamingRules         |                                                                    |
| ldapLoginFilter               | (&(|(objectclass=inetOrgPerson)(objectclass=person))(|(uid=%uid))) |
| ldapLoginFilterAttributes     | uid                                                                |
| ldapLoginFilterEmail          | 0                                                                  |
| ldapLoginFilterMode           | 0                                                                  |
| ldapLoginFilterUsername       | 1                                                                  |
| ldapNestedGroups              | 0                                                                  |
| ldapOverrideMainServer        |                                                                    |
| ldapPagingSize                | 500                                                                |
| ldapPort                      | 389                                                                |
| ldapQuotaAttribute            |                                                                    |
| ldapQuotaDefault              |                                                                    |
| ldapTLS                       | 0                                                                  |
| ldapUserAvatarRule            | default                                                            |
| ldapUserDisplayName           | cn                                                                 |
| ldapUserDisplayName2          |                                                                    |
| ldapUserFilter                | (|(objectclass=inetOrgPerson)(objectclass=person))                 |
| ldapUserFilterGroups          |                                                                    |
| ldapUserFilterMode            | 0                                                                  |
| ldapUserFilterObjectclass     | inetOrgPerson;person                                               |
| ldapUuidGroupAttribute        | auto                                                               |
| ldapUuidUserAttribute         | auto                                                               |
| turnOffCertCheck              | 0                                                                  |
| turnOnPasswordChange          | 0                                                                  |
| useMemberOfToDetectMembership | 1                                                                  |
+-------------------------------+--------------------------------------------------------------------+
