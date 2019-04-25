module AdminAccount exposing (main)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Bootstrap.Form.Select as Select
import Bootstrap.Button as Button
import Bootstrap.Form.Input as Input
import Bootstrap.Table as Table
import Bootstrap.Grid as Grid
import Bootstrap.Alert as Alert
import Bootstrap.Tab as Tab
import Json.Decode as Decode
import Json.Encode as Encode
import Browser as Browser
import Bootstrap.CDN as CDN

main =
  Browser.element {
    init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
  }

type alias Model = {
    users : List User,
    error : String,
    searchUser : String,
    tab_state : Tab.State,
    topics : List Topic,
    new_topic : String
  }

type alias User = {
  username : String,
  userType : String
  }

type alias Topic = {
  id : Int,
  name : String
  }

type Msg =
    ChangeType String String
  | PostResponce (Result Http.Error String)
  | GetUsersResponce (Result Http.Error (List User))
  | SearchUser String
  | SearchButton
  | TabMsg Tab.State
  | DeleteTopic Int
  | NewTopic String
  | AddTopic
  -- | GetTopicResponce

type alias Flag = {
  users : List User,
  topics : List Topic
  }

init : Flag -> (Model, Cmd Msg)
init flag =
    ( { users = flag.users
    , error = ""
    , searchUser = ""
    , tab_state = Tab.initialState
    , topics = flag.topics
    , new_topic = ""
    }, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ChangeType string string2 ->
          (model, setType string string2)
        PostResponce stringErrorHttpResult ->
          case stringErrorHttpResult of
            Ok val ->
              case val of
                "" ->
                  (model, Cmd.none)
                _ ->
                  ({model | error = val}, Cmd.none)
            Err val ->
              (errorHandler model val, Cmd.none)
        GetUsersResponce result ->
          case result of
            Ok val ->
              ({model | users = val}, Cmd.none)
            Err val ->
              (errorHandler model val, Cmd.none)
        SearchUser val ->
          ({model | searchUser = val}, Cmd.none)
        SearchButton ->
          (model, Http.post {
            url = "/e/alkersho/account/accounts/",
            body = Http.jsonBody <| Encode.object [("userSearch", Encode.string model.searchUser)],
            expect = Http.expectJson GetUsersResponce decodeResponce
          })
        TabMsg tState ->
          ({model | tab_state = tState}, Cmd.none)
        DeleteTopic tId ->
          (model, Http.post {
            url = "/e/alkersho/forum/"
            , body = Http.jsonBody <| Encode.object [("post", Encode.int tId)]
            , expect = Http.expectString PostResponce
          })
        NewTopic string ->
          ({model | new_topic = string}, Cmd.none)
        AddTopic ->
          if model.new_topic /= "" then
            (model, Http.post {
              url = "/e/alkersho/forum/"
              , body = Http.jsonBody <| Encode.object [("newTopic", Encode.string model.new_topic)]
              , expect = Http.expectString PostResponce
            })
          else
            ({model | error = "Topic must not be empty"}, Cmd.none)

setType : String -> String -> Cmd Msg
setType username newType =
    Http.post {
    url = "/e/alkersho/account/accounts/",
    body = Http.jsonBody <| encodeRequest username newType,
    expect = Http.expectString PostResponce
  }

encodeRequest : String -> String -> Encode.Value
encodeRequest username newType =
    Encode.object [
    ("username", Encode.string username)
    , ("newType", Encode.string newType)
    ]

decodeResponce : Decode.Decoder (List User)
decodeResponce =
    Decode.field "responce" <| Decode.list
        (Decode.map2 User
            (Decode.field "username" Decode.string)
            (Decode.field "userType" Decode.string)
        )


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

--add topics view
view : Model -> Html Msg
view model =
  Grid.container [] [
    Tab.config TabMsg
    |> Tab.items [
      Tab.item {
        id = "accounts"
        , link = Tab.link [] [text "Accounts"]
        , pane = Tab.pane [] [
            errorView model,
            Table.table { options = []
            , thead = Table.thead [] [
              Table.tr [] [
                Table.td [] [text "User Name:"]
                , Table.td [] [text "User Type:"]
              ]
            ]
            , tbody = Table.tbody [] <|
              Table.tr [] [
                Table.td [] [Input.text [Input.value model.searchUser, Input.placeholder "Search...", Input.onInput SearchUser]],
                Table.td [] [Button.button [Button.primary, Button.onClick SearchButton] [text "Search"]]
              ]
               :: users model
           }
        ]
      }
      , Tab.item {
        id = "topics"
        , link = Tab.link [] [ text "Topics" ]
        , pane = Tab.pane [] [
          Table.table {
            options = []
            , thead = Table.thead [] []
            , tbody = Table.tbody [] <|
              [
                Table.tr [] [
                  Table.td [] [Input.text [Input.onInput NewTopic, Input.value model.new_topic, Input.placeholder "New Topic..."]]
                  , Table.td [] [ Button.button [ Button.primary, Button.onClick AddTopic ] [ text "Add Topic"]]
                ]
              ] ++ topics model.topics
        }
        ]
      }
    ] |> Tab.view model.tab_state
  ]

errorView : Model -> Html Msg
errorView model =
    case model.error of
      "" ->
        div [] []
      _ ->
        Alert.simpleDanger [] [text model.error]

userTypes : List (String, String)
userTypes =
  [
    ("USR", "User"),
    ("ADM", "Admin")
  ]

users : Model -> List (Table.Row Msg)
users model =
    let
        row userList =
          case userList of
            x::xs ->
              Table.tr [] [
                Table.td [] [text x.username]
                , Table.td [] [Select.select [ Select.onChange <| ChangeType x.username]
                    <| items x.userType userTypes
                ]
              ] :: row xs
            [] ->
              []

        items : String -> List (String, String) -> List (Select.Item Msg)
        items cType types =
          case types of
            (a,b)::xs ->
              if a == cType then
                  Select.item [ value a, selected True] [text b] :: items cType xs
              else
                  Select.item [ value a, selected False] [text b] :: items cType xs
            [] ->
              []
    in row model.users

topics : List Topic -> List (Table.Row Msg)
topics topicList =
    case topicList of
      [] ->
        []
      x::xs ->
        Table.tr [] [
          Table.td [] [ text x.name ]
          , Table.td [] [ Button.button [ Button.danger, Button.onClick <| DeleteTopic x.id ] [ text "Delete Topic" ]]
        ] :: topics xs
