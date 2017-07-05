module Integration.GiveRideSpec exposing (tests)

import Common.Response exposing (Response(..))
import Expect
import GiveRide.Model exposing (Msg(..))
import GiveRide.Ports
import Helpers exposing (expectToContainText, fixtures, initialContext, signedInContext, someUser, toLocation)
import Model as Root exposing (Model, Msg(..))
import Notifications.Model exposing (Msg(..))
import Test exposing (..)
import Test.Html.Events as Events exposing (Event(..))
import Test.Html.Query exposing (..)
import Test.Html.Selector exposing (..)
import TestContext exposing (..)
import UrlRouter.Routes exposing (Page(..), toPath)


tests : Test
tests =
    describe "gives a new ride" <|
        [ test "fill the fields correctly" <|
            fillNewRide
                >> expectView
                >> find [ id "origin" ]
                >> has [ attribute "value" "bar" ]
        , test "shows loading on submit" <|
            submitNewRide
                >> expectView
                >> find [ id "submitNewRide" ]
                >> has [ text "Carregando..." ]
        , test "sends request via giveRide port" <|
            submitNewRide
                >> expectCmd (Cmd.map MsgForGiveRide <| GiveRide.Ports.giveRide fixtures.newRide)
        , test "shows error when giveRide port returns an error" <|
            submitNewRide
                >> update (MsgForGiveRide <| GiveRideResponse (Error "Scientists just proved that undefined is indeed not a function"))
                >> expectView
                >> has [ text "not a function" ]
        , test "goes to enable notifications page on success" <|
            submitNewRide
                >> successResponse
                >> expectModel
                    (\model ->
                        Expect.equal EnableNotificationsPage model.urlRouter.page
                    )
        , test "goes to the groups page on success if notifications are already enabled" <|
            submitNewRide
                >> update (MsgForNotifications <| NotificationsResponse (Success True))
                >> successResponse
                >> expectModel
                    (\model ->
                        Expect.equal GroupsPage model.urlRouter.page
                    )
        , test "shows notification on success" <|
            submitNewRide
                >> successResponse
                >> expectView
                >> has [ text "Carona criada com sucesso!" ]
        , test "clear fields on success after returning to the form" <|
            submitNewRide
                >> successResponse
                >> navigate (toPath GiveRidePage)
                >> expectView
                >> find [ id "origin" ]
                >> has [ attribute "value" "" ]
        ]


ridesContext : a -> TestContext Model Root.Msg
ridesContext =
    signedInContext GiveRidePage


fillNewRide : a -> TestContext Model Root.Msg
fillNewRide =
    ridesContext
        >> simulate (find [ id "origin" ]) (Input fixtures.newRide.origin)
        >> simulate (find [ id "destination" ]) (Input fixtures.newRide.destination)
        >> simulate (find [ id "days" ]) (Input fixtures.newRide.days)
        >> simulate (find [ id "hours" ]) (Input fixtures.newRide.hours)


submitNewRide : a -> TestContext Model Root.Msg
submitNewRide =
    fillNewRide
        >> simulate (find [ tag "form" ]) Events.Submit


successResponse : TestContext Model Root.Msg -> TestContext Model Root.Msg
successResponse =
    update (MsgForGiveRide <| GiveRideResponse (Success True))
