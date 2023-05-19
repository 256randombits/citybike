module Api.Endpoint exposing (Endpoint, request, stations)

import Http
import Station exposing (StationQuery, unwrapId, unwrapNameFi)
import Url.Builder as Builder exposing (QueryParameter, string)
import Validate exposing (Valid, fromValid)
import Station exposing (unwrapAddressFi)
import Station exposing (unwrapCityFi)
import Station exposing (unwrapOperator)
import Station exposing (unwrapCapacity)


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
    Builder.crossOrigin "http://localhost:3001"
        paths
        queryParams
        |> Endpoint



-- ENDPOINTS


stations : StationQuery -> Endpoint
stations stationQuery =
    let
        queryParams =
            let
                fieldToQueryParams : String -> Maybe a -> (a -> String) -> List QueryParameter
                fieldToQueryParams key maybeWrappedString unwrap =
                    case maybeWrappedString of
                        Nothing ->
                            []

                        Just wrappedString ->
                            [ Builder.string key ("eq." ++ unwrap wrappedString) ]
            in
            List.foldl (++)
                []
                [ fieldToQueryParams "id" stationQuery.maybeId unwrapId
                , fieldToQueryParams "name_fi" stationQuery.maybeNameFi unwrapNameFi
                , fieldToQueryParams "address_fi" stationQuery.maybeAddressFi unwrapAddressFi
                , fieldToQueryParams "city_fi" stationQuery.maybeCityFi unwrapCityFi
                , fieldToQueryParams "operator" stationQuery.maybeOperator unwrapOperator
                , fieldToQueryParams "capacity" stationQuery.maybeCapacity unwrapCapacity
                ]
    in
    internalStations queryParams



-- INTERNAL


internalStations : List QueryParameter -> Endpoint
internalStations params =
    url [ "stations" ] params
