# Authentication Authorization Audit

```text
               API Request
                    |
                    v
 +--------------------------------------+  No
 |           AUTHENTICATION             |------> eg,. 401
 | Has this user proven their identity? |
 +--------------------------------------+
                    | Yes
                    v
 +--------------------------------------+
 |           ACCESS CONTROL             |  No
 | Is this user allowed to perform      |------> eg,. 403
 |           this action?               |
 +--------------------------------------+
                    | Yes
                    v
 +--------------------------------------+  No
 |          ADMINSSION CONTROL          |------> eg,. 409
 | Does this request look good?         |
 +--------------------------------------+
                    | Yes
                    v
            Process the request
```

## Authentication

- Basic authentication

```text
password,username,uid,"group1,group2,group3"
password,username,uid,"group1,group2,group3"
```

- X.509 client certificates

Common Name CN maps to username, and all Organization fields map to
the groups that the user is a member of.

- Bearer tokens

```json
{
  "iss": "https://auth.example.com",
  "sub": "Ch5hdXRoMHwMTYzOTgzZTdjN2EyNWQxMDViNjESBWF1N2Q2",
  "aud": "dDblg7xO7dks1uG6Op976jC7TjUZDCDz",
  "exp": 1517266346,
  "iat": 1517179946,
  "at_hash": "OjgZQ0vauibNVcXP52CtoQ",
  "username": "user",
  "email": "user@example.com",
  "email_verified": true,
  "groups": [
    "qa",
    "infrastructure"
  ]
}
```

- TokenReview

A custom bearer token (maybe just a uuid string) will be sent to an
authentication service, and the auth/n service should response status
false or true with correct user info.

```json
{
  "apiVersion": "authentication.k8s.io/v1beta1",
  "kind": "TokenReview",
  "status": {
    "authenticated": true,
    "user": {
      "username": "janedoe@example.com",
      "uid": "42",
      "groups": [
        "developers",
        "qa"
      ],
      "extra": {
        "extrafield1": [
          "extravalue1",
          "extravalue2"
        ]
      }
    }
  }
}
```
