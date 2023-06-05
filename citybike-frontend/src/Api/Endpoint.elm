module Api.Endpoint exposing
    ( Endpoint
    , journeys
    , request
    , station
    , stationStats
    , stations
    )

import Citybike.Journey as Journey exposing (JourneyQuery)
import Citybike.Station as Station
    exposing
        ( StationQuery
        , unwrapAddressFi
        , unwrapCapacity
        , unwrapCityFi
        , unwrapId
        , unwrapNameFi
        , unwrapOperator
        )
import Http
import Url.Builder as Builder exposing (QueryParameter)


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
                [ Builder.string "limit" (String.fromInt stationQuery.limit), Builder.string "offset" (String.fromInt stationQuery.offset) ]
                [ fieldToQueryParams "id" stationQuery.maybeId unwrapId
                , fieldToQueryParams "name_fi" stationQuery.maybeNameFi unwrapNameFi
                , fieldToQueryParams "address_fi" stationQuery.maybeAddressFi unwrapAddressFi
                , fieldToQueryParams "city_fi" stationQuery.maybeCityFi unwrapCityFi
                , fieldToQueryParams "operator" stationQuery.maybeOperator unwrapOperator
                , fieldToQueryParams "capacity" stationQuery.maybeCapacity unwrapCapacity
                ]
    in
    internalStations queryParams


journeys : JourneyQuery -> Endpoint
journeys _ =
    url [ "journeys?select=*,departure_station:stations!departure_station(*),return_station:stations!return_station(*)&limit=15&offset=0" ] []


station : Int -> Endpoint
station id =
    let
        queryParams =
            [ Builder.string "id" ("eq." ++ String.fromInt id) ]
    in
    internalStations queryParams


stationStats : Int -> Endpoint
stationStats id =
    let
        queryParams =
            [ Builder.string "id" ("eq." ++ String.fromInt id)
            , Builder.string "select" "*,stats(*,top5_destinations(rank1_destination,rank2_destination,rank3_destination,rank4_destination,rank5_destination),top5_origins(rank1_origin,rank2_origin,rank3_origin,rank4_origin,rank5_origin))"
            ]
    in
    internalStations queryParams



-- INTERNAL


internalStations : List QueryParameter -> Endpoint
internalStations params =
    url [ "stations" ] params
