# PIC-SURE 2.0 Quick-Start

    $ cd deployments/picsure-2/quick-start
    $ docker-compose up -d

## Test PIC-SURE Access

JWT Token can be generated [here](https://github.com/hms-dbmi/jwt-creator.git)

Use `CLIENT_SECRET` value found in `quick_start.env` to generate your token.

Test query:

```bash
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <JWT Token>" \
-X GET https://<docker host>/rest/v1/systemService/about
```
