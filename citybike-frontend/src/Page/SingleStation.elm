module Page.SingleStation exposing (Model, Msg, init, toSession, update, view)

import Html exposing (..)
import Session exposing (Session)



-- MODEL


type alias Model =
    { session : Session, id : Int }


init : Session -> Int -> ( Model, Cmd Msg )
init session id =
    ( { session = session, id = id }, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view _ =
    { title = "Single"
    , content = div [] [ text "Single Station" ]
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
toSession model =
    model.session
