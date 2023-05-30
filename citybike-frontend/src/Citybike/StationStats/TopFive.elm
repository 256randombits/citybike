module Citybike.StationStats.TopFive exposing
    ( Destinations
    , Origins
    , destinationsDecoder
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
    , originsDecoder
    )

import Citybike.Station as Station exposing (Station)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional)


type Destinations
    = Destinations
        { rank1 : Maybe Station
        , rank2 : Maybe Station
        , rank3 : Maybe Station
        , rank4 : Maybe Station
        , rank5 : Maybe Station
        }


type Origins
    = Origins
        { rank1 : Maybe Station
        , rank2 : Maybe Station
        , rank3 : Maybe Station
        , rank4 : Maybe Station
        , rank5 : Maybe Station
        }


createTopFive : ({ rank1 : b, rank2 : c, rank3 : d, rank4 : e, rank5 : f } -> a) -> b -> c -> d -> e -> f -> a
createTopFive con mr1 mr2 mr3 mr4 mr5 =
    con
        { rank1 = mr1
        , rank2 = mr2
        , rank3 = mr3
        , rank4 = mr4
        , rank5 = mr5
        }


destinationsDecoder : Decoder Destinations
destinationsDecoder =
    Decode.succeed (createTopFive Destinations)
        |> optional "rank1" (Decode.maybe Station.decoder) Nothing
        |> optional "rank2" (Decode.maybe Station.decoder) Nothing
        |> optional "rank3" (Decode.maybe Station.decoder) Nothing
        |> optional "rank4" (Decode.maybe Station.decoder) Nothing
        |> optional "rank5" (Decode.maybe Station.decoder) Nothing


originsDecoder : Decoder Origins
originsDecoder =
    Decode.succeed (createTopFive Origins)
        |> optional "rank1" (Decode.maybe Station.decoder) Nothing
        |> optional "rank2" (Decode.maybe Station.decoder) Nothing
        |> optional "rank3" (Decode.maybe Station.decoder) Nothing
        |> optional "rank4" (Decode.maybe Station.decoder) Nothing
        |> optional "rank5" (Decode.maybe Station.decoder) Nothing


getRank1Destination : Destinations -> Maybe Station
getRank1Destination (Destinations rec) =
    rec.rank1


getRank2Destination : Destinations -> Maybe Station
getRank2Destination (Destinations rec) =
    rec.rank2


getRank3Destination : Destinations -> Maybe Station
getRank3Destination (Destinations rec) =
    rec.rank3


getRank4Destination : Destinations -> Maybe Station
getRank4Destination (Destinations rec) =
    rec.rank4


getRank5Destination : Destinations -> Maybe Station
getRank5Destination (Destinations rec) =
    rec.rank5


getRank1Origin : Origins -> Maybe Station
getRank1Origin (Origins rec) =
    rec.rank1


getRank2Origin : Origins -> Maybe Station
getRank2Origin (Origins rec) =
    rec.rank2


getRank3Origin : Origins -> Maybe Station
getRank3Origin (Origins rec) =
    rec.rank3


getRank4Origin : Origins -> Maybe Station
getRank4Origin (Origins rec) =
    rec.rank4


getRank5Origin : Origins -> Maybe Station
getRank5Origin (Origins rec) =
    rec.rank5
