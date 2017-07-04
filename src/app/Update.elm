module Update exposing (init, update)

import GiveRide.Update as GiveRide
import Infix exposing ((<*>))
import Layout.Update as Layout
import Login.Model exposing (signedInUser)
import Login.Update as Login
import Model exposing (Flags, Model, Msg(..))
import Navigation exposing (Location)
import Notifications.Update as Notifications
import Profile.Update as Profile
import Return exposing (Return, mapCmd, return, singleton)
import Rides.Update as Rides
import UrlRouter.Model
import UrlRouter.Update as UrlRouter


init : Flags -> Location -> Return Msg Model
init { currentUser, profile } location =
    let
        initialModel =
            { urlRouter = UrlRouter.init location
            , login = Login.init currentUser
            , rides = Rides.init
            , layout = Layout.init
            , giveRide = GiveRide.init
            , notifications = Notifications.init
            , profile = Profile.init profile
            }
    in
    initialRouting location initialModel


update : Msg -> Model -> Return Msg Model
update msg model =
    singleton Model
        <*> mapCmd MsgForUrlRouter (UrlRouter.update msg model)
        <*> mapCmd MsgForLogin (Login.update msg model.login)
        <*> mapCmd MsgForRides (Rides.update msg model.rides)
        <*> mapCmd MsgForLayout (Layout.update msg model.layout)
        <*> mapCmd MsgForGiveRide (GiveRide.update (signedInUser model.login) msg model.giveRide)
        <*> mapCmd MsgForNotifications (Notifications.update msg model.notifications)
        <*> mapCmd MsgForProfile (Profile.update msg model.profile)


initialRouting : Location -> Model -> Return Msg Model
initialRouting location model =
    UrlRouter.update (MsgForUrlRouter <| UrlRouter.Model.UrlChange location) model
        |> Return.map (\urlRouter -> { model | urlRouter = urlRouter })
        |> mapCmd MsgForUrlRouter
