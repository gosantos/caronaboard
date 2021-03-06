module Helpers exposing (..)

import Common.Response exposing (Response(..))
import Expect
import Groups.Model as Groups
import Login.Model exposing (Msg(..), User)
import Model exposing (Msg(..))
import NativeLoadFix
import Navigation exposing (Location)
import Ports exposing (subscriptions)
import Profile.Model exposing (Profile)
import Rides.Model as Rides exposing (NewRide)
import String.Extra
import TestContext exposing (..)
import Update
import UrlRouter.Model exposing (Msg(..))
import UrlRouter.Routes exposing (Page(..), toPath)
import View


initialContext : Maybe User -> Maybe Profile -> Page -> a -> TestContext Model.Model Model.Msg
initialContext currentUser profile page _ =
    Navigation.program (MsgForUrlRouter << UrlChange)
        { init = Update.init { currentUser = currentUser, profile = profile }
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        }
        |> start
        |> navigate (toPath page)


signedInContext : Page -> a -> TestContext Model.Model Model.Msg
signedInContext =
    initialContext someUser (Just fixtures.profile)


toLocation : Page -> Location
toLocation page =
    { href = "", host = "", hostname = "", protocol = "", origin = "", port_ = "", pathname = "", search = "", hash = toPath page, username = "", password = "" }


expectToContainText : String -> String -> Expect.Expectation
expectToContainText expected actual =
    Expect.true ("Expected\n\t" ++ actual ++ "\nto contain\n\t" ++ expected)
        (String.contains expected actual)


expectToNotContainText : String -> String -> Expect.Expectation
expectToNotContainText expected actual =
    Expect.false ("Expected\n\t" ++ actual ++ "\nto NOT contain\n\t" ++ expected)
        (String.contains expected actual)


someUser : Maybe User
someUser =
    Just fixtures.user


successSignIn : TestContext model Model.Msg -> TestContext model Model.Msg
successSignIn =
    update (Model.MsgForLogin <| SignInResponse (Success { user = fixtures.user, profile = Just fixtures.profile }))


successSignInWithoutProfile : TestContext model Model.Msg -> TestContext model Model.Msg
successSignInWithoutProfile =
    update (Model.MsgForLogin <| SignInResponse (Success { user = fixtures.user, profile = Nothing }))


jsonQuotes : String -> String
jsonQuotes =
    String.Extra.replace "'" "\""


expectCurrentPage : Page -> TestContext Model.Model msg -> Expect.Expectation
expectCurrentPage page =
    expectModel
        (\model ->
            Expect.equal page model.urlRouter.page
        )


fixtures : { rides : List Rides.Model, ride1 : Rides.Model, ride2 : Rides.Model, user : User, profile : Profile, newRide : NewRide, group1 : Groups.Group, group2 : Groups.Group, groups : List Groups.Group }
fixtures =
    let
        user =
            { id = "idUser1" }

        profile =
            { name = "fulano", contact = { kind = "Whatsapp", value = "passenger-wpp" } }

        ride1 =
            { id = "idRide1", groupId = "idGroup1", userId = "isUser1", origin = "bar", destination = "baz, near qux", days = "Mon to Fri", hours = "18:30", profile = { name = "foo", contact = { kind = "Whatsapp", value = "+5551" } } }

        ride2 =
            { id = "idRide2", groupId = "idGroup1", userId = "isUser2", origin = "lorem", destination = "ipsum", days = "sit", hours = "amet", profile = { name = "bar", contact = { kind = "Whatsapp", value = "wpp-for-idRide2" } } }

        newRide =
            { groupId = "idGroup1", origin = "bar", destination = "baz, near qux", days = "Mon to Fri", hours = "18:30" }

        group1 =
            { id = "idGroup1", name = "winona riders", members = [ { userId = "idUser1", admin = True } ], joinRequest = Empty, joinRequests = Empty }

        group2 =
            { id = "idGroup2", name = "the uber killars", members = [], joinRequest = Empty, joinRequests = Empty }

        groups =
            [ group1, group2 ]
    in
    { rides = [ ride1, ride2 ]
    , ride1 = ride1
    , ride2 = ride2
    , user = user
    , profile = profile
    , newRide = newRide
    , group1 = group1
    , group2 = group2
    , groups = groups
    }
