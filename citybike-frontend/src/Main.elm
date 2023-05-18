module Main exposing (main)

import Api
import Api.Endpoint as Endpoint
import Browser
import Html exposing (Html, button, div, p, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Station exposing (..)



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


type StationSortBy
    = NameFi
    | AddressFi
    | CityFi
    | Operator
    | Capacity
    | NoSort


type alias JourneyQuery =
    { id : Maybe Int
    }


type Results
    = HasNothing
    | Loading
    | Failure Api.Error
    | HasStations (List Station) StationSortBy
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
    , stationQuery = emptyQuery
    , journeyQuery = { id = Nothing }
    , results = HasNothing
    }



-- UPDATE


type Msg
    = GetStations StationQuery
    | GotStations (Result Api.Error (List Station))
    | SetStationSortBy StationSortBy
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetStations _->
            ( { model | results = Loading }, Api.get (Endpoint.stations []) (Decode.list Station.decoder) GotStations )

        GotStations result ->
            case result of
                Ok stations ->
                    ( { model | results = HasStations stations NoSort }, Cmd.none )

                Err err ->
                    ( { model | results = Failure err }, Cmd.none )

        SetStationSortBy sortBy ->
            case model.results of
                HasStations stations _ ->
                    ( { model | results = HasStations stations sortBy }, Cmd.none )

                -- Maybe sorting should be put on the root level of
                -- the model so it would be remembered and this branch would not
                -- need to be here.
                _ ->
                    ( model, Cmd.none )

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
viewJourneyQueryEditor _=
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


viewResultsViewer : ResultsMode -> Results -> Html Msg
viewResultsViewer resultsMode results =
    div [ class "flex flex-col grow bg-red-900 overflow-scroll" ]
        [ viewResultsModeSelector resultsMode
        , viewResults resultsMode results
        ]


viewResults : ResultsMode -> Results -> Html Msg
viewResults resultsMode results =
    div [ class "flex grow p-4" ]
        [ case results of
            Failure err ->
                div [] [ text (Api.showError err) ]

            Loading ->
                div [] [ text "Here you could see the results loading." ]

            HasNothing ->
                div [] [ text "Here you could see nothing." ]

            HasJourneys _ ->
                div [] [ text "Here you could see journeys on a map." ]

            HasStations stationsList stationsSortBy ->
                case resultsMode of
                    MapMode ->
                        div [] [ text "Here you could see stations on a map." ]

                    ListMode ->
                        div [ class "flex grow" ] [ viewStationsInAList stationsList stationsSortBy ]
        ]


viewStationsInAList : List Station -> StationSortBy -> Html Msg
viewStationsInAList stationsList sortBy =
    let
        singleCell whenClicked x =
            th [ class "border-separate border-seperate border-spacing-2 border border-slate-400 p-2" ] [ button [ class "hover:bg-blue-800", onClick whenClicked ] [ x ] ]
    in
    table [ class "bg-red-100 grow table-fixed border-seperate border-spacing-2 border border-slate-400" ]
        [ thead []
            [ tr []
                [ text "Name" |> singleCell (SetStationSortBy NameFi)
                , text "Address" |> singleCell (SetStationSortBy AddressFi)
                , text "City" |> singleCell (SetStationSortBy CityFi)
                , text "Operator" |> singleCell (SetStationSortBy Operator)
                , text "Capacity" |> singleCell (SetStationSortBy Capacity)
                ]
            ]
        , tbody []
            (List.map viewStationInAList
                (case sortBy of
                    NoSort ->
                        stationsList

                    Capacity ->
                        List.sortBy Station.getCapacity stationsList

                    NameFi ->
                        List.sortBy Station.getNameFi stationsList

                    AddressFi ->
                        List.sortBy Station.getAddressFi stationsList

                    CityFi ->
                        List.sortBy Station.getCityFi stationsList

                    Operator ->
                        List.sortBy Station.getOperator stationsList
                )
            )
        ]


viewStationInAList : Station -> Html Msg
viewStationInAList station =
    let
        singleCell x =
            td [ class "border-seperate border-spacing-2 border border-slate-400 p-2" ] [ x ]
    in
    tr []
        [ station |> Station.getNameFi |> text |> singleCell
        , station |> Station.getAddressFi |> text |> singleCell
        , station |> Station.getCityFi |> text |> singleCell
        , station |> Station.getOperator |> text |> singleCell
        , station |> Station.getCapacity |> String.fromInt |> text |> singleCell
        ]


viewResultsModeSelector : ResultsMode -> Html msg
viewResultsModeSelector resultsMode =
    case resultsMode of
        MapMode ->
            div [] [ text "Here you could see that the map mode is active." ]

        ListMode ->
            div [] [ text "Here you could see that the list mode is active." ]
