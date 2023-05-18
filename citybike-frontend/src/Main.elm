module Main exposing (main)

import Browser
import Html exposing (Html, button, div, p, pre, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http exposing (Error(..))
import Station as Station exposing (..)
import Station exposing (Station)
import Json.Decode as Decode
import Json.Decode exposing (list)



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = \_ _ _ -> ( initQueryTool, Cmd.none )
        , view = \model -> { title = "Citybike", body = [ view model ] }
        , update = update
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
    { id : String
    }


type alias JourneyQuery =
    { id : Maybe Int
    }


type Results
    = HasNothing
    | Loading
    | Failure Http.Error
    | HasStations (List Station)
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
    , stationQuery = { id = "" }
    , journeyQuery = { id = Nothing }
    , results = HasNothing
    }



-- UPDATE


type Msg
    = GetStations StationQuery
    | GotStations (Result Http.Error (List Station))
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetStations stationQuery ->
            ( { model | results = Loading }, Http.get { url = "http://localhost:3001/stations", expect = Http.expectJson GotStations (list Station.decoder)} )

        GotStations result ->
            case result of
                Ok stations ->
                    ( { model | results = HasStations stations }, Cmd.none )

                Err err ->
                    ( { model | results = Failure err }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "flex flex-col gap-4 h-screen p-4 bg-gray-900 text-black" ]
        [ viewQueryTool model.queryMode model.stationQuery model.journeyQuery
        , viewResultsViewer model.resultsMode model.results
        ]


viewQueryTool : QueryMode -> StationQuery -> JourneyQuery -> Html Msg
viewQueryTool queryMode stationQuery journeyQuery =
    div [ class "bg-green-800" ]
        [ viewQueryModeSelector queryMode
        , viewQueryEditor queryMode stationQuery journeyQuery
        ]


viewQueryEditor : QueryMode -> StationQuery -> JourneyQuery -> Html Msg
viewQueryEditor queryMode stationQuery journeyQuery =
    div []
        [ case queryMode of
            JourneyMode ->
                viewJourneyQueryEditor journeyQuery

            StationMode ->
                viewStationQueryEditor stationQuery
        ]


viewJourneyQueryEditor : JourneyQuery -> Html Msg
viewJourneyQueryEditor journeyQuery =
    text "Here you could edit the journey query."


viewStationQueryEditor : StationQuery -> Html Msg
viewStationQueryEditor stationQuery =
    div []
        [ button [ onClick (GetStations stationQuery) ] [ text "hh" ]
        ]


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


viewResultsViewer resultsMode results =
    div [ class "grow bg-red-900 overflow-scroll" ]
        [ viewResultsModeSelector resultsMode
        , viewResults resultsMode results
        ]


viewResults : ResultsMode -> Results -> Html msg
viewResults resultsMode results =
    div [ class "" ]
        [ case results of
            Failure err ->
                case err of
                    BadUrl str ->
                        div [] [ text ("BADURL" ++ str) ]

                    Timeout ->
                        div [] [ text "TIMEOUT" ]

                    NetworkError ->
                        div [] [ text "NETWORKERROR" ]

                    BadStatus int ->
                        div [] [ text ("BadStatus" ++ String.fromInt int) ]

                    BadBody str ->
                        div [] [ text ("BADBODY" ++ str)]

            Loading ->
                div [] [ text "Here you could see the results loading." ]

            HasNothing ->
                div [] [ text "Here you could see nothing." ]

            HasJourneys journeysList ->
                div [] [ text "Here you could see journeys on a map." ]

            HasStations stationsList ->
                case resultsMode of
                    MapMode ->
                        div [] [ text "Here you could see stations on a map." ]

                    ListMode ->
                        div [] (stationsList |> List.map Station.getNameFi |> List.map text)
        ]


viewResultsModeSelector : ResultsMode -> Html msg
viewResultsModeSelector resultsMode =
    case resultsMode of
        MapMode ->
            div [] [ text "Here you could see that the map mode is active." ]

        ListMode ->
            div [] [ text "Here you could see that the list mode is active." ]
