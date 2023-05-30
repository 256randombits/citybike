module Session exposing (Session, empty, getNavKey)

import Browser.Navigation as Nav


type Session
    = Session { navKey : Nav.Key }


empty : Nav.Key -> Session
empty navKey =
    Session { navKey = navKey }


getNavKey : Session -> Nav.Key
getNavKey (Session fields) =
    fields.navKey
