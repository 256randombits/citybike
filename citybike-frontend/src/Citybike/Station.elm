module Citybike.Station exposing
    ( AddressFi(..)
    , AddressSv(..)
    , Capacity(..)
    , CityFi(..)
    , CitySv(..)
    , Id(..)
    , Latitude(..)
    , Longitude(..)
    , NameEn(..)
    , NameFi(..)
    , NameSv(..)
    , Operator(..)
    , Station
    , StationQuery
    , createStation
    , decoder
    , emptyQuery
    , getAddressFi
    , getAddressSv
    , getCapacity
    , getCityFi
    , getCitySv
    , getId
    , getNameEn
    , getNameFi
    , getNameSv
    , getOperator
    , getX
    , getY
    , stationQueryValidator
    , unwrapAddressFi
    , unwrapAddressSv
    , unwrapCapacity
    , unwrapCityFi
    , unwrapCitySv
    , unwrapId
    , unwrapLatitude
    , unwrapLongitude
    , unwrapNameEn
    , unwrapNameFi
    , unwrapNameSv
    , unwrapOperator
    , validateAddressFi
    , validateAddressSv
    , validateCapacity
    , validateCityFi
    , validateCitySv
    , validateId
    , validateLatitude
    , validateLongitude
    , validateNameEn
    , validateNameFi
    , validateNameSv
    , validateOperator
    )

import Json.Decode exposing (Decoder, float, int, string)
import Json.Decode.Pipeline exposing (required)
import Validate exposing (Validator, fromErrors, ifNotInt, ifTrue, validate)


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
        , longitude : Float
        , latitude : Float
        }


createStation : Int -> String -> String -> String -> String -> String -> String -> String -> String -> Int -> Float -> Float -> Station
createStation id nameFi nameSv nameEn addressFi addressSv cityFi citySv operator capacity longitude latitude =
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
        , longitude = longitude
        , latitude = latitude
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
        |> required "longitude" float
        |> required "latitude" float



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
    values.longitude


getY : Station -> Float
getY (Station values) =
    values.latitude


type alias StationQuery =
    { maybeId : Maybe Id
    , maybeNameFi : Maybe NameFi
    , maybeNameSv : Maybe NameSv
    , maybeNameEn : Maybe NameEn
    , maybeAddressFi : Maybe AddressFi
    , maybeAddressSv : Maybe AddressSv
    , maybeCityFi : Maybe CityFi
    , maybeCitySv : Maybe CitySv
    , maybeOperator : Maybe Operator
    , maybeCapacity : Maybe Capacity
    , maybeLongitude : Maybe Longitude
    , maybeLatitude : Maybe Latitude
    , offset : Int
    , limit : Int
    }


emptyQuery : StationQuery
emptyQuery =
    { maybeId = Nothing
    , maybeNameFi = Nothing
    , maybeNameSv = Nothing
    , maybeNameEn = Nothing
    , maybeAddressFi = Nothing
    , maybeAddressSv = Nothing
    , maybeCityFi = Nothing
    , maybeCitySv = Nothing
    , maybeOperator = Nothing
    , maybeCapacity = Nothing
    , maybeLongitude = Nothing
    , maybeLatitude = Nothing
    , offset = 0
    , limit = 15
    }


stationQueryToErrors : StationQuery -> List String
stationQueryToErrors stationQuery =
    let
        fieldErrors : (StationQuery -> Maybe a) -> Validator error a -> List error
        fieldErrors toMaybeField fieldValidator =
            case toMaybeField stationQuery of
                Nothing ->
                    []

                Just field ->
                    case validate fieldValidator field of
                        Ok _ ->
                            []

                        Err errorsList ->
                            errorsList
    in
    fieldErrors .maybeId validateId
        ++ fieldErrors .maybeNameFi validateNameFi
        ++ fieldErrors .maybeNameSv validateNameSv
        ++ fieldErrors .maybeNameEn validateNameEn
        ++ fieldErrors .maybeAddressFi validateAddressFi
        ++ fieldErrors .maybeAddressSv validateAddressSv
        ++ fieldErrors .maybeCityFi validateCityFi
        ++ fieldErrors .maybeCitySv validateCitySv
        ++ fieldErrors .maybeOperator validateOperator
        ++ fieldErrors .maybeCapacity validateCapacity
        ++ fieldErrors .maybeLongitude validateLongitude
        ++ fieldErrors .maybeLatitude validateLatitude


stationQueryValidator : Validator String StationQuery
stationQueryValidator =
    fromErrors stationQueryToErrors


type Id
    = Id String


unwrapId : Id -> String
unwrapId (Id internal) =
    internal


validateId : Validator String Id
validateId =
    Validate.all
        [ ifNotInt
            unwrapId
            (\_ -> "Id needs to be an integer!")
        ]



-- NameFi


type NameFi
    = NameFi String


unwrapNameFi : NameFi -> String
unwrapNameFi (NameFi internal) =
    internal


validateNameFi : Validator String NameFi
validateNameFi =
    Validate.all
        [ ifTrue
            (\nameFi -> unwrapNameFi nameFi |> String.startsWith " ")
            "Name can not start with a space!"
        ]



-- NameSv


type NameSv
    = NameSv String


unwrapNameSv : NameSv -> String
unwrapNameSv (NameSv internal) =
    internal


validateNameSv : Validator String NameSv
validateNameSv =
    Validate.all []



-- NameEn


type NameEn
    = NameEn String


unwrapNameEn : NameEn -> String
unwrapNameEn (NameEn internal) =
    internal


validateNameEn : Validator String NameEn
validateNameEn =
    Validate.all []



-- AddressFi


type AddressFi
    = AddressFi String


unwrapAddressFi : AddressFi -> String
unwrapAddressFi (AddressFi internal) =
    internal


validateAddressFi : Validator String AddressFi
validateAddressFi =
    Validate.all
        [ ifTrue
            (\addressFi -> unwrapAddressFi addressFi |> String.startsWith " ")
            "Address can not start with a space!"
        ]



-- AddressSv


type AddressSv
    = AddressSv String


unwrapAddressSv : AddressSv -> String
unwrapAddressSv (AddressSv internal) =
    internal


validateAddressSv : Validator String AddressSv
validateAddressSv =
    Validate.all []



-- CityFi


type CityFi
    = CityFi String


unwrapCityFi : CityFi -> String
unwrapCityFi (CityFi internal) =
    internal


validateCityFi : Validator String CityFi
validateCityFi =
    Validate.all
        [ ifTrue
            (\cityFi -> unwrapCityFi cityFi |> String.startsWith " ")
            "City can not start with a space!"
        ]



-- CitySv


type CitySv
    = CitySv String


unwrapCitySv : CitySv -> String
unwrapCitySv (CitySv internal) =
    internal


validateCitySv : Validator String CitySv
validateCitySv =
    Validate.all []



-- Operator


type Operator
    = Operator String


unwrapOperator : Operator -> String
unwrapOperator (Operator internal) =
    internal


validateOperator : Validator String Operator
validateOperator =
    Validate.all []



-- Capacity


type Capacity
    = Capacity String


unwrapCapacity : Capacity -> String
unwrapCapacity (Capacity internal) =
    internal


validateCapacity : Validator String Capacity
validateCapacity =
    Validate.all
        [ ifNotInt
            unwrapCapacity
            (\_ -> "Capacity needs to be an integer!")
        ]



-- Longitude


type Longitude
    = Longitude String


unwrapLongitude : Longitude -> String
unwrapLongitude (Longitude internal) =
    internal


validateLongitude : Validator String Longitude
validateLongitude =
    Validate.all []



-- Latitude


type Latitude
    = Latitude String


unwrapLatitude : Latitude -> String
unwrapLatitude (Latitude internal) =
    internal


validateLatitude : Validator String Latitude
validateLatitude =
    Validate.all []
