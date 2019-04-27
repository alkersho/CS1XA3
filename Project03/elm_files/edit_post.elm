module EditPost exposing (main)

import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Button as Button
import Bootstrap.Alert as Alert
import Bootstrap.Grid as Grid
import Browser
import Browser.Navigation as Nav
import Http
import Html exposing (Html, div, text, br, a, p)
import Html.Attributes exposing (href, class)
import Html.Events exposing (onClick)
import Json.Encode as Encode

main : Program Flag Model Msg
main =
  Browser.element
    {
    init = init
    , update = update
    , view = view
    , subscriptions = \_-> Sub.none
  }

type alias Model = {
  postId : Int
  , title : String
  , body : String
  ,error : String
  }

type alias Flag = {
  postId : Int
  , title : String
  , body : String
  }

type Msg =
  Body String
  | Submit
  | PostResponce (Result Http.Error String)

init : Flag -> (Model, Cmd Msg)
init flag =
    ( { postId = flag.postId
    , title = flag.title
    , body = flag.body
    , error = "" }, Cmd.none )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Body string ->
            ({model | body = string}, Cmd.none)

        Submit ->
            (model, Http.post {
              url = "/e/alkersho/forum/edit/" ++ (String.fromInt model.postId)
               ++ "/"
              , body = Http.jsonBody <| encodeRequest model
              , expect = Http.expectString PostResponce
            })

        PostResponce result ->
          case result of
            Ok val ->
              case val of
                "" ->
                  (model, Nav.load <| "/e/alkersho/forum/" ++
                    (String.fromInt model.postId) ++ "/")
                _ ->
                  ({model | error = val}, Cmd.none)
            Err val ->
              (errorHandler model val, Cmd.none)

encodeRequest : Model -> Encode.Value
encodeRequest v =
    Encode.object
        [ ( "postId", Encode.int v.postId )
        , ( "body", Encode.string v.body )
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

view : Model -> Html Msg
view model =
    Grid.container [] [
      errorMsg model
      , text model.title
      , Textarea.textarea [
        Textarea.value model.body
        , Textarea.onInput Body
        , Textarea.rows 20
      ]
      , p [ class "text-muted"] [ text "Markdown Enabled." ]
      , a [ href "https://www.markdownguide.org/basic-syntax/"] [ text "Basics." ]
      , br [] []
      , Button.button [ Button.primary, Button.onClick Submit ] [ text "Edit" ]
    ]

errorMsg : Model -> Html Msg
errorMsg model =
  if model.error == "" then
      div [] []
  else
      div [] [Alert.simpleDanger [] [text model.error]]
