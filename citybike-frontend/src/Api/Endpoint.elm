module Api.Endpoint exposing (Endpoint, request, stations, journeys)

import Http
import Station exposing (StationQuery, unwrapAddressFi, unwrapCapacity, unwrapCityFi, unwrapId, unwrapNameFi, unwrapOperator)
import Url.Builder as Builder exposing (QueryParameter, string)
import Validate exposing (Valid, fromValid)
import Journey exposing (JourneyQuery)


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
                [ Builder.string "limit" (String.fromInt stationQuery.limit), Builder.string "offset" (String.fromInt stationQuery.offset)]
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

journeys : JourneyQuery -> Endpoint
journeys journeyQuery = 
    url [ "journeys?select=*,departure_station:stations!journeys_departure_station_id_fkey(*),return_station:stations!journeys_return_station_id_fkey(*)" ] []

internalStations : List QueryParameter -> Endpoint
internalStations params =
    url [ "stations" ] params


