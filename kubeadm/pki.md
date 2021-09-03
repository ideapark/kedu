# Public Key Infrastracture

There are many certificates involved between any two components of kubernetes:

| FROM                    | TO             |
|-------------------------|----------------|
| kube-apiserver          | etcd           |
| kube-apiserver          | kubelet        |
| kube-controller-manager | kube-apiserver |
| kube-scheduler          | kube-apiserver |
| kube-proxy              | kube-apiserver |
| kubelet                 | kube-apiserver |
| kubectl                 | kube-apiserver |

## openssl

Let's generate self-signed root certificate, and then issue itermediate
certificates to other subjects.

### self-signed root certificate

```bash
$openssl req -x509 -sha256 -nodes -newkey rsa:2048 -keyout ca.key -out ca.crt
```

1. ca.crt

```text
-----BEGIN CERTIFICATE-----
MIIDkjCCAnoCCQD3Y34DbDfJSDANBgkqhkiG9w0BAQsFADCBijELMAkGA1UEBhMC
Y24xEDAOBgNVBAgMB1NpY2h1YW4xEDAOBgNVBAcMB0NoZW5nZHUxETAPBgNVBAoM
CHRoaW5wYXJrMQ0wCwYDVQQLDARjbmNmMRQwEgYDVQQDDAt0aGlucGFyay1jYTEf
MB0GCSqGSIb3DQEJARYQcm9vdEB0aGlucGFyay5pbzAeFw0yMTA2MTMwNjUwMjBa
Fw0yMTA3MTMwNjUwMjBaMIGKMQswCQYDVQQGEwJjbjEQMA4GA1UECAwHU2ljaHVh
bjEQMA4GA1UEBwwHQ2hlbmdkdTERMA8GA1UECgwIdGhpbnBhcmsxDTALBgNVBAsM
BGNuY2YxFDASBgNVBAMMC3RoaW5wYXJrLWNhMR8wHQYJKoZIhvcNAQkBFhByb290
QHRoaW5wYXJrLmlvMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuRso
f3F84lqsFZLOLhSzrJy50xuNRnc93T+0cOdhYHlGme6mfKZ5ewvKAy1PAwl/qJD6
8wbUYQHo1pgQtDgMybhgjzEuL3aVI/xj99PLI654ySEz2fhDN/MmnmFW3qZoX1he
GCJ8arf+wTB9k9AjXNDTMq47n3+hQIwSk3yIU3MmLBW9pb536Kj1906W0U3pn2Yw
mgvS+2TeYKe1P++gecJwSaiNBIEaM9g1TF8ccbqiSkRzQFkT6Uv5Ra6OjtTweXgt
eMDdYdQvhRiMeud22qWftSmgETBxyLg7YgOuDRFXCK4Yi09uabWRY136jV07FNB0
Qy9bP0AqAmbKNTV78QIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQAbwbpp9+3xBYnL
To+jCytBU1ekQMo3VJq/0ApuFj2XwUe9fWtLO1vgU6AJPLdK9MFmztz8GVoYKOoj
380WOHXjRGeei+TA/9Y2NaH7ojGDdTWC2vdF+MLLTq3MyxjKkw8iT5BofFIWb/mw
hlRRhiZSoMF9ojCMmiVVnLouB/kWIupjbbEEU6XhIijsgqbcLsx5omt4PmyM4dDh
E9xttWEvMubcbPiKIww1zxfcSFcW0+F+Wv0FDzKW1u4W9FlQ7wr16O6M8Xw+MEGV
th9ET9T0jgKQVpcs9uOljrVgiVvTxHt3YSgLb/kTgvDHH87PVqDUgTAjO/M3wBxp
UNxkwM4N
-----END CERTIFICATE-----
```

2. ca.key

```text
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC5Gyh/cXziWqwV
ks4uFLOsnLnTG41Gdz3dP7Rw52FgeUaZ7qZ8pnl7C8oDLU8DCX+okPrzBtRhAejW
mBC0OAzJuGCPMS4vdpUj/GP308sjrnjJITPZ+EM38yaeYVbepmhfWF4YInxqt/7B
MH2T0CNc0NMyrjuff6FAjBKTfIhTcyYsFb2lvnfoqPX3TpbRTemfZjCaC9L7ZN5g
p7U/76B5wnBJqI0EgRoz2DVMXxxxuqJKRHNAWRPpS/lFro6O1PB5eC14wN1h1C+F
GIx653bapZ+1KaARMHHIuDtiA64NEVcIrhiLT25ptZFjXfqNXTsU0HRDL1s/QCoC
Zso1NXvxAgMBAAECggEAdBcySOtWFWgkcMtHf+L/5IvOhzXKXp0+MVpYwk565dRp
kPT5eUe2/JKiOWfbG96DL6btnCl2XPijnKJ2J3DXpFN8S5Hek2ndk1ohIDa2OkSc
ABhQuq1XCun2GHKX1r+qydFUAfLu8MdAgMz2lRN+eiGFs01Om3OiICc5J0J9BUgr
ZYrsT/0DnncFWH3ZgwL7HqdJFCAIRimg6/UhYFXxodBfSyO9qqK0fQv2yoM90dYt
NozTEm0debeykDAS020P2nUElp5vO8HiG5inFO8ojjxUXogbiBCEWSEsjVBM2q2E
yM9rmHy7h+dwBb5dtYp7BgkPj6haxFTizCcHapF2+QKBgQDZ36lHZU/YwiE7TirE
ElTa6YuzDYGttH4qurNAzRT36F6buxpHjj71c3X65xh5JYdZv7unyLZ82LO6NeE+
SdaQ0x2xR+DkS1OxruioFnuJrZjh5OBIJWo1ngdOtraDqgwuMtTocaBVXJ4DkRDB
5gM4DsBdXubo1xvh2zkWuKEf9wKBgQDZf5HCLsj2AK6x+zkP5CDkvuHUQ7j+QtDi
E8+sjrY49NUq/2umGX17F1q3uHy8WqNGqwiw9sF4nXyHNloU6nh+BcRpTwOWhBPb
RBntM6oDsHBRRaOhSmIxGEhtHuuXHcIIeHInsUs4EIyJUTWRuHQhVyGbMOr348cc
PH5DFC+ZVwKBgC0Lz0YRrlaUnKZUXQc4+w5f5yBYFI3Dmapf+5vUSxeOlbEBGEff
IylAfA4qJac2mSt3NudT2lcpvs8rQKzOO2yqGaODxv2sjVtZXIUUUOqAV/Gsjqqc
Ab+gMsaVhFrol6gdnmOIyqubgJggMCTG17eJZUBo1LkjcIJb/wuxlK61AoGAPOvr
sv2R0r5MMJRS3m2i/Q+uh9tUVPv4MGsmL4pl5jxF/V5AE+1t5W2cPnvRjJzCwUel
DpR/ir5qJCGIR/WJPJt28ZxtP9rNCQzhSjy/cXsZatpbxBDmwiOwHcicat6t+9to
9k9F53VTOB9kJuYIuVIDmsmv9zF5EyKqpzVfQ88CgYA3QFaUBAFjJCfjktnU4deO
tvxuOTGYnVAAssJbRqfWVyYVA4M36YdZJbea/zZ2GfgyRTw9U5X6fQ9ATIZDPnbS
PzPx5IMBemiZJRF/HkwAEChpuaXdTutowNfSH9n2NhQM+TgUDMZq1Zk5bGyNyujY
OGqGcsIsgQboj2BYhxHl1A==
-----END PRIVATE KEY-----
```

3. display human readable output

```bash
$openssl x509 -in ca.crt -text -noout
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number: 17826230303228152136 (0xf7637e036c37c948)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=cn, ST=Sichuan, L=Chengdu, O=ideapark, OU=cncf, CN=ideapark-ca/emailAddress=root@ideapark.io
        Validity
            Not Before: Jun 13 06:50:20 2021 GMT
            Not After : Jul 13 06:50:20 2021 GMT
        Subject: C=cn, ST=Sichuan, L=Chengdu, O=ideapark, OU=cncf, CN=ideapark-ca/emailAddress=root@ideapark.io
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:b9:1b:28:7f:71:7c:e2:5a:ac:15:92:ce:2e:14:
                    b3:ac:9c:b9:d3:1b:8d:46:77:3d:dd:3f:b4:70:e7:
                    61:60:79:46:99:ee:a6:7c:a6:79:7b:0b:ca:03:2d:
                    4f:03:09:7f:a8:90:fa:f3:06:d4:61:01:e8:d6:98:
                    10:b4:38:0c:c9:b8:60:8f:31:2e:2f:76:95:23:fc:
                    63:f7:d3:cb:23:ae:78:c9:21:33:d9:f8:43:37:f3:
                    26:9e:61:56:de:a6:68:5f:58:5e:18:22:7c:6a:b7:
                    fe:c1:30:7d:93:d0:23:5c:d0:d3:32:ae:3b:9f:7f:
                    a1:40:8c:12:93:7c:88:53:73:26:2c:15:bd:a5:be:
                    77:e8:a8:f5:f7:4e:96:d1:4d:e9:9f:66:30:9a:0b:
                    d2:fb:64:de:60:a7:b5:3f:ef:a0:79:c2:70:49:a8:
                    8d:04:81:1a:33:d8:35:4c:5f:1c:71:ba:a2:4a:44:
                    73:40:59:13:e9:4b:f9:45:ae:8e:8e:d4:f0:79:78:
                    2d:78:c0:dd:61:d4:2f:85:18:8c:7a:e7:76:da:a5:
                    9f:b5:29:a0:11:30:71:c8:b8:3b:62:03:ae:0d:11:
                    57:08:ae:18:8b:4f:6e:69:b5:91:63:5d:fa:8d:5d:
                    3b:14:d0:74:43:2f:5b:3f:40:2a:02:66:ca:35:35:
                    7b:f1
                Exponent: 65537 (0x10001)
    Signature Algorithm: sha256WithRSAEncryption
         1b:c1:ba:69:f7:ed:f1:05:89:cb:4e:8f:a3:0b:2b:41:53:57:
         a4:40:ca:37:54:9a:bf:d0:0a:6e:16:3d:97:c1:47:bd:7d:6b:
         4b:3b:5b:e0:53:a0:09:3c:b7:4a:f4:c1:66:ce:dc:fc:19:5a:
         18:28:ea:23:df:cd:16:38:75:e3:44:67:9e:8b:e4:c0:ff:d6:
         36:35:a1:fb:a2:31:83:75:35:82:da:f7:45:f8:c2:cb:4e:ad:
         cc:cb:18:ca:93:0f:22:4f:90:68:7c:52:16:6f:f9:b0:86:54:
         51:86:26:52:a0:c1:7d:a2:30:8c:9a:25:55:9c:ba:2e:07:f9:
         16:22:ea:63:6d:b1:04:53:a5:e1:22:28:ec:82:a6:dc:2e:cc:
         79:a2:6b:78:3e:6c:8c:e1:d0:e1:13:dc:6d:b5:61:2f:32:e6:
         dc:6c:f8:8a:23:0c:35:cf:17:dc:48:57:16:d3:e1:7e:5a:fd:
         05:0f:32:96:d6:ee:16:f4:59:50:ef:0a:f5:e8:ee:8c:f1:7c:
         3e:30:41:95:b6:1f:44:4f:d4:f4:8e:02:90:56:97:2c:f6:e3:
         a5:8e:b5:60:89:5b:d3:c4:7b:77:61:28:0b:6f:f9:13:82:f0:
         c7:1f:ce:cf:56:a0:d4:81:30:23:3b:f3:37:c0:1c:69:50:dc:
         64:c0:ce:0d
```

### certificate signing request

```bash
$openssl req -out kedu.csr -newkey rsa:2048 -nodes -keyout kedu.key
```

1. kedu.csr

```text
-----BEGIN CERTIFICATE REQUEST-----
MIICyTCCAbECAQAwgYMxCzAJBgNVBAYTAmNuMRAwDgYDVQQIDAdTaWNodWFuMRAw
DgYDVQQHDAdDaGVuZ2R1MREwDwYDVQQKDAh0aGlucGFyazENMAsGA1UECwwEY25j
ZjENMAsGA1UEAwwEa2VkdTEfMB0GCSqGSIb3DQEJARYQa2VkdUB0aGlucGFyay5p
bzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALklmZ93ahV/QMD7fs8V
knSXpitDLd0ewqUmz8nro2tAgwS/w2XzkotfoRFjvRxJzsIdFAXQKdaupJu126NZ
BZWSONbAkSmNj8jbjwIsCqJZGIcUAOl3Bg164xgDTBgNSMi/fmQrpHfS6qg+5jhF
ahhp2pJf/XNYy1PVGbPNaeOHY7/j10BwJqH1kmkpucbfxOqW4j65sKRRTLcjYdyQ
8ZHGOe2u6lMT0JdqiVDR4tgIUAOmOL+qx3TCFbZaeCa9YVPL/Fai+rNa8RYWSUH0
ngGQIPga3DPRGao9VGWrd+tVORo3b67EW8OIWk3tsRQAYMGtvnyPzXOCo9voXdSV
RHECAwEAAaAAMA0GCSqGSIb3DQEBCwUAA4IBAQCQOg6GJAMwctIW8va2hHylJhBv
l+gszJwsIfB1b3cjxX/0wMRv7MQF2zia27d95AoYoo4Lc44LjNNPlPPkGInLT6u2
htQeiilPvuO4+23qenZtCnvDlwXFN4wBeIl6oXJzhbDdP45NoAhuDclHhWQMizcP
me62IxcjP3mrXd+baq9pgzEGOKsZWGDCQ+Uu6KCzZirEAbFGSXAgr2u3y7j5sSRI
0KXpOOtrNN0LuMA6gXZ9FJi0/Xon8g9K4MgisNnfyyIWxEvAFDqbBpzSxIEAFWFm
YqHSxSE16y49Q5L0vTZgKWkyZ3XVGxOMVjBw2K9dXL2A5yhfzTezAEOOFrMQ
-----END CERTIFICATE REQUEST-----
```

2. kedu.key

```text
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC5JZmfd2oVf0DA
+37PFZJ0l6YrQy3dHsKlJs/J66NrQIMEv8Nl85KLX6ERY70cSc7CHRQF0CnWrqSb
tdujWQWVkjjWwJEpjY/I248CLAqiWRiHFADpdwYNeuMYA0wYDUjIv35kK6R30uqo
PuY4RWoYadqSX/1zWMtT1RmzzWnjh2O/49dAcCah9ZJpKbnG38TqluI+ubCkUUy3
I2HckPGRxjntrupTE9CXaolQ0eLYCFADpji/qsd0whW2WngmvWFTy/xWovqzWvEW
FklB9J4BkCD4Gtwz0RmqPVRlq3frVTkaN2+uxFvDiFpN7bEUAGDBrb58j81zgqPb
6F3UlURxAgMBAAECggEANvnXN+a5dVCn5aXH7a22IzC0grwb7kCoA2oW4Ro7GCm7
vblDSA6fQQtQRF2dVb0Ey9bejytUgQ6yihnh8gsJAXS9s+bSM8h5HWc0e6ygK7zQ
76sc6jYRcgc/T24LNkkbh6B040GiQII8c2DZ83OJIV6tLDGcjJedKHNqgl1IR+r2
g/Z+bp0TRpTvSFvZGW3tztEc6kJMoIO/3dpwE7sMEDyzdwQApFC0C4APZ1oZ1jaj
5MPndwtnadkDPx8ovlcdJ27WG58Cq87tBKoZwPcKMRxv8tXBb3b4pNscl2i5yzyN
Zpf/RENOp07/vz1Mm0Hhh/pv9ho++bAfuC4O348RwQKBgQDbUGy89aUsL1sQFmnO
WWVtiM4OTatsI1hxHy0GHFW/QShhk8P0A1m3bmiWktdcda5mjqZ20KGbtU2YJaTI
LAOzlScWF0D00YKrFE1/aW1wvV4ZYjaKeNrWe86L6IQNWhd1tV9IRRNb6/efyC+e
UL8s6CBzjOxy/3Bk39FmTSm2VQKBgQDYHgwyzIJxKiRZ10KcROuJ41nar3Kuwr47
te0E5etSKO4zcQZ8wNgI5c88eLW75TZ4b3n+F9TwUpO7mncs/JGkFOPCzS5fMfcZ
LfHafHvf2/jDqWRKFZHO1tKIeAhNNJkNSOJj+dajMfIx1j0MmUiBpsX3UIlYMQtV
jhbE1XvZrQKBgDzRWrYz8LAGGdymOoUsqUHs1CeHRmhgjOAh4xx0sxqseQRGM+rx
GuoRRhOreOl9APYTzPnZ9Vb2uiPdHIseGZCtZf9sR2kcyH2kzbDtjZncCcJESBey
WA1um+KUgjopp6POvjOOZEXzc+HtY7clcT6EyKsCg3eIeqSepLUX5N9ZAoGABNMO
5KdqFgqhyxuiEgj71RUtMVOPVNVmF8Ek7GIRkcD2KFHSmkBX0kMHEEuFiw8/2wpq
B8EScNb3E04McQWmXqpUt0mLSna8FGTRLFZxEXtAn2WNppW6ropfIsrDLK4K6KAC
5cZzAyufQ3uL21ckpjhJ3Q6AMmbN4PgODBDT9fUCgYAztjpuutH8XgD5w1i9nKOE
nantciM+jeKLExv0xmsInFLY/rPRlL2zDglM6TflbQDPQOdi/vL8EpnNcmZSDA3G
jW6Ay2RuL5jyRuaerGtRhQLuvGpwO2S+eOfCJRYmTrt6PBUQesmHG3DqWvMzOkn/
J4g8AdItyzzxDfhDheKsiA==
-----END PRIVATE KEY-----
```

### signning csr

```bash
$openssl ca -out kedu.crt -infiles ca.key
```
