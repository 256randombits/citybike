module Page exposing (view)

import Browser exposing (Document)
import Html exposing (Html, a, div, nav, text)
import Html.Attributes exposing (class)
import Route


view : { title : String, content : Html msg } -> Document msg
view { title, content } =
    { title = title ++ " - Citybike"
    , body =
        [ viewHeader
        , content
        ]
    }


viewHeader : Html msg
viewHeader =
    let
        navBarLink route linkText =
            a [ class "rounded-lg px-3 py-2 text-slate-700 font-medium hover:bg-slate-100 hover:text-slate-900", Route.href route ]
                [ text linkText ]
    in
    nav [ class "flex sm:justify-center space-x-4" ]
        [ navBarLink Route.Home "Home"
        , navBarLink Route.Stations "Station"
        , navBarLink Route.QueryTool "QueryTool"
        ]
