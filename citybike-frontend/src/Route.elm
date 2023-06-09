module Route exposing (Route(..), fromUrl, href, parser, replaceUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, int, oneOf, s)


type Route
    = Home
    | SingleStation Int
    | Stations
    | Journeys


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map SingleStation (s "stations" </> int)
        , Parser.map Stations (s "stations")
        , Parser.map Journeys (s "journeys")
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    url |> Parser.parse parser


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)



-- INTERNAL


routeToString : Route -> String
routeToString page =
    "/" ++ String.join "/" (routeToPieces page)


routeToPieces : Route -> List String
routeToPieces page =
    case page of
        Home ->
            []

        SingleStation id ->
            [ "stations", String.fromInt id ]

        Stations ->
            [ "stations" ]

        Journeys ->
            [ "journeys" ]
