# Matter hostap patches

This overlay augments the hostapd package with a patch set that implements Matter PDC authentication. This is currently a proof-of-concept only, and as such has various limitations. In particular, only a single client certificate can be configured on the hostapd side.

### Access Point Configuration

The following settings can be added to a network configured for WPA2 or WPA3 Personal mode to enable PDC authentication:

`hostapd.conf`

```
wpa_pairwise=CCMP
wpa_unadvertised_key_mgmt=WPA-EAP-SHA256
vendor_elements=dd064a191b010100
ieee80211w=1
ieee8021x=1
eap_server=1
eap_user_file=/path/to/eap-users.conf
tls_flags=[DISABLE-TLSv1.0][DISABLE-TLSv1.1][DISABLE-TLSv1.2][ENABLE-TLSv1.3]
openssl_ciphers=TLS_AES_128_CCM_SHA256
openssl_ecdh_curves=P-256
server_cert=/path/to/network.cert
private_key=/path/to/network.key
ca_cert=/path/to/client.cert
```

`eap-users.conf`

```
"@pdc.csa-iot.org" TLS
```

### Client Configuration

`wpa_supplicant.conf`

```
network={
  ssid="My Home"
  key_mgmt=WPA-EAP-SHA256
  fallback_key_mgmt=WPA-EAP-SHA256
  pairwise=CCMP
  group=CCMP
  ieee80211w=2
  eap=TLS
  eap_workaround=0
  identity="@pdc.csa-iot.org"
  phase1="tls_disable_tlsv1_0=1,tls_disable_tlsv1_1=1,tls_disable_tlsv1_2=1,tls_disable_tlsv1_3=0"
  openssl_ciphers="TLS_AES_128_CCM_SHA256"
  openssl_ecdh_curves="P-256"
  ca_cert="/path/to/network.cert"
  client_cert="/path/to/client.cert"
  private_key="/path/to/client.key"
}
```
