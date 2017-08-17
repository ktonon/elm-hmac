# elm-hmac

[![elm-package](https://img.shields.io/badge/elm-1.0.0-blue.svg)](http://package.elm-lang.org/packages/ktonon/elm-hmac/latest)

Compute HMAC digests.

Currently only provides.

* `HMAC.sha1`
* `HMAC.sha256`

## Example 

Key and message are `Bytes`, a type provided by [spisemisu/elm-bytes][].

```elm
import HMAC
import Bytes

HMAC.sha256
    (Bytes.fromBytes "key")
    (Bytes.fromBytes "The quick brown fox jumps over the lazy dog")
--> Ok "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8"
```

## Test Suites

* `HMAC.sha1` is tested against https://tools.ietf.org/html/rfc2202
* `HMAC.sha256` is tested against https://tools.ietf.org/rfc/rfc4231.txt

[spisemisu/elm-bytes]:http://package.elm-lang.org/packages/spisemisu/elm-bytes/1.1.0/Bytes
