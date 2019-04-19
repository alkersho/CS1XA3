module NavBar exposing (main)

import Bootstrap.Navbar as Nav
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Button as Button
import Browser as Browser
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
  navBarState : Nav.State
  }

type Msg = NoOp
         | NavMsg Nav.State


type alias Flag = {
  authorized : Bool,
  userName : String
  }

init : () -> (Model, Cmd Msg)
init _ =
  let
    (navState, navCmd) = Nav.initialState NavMsg
  in
  -- if flag.authorized then
  --     (Model flag.userName navState, navCmd)
  -- else
      (Model "" navState, navCmd)

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
    CDN.stylesheet,
    Nav.config NavMsg
    |> Nav.withAnimation
    |> Nav.collapseMedium
    |> Nav.fixTop
    |> Nav.brand [] [text "test Brand"]
    |> Nav.items [
      Nav.itemLink [ href "#" ] [text "Forum"],
      Nav.itemLink [ href "#" ] [text ""],
      Nav.dropdown {
        id = "classesDropDown"
        , toggle = Nav.dropdownToggle [] [text "Classes"]
        , items = [
            Nav.dropdownHeader [text "Classes"],
            Nav.dropdownItem [ href "#"] [text "Class 1"],
            Nav.dropdownItem [ href "#"] [text "Class 3"],
            Nav.dropdownItem [ href "#"] [text "Class 2"]
        ]
      }
    ]
    |> Nav.customItems [
      Nav.formItem [] [
        Button.linkButton [ ] [ text <| "User" ++ ", logout" ]
      ]
    ]
    |> Nav.view model.navBarState
  ]


subs : Model -> Sub Msg
subs model =
     Nav.subscriptions model.navBarState NavMsg
