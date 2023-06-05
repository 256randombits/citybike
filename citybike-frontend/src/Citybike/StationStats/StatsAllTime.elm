module Citybike.StationStats.StatsAllTime exposing (StatsAllTime, decoder, getStats)

import Citybike.StationStats.Stats as Stats exposing (Stats)
import Citybike.StationStats.TopFive exposing (..)
import Json.Decode as Decode exposing (Decoder)


type StatsAllTime
    = StatsAllTime Stats


decoder : Decoder StatsAllTime
decoder =
    Decode.map StatsAllTime
        Stats.decoder


getStats : StatsAllTime -> Stats
getStats (StatsAllTime stats) =
    stats
