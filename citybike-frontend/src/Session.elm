module Session exposing (Session, empty, getNavKey)

import Browser.Navigation as Nav
import Station exposing (Station)


type Session
    = Session { navKey : Nav.Key, stations : List Station }


empty : Nav.Key -> Session
empty navKey =
    Session { navKey = navKey, stations = [] }

getNavKey : Session -> Nav.Key
getNavKey (Session fields) = fields.navKey
