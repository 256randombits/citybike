module Journey exposing
    ( Journey
    , JourneyQuery
    , createJourney
    , decoder
    , encoder
    , getDepartureStation
    , getDepartureTime
    , getDistanceInMeters
    , getReturnStation
    , getReturnTime
    )

import Json.Decode as Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Station exposing (Station, decoder)


type alias JourneyQuery =
    { id : Maybe Int
    }


type Journey
    = Journey
        { id : Int
        , departureTime : String
        , returnTime : String
        , departureStation : Station
        , returnStation : Station
        , distanceInMeters : Int
        }


createJourney : Int -> String -> String -> Station -> Station -> Int -> Journey
createJourney id departureTime returnTime departureStation returnStation distanceInMeters =
    Journey
        { id = id
        , departureTime = departureTime
        , returnTime = returnTime
        , departureStation = departureStation
        , returnStation = returnStation
        , distanceInMeters = distanceInMeters
        }


decoder : Decoder Journey
decoder =
    Decode.succeed createJourney
        |> required "id" int
        |> required "departure_time" string
        |> required "return_time" string
        |> required "departure_station" Station.decoder
        |> required "return_station" Station.decoder
        |> required "distance_in_meters" int


encoder : Journey -> Encode.Value
encoder journey =
    Encode.object
        [ ( "id", getId journey |> Encode.int )
        ]


getId : Journey -> Int
getId (Journey values) =
    values.id


getDepartureTime : Journey -> String
getDepartureTime (Journey values) =
    values.departureTime


getReturnTime : Journey -> String
getReturnTime (Journey values) =
    values.returnTime


getDepartureStation : Journey -> Station
getDepartureStation (Journey values) =
    values.departureStation


getReturnStation : Journey -> Station
getReturnStation (Journey values) =
    values.returnStation


getDistanceInMeters : Journey -> Int
getDistanceInMeters (Journey values) =
    values.distanceInMeters
