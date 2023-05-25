module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html
import Page
import Page.Blank as Blank
import Page.Home as Home
import Page.NotFound as NotFound
import Page.QueryTool as QueryTool
import Page.Stations as Stations
import Route exposing (..)
import Session exposing (Session)
import Url exposing (Url)


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
    = NotFound Session
    | Redirect Session
    | Home Home.Model
    | Stations Stations.Model
    | QueryTool QueryTool.Model



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

        Just Route.Stations ->
            Stations.init session
                |> updateWith Stations GotStationMsg

        Just Route.QueryTool ->
            QueryTool.init session
                |> updateWith QueryTool GotQueryToolMsg


type Msg
    = ChangedUrl Url
    | RequestedUrl Browser.UrlRequest
    | GotHomeMsg Home.Msg
    | GotStationMsg Stations.Msg
    | GotQueryToolMsg QueryTool.Msg


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
                Stations station ->
                    Stations.update stationMsg station
                        |> updateWith Stations GotStationMsg

                _ ->
                    noChange

        GotQueryToolMsg queryToolMsg ->
            case model of
                QueryTool queryTool ->
                    QueryTool.update queryToolMsg queryTool
                        |> updateWith QueryTool GotQueryToolMsg

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

        Stations station ->
            Stations.toSession station

        QueryTool queryTool ->
            QueryTool.toSession queryTool


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

        Stations station ->
            viewPage GotStationMsg (Stations.view station)

        QueryTool queryTool ->
            viewPage GotQueryToolMsg (QueryTool.view queryTool)
