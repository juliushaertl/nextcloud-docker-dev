<?php
$metadata['https://nextcloud.local.dev.bitgrid.net/index.php/apps/user_saml/saml/metadata'] = array (
    'entityid' => 'https://nextcloud.local.dev.bitgrid.net/index.php/apps/user_saml/saml/metadata',
    'contacts' => 
    array (
    ),
    'metadata-set' => 'saml20-sp-remote',
    'expire' => 2212072296,
    'AssertionConsumerService' => 
    array (
      0 => 
      array (
        'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
        'Location' => 'https://nextcloud.local.dev.bitgrid.net/index.php/apps/user_saml/saml/acs',
        'index' => 1,
      ),
    ),
    'SingleLogoutService' => 
    array (
      0 => 
      array (
        'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
        'Location' => 'https://nextcloud.local.dev.bitgrid.net/index.php/apps/user_saml/saml/sls',
      ),
    ),
    'NameIDFormat' => 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified',
    'keys' => 
    array (
      0 => 
      array (
        'encryption' => false,
        'signing' => true,
        'type' => 'X509Certificate',
        'X509Certificate' => 'MIIEazCCAtOgAwIBAgIUXZLzr3z5Rd+YJDgaXfbISQXSkXcwDQYJKoZIhvcNAQELBQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoMGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0xOTA3MDMxMjA3MjJaFw0yOTA3MDIxMjA3MjJaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQCySq3L3jGZI78Q21NtKWKSY8uw7ts+Z7yUwT/Ot0l0NSTefZhhzh/eIg/ISq9VoLws0HYdHD4EYGVWOCUW6VHnDLhoKfXgyaWxXd4z2XgzmBdVThuN8uoFw9IoHvEPCm+OH9nviKsF0uX2+N6utNc1dmW5lY9+b0Vts+yckXk7QhBW+06FsfC6J0jRJmaQJi3D8MFrhER5SUEKZrSL5pRqnL6iyoINbUgZs8VvaHKBmh+l4+L0z4lu8ZZSiHCYGqxokXgCAlDzChxnsEnGi+kbyEblkUkzPS5Mu3di+o9DTUtJ5DDT8og9yVfIlPR3iIBvnuqHp03SQpndn6fxdORISuP0iBiCeTiwr3eM/lNqeA0KPN6Xx8kxGrikqXIOpFv0aSM2W0EnPUhOSfymnF7doFWhbFvYk9IuaiTuIHXZvsQBJk5Ektid4GVmtMf84pZNVgfv2Sfg5JRme0FI+mV3nVUhNoZj6e5Z8FYp4RIGZVAR8i4vdrey2mp2lfyQbKsCAwEAAaNTMFEwHQYDVR0OBBYEFGW70fG73HidEnhm12J6ggYm4TeCMB8GA1UdIwQYMBaAFGW70fG73HidEnhm12J6ggYm4TeCMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggGBACLbjoNIdG5oUVmkIFwx2RvLR3Xax9TkHGB+afAWeYX2HDMKnMMZTO98jeJKUQFJTiiUNJ33E9XHCQvg6nXCRAJesbSIikuRan+80TFeAmbb4EJqqI1ZAmvhQzZ7OhtLHRlnrqb80x1Av5GseiPXeG3KHv1rkasqzHEhxhJWY5llXSNe2rINNz/n1LFD1eorNzI8FFiW3d0zAB2NelEcWp1UgHeluVDrLIMVdOlmmN5XQpMAMgoAd8RgYpdcsZ/s4gDK1kotXH8lmhI238TP7Wl3n5FrxP8cSui5dIGMPgzr3jR+0pqfnn7BJhIk+mPbl8hDgsHOuSK0wMQ3C7qQeiCUtha4O5sPIAQqwtvQDDdR2tc58or9ui3s1NtsiU5Eb+ZBKSPRsPfd4yqcFG5IFzUTZ2EM+mw2GOMBegoDpbqBUiSHdgD0lNrTYrSCDw3DDoAVykPPv1nTXAdy+O0VX07RJCBiLXeDWyaJypf92gqa5ejgjFw+wGnPQ/ibujlCrQ==',
      ),
    ),
    'validate.authnrequest' => false,
    'saml20.sign.assertion' => false,
  );