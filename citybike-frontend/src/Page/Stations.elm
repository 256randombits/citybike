module Page.Stations exposing (Model, Msg, init, toSession, update, view)

import Api
import Api.Endpoint as Endpoint
import Html exposing (..)
import Json.Decode as Decode
import Session exposing (Session)
import Station exposing (Station, emptyQuery)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)



-- MODEL


type alias Model =
    { session : Session
    , results : Results
    }


type Results
    = Loading
    | HasStations (List Station)
    | Failure Api.Error


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session, results = Loading }, getStations)



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "STATION"
    , content =
        div []
            [ h1 [] [ text "STATION PAGE"]
            , div [] [
                viewResults model.results
              ]
            ]
    }

viewResults : Results -> Html Msg
viewResults results = case results of
  Loading ->
    div [] [text "Loading stations..."]
  Failure _ ->
    div [] [text "Something went wrong."]
  HasStations stationsList ->
    div [] [ viewStationsInAList stationsList ]

viewStationsInAList : List Station -> Html Msg
viewStationsInAList stationsList =
    let
        singleCell x =
            th [ class "border-separate border-seperate border-spacing-2 border border-slate-400 p-2" ]
                [ button [ class "hover:bg-blue-800" ] [ x ] ]
    in
    table [ class "bg-red-100 grow table-fixed border-seperate border-spacing-2 border border-slate-400" ]
        [ thead []
            [ tr []
                [ text "Name" |> singleCell
                , text "Address" |> singleCell 
                , text "City" |> singleCell
                , text "Operator" |> singleCell
                , text "Capacity" |> singleCell
                ]
            ]
        , tbody []
            (List.map viewStationInAList
                        stationsList
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

-- UPDATE


type Msg
    = GetStations
    | GotStations (Result Api.Error (List Station))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetStations ->
            ( { model | results = Loading }, getStations)

        GotStations result ->
            case result of
                Ok stations ->
                    ( { model | results = HasStations stations }, Cmd.none )

                Err err ->
                    ( { model | results = Failure err }, Cmd.none )

getStations : Cmd Msg
getStations =
  Api.get (Endpoint.stations emptyQuery) (Decode.list Station.decoder) GotStations 


toSession : Model -> Session
toSession model =
    model.session
