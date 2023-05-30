module Page.SingleStation exposing (Model, Msg, init, toSession, update, view)

import Api
import Api.Endpoint as Endpoint
import Html exposing (..)
import Http exposing (Error(..))
import Session exposing (Session)
import Citybike.Station as Station exposing (Station)



-- MODEL


type alias Model =
    { session : Session, id : Int, state : State }


init : Session -> Int -> ( Model, Cmd Msg )
init session id =
    ( { session = session, id = id, state = Loading }, getStation id )


type State
    = Loading
    | HasStation Station
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

                HasStation station ->
                    let
                        name =
                            Station.getNameFi station
                    in
                    text name

                Error err ->
                    text <| Api.showError err
            ]
    }



-- UPDATE


getStation : Int -> Cmd Msg
getStation id =
    Api.getSingular (Endpoint.station id) Station.decoder GotStation


type Msg
    = GotStation (Result Api.Error Station)


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
