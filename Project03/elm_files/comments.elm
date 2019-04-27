module Comments exposing (main)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Card.Block as Block
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Grid as Grid
import Bootstrap.Utilities.Border as Border
import Browser
import Browser.Navigation as Nav
import Dict
import FontAwesome exposing (icon, reply)
import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Encode as Encode
import Json.Decode as Decode

main : Program Flag Model Msg
main =
  Browser.element
    {
    init = init
    , update = update
    , view = view
    , subscriptions = \_-> Sub.none
  }

-- comments types
type Children =
  Comments (List CommentRecord)

type alias CommentRecord =
  {postID: Int
  , commentID: Int
  , body: String
  , children: Children
  }

-- expand dictionary, keeps track of expanded comment replies
-- keys are comment id
-- values are isExpanded
-- only special entry is "mainComment" for submitting a top level comment
type alias ExpandDic = Dict.Dict String Bool

-- flag for initialization
type alias Flag = {
  postID : String
  }

-- model
type alias Model =
  {
    postID : String
    , comments : List CommentRecord
    , newCommentBody : String
    , error : String
    , exState : ExpandDic
  }

-- Msg
type Msg =
  GetComments (Result Http.Error (List CommentRecord))
  | EditCommentBody String
  | AddParentComment
  | AddSubComment String
  | PostResponce (Result Http.Error String)
  | ExpandMsg String

init : Flag -> (Model, Cmd Msg)
init flag =
    ( { postID = flag.postID
    , comments = []
    , newCommentBody = ""
    , error = ""
    , exState = (Dict.singleton "pComment" False) -- the special exception
     }, Http.get -- gets comments for the post
      {
        url = "/e/alkersho/forum/comment-"++ flag.postID ++"--1/"
        , expect = Http.expectJson GetComments <| Decode.list decodeCommentRecord
      } )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        -- saves text to be sent as comment
        EditCommentBody string ->
          ({model | newCommentBody = string} , Cmd.none)
        -- sends a top level comment
        AddParentComment ->
          (model, Http.post
            { url = "/e/alkersho/forum/comment-" ++ model.postID ++ "--1/"
            , body = Http.jsonBody <| encodeCommentParent model.newCommentBody
            , expect = Http.expectString PostResponce
            })
        -- sends a subcomment
        AddSubComment commentId ->
          (model, Http.post
            { url = "/e/alkersho/forum/comment-" ++ model.postID ++ "-"
            ++ commentId ++ "/"
            , body = Http.jsonBody
            <| encodeCommentChild model.newCommentBody commentId
            , expect = Http.expectString PostResponce
            })
        -- handle responce to getting the comments
        GetComments result ->
          case result of
            Ok val ->
              ({model | comments = val
              , exState = Dict.union model.exState
                                  <| createDict (Dict.empty) val}, Cmd.none)
            Err val ->
              (errorHandler model val, Cmd.none)
        -- post responce to positng comments, empty responce means no errors
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
        -- expands comment reply section for the specific comment
        ExpandMsg v ->
          ({model | exState = updateExpand v (not (getExpand v model.exState)) model.exState}
            , Cmd.none)

-- creates the remainder of the dictionary
createDict : ExpandDic -> List CommentRecord -> ExpandDic
createDict expandDic commentsList =
    case commentsList of
      [] ->
        expandDic
      x::xs ->
        Dict.union (createDict (newExpand (String.fromInt x.commentID) expandDic)
                      (commentFromChildren x.children))
                   (createDict expandDic xs)

-- helper function to add a new entry into the dictionary
newExpand : String -> ExpandDic -> ExpandDic
newExpand string expandDic =
    Dict.insert string False expandDic

-- updates dictionary value for commentID 'string'
updateExpand : String -> Bool -> ExpandDic -> ExpandDic
updateExpand string bool expandDic =
    Dict.update string (\_-> Just bool) expandDic

-- gets value of commentID 'string'
getExpand : String -> ExpandDic -> Bool
getExpand string expandDic =
    Maybe.withDefault False <| Dict.get string expandDic

-- extracts dictionary from Children type, only and single use
commentFromChildren : Children -> List CommentRecord
commentFromChildren children =
    case children of
        Comments commentRecordList ->
            commentRecordList

-- encodes a parent comment to be sent to server
encodeCommentParent : String -> Encode.Value
encodeCommentParent v =
    Encode.object [
    ("body", Encode.string v)
    ]

--encodes child comment to be sent to server
encodeCommentChild : String -> String -> Encode.Value
encodeCommentChild body parentID =
    Encode.object [
      ("parentID", Encode.string parentID)
      , ("body", Encode.string body)
    ]

-- dedcodes comment json data
decodeCommentRecord : Decode.Decoder CommentRecord
decodeCommentRecord =
    Decode.map4 CommentRecord
        (Decode.field "postID" Decode.int)
        (Decode.field "commentID" Decode.int)
        (Decode.field "body" Decode.string)
        (Decode.field "children"
          (Decode.map Comments (Decode.list (Decode.lazy ( \_ -> decodeCommentRecord)))))

-- handles Http responce errors, stolen form Curtise's exampls
-- https://github.com/NotAProfDalves/elm_django_examples/blob/master/elm_examples/GetPostExample.elm
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

-- main view function
view : Model -> Html Msg
view model =
    Grid.container [] <| [
      errorView model
      , if getExpand "mainComment" model.exState then
           div [] [
            Textarea.textarea [ Textarea.onInput EditCommentBody]
            , Button.button [ Button.primary, Button.onClick AddParentComment] [ text "Submit"]
          ]
        else
          div [] [Button.button [ Button.light, Button.onClick <| ExpandMsg "mainComment"]
                                [ icon reply]
          ]
    ] ++ commentView model.comments model

-- creates views from Comments list
commentView : List CommentRecord -> Model -> List (Html Msg)
commentView commentRecord model =
  let

      comment : CommentRecord -> Html Msg
      comment record =
        Grid.container [] [
        text record.body
        , if getExpand (String.fromInt record.commentID) model.exState then
             div [] [
              Textarea.textarea [ Textarea.onInput EditCommentBody]
              , Button.button [ Button.primary, Button.onClick AddParentComment] [ text "Submit"]
            ]
          else
            div [] [Button.button [ Button.light, Button.onClick <| ExpandMsg
                                    <| String.fromInt record.commentID]
                                  [ icon reply]
            ]
        , div [ Border.left ] <| commentView (commentFromChildren record.children) model
        ]
  in case commentRecord of
      [x] ->
        [comment x]
      x::xs ->
        comment x :: commentView xs model
      [] ->
        [ div [] [] ]

-- shows any errors
errorView : Model -> Html Msg
errorView model =
    case model.error of
      "" ->
        div [] []
      _ ->
        Alert.simpleDanger [] [text model.error]
