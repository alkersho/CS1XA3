module Post exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import FontAwesome exposing (..)
import Browser.Navigation as Nav
import Browser

main : Program Flag Model Msg
main =
  Browser.element {
    init = init
    , update = update
    , view = view
    , subscriptions = \_-> Sub.none
  }

type alias Model = {
  title : String
  , body : String
  , id : String
  , canEdit : Bool
  }

type alias Flag = {
  title : String
  , body : String
  , id : String
  , canEdit : Bool
  }

type Msg =
  NoOp
  | Edit

init : Flag -> (Model, Cmd Msg)
init flag =
    ( flag, Cmd.none )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            (model, Cmd.none)
        Edit ->
            (model, Nav.load <| "/e/alkersho/forum/edit/" ++ model.id ++ "/")

view : Model -> Html Msg
view model =
    Grid.container [] [
      Html.table [style "width" "inherit"] [
        tr [] [
          td [] [
            Html.h1 [ style "max-width" "90%"] [text model.title]
        ],
        td [] [
          if model.canEdit then
              iconWithOptions edit Solid [] [style "cursor" "pointer", onClick Edit]
          else
            div [] []
      ]
        ]
      ]
      ,Card.config []
      |> Card.block [] [
        Block.text [] [text model.body]
      ]
      |> Card.view
    ]
