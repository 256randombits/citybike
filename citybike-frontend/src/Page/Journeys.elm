module Page.Journeys exposing (Model, Msg, init, toSession, update, view)

import Api
import Api.Endpoint as Endpoint
import GenericTable as Table
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Journey exposing (Journey, emptyQuery)
import Json.Decode as Decode
import Session exposing (Session)
import Station



-- MODEL


type alias Model =
    { session : Session
    , results : Results
    }


type Results
    = Loading
    | HasJourneys (List Journey)
    | Failure Api.Error


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session, results = Loading }, getJourneys )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "JOURNEYS"
    , content =
        div []
            [ h1 [] [ text "JOURNEYS PAGE" ]
            , div []
                [ viewResults model.results
                ]
            ]
    }


viewResults : Results -> Html Msg
viewResults results =
    case results of
        Loading ->
            div [] [ text "Loading journeys..." ]

        Failure _ ->
            div [] [ text "Something went wrong." ]

        HasJourneys journeysList ->
            div [] [ viewJourneysInAList journeysList ]


viewJourneysInAList : List Journey -> Html Msg
viewJourneysInAList journeysList =
    let
        metersToKm meters =
            toFloat meters / 100

        headersWithDecoders =
            [ ( "Departure"
              , \x -> x |> Journey.getDepartureStation |> Station.getNameFi
              )
            , ( "Return"
              , \x -> x |> Journey.getReturnStation |> Station.getNameFi
              )
            , ( "Distance (km)"
              , \x -> x |> Journey.getDistanceInMeters |> metersToKm |> String.fromFloat
              )
            , ( "Departure time"
              , Journey.getDepartureTime
              )
            , ( "Return time"
              , Journey.getReturnTime
              )
            , ( "Duration (min)"
              , \x -> x |> Journey.getDurationInSeconds |> String.fromInt
              )
            ]
    in
    Table.view headersWithDecoders journeysList



-- UPDATE


type Msg
    = GetJourneys
    | GotJourneys (Result Api.Error (List Journey))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetJourneys ->
            ( { model | results = Loading }, getJourneys )

        GotJourneys result ->
            case result of
                Ok journeys ->
                    ( { model | results = HasJourneys journeys }, Cmd.none )

                Err err ->
                    ( { model | results = Failure err }, Cmd.none )


getJourneys : Cmd Msg
getJourneys =
    Api.get (Endpoint.journeys emptyQuery) (Decode.list Journey.decoder) GotJourneys


toSession : Model -> Session
toSession model =
    model.session
