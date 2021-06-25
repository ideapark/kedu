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
