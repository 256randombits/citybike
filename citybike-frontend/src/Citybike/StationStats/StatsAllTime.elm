module Citybike.StationStats.StatsAllTime exposing (StatsAllTime, decode, getStats)

import Citybike.StationStats.Stats as Stats exposing (Stats)
import Citybike.StationStats.TopFive exposing (..)
import Json.Decode as Decode exposing (Decoder)


type StatsAllTime
    = StatsAllTime Stats


decode : Decoder StatsAllTime
decode =
    Decode.map StatsAllTime
        Stats.decoder


getStats : StatsAllTime -> Stats
getStats (StatsAllTime stats) =
    stats
