module Forum exposing (main)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Utilities.Spacing as Spacing
import Browser
import Browser.Navigation as Nav
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Json.Encode as Encode

main : Program Flag Model Msg
main =
  Browser.element {
  init = init
  , update = update
  , view = view
  , subscriptions = \_-> Sub.none
  }

type alias Post = {
  title : String
  , id : Int
  }

type alias Model = {
  postList : List Post
  , search : String
  , error : String
  }

type Msg =
    Search String
  | SearchButton
  | SearchResponce (Result Http.Error (List Post))
  | GotoPost String
  | CreatePost

type alias Flag = {
    posts : List Post
  }

init : Flag -> (Model, Cmd Msg)
init flag =
    ( { postList = flag.posts, search = "", error = "" }, Cmd.none )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Search string ->
            ({model | search = string}, Cmd.none)
        SearchButton ->
          if model.search == "" then
              (model, Cmd.none)
          else
              (model, Http.post {
                url = "/e/alkersho/forum/"
                , body = Http.jsonBody <| searchEncode model.search
                , expect = Http.expectJson SearchResponce decodePostList
                })
        SearchResponce result ->
            case result of
              Ok val ->
                ({model | postList = val}, Cmd.none)
              Err val ->
                (errorHandler model val, Cmd.none)

        GotoPost int ->
          (model, Nav.load <| "/e/alkersho/forum/" ++ int ++ "/")
        CreatePost ->
          (model, Nav.load "/e/alkersho/forum/create/")

searchEncode : String -> Encode.Value
searchEncode v =
  Encode.object [
    ("postName", Encode.string v)
  ]

decodePostList : Decode.Decoder (List Post)
decodePostList =
    Decode.list
        (Decode.map2 Post
            (Decode.field "title" Decode.string)
            (Decode.field "id" Decode.int)
        )

view : Model -> Html Msg
view model =
    Grid.container [] <| [
      Grid.container [] [
        Input.text [Input.onInput Search, Input.value model.search, Input.placeholder "Search...", Input.attrs [style "width" "80%", style "float" "left"]]
        , Button.button [Button.primary, Button.onClick SearchButton] [text "Search"]
      ]
      , Button.button [ Button.primary, Button.onClick CreatePost ] [ text "Create a Post"]
      , Grid.containerFluid [Spacing.mt5] <| postCards model.postList
    ]

postCards : List Post -> List (Html Msg)
postCards postList =
    case postList of
      [] ->
        []
      x::xs ->
        (Card.config []
        |> Card.block [ Block.attrs [ onClick <| GotoPost <| String.fromInt x.id, style "cursor" "pointer" ]] [Block.text [] [text x.title] ]
        |> Card.view ) :: postCards xs

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

errorMsg : Model -> Html Msg
errorMsg model =
  if model.error == "" then
      div [] []
  else
      div [] [Alert.simpleDanger [] [text model.error]]
