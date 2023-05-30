module Citybike.StationStats.Basic exposing
    ( Basic
    , decoder
    , getAverageDepartureDistanceInMeters
    , getAverageReturnDistanceInMeters
    , getDeparturesCount
    , getReturnsCount
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type Basic
    = Basic
        { departuresCount : Int
        , retrunsCount : Int
        , averageDepartureDistanceInMeters : Float
        , averageReturnDistanceInMeters : Float
        }


createBasic : Int -> Int -> Float -> Float -> Basic
createBasic departuresCount retrunsCount averageReturnLengthInMeters averageDepartureLengthInMeters =
    Basic
        { departuresCount = departuresCount
        , retrunsCount = retrunsCount
        , averageDepartureDistanceInMeters = averageDepartureLengthInMeters
        , averageReturnDistanceInMeters = averageReturnLengthInMeters
        }


decoder : Decoder Basic
decoder =
    Decode.succeed createBasic
        |> required "departures_count" Decode.int
        |> required "returns_count" Decode.int
        |> required "average_departure_distance_in_meters" Decode.float
        |> required "average_return_distance_in_meters" Decode.float


getDeparturesCount : Basic -> Int
getDeparturesCount (Basic rec) =
    rec.departuresCount


getReturnsCount : Basic -> Int
getReturnsCount (Basic rec) =
    rec.retrunsCount


getAverageDepartureDistanceInMeters : Basic -> Float
getAverageDepartureDistanceInMeters (Basic rec) =
    rec.averageDepartureDistanceInMeters


getAverageReturnDistanceInMeters : Basic -> Float
getAverageReturnDistanceInMeters (Basic rec) =
    rec.averageReturnDistanceInMeters
