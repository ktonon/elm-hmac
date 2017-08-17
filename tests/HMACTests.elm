module HMACTests exposing (all)

import Bytes exposing (Bytes)
import Expect
import HMAC
import Test exposing (Test, describe, test)


all : Test
all =
    describe "HMAC"
        [ describeDigest "sha1" HMAC.sha1 sha1Cases
        , describeDigest "sha256" HMAC.sha256 sha256Cases
        ]


describeDigest :
    String
    -> (Bytes -> Bytes -> Result String String)
    -> List TestCase
    -> Test
describeDigest label digest testCases =
    describe label
        (testCases
            |> List.indexedMap
                (\index tc ->
                    test (toString <| index + 1) <|
                        \_ ->
                            Expect.equal
                                (Ok tc.digest)
                                (case tc.compare of
                                    FullMatch ->
                                        digest tc.key tc.data

                                    Truncate n ->
                                        digest tc.key tc.data
                                            |> Result.map (String.slice 0 (n * 2))
                                )
                )
        )


type Compare
    = FullMatch
    | Truncate Int


type alias TestCase =
    { key : Bytes
    , data : Bytes
    , digest : String
    , compare : Compare
    }



-- Take from https://tools.ietf.org/html/rfc2202


sha1Cases : List TestCase
sha1Cases =
    [ TestCase
        (hex "0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b")
        (str "Hi There")
        "b617318655057264e28bc0b6fb378c8ef146be00"
        FullMatch
    , TestCase
        (str "Jefe")
        (str "what do ya want for nothing?")
        "effcdf6ae5eb2fa2d27416d5f184df9c259a7c79"
        FullMatch
    , TestCase
        (hex "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        (dup 50 "dd")
        "125d7342b9ac11cd91a39af48aa17b4f63f175d3"
        FullMatch
    , TestCase
        (hex "0102030405060708090a0b0c0d0e0f10111213141516171819")
        (dup 50 "cd")
        "4c9007f4026250c6bc8414f9bf50c86c2d7235da"
        FullMatch
    , TestCase
        (hex "0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c")
        (str "Test With Truncation")
        "4c1a03424b55e07fe7f27be1d58bb9324a9a5a04"
        FullMatch
    , TestCase
        (dup 80 "aa")
        (str "Test Using Larger Than Block-Size Key - Hash Key First")
        "aa4ae5e15272d00e95705637ce8a3b55ed402112"
        FullMatch
    , TestCase
        (dup 80 "aa")
        (str "Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data")
        "e8e99d0f45237d786d6bbaa7965c7808bbff1a91"
        FullMatch
    ]


sha256Cases : List TestCase
sha256Cases =
    [ TestCase
        (dup 20 "0b")
        (str "Hi There")
        "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7"
        FullMatch
    , TestCase
        (str "Jefe")
        (str "what do ya want for nothing?")
        "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843"
        FullMatch
    , TestCase
        (dup 20 "aa")
        (dup 50 "dd")
        "773ea91e36800e46854db8ebd09181a72959098b3ef8c122d9635514ced565fe"
        FullMatch
    , TestCase
        (hex "0102030405060708090a0b0c0d0e0f10111213141516171819")
        (dup 50 "cd")
        "82558a389a443c0ea4cc819899f2083a85f0faa3e578f8077a2e3ff46729665b"
        FullMatch
    , TestCase
        (dup 20 "0c")
        (str "Test With Truncation")
        "a3b6167473100ee06e0c796c2955552b"
        (Truncate 16)
    , TestCase
        (dup 131 "aa")
        (str "Test Using Larger Than Block-Size Key - Hash Key First")
        "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54"
        FullMatch
    , TestCase
        (dup 131 "aa")
        (str "This is a test using a larger than block-size key and a larger than block-size data. The key needs to be hashed before being used by the HMAC algorithm.")
        "9b09ffa71b942fcb27635fbcd5b0e944bfdc63644f0713938a7f51535c3a35e2"
        FullMatch
    ]



-- HELPERS


hex : String -> Bytes
hex =
    Bytes.fromHex


str : String -> Bytes
str =
    Bytes.fromBytes


dup : Int -> String -> Bytes
dup n hex =
    List.repeat n hex |> String.join "" |> Bytes.fromHex
