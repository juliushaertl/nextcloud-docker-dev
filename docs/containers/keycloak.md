# Keycloak

- Keycloak is using ldap as a user backend (make sure the ldap container is also running)
- `occ user_oidc:provider Keycloak -c nextcloud -s 09e3c268-d8bc-42f1-b7c6-74d307ef5fde -d https://keycloak.local.dev.bitgrid.net/auth/realms/Example/.well-known/openid-configuration`
- https://keycloak.local.dev.bitgrid.net/auth/realms/Example/.well-known/openid-configuration
- nextcloud
- 09e3c268-d8bc-42f1-b7c6-74d307ef5fde
