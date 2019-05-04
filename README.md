# nextcloud-dev-docker-compose

Nextcloud development environment using docker-compose 

## Start all

- Start full setup: `docker-compose up`
- Minimum: `docker-compose up nextcloud`

## Environment variables

```
COMPOSE_PROJECT_NAME=master
REPO_PATH_SERVER=/home/jus/repos/nextcloud/server
ADDITIONAL_APPS_PATH=/home/jus/repos/nextcloud/server/apps-extra
NEXTCLOUD_DOMAIN=nextcloud.local.dev.bitgrid.net
NEXTCLOUD_AUTOINSTALL_APPS="viewer activity"
BLACKFIRE_CLIENT_ID=
BLACKFIRE_CLIENT_TOKEN=
BLACKFIRE_SERVER_ID=
BLACKFIRE_SERVER_TOKEN=

## can be used to run separate setups besides each other
DOCKER_SUBNET=192.168.15.0/24
PORTBASE=815
```

Switching to different env settings:

```
set -a; . stable15.env; set +a
docker-compose up nextcloud
```

## Reverse Proxy

Used for SSL termination

## Mail

Sending/receiving mails can be tested with mailhog which is available on ports 1025 (SMTP) and 8025 (HTTP).

## Blackfire

Blackfire needs to use a hostname/ip that is resolvable from within the blackfire container. Their free version is [limited to local profiling](https://support.blackfire.io/troubleshooting/hack-edition-users-cannot-profile-non-local-http-applications) so we need to browse Nextcloud though its local docker IP.

Secrets need to be added to the environment:

```
BLACKFIRE_CLIENT_ID=
BLACKFIRE_CLIENT_TOKEN=
BLACKFIRE_SERVER_ID=
BLACKFIRE_SERVER_TOKEN=
```

### Using with curl

```
alias blackfire='docker-compose -p master -f docker-compose.yml exec \
    -e BLACKFIRE_CLIENT_ID=$BLACKFIRE_CLIENT_ID \
    -e BLACKFIRE_CLIENT_TOKEN=$BLACKFIRE_CLIENT_TOKEN \
blackfire blackfire'
blackfire curl http://192.168.21.8/
```

## LDAP

Example ldif is generated using http://ldapwiki.com/wiki/LDIF%20Generator


```
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
```