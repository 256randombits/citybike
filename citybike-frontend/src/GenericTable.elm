module GenericTable exposing (view)

import Html exposing (Html, div, table, tbody, td, text, tfoot, th, thead, tr)
import Html.Attributes exposing (class)


view : List ( String, value -> String ) -> List value -> Html msg
view headersToValues values =
    let
        headerCell : String -> Html msg
        headerCell x =
            th [ class "border-separate border-seperate border-spacing-2 border border-slate-400 p-2" ]
                [ text x ]

        dataCell : String -> Html msg
        dataCell x =
            td [ class "border-seperate border-spacing-2 border border-slate-400 p-2" ]
                [ text x ]

        headers : List (Html msg)
        headers =
            List.map (\( header, _ ) -> headerCell header) headersToValues

        toHeaderValueFunctions : List (value -> String)
        toHeaderValueFunctions =
            List.map (\( _, toString ) -> toString) headersToValues

        oneRow : value -> List String
        oneRow oneValue =
            List.map (\f -> f oneValue) toHeaderValueFunctions

        valueInATable : value -> List (Html msg)
        valueInATable value =
            List.map dataCell (oneRow value)

        allTheRows : List (List (Html msg))
        allTheRows =
            List.map valueInATable values

        valuesUnderHeader : List (Html msg)
        valuesUnderHeader =
            List.map (tr []) allTheRows
    in
    table [ class "bg-red-100 grow table-fixed border-seperate border-spacing-2 border border-slate-400" ]
        [ thead []
            [ div [] [ text "where am I" ]
            , tr []
                headers
            ]
        , tfoot [] [ text "where am I" ]
        , tbody [] valuesUnderHeader
        ]
