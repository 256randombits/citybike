module Page.SingleStation exposing
    ( Model
    , Msg
    , init
    , toSession
    , update
    , view
    )

import Api
import Api.Endpoint as Endpoint
import Citybike.Station as Station exposing (Station)
import Citybike.StationStats.Stats as Stats exposing (Stats)
import Citybike.StationStats.StatsAllTime as StatsAllTime exposing (StatsAllTime)
import Citybike.StationStats.StatsOnMonth as StatsOnMonth exposing (StatsOnMonth)
import GenericTable as Table
import Html exposing (..)
import Http exposing (Error(..))
import Json.Decode as Decode
import Session exposing (Session)
import Tuple exposing (pair)



-- MODEL


type alias Model =
    { session : Session, id : Int, state : State }


type alias StationWithStats =
    { station : Station, statsAllTime : StatsAllTime, statsOnMonthList : List StatsOnMonth }


init : Session -> Int -> ( Model, Cmd Msg )
init session id =
    ( { session = session, id = id, state = Loading }, getStation id )


type State
    = Loading
    | HasStation StationWithStats
    | Error Api.Error



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Single"
    , content =
        div []
            [ case model.state of
                Loading ->
                    text "Loading..."

                HasStation { station, statsAllTime, statsOnMonthList } ->
                    let
                        name =
                            Station.getNameFi station

                        address =
                            Station.getAddressFi station

                        stats =
                            StatsAllTime.getStats statsAllTime
                    in
                    div []
                        [ text <| name ++ " " ++ address
                        , div []
                          [ p [] [text "ALL TIME STATS"]
                          , viewStatsInATable stats
                          ]
                        , div []
                          [ p [] [text "MONTHLY STATS"]
                          , viewMonthlyStatsInATable statsOnMonthList
                          ]
                        ]

                Error err ->
                    text <| Api.showError err
            ]
    }


viewMonthlyStatsInATable : List StatsOnMonth -> Html Msg
viewMonthlyStatsInATable statsOnMonthList =
    let
        headersWithDecoders =
            [ ( "Month", \x -> StatsOnMonth.getMonth x )
            , ( "Dperatures", \x -> StatsOnMonth.getStats x |> Stats.getDeparturesCount |> String.fromInt )
            , ( "Return", \x -> StatsOnMonth.getStats x |> Stats.getReturnsCount |> String.fromInt )
            , ( "Avg dep dist", \x -> StatsOnMonth.getStats x |> Stats.getAverageDepartureDistanceInMeters |> floor |> String.fromInt )
            , ( "Avg ret dist", \x -> StatsOnMonth.getStats x |> Stats.getAverageReturnDistanceInMeters |> floor |> String.fromInt )
            , ( "Rank1_d", \x -> StatsOnMonth.getStats x |> Stats.getRank1Destination |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank2_d", \x -> StatsOnMonth.getStats x |> Stats.getRank2Destination |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank3_d", \x -> StatsOnMonth.getStats x |> Stats.getRank3Destination |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank4_d", \x -> StatsOnMonth.getStats x |> Stats.getRank4Destination |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank5_d", \x -> StatsOnMonth.getStats x |> Stats.getRank5Destination |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank1_o", \x -> StatsOnMonth.getStats x |> Stats.getRank1Origin |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank2_o", \x -> StatsOnMonth.getStats x |> Stats.getRank2Origin |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank3_o", \x -> StatsOnMonth.getStats x |> Stats.getRank3Origin |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank4_o", \x -> StatsOnMonth.getStats x |> Stats.getRank4Origin |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank5_o", \x -> StatsOnMonth.getStats x |> Stats.getRank5Origin |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            ]
    in
    Table.view headersWithDecoders statsOnMonthList

viewStatsInATable : Stats -> Html Msg
viewStatsInATable stats =
    let
        headersWithDecoders =
            [ ( "Dperatures", \x -> x |> Stats.getDeparturesCount |> String.fromInt )
            , ( "Return", \x -> x |> Stats.getReturnsCount |> String.fromInt )
            , ( "Avg dep dist", \x -> x |> Stats.getAverageDepartureDistanceInMeters |> floor |> String.fromInt )
            , ( "Avg ret dist", \x -> x |> Stats.getAverageReturnDistanceInMeters |> floor |> String.fromInt )
            , ( "Rank1_d", \x -> x |> Stats.getRank1Destination |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank2_d", \x -> x |> Stats.getRank2Destination |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank3_d", \x -> x |> Stats.getRank3Destination |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank4_d", \x -> x |> Stats.getRank4Destination |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank5_d", \x -> x |> Stats.getRank5Destination |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank1_o", \x -> x |> Stats.getRank1Origin |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank2_o", \x -> x |> Stats.getRank2Origin |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank3_o", \x -> x |> Stats.getRank3Origin |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank4_o", \x -> x |> Stats.getRank4Origin |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            , ( "Rank5_o", \x -> x |> Stats.getRank5Origin |> Maybe.map Station.getNameFi |> Maybe.withDefault "No station" )
            ]
    in
    Table.view headersWithDecoders [ stats ]



-- UPDATE


getStation : Int -> Cmd Msg
getStation id =
    let
        yay : Station -> StatsAllTime -> List StatsOnMonth -> StationWithStats
        yay st at mt =
            { station = st, statsAllTime = at, statsOnMonthList = mt }

        stationWithStatsDecoder =
            Decode.map3 yay Station.decoder (Decode.field "stats" StatsAllTime.decoder) (Decode.field "stats_monthly" <| Decode.list StatsOnMonth.decoder)
    in
    Api.getSingular (Endpoint.stationStats id) stationWithStatsDecoder GotStation


type Msg
    = GotStation (Result Api.Error StationWithStats)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotStation result ->
            case model.state of
                Loading ->
                    case result of
                        Ok station ->
                            ( { model | state = HasStation station }, Cmd.none )

                        Err err ->
                            ( { model | state = Error err }, Cmd.none )

                -- User changed something before the results came?
                _ ->
                    ( model, Cmd.none )


toSession : Model -> Session
toSession model =
    model.session
