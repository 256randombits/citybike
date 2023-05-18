module Station exposing (Station, StationQuery, createStation, decoder, emptyQuery, getAddressFi, getAddressSv, getCapacity, getCityFi, getCitySv, getId, getNameEn, getNameFi, getNameSv, getOperator, getX, getY)

import Json.Decode exposing (Decoder, float, int, string)
import Json.Decode.Pipeline exposing (required)


type Station
    = Station
        { id : Int
        , nameFi : String
        , nameSv : String
        , nameEn : String
        , addressFi : String
        , addressSv : String
        , cityFi : String
        , citySv : String
        , operator : String
        , capacity : Int
        , x : Float
        , y : Float
        }


createStation : Int -> String -> String -> String -> String -> String -> String -> String -> String -> Int -> Float -> Float -> Station
createStation id nameFi nameSv nameEn addressFi addressSv cityFi citySv operator capacity x y =
    Station
        { id = id
        , nameFi = nameFi
        , nameSv = nameSv
        , nameEn = nameEn
        , addressFi = addressFi
        , addressSv = addressSv
        , cityFi = cityFi
        , citySv = citySv
        , operator = operator
        , capacity = capacity
        , x = x
        , y = y
        }


decoder : Decoder Station
decoder =
    Json.Decode.succeed createStation
        |> required "id" int
        |> required "name_fi" string
        |> required "name_sv" string
        |> required "name_en" string
        |> required "address_fi" string
        |> required "address_sv" string
        |> required "city_fi" string
        |> required "city_sv" string
        |> required "operator" string
        |> required "capacity" int
        |> required "x" float
        |> required "y" float



-- encoder : Station -> Encode.Value
-- encoder station =
--     Encode.object
--         [ ( "id", getId station |> Encode.int )
--         , ( "name_fi", getNameFi station |> Encode.string )
--         , ( "name_fi", getNameFi station |> Encode.string )
--          TODO...
--         ]


getId : Station -> Int
getId (Station values) =
    values.id


getNameFi : Station -> String
getNameFi (Station values) =
    values.nameFi


getNameSv : Station -> String
getNameSv (Station values) =
    values.nameSv


getNameEn : Station -> String
getNameEn (Station values) =
    values.nameEn


getAddressFi : Station -> String
getAddressFi (Station values) =
    values.addressFi


getAddressSv : Station -> String
getAddressSv (Station values) =
    values.addressSv


getCityFi : Station -> String
getCityFi (Station values) =
    values.cityFi


getCitySv : Station -> String
getCitySv (Station values) =
    values.citySv


getOperator : Station -> String
getOperator (Station values) =
    values.operator


getCapacity : Station -> Int
getCapacity (Station values) =
    values.capacity


getX : Station -> Float
getX (Station values) =
    values.x


getY : Station -> Float
getY (Station values) =
    values.y



-- Querying


type alias StationQuery =
    { id : Maybe Int
    , nameFi : Maybe String
    , nameSv : Maybe String
    , nameEn : Maybe String
    , addressFi : Maybe String
    , addressSv : Maybe String
    , cityFi : Maybe String
    , citySv : Maybe String
    , operator : Maybe String
    , capacity : Maybe Int
    , x : Maybe Float
    , y : Maybe Float
    }


emptyQuery : { id : Maybe a, nameFi : Maybe b, nameSv : Maybe c, nameEn : Maybe d, addressFi : Maybe e, addressSv : Maybe f, cityFi : Maybe g, citySv : Maybe h, operator : Maybe i, capacity : Maybe j, x : Maybe k, y : Maybe l }
emptyQuery =
    { id = Nothing
    , nameFi = Nothing
    , nameSv = Nothing
    , nameEn = Nothing
    , addressFi = Nothing
    , addressSv = Nothing
    , cityFi = Nothing
    , citySv = Nothing
    , operator = Nothing
    , capacity = Nothing
    , x = Nothing
    , y = Nothing
    }
