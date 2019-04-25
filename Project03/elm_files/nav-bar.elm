module NavBar exposing (main)

import Bootstrap.Navbar as Nav
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Button as Button
import Browser as Browser
import Json.Decode as Decode
import Http
import Html exposing (..)
import Html.Attributes exposing (..)

main = Browser.element {
  init = init,
  update = update,
  view = view,
  subscriptions = subs
  }

type alias Model = {
  userName : String,
  navBarState : Nav.State,
  error : String
  }

type Msg = NoOp
         | NavMsg Nav.State

type alias Flag = {
  authorized : Bool,
  userName : String
  }

init : Flag -> (Model, Cmd Msg)
init flag =
  let
    (navState, navCmd) = Nav.initialState NavMsg
  in
  if flag.authorized then
      (Model flag.userName navState "", navCmd)
  else
      (Model "" navState "", navCmd)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            (model, Cmd.none)
        NavMsg state ->
          ({model | navBarState = state}, Cmd.none)

view : Model -> Html Msg
view model =
  Grid.container [] [
    Nav.config NavMsg
    |> Nav.withAnimation
    |> Nav.collapseMedium
    |> Nav.fixTop
    |> Nav.brand [] [text "test Brand"]
    |> Nav.items [
      Nav.itemLink [ href "/e/alkersho/forum/" ] [text "Forum"]
    ]
    |> Nav.customItems [
      Nav.formItem [] <| loginButton model
    ]
    |> Nav.view model.navBarState
  ]


subs : Model -> Sub Msg
subs model =
     Nav.subscriptions model.navBarState NavMsg

loginButton : Model -> List (Html Msg)
loginButton model =
    if model.userName == "" then
      [Button.linkButton [ Button.attrs [ href "/e/alkersho/account/login/" ] ] [ text "Login!"]]
    else
      [
      Button.linkButton [ Button.attrs [ href "/e/alkersho/account/" ]] [ text <| "Hello," ++ model.userName],
      Button.linkButton [ Button.attrs [ href "/e/alkersho/account/logout/" ]] [text "Logout"]
      ]

errorHandler : Model -> Http.Error -> Model
errorHandler model error =
    case error of
        Http.BadUrl url ->
            { model | error = "bad url: " ++ url }

        Http.Timeout ->
            { model | error = "timeout" }

        Http.NetworkError ->
            { model | error = "network error" }

        Http.BadStatus i ->
            { model | error = "bad status " ++ String.fromInt i }

        Http.BadBody body ->
            { model | error = "bad body " ++ body }
