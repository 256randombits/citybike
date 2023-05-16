module Main exposing (main)

import Browser
import Html exposing (Html, div, p, pre, text)
import Http
import Json.Decode as Decode



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = \_ _ _ -> ( initQueryTool, Cmd.none )
        , view = \model -> { title = "Citybike", body = [ view model ] }
        , update = \_ _ -> ( initQueryTool, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = \_ -> NoOp
        , onUrlChange = \_ -> NoOp
        }



-- MODEL


type alias Model =
    { queryMode : QueryMode
    , stationQuery : StationQuery
    , journeyQuery : JourneyQuery
    , resultsMode : ResultsMode
    , results : Results
    }


type alias StationQuery =
    { id : Maybe Int
    }


type alias JourneyQuery =
    { id : Maybe Int
    }


type Results
    = HasNothing
    | HasStations (List String)
    | HasJourneys (List String)


type ResultsMode
    = MapMode
    | ListMode


type QueryMode
    = JourneyMode
    | StationMode


initQueryTool : Model
initQueryTool =
    { queryMode = StationMode
    , resultsMode = ListMode
    , stationQuery = { id = Nothing }
    , journeyQuery = { id = Nothing }
    , results = HasNothing
    }



-- UPDATE


type Msg
    = GetStations StationQuery
    | LoadingStations
    | GotStations Decode.Value
    | NoOp



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewQueryTool model.queryMode model.stationQuery model.journeyQuery
        , viewResultsViewer model.resultsMode model.results
        ]


viewResultsViewer resultsMode results =
    div []
        [ viewResultsModeSelector resultsMode
        , viewResults resultsMode results
        ]


viewResults : ResultsMode -> Results -> Html msg
viewResults resultsMode results =
    case resultsMode of
        MapMode ->
            case results of
                HasNothing ->
                    div [] [ text "Here you could see nothing on a map." ]

                HasJourneys journeysList ->
                    div [] [ text "Here you could see journeys on a map." ]

                HasStations stationsList ->
                    div [] [ text "Here you could see stations on a map." ]

        ListMode ->
            case results of
                HasNothing ->
                    div [] [ text "Here you could see nothing in a list." ]

                HasJourneys journeysList ->
                    div [] [ text "Here you could see journeys in a list." ]

                HasStations stationsList ->
                    div [] [ text "Here you could see stations in a list." ]


viewResultsModeSelector : ResultsMode -> Html msg
viewResultsModeSelector resultsMode =
    case resultsMode of
        MapMode ->
            div [] [ text "Here you could see that the map mode is active." ]

        ListMode ->
            div [] [ text "Here you could see that the list mode is active." ]


viewQueryTool : QueryMode -> StationQuery -> JourneyQuery -> Html Msg
viewQueryTool queryMode stationQuery journeyQuery =
    div []
        [ viewQueryModeSelector queryMode
        , viewQueryEditor queryMode stationQuery journeyQuery
        ]


viewQueryEditor : QueryMode -> StationQuery -> JourneyQuery -> Html msg
viewQueryEditor queryMode stationQuery journeyQuery=
    div []
        [ case queryMode of
            JourneyMode ->
                viewJourneyQueryEditor journeyQuery

            StationMode ->
                viewStationQueryEditor stationQuery
        ]


viewJourneyQueryEditor : JourneyQuery -> Html msg
viewJourneyQueryEditor journeyQuery =
    text "Here you could edit the station query."

viewStationQueryEditor : StationQuery -> Html msg
viewStationQueryEditor stationQuery =
    text "Here you could edit the station query."


viewQueryModeSelector : QueryMode -> Html Msg
viewQueryModeSelector queryMode =
    div []
        [ p []
            [ case queryMode of
                JourneyMode ->
                    text "Current mode is JourenyMode"

                StationMode ->
                    text "Current mode is StationMode"
            ]
        ]
