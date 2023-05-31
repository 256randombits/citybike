module Citybike.StationStats.StatsOnMonth exposing (StatsOnMonth, decoder, getStats, getMonth)

import Citybike.StationStats.Stats as Stats exposing (Stats)
import Json.Decode as Decode exposing (Decoder, field, string)


type StatsOnMonth
    = StatsOnMonth
        { month : String
        , stats : Stats
        }


createStatsOnMonth : String -> Stats -> StatsOnMonth
createStatsOnMonth month stats =
    StatsOnMonth { month = month, stats = stats }


decoder : Decoder StatsOnMonth
decoder =
    Decode.map2 createStatsOnMonth
        (field "month_timestamp" string)
        Stats.decoder


getStats : StatsOnMonth -> Stats
getStats (StatsOnMonth { stats }) =
    stats

getMonth : StatsOnMonth -> String
getMonth (StatsOnMonth { month }) = month
