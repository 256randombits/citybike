module Citybike.StationStats.Stats exposing
    ( Stats
    , decoder
    , getAverageDepartureDistanceInMeters
    , getAverageReturnDistanceInMeters
    , getDeparturesCount
    , getRank1Destination
    , getRank1Origin
    , getRank2Destination
    , getRank2Origin
    , getRank3Destination
    , getRank3Origin
    , getRank4Destination
    , getRank4Origin
    , getRank5Destination
    , getRank5Origin
    , getReturnsCount
    )

import Citybike.Station exposing (Station)
import Citybike.StationStats.Basic as Basic exposing (Basic)
import Citybike.StationStats.TopFive as TopFive
import Json.Decode as Decode exposing (Decoder)


type alias Stats =
    { basic : Basic
    , topFiveDestinations : TopFive.Destinations
    , topFiveOrigins : TopFive.Origins
    }


createStats : a -> b -> c -> { basic : a, topFiveDestinations : b, topFiveOrigins : c }
createStats basic topFiveDestinations topFiveOrigins =
    { basic = basic, topFiveDestinations = topFiveDestinations, topFiveOrigins = topFiveOrigins }


decoder : Decoder Stats
decoder =
    Decode.map3 createStats
        Basic.decoder
        TopFive.destinationsDecoder
        TopFive.originsDecoder



-- Internal getters


getBasic : { a | basic : b } -> b
getBasic stats =
    stats.basic


getTopFiveDestinations : { a | topFiveDestinations : b } -> b
getTopFiveDestinations stats =
    stats.topFiveDestinations


getTopFiveOrigins : { a | topFiveOrigins : b } -> b
getTopFiveOrigins stats =
    stats.topFiveOrigins



-- Exported getters


getDeparturesCount : { a | basic : Basic } -> Int
getDeparturesCount stats =
    stats |> getBasic |> Basic.getDeparturesCount


getReturnsCount : { a | basic : Basic } -> Int
getReturnsCount stats =
    stats |> getBasic |> Basic.getReturnsCount


getAverageDepartureDistanceInMeters : { a | basic : Basic } -> Float
getAverageDepartureDistanceInMeters stats =
    stats |> getBasic |> Basic.getAverageDepartureDistanceInMeters


getAverageReturnDistanceInMeters : { a | basic : Basic } -> Float
getAverageReturnDistanceInMeters stats =
    stats |> getBasic |> Basic.getAverageReturnDistanceInMeters


getRank1Destination : { a | topFiveDestinations : TopFive.Destinations } -> Maybe Station
getRank1Destination stats =
    stats
        |> getTopFiveDestinations
        |> TopFive.getRank1Destination


getRank2Destination : { a | topFiveDestinations : TopFive.Destinations } -> Maybe Station
getRank2Destination stats =
    stats
        |> getTopFiveDestinations
        |> TopFive.getRank2Destination


getRank3Destination : { a | topFiveDestinations : TopFive.Destinations } -> Maybe Station
getRank3Destination stats =
    stats
        |> getTopFiveDestinations
        |> TopFive.getRank3Destination


getRank4Destination : { a | topFiveDestinations : TopFive.Destinations } -> Maybe Station
getRank4Destination stats =
    stats
        |> getTopFiveDestinations
        |> TopFive.getRank4Destination


getRank5Destination : { a | topFiveDestinations : TopFive.Destinations } -> Maybe Station
getRank5Destination stats =
    stats
        |> getTopFiveDestinations
        |> TopFive.getRank5Destination


getRank1Origin : { a | topFiveOrigins : TopFive.Origins } -> Maybe Station
getRank1Origin stats =
    stats
        |> getTopFiveOrigins
        |> TopFive.getRank1Origin


getRank2Origin : { a | topFiveOrigins : TopFive.Origins } -> Maybe Station
getRank2Origin stats =
    stats
        |> getTopFiveOrigins
        |> TopFive.getRank2Origin


getRank3Origin : { a | topFiveOrigins : TopFive.Origins } -> Maybe Station
getRank3Origin stats =
    stats
        |> getTopFiveOrigins
        |> TopFive.getRank3Origin


getRank4Origin : { a | topFiveOrigins : TopFive.Origins } -> Maybe Station
getRank4Origin stats =
    stats
        |> getTopFiveOrigins
        |> TopFive.getRank4Origin


getRank5Origin : { a | topFiveOrigins : TopFive.Origins } -> Maybe Station
getRank5Origin stats =
    stats
        |> getTopFiveOrigins
        |> TopFive.getRank5Origin
