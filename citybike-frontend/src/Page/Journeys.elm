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
        flip =
            \f x y -> f y x

        percision2 x =
            x * 100 |> floor |> toFloat |> flip (/) 100

        metersToKm meters =
            toFloat meters / 1000 |> percision2

        secondsToMinutes seconds =
            toFloat seconds / 60 |> percision2

        toDistance journey =
            journey |> Journey.getDistanceInMeters |> metersToKm |> String.fromFloat |> addTrail

        toDuration journey =
            journey |> Journey.getDurationInSeconds |> secondsToMinutes |> String.fromFloat |> addTrail

        addTrail str =
            case String.split "." str of
                -- Two parts when there is one '.'
                wholePart :: [ decimalPart ] ->
                    -- Ensure there are at least two trailing digits.
                    wholePart ++ "." ++ String.padRight 2 '0' decimalPart

                -- There was no '.' in the string
                [ wholePart ] ->
                    wholePart ++ ".00"

                -- Multiple '.'. Just return the string.
                _ ->
                    str

        headersWithDecoders =
            [ ( "Departure"
              , \x -> x |> Journey.getDepartureStation |> Station.getNameFi
              )
            , ( "Return"
              , \x -> x |> Journey.getReturnStation |> Station.getNameFi
              )
            , ( "Distance (km)", toDistance )

            -- , ( "Departure time"
            --   , Journey.getDepartureTime
            --   )
            -- , ( "Return time"
            --   , \x -> x |> Journey.getReturnTime |> niceTime
            --   )
            , ( "Duration (min)"
              , toDuration
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
