module Api exposing (Error, showError, delete, get, post, put)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http as Http exposing (Body, Error(..))
import Json.Decode exposing (Decoder)



get : Endpoint -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
get url decoder whenReady =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = Http.expectJson whenReady decoder
        -- , headers = [ Http.header "Range-Unit" "items", Http.header "Range" "10-19"]
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        }


put : Endpoint -> Body -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
put url body decoder whenReady =
    Endpoint.request
        { method = "PUT"
        , url = url
        , expect = Http.expectJson whenReady decoder
        , headers = []
        , body = body
        , timeout = Nothing
        }


post : Endpoint -> Body -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
post url body decoder whenReady =
    Endpoint.request
        { method = "POST"
        , url = url
        , expect = Http.expectJson whenReady decoder
        , headers = []
        , body = body
        , timeout = Nothing
        }


delete : Endpoint -> Body -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
delete url body decoder whenReady =
    Endpoint.request
        { method = "DELETE"
        , url = url
        , expect = Http.expectJson whenReady decoder
        , headers = []
        , body = body
        , timeout = Nothing
        }



-- Errors
type alias Error = Http.Error

showError : Http.Error -> String
showError err =
    case err of
        BadUrl str ->
          "BADURL: " ++ str

        Timeout ->
            "TIMEOUT"

        NetworkError ->
           "NETWORKERROR"

        BadStatus int ->
            "BadStatus" ++ String.fromInt int

        BadBody str ->
            "BADBODY: " ++ str
