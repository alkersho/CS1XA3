module Comments exposing (main)

import Bootstrap.Button as Button
import Bootstrap.Form.Input as Input
import Bootstrap.Utilities.Border as Border
import Bootstrap.Alert as Alert
import Bootstrap.Grid as Grid
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Accordion as Accordion
import Bootstrap.Card.Block as Block
import FontAwesome exposing (icon, reply)
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required, optional, hardcoded)

main : Program Flag Model Msg
main =
  Browser.element
    {
    init = init
    , update = update
    , view = view
    , subscriptions = subscription
  }

type Children =
  Comments (List CommentRecord)

type alias CommentRecord =
  {postID: Int
  , commentID: Int
  , body: String
  , children: Children
  }

type alias Flag = {
  postID : String
  }

type alias Model =
  {
    postID : String
    , comments : List CommentRecord
    , newCommentBody : String
    , error : String
    , acState : Accordion.State
  }

type Msg =
  NoOp
  | GetComments (Result Http.Error (List CommentRecord))
  | EditCommentBody String
  | AddParentComment
  | AddSubComment String
  | PostResponce (Result Http.Error String)
  | AccordionMsg Accordion.State

init : Flag -> (Model, Cmd Msg)
init flag =
    ( { postID = flag.postID
    , comments = []
    , newCommentBody = ""
    , error = ""
    , acState = Accordion.initialState }, Http.get {
      url = "/e/alkersho/forum/comment-"++ flag.postID ++"--1/"
      , expect = Http.expectJson GetComments <| Decode.list decodeCommentRecord
    } )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
          (model, Cmd.none)
        EditCommentBody string ->
          ({model | newCommentBody = string} , Cmd.none)
        AddParentComment ->
          (model, Http.post
            { url = "/e/alkersho/forum/comment-" ++ model.postID ++ "--1/"
            , body = Http.jsonBody <| encodeCommentParent model.newCommentBody
            , expect = Http.expectString PostResponce
            })
        AddSubComment commentId ->
          (model, Http.post
            { url = "/e/alkersho/forum/comment-" ++ model.postID ++ "-"
            ++ commentId ++ "/"
            , body = Http.jsonBody
            <| encodeCommentChild model.newCommentBody commentId
            , expect = Http.expectString PostResponce
            })
        GetComments result ->
          case result of
            Ok val ->
              ({model | comments = val}, Cmd.none)
            Err val ->
              (errorHandler model val, Cmd.none)
        PostResponce result ->
          case result of
            Ok val ->
              case val of
                "" ->
                  (model, Nav.reload )
                _ ->
                  ({model | error = val}, Cmd.none)
            Err val ->
              (errorHandler model val, Cmd.none)
        AccordionMsg state ->
          ({model | acState = state}, Cmd.none)

encodeCommentParent : String -> Encode.Value
encodeCommentParent v =
    Encode.object [
    ("body", Encode.string v)
    ]

encodeCommentChild : String -> String -> Encode.Value
encodeCommentChild body parentID =
    Encode.object [
      ("parentID", Encode.string parentID)
      , ("body", Encode.string body)
    ]

decodeCommentRecord : Decode.Decoder CommentRecord
decodeCommentRecord =
    Decode.map4 CommentRecord
        (Decode.field "postID" Decode.int)
        (Decode.field "commentID" Decode.int)
        (Decode.field "body" Decode.string)
        (Decode.field "children"
          (Decode.map Comments (Decode.list (Decode.lazy ( \_ -> decodeCommentRecord)))))


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
    Grid.container [] <| [
      errorView model
      , Accordion.config AccordionMsg
        |> Accordion.withAnimation
        |> Accordion.cards [
          Accordion.card {
          id = "mainComment"
          , header =
             Accordion.header [] <| Accordion.toggle [] [icon reply, text "Reply"]
          , blocks = [
            Accordion.block [] [
              Block.custom (Textarea.textarea [ Textarea.onInput EditCommentBody])
              , Block.custom (Button.button [ Button.primary, Button.onClick AddParentComment] [ text "Submit"])
            ]
          ]
          , options = []
        }
        ]
        |> Accordion.view model.acState
    ] ++ commentView model.comments model

commentView : List CommentRecord -> Model -> List (Html Msg)
commentView commentRecord model =
  let
      comment : CommentRecord -> Html Msg
      comment record =
        Grid.container [] [
        text record.body
        , Accordion.config AccordionMsg
          |> Accordion.withAnimation
          |> Accordion.cards [
            Accordion.card {
              id = String.fromInt record.commentID
              , options = []
              , header = Accordion.header [] <| Accordion.toggle [] [icon reply]
              , blocks = [
                Accordion.block [] [
                  Block.custom (Textarea.textarea [ Textarea.onInput EditCommentBody])
                  , Block.custom (Button.button [ Button.primary, Button.onClick <| AddSubComment
                                  <| String.fromInt record.commentID] [ text "Submit"])
                ]
              ]
            }
          ]
          |> Accordion.view model.acState
        , div [ Border.left ] <| commentView (commentFromChildren record.children) model
        ]
  in case commentRecord of
      [x] ->
        [comment x]
      x::xs ->
        comment x :: commentView xs model
      [] ->
        [text "No Comments"]

commentFromChildren : Children -> List CommentRecord
commentFromChildren children =
    case children of
        Comments commentRecordList ->
            commentRecordList

errorView : Model -> Html Msg
errorView model =
    case model.error of
      "" ->
        div [] []
      _ ->
        Alert.simpleDanger [] [text model.error]

subscription : Model -> Sub Msg
subscription model =
    Accordion.subscriptions model.acState AccordionMsg
