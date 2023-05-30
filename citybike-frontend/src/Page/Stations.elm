module Page.Stations exposing (Model, Msg, init, toSession, update, view)

import Api
import Api.Endpoint as Endpoint
import GenericTable as Table
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Session exposing (Session)
import Station exposing (Station, emptyQuery)



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
    ( { session = session, results = Loading }, getStations )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "STATION"
    , content =
        div []
            [ h1 [] [ text "STATION PAGE" ]
            , div []
                [ viewResults model.results
                ]
            ]
    }


viewResults : Results -> Html Msg
viewResults results =
    case results of
        Loading ->
            div [] [ text "Loading stations..." ]

        Failure _ ->
            div [] [ text "Something went wrong." ]

        HasStations stationsList ->
            div [] [ viewStationsInAList stationsList ]


viewStationsInAList : List Station -> Html Msg
viewStationsInAList stationsList =
    let
        headersWithDecoders =
            [ ( "Name", Station.getNameFi )
            , ( "Address", Station.getAddressFi )
            , ( "City", Station.getCityFi )
            , ( "Operator", Station.getOperator )
            , ( "Operator", \x -> x |> Station.getCapacity |> String.fromInt )
            ]
    in
    Table.view headersWithDecoders stationsList



-- UPDATE


type Msg
    = GetStations
    | GotStations (Result Api.Error (List Station))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetStations ->
            ( { model | results = Loading }, getStations )

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
