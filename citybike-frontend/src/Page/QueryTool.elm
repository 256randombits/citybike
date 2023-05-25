module Page.QueryTool exposing (Model, Msg, init, toSession, update, view)

import Api
import Api.Endpoint as Endpoint
import Html exposing (Html, button, div, input, p, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Journey exposing (Journey, JourneyQuery)
import Json.Decode as Decode
import Session exposing (Session)
import Station exposing (..)
import Validate exposing (validate)



-- MODEL


type alias Model =
    { queryMode : QueryMode
    , stationQuery : StationQuery
    , journeyQuery : JourneyQuery
    , resultsMode : ResultsMode
    , results : Results
    , session : Session
    }


type StationSortBy
    = NameFiAsc
    | AddressFiAsc
    | CityFiAsc
    | OperatorAsc
    | CapacityAsc
    | NoSortAsc


type Results
    = HasNothing
    | LoadingStations StationQuery
    | LoadingJourneys JourneyQuery
    | Failure Api.Error
    | HasStations (List Station) StationSortBy StationQuery
    | HasJourneys (List Journey)


type ResultsMode
    = MapMode
    | ListMode


type QueryMode
    = JourneyMode
    | StationMode


init : Session -> ( Model, Cmd Msg )
init session =
    ( { queryMode = StationMode
      , resultsMode = ListMode
      , stationQuery = emptyQuery
      , journeyQuery = { id = Nothing }
      , results = HasNothing
      , session = session
      }
    , Cmd.none
    )



-- UPDATE


type
    Msg
    -- Station
    = GetStations StationQuery
    | LoadMoreStations
    | GotStations (Result Api.Error (List Station))
    | GotMoreStations (Result Api.Error (List Station))
    | SetStationSortBy StationSortBy
    | UpdateStationQuery StationQuery
      -- Journey
    | GetJourneys JourneyQuery
    | GotJourneys (Result Api.Error (List Journey))
      --QueryTool
    | SetQueryToolToStationMode
    | SetQueryToolToJourneyMode
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetStations executedQuery ->
            ( { model | results = LoadingStations executedQuery }, Api.get (Endpoint.stations model.stationQuery) (Decode.list Station.decoder) GotStations )

        LoadMoreStations ->
            case model.results of
                HasStations stations sortBy executedQuery ->
                    let
                        newQuery =
                            { executedQuery | offset = executedQuery.limit + executedQuery.offset }
                    in
                    ( { model | results = HasStations stations sortBy newQuery }
                    , Api.get (Endpoint.stations newQuery) (Decode.list Station.decoder) GotMoreStations
                    )

                -- TODO: Figure out if the model should be changed.
                _ ->
                    ( model, Cmd.none )

        GotStations result ->
            case model.results of
                LoadingStations executedQuery ->
                    case result of
                        Ok stations ->
                            ( { model | results = HasStations stations NoSortAsc executedQuery }, Cmd.none )

                        Err err ->
                            ( { model | results = Failure err }, Cmd.none )

                -- User changed something before the results came.
                _ ->
                    ( model, Cmd.none )

        GotMoreStations result ->
            case model.results of
                HasStations oldStations sortBy executedQuery ->
                    case result of
                        Ok newStations ->
                            ( { model | results = HasStations (oldStations ++ newStations) sortBy executedQuery }, Cmd.none )

                        Err err ->
                            ( { model | results = Failure err }, Cmd.none )

                -- User changed something before the results came.
                _ ->
                    ( model, Cmd.none )

        SetStationSortBy sortBy ->
            case model.results of
                HasStations stations _ executedQuery ->
                    ( { model | results = HasStations stations sortBy executedQuery }, Cmd.none )

                -- Maybe sorting should be put on the root level of
                -- the model so it would be remembered and this branch would not
                -- need to be here.
                _ ->
                    ( model, Cmd.none )

        UpdateStationQuery newQuery ->
            ( { model | stationQuery = newQuery }, Cmd.none )

        SetQueryToolToStationMode ->
            ( { model | queryMode = StationMode }, Cmd.none )

        SetQueryToolToJourneyMode ->
            ( { model | queryMode = JourneyMode }, Cmd.none )

        -- Journey
        GetJourneys executedQuery ->
            ( { model | results = LoadingJourneys executedQuery }, Api.get (Endpoint.journeys executedQuery) (Decode.list Journey.decoder) GotJourneys )

        GotJourneys result ->
            case model.results of
                LoadingJourneys _ ->
                    case result of
                        Ok journeys ->
                            ( { model | results = HasJourneys journeys }, Cmd.none )

                        Err err ->
                            ( { model | results = Failure err }, Cmd.none )

                -- User changed something before the results came.
                _ ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Query Tool"
    , content =
        div [ class "flex flex-col gap-4 h-screen p-4 bg-gray-900 text-black" ]
            [ viewQueryTool model.queryMode model.stationQuery model.journeyQuery
            , viewResultsViewer model.resultsMode model.results
            ]
    }


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
    div []
        [ input [ type_ "text", placeholder "placeholder", value "", onInput (\_ -> NoOp) ] []
        , button [ onClick (GetJourneys journeyQuery), class "col-span-3" ] [ text "hh" ]
        ]


viewStationQueryEditor : StationQuery -> Html Msg
viewStationQueryEditor stationQuery =
    let
        viewField : String -> Maybe a -> (a -> String) -> (String -> msg) -> Validate.Validator String a -> Html msg
        viewField ph val unwrap toMsg validator =
            let
                viewErrors =
                    case val of
                        Nothing ->
                            []

                        Just nonEmptyVal ->
                            case validate validator nonEmptyVal of
                                Ok _ ->
                                    []

                                Err errors ->
                                    List.map text errors

                viewInput =
                    input
                        [ type_ "text"
                        , placeholder ph
                        , value (Maybe.withDefault "" <| Maybe.map unwrap val)
                        , onInput toMsg
                        ]
                        []
            in
            div []
                [ viewInput
                , p [ class "text-red-900" ] viewErrors
                ]

        emptyStringToNothing : (String -> a) -> String -> Maybe a
        emptyStringToNothing constructor str =
            if str == "" then
                Nothing

            else
                Just (constructor str)
    in
    div [ class "grid grid-cols-3 m-4" ]
        [ button [ onClick (GetStations stationQuery), class "col-span-3" ] [ text "hh" ]
        , viewField
            "id"
            stationQuery.maybeId
            unwrapId
            (\newId -> UpdateStationQuery { stationQuery | maybeId = emptyStringToNothing Id newId })
            validateId
        , viewField
            "name_fi"
            stationQuery.maybeNameFi
            unwrapNameFi
            (\newNameFi -> UpdateStationQuery { stationQuery | maybeNameFi = emptyStringToNothing NameFi newNameFi })
            validateNameFi
        , viewField
            "address_fi"
            stationQuery.maybeAddressFi
            unwrapAddressFi
            (\newAddressFi -> UpdateStationQuery { stationQuery | maybeAddressFi = emptyStringToNothing AddressFi newAddressFi })
            validateAddressFi
        , viewField
            "city_fi"
            stationQuery.maybeCityFi
            unwrapCityFi
            (\newCityFi -> UpdateStationQuery { stationQuery | maybeCityFi = emptyStringToNothing CityFi newCityFi })
            validateCityFi
        , viewField
            "operator"
            stationQuery.maybeOperator
            unwrapOperator
            (\newOperator -> UpdateStationQuery { stationQuery | maybeOperator = emptyStringToNothing Operator newOperator })
            validateOperator
        , viewField
            "capacity"
            stationQuery.maybeCapacity
            unwrapCapacity
            (\newCapacity -> UpdateStationQuery { stationQuery | maybeCapacity = emptyStringToNothing Capacity newCapacity })
            validateCapacity
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
            , button [ onClick SetQueryToolToJourneyMode, class "col-span-3" ] [ text "SET TO JourneyMode" ]
            , button [ onClick SetQueryToolToStationMode, class "col-span-3" ] [ text "SET TO StationMode" ]
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
    div [ class "flex grow p-4 m-4" ]
        [ case results of
            Failure err ->
                div [] [ text (Api.showError err) ]

            LoadingStations _ ->
                div [] [ text "Here you could see the results loading." ]

            HasNothing ->
                div [] [ text "Here you could see nothing." ]

            HasJourneys journeysList ->
                case resultsMode of
                    MapMode ->
                        div [] [ text "Here you could see journeys on a map." ]

                    ListMode ->
                        div [ class "flex flex-col grow" ]
                            [ viewJourneysInAList journeysList OperatorAsc
                            , button [ onClick LoadMoreStations ] [ text "Load More" ]
                            ]

            LoadingJourneys _ ->
                div [] [ text "Here you could see the results loading." ]

            HasStations stationsList stationsSortBy _ ->
                case resultsMode of
                    MapMode ->
                        div [] [ text "Here you could see stations on a map." ]

                    ListMode ->
                        div [ class "flex flex-col grow" ]
                            [ viewStationsInAList stationsList stationsSortBy
                            , button [ onClick LoadMoreStations ] [ text "Load More" ]
                            ]
        ]


viewJourneysInAList : List Journey -> StationSortBy -> Html Msg
viewJourneysInAList journeysList _ =
    let
        singleCell whenClicked x =
            th [ class "border-separate border-seperate border-spacing-2 border border-slate-400 p-2" ] [ button [ class "hover:bg-blue-800", onClick whenClicked ] [ x ] ]
    in
    table [ class "bg-red-100 grow table-fixed border-seperate border-spacing-2 border border-slate-400" ]
        [ thead []
            [ tr []
                [ text "Departure Station" |> singleCell (SetStationSortBy NameFiAsc)
                , text "Return Station" |> singleCell (SetStationSortBy AddressFiAsc)
                , text "Covered distance(km)" |> singleCell (SetStationSortBy CityFiAsc)
                , text "Duration(min)" |> singleCell (SetStationSortBy OperatorAsc)
                ]
            ]
        , tbody []
            (List.map viewJourneyInAList journeysList)
        ]


viewJourneyInAList : Journey -> Html Msg
viewJourneyInAList journey =
    let
        singleCell x =
            td [ class "border-seperate border-spacing-2 border border-slate-400 p-2" ] [ x ]

        precision2 x =
            x * 100 |> floor |> toFloat |> (\y -> y / 100)
    in
    tr []
        [ journey |> Journey.getDepartureStation |> Station.getNameFi |> text |> singleCell
        , journey |> Journey.getReturnStation |> Station.getNameFi |> text |> singleCell
        , journey |> Journey.getDistanceInMeters |> toFloat |> (\x -> x / 1000) |> String.fromFloat |> text |> singleCell
        , journey |> Journey.getDurationInSeconds |> toFloat |> (\x -> x / 60) |> precision2 |> String.fromFloat |> text |> singleCell
        ]


viewStationsInAList : List Station -> StationSortBy -> Html Msg
viewStationsInAList stationsList sortBy =
    let
        singleCell whenClicked x =
            th [ class "border-separate border-seperate border-spacing-2 border border-slate-400 p-2" ]
                [ button [ class "hover:bg-blue-800", onClick whenClicked ] [ x ] ]
    in
    table [ class "bg-red-100 grow table-fixed border-seperate border-spacing-2 border border-slate-400" ]
        [ thead []
            [ tr []
                [ text "Name" |> singleCell (SetStationSortBy NameFiAsc)
                , text "Address" |> singleCell (SetStationSortBy AddressFiAsc)
                , text "City" |> singleCell (SetStationSortBy CityFiAsc)
                , text "Operator" |> singleCell (SetStationSortBy OperatorAsc)
                , text "Capacity" |> singleCell (SetStationSortBy CapacityAsc)
                ]
            ]
        , tbody []
            (List.map viewStationInAList
                (case sortBy of
                    NoSortAsc ->
                        stationsList

                    CapacityAsc ->
                        List.sortBy Station.getCapacity stationsList

                    NameFiAsc ->
                        List.sortBy Station.getNameFi stationsList

                    AddressFiAsc ->
                        List.sortBy Station.getAddressFi stationsList

                    CityFiAsc ->
                        List.sortBy Station.getCityFi stationsList

                    OperatorAsc ->
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


toSession : Model -> Session
toSession model =
    model.session
