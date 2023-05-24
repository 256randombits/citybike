module Page.Home exposing (Model, Msg, init, update, view)

import Html exposing (..)



-- MODEL


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view _ =
    { title = "Citybike"
    , content = div [] [ text "HOME PAGE" ]
    }



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        NoOp ->
            ( {}, Cmd.none )
