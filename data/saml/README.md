# Keycloak SAML test setup

Currently the Keycloak realm only supports the main instance (nextcloud.dev.local). For other instances this would need a separate realm and adjusting the imported realm in `docker/configs/keycloak`.

Setup can be done automatically through:

```bash
occ saml:config:create
occ saml:config:set \
        --general-idp0_display_name "Keycloak SAML" \
        --general-uid_mapping "username" \
        --idp-entityId "http://keycloak.dev.local/realms/Example" \
        --idp-singleLogoutService.url "http://keycloak.dev.local/realms/Example/protocol/saml" \
        --idp-singleSignOnService.url "http://keycloak.dev.local/realms/Example/protocol/saml" \
        --idp-x509cert="$(cat keycloak.crt)" \
        --security-authnRequestsSigned 1 \
        --security-logoutRequestSigned 1 \
        --security-logoutResponseSigned 1 \
        --security-wantAssertionsEncrypted 0 \
        --security-wantAssertionsSigned 1 \
        --security-wantMessagesSigned 1 \
        --security-nameIdEncrypted 0 --security-wantNameId 0 \
        --security-wantNameIdEncrypted 0 \
        --sp-x509cert="$(cat public.cert)" \
        --sp-privateKey="$(cat private.key)" \
        "1"
```

## References

- Setup keycloak for SAML usage: https://janikvonrotz.ch/2020/04/21/configure-saml-authentication-for-nextcloud-with-keycloack/

## Generate keys for Nextcloud

openssl req  -nodes -new -x509  -keyout private.key -out public.crt


## update keycloak from example realm

nc-dev exec keycloak /opt/keycloak/bin/kc.sh export --realm Example --users skip --dir /opt/keycloak/data/import
