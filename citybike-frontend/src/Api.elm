module Api exposing (Error, delete, get, getSingular, post, put, showError)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http exposing (Body, Error(..))
import Json.Decode exposing (Decoder)


type GetMode
    = Singular
    | Normal


get : Endpoint -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
get =
    getInternal Normal


getSingular : Endpoint -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
getSingular =
    getInternal Singular


getInternal : GetMode -> Endpoint -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
getInternal mode url decoder whenReady =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = Http.expectJson whenReady decoder
        , headers =
            case mode of
                Singular ->
                    [ Http.header "Accept" "application/vnd.pgrst.object+json" ]

                Normal ->
                    []
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


type alias Error =
    Http.Error


showError : Http.Error -> String
showError err =
    let
        somethingWentWrong =
            "Something went wrong."
    in
    case err of
        Timeout ->
            "Request timed out."

        NetworkError ->
            "No network."

        BadStatus int ->
            -- https://postgrest.org/en/stable/references/api/resource_representation.html?highlight=plural#singular-or-plural
            -- PostgREST says 406 means that the entry was not found.
            if int == 406 then
                "Does not exist."

            else
                somethingWentWrong

        BadUrl str ->
            somethingWentWrong

        -- "BADURL: " ++ str
        BadBody str ->
            somethingWentWrong



-- "BADBODY: " ++ str
