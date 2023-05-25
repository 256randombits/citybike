module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (div, text)
import Page
import Page.Home as Home
import Page.Station as Station
import Route exposing (..)
import Session exposing (Session)
import Station exposing (Station)
import Url exposing (Url)
import Page.NotFound as NotFound
import Page.Blank as Blank


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = RequestedUrl
        , onUrlChange = ChangedUrl
        }



-- MODEL


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    changeRouteTo (Route.fromUrl url)
        (Redirect (Session.empty navKey))


type Model
    = Home Home.Model
    | NotFound Session
    | Station Station.Model
    | Redirect Session



-- UPDATE


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo route model =
    let
        session =
            toSession model
    in
    case route of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Home ->
            Home.init session
                |> updateWith Home GotHomeMsg

        Just Route.Station ->
            Station.init session
                |> updateWith Station GotStationMsg


type Msg
    = GotHomeMsg Home.Msg
    | GotStationMsg Station.Msg
    | ChangedUrl Url
    | RequestedUrl Browser.UrlRequest



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        noChange =
            ( model, Cmd.none )
    in
    case msg of
        RequestedUrl urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (Session.getNavKey (toSession model)) (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ChangedUrl url ->
            changeRouteTo (Route.fromUrl url) model


        GotHomeMsg homeMsg ->
            case model of
                Home home ->
                    Home.update homeMsg home
                        |> updateWith Home GotHomeMsg

                _ ->
                    noChange

        GotStationMsg stationMsg ->
          case model of
                Station station ->
                    Station.update stationMsg station
                        |> updateWith Station GotStationMsg

                _ ->
                    noChange


toSession : Model -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Home home ->
            Home.toSession home

        Station station ->
            Station.toSession station


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- View


view : Model -> Document Msg
view model =
    let
        viewPage toMsg subView =
            let
                { title, body } =
                    Page.view subView
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect _ ->
            Page.view Blank.view

        NotFound _ ->
            Page.view NotFound.view

        Home home ->
            viewPage GotHomeMsg (Home.view home)

        Station station ->
            viewPage GotStationMsg (Station.view station)
