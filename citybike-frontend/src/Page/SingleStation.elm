module Page.SingleStation exposing
    ( Model
    , Msg
    , init
    , toSession
    , update
    , view
    )

import GenericTable as Table
import Api
import Api.Endpoint as Endpoint
import Citybike.Station as Station exposing (Station)
import Citybike.StationStats.StatsAllTime as StatsAllTime exposing (StatsAllTime)
import Citybike.StationStats.Stats as Stats exposing (Stats)
import Html exposing (..)
import Http exposing (Error(..))
import Json.Decode as Decode
import Session exposing (Session)
import Tuple exposing (pair)



-- MODEL


type alias Model =
    { session : Session, id : Int, state : State }


init : Session -> Int -> ( Model, Cmd Msg )
init session id =
    ( { session = session, id = id, state = Loading }, getStation id )


type State
    = Loading
    | HasStation ( Station, StatsAllTime )
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

                HasStation ( station, statsAllTime ) ->
                    let
                        name =
                            Station.getNameFi station

                        stats =
                            StatsAllTime.getStats statsAllTime
                        departures = Stats.getDeparturesCount stats
                    in
                    div []
                        [ text <| String.fromInt departures
                        , viewStatsInATable stats
                        ]

                Error err ->
                    text <| Api.showError err
            ]
    }

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
    Table.view headersWithDecoders [stats]


-- UPDATE


getStation : Int -> Cmd Msg
getStation id =
    let
        stationWithStatsDecoder =
            Decode.map2 pair Station.decoder (Decode.field "stats" StatsAllTime.decoder)
    in
    Api.getSingular (Endpoint.stationStats id) stationWithStatsDecoder GotStation


type Msg
    = GotStation (Result Api.Error ( Station, StatsAllTime ))


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
