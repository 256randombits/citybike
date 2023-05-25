module Page.Station exposing (Model, Msg, init, toSession, update, view)

import Browser.Navigation as Nav
import Html exposing (..)
import Session exposing (Session)



-- MODEL


type alias Model =
    -- TODO: Home does not actually use session?
    { session : Session }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view _ =
    { title = "STATION"
    , content = div [] [ text "STATION PAGE" ]
    }



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

toSession : Model -> Session
toSession model = model.session
