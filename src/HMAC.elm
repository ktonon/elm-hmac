module HMAC exposing (Key, Message, sha1, sha256)

{-| Basic HMAC hashing.

Key and message are `Bytes`, a type provided by `spisemisu/elm-bytes`.

    import Bytes

@docs sha1, sha256


## Aliases

@docs Key, Message

-}

import Bitwise
import Bytes exposing (Bytes)
import SHA


-- EXPOSED API


{-| Secret key
-}
type alias Key =
    Bytes


{-| Message to be hashed
-}
type alias Message =
    Bytes


{-| HMAC SHA1 digest

    sha1 Bytes.empty Bytes.empty
    --> Ok "fbdb1d1b18aa6c08324b7d64b71fb76370690e1d"

    sha1
        (Bytes.fromBytes "key")
        (Bytes.fromBytes "The quick brown fox jumps over the lazy dog")
    --> Ok "de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9"

-}
sha1 : Key -> Message -> Result String String
sha1 =
    hmac SHA.sha1bytes 64


{-| HMAC SHA256 digest.

    sha256 Bytes.empty Bytes.empty
    --> Ok "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad"

    sha256
        (Bytes.fromBytes "key")
        (Bytes.fromBytes "The quick brown fox jumps over the lazy dog")
    --> Ok "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8"

-}
sha256 : Key -> Message -> Result String String
sha256 =
    hmac SHA.sha256bytes 64



-- HMAC


hmac : (Bytes -> String) -> Int -> Key -> Message -> Result String String
hmac hash blockSize key message =
    hmac_ hash (Bytes.toList message) <|
        normalizeKey hash blockSize key


hmac_ : (Bytes -> String) -> List Int -> List Int -> Result String String
hmac_ hash messageBytes keyBytes =
    let
        oKeyPad =
            List.map (Bitwise.xor 92) keyBytes

        iKeyPad =
            List.map (Bitwise.xor 54) keyBytes
    in
    concat iKeyPad messageBytes
        |> Result.andThen
            (hash
                >> Bytes.fromHex
                >> Bytes.toList
                >> concat oKeyPad
                >> Result.map hash
            )



-- HELPERS


concat : List Int -> List Int -> Result String Bytes
concat bytes =
    (++) bytes >> Bytes.fromList


normalizeKey : (Bytes -> String) -> Int -> Bytes -> List Int
normalizeKey hash blockSize key =
    let
        n =
            List.length <| Bytes.toList <| key
    in
    if n > blockSize then
        key
            |> hash
            |> Bytes.fromHex
            |> padEnd blockSize
    else if n < blockSize then
        padEnd blockSize key
    else
        Bytes.toList key


padEnd : Int -> Bytes -> List Int
padEnd blockSize bytes =
    let
        byteList =
            Bytes.toList bytes

        n =
            List.length byteList
    in
    List.append byteList <|
        List.repeat (blockSize - n) 0
