module Main exposing (main)

import Browser exposing (Document)
import Html exposing (Html, div, text)
import Page.Home as Home


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = \_ -> NoOp
        , onUrlChange = \_ -> NoOp
        }



-- MODEL


type alias Model =
    { page : Page
    }


type Page
    = Home Home.Model
    | NotFound


init _ url key =
    ( { page = NotFound }, Cmd.none )



-- VIEW


view : Model -> { title : String, body : List (Html Msg) }
view model =
    { title = "Citybike"
    , body =
        [ case model.page of
            _ ->
                div [] [ text "hmm" ]
        ]
    }



-- UPDATE


type Msg
    = NoOp
    | GotHomeMsg Home.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        _ ->
            ( { page = NotFound }, Cmd.none )
