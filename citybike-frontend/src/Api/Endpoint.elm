module Api.Endpoint exposing (Endpoint, request, stations)

import Http
import Url.Builder exposing (QueryParameter)


request :
    { body : Http.Body
    , expect : Http.Expect a
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , url : Endpoint
    }
    -> Cmd a
request config =
    let
        unwrap : Endpoint -> String
        unwrap (Endpoint str) =
            str
    in
    Http.request
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = config.timeout
        , url = unwrap config.url
        , tracker = Nothing
        }



-- TYPES


type Endpoint
    = Endpoint String


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    Url.Builder.crossOrigin "http://localhost:3001"
        paths
        queryParams
        |> Endpoint



-- ENDPOINTS


stations : List QueryParameter -> Endpoint
stations params =
    url [ "stations" ] params
