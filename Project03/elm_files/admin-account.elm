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
    searchUser : String
  }

type alias User = {
  username : String,
  userType : String
  }

type Msg =
    ChangeType String String
  | PostResponce (Result Http.Error String)
  | GetResponce (Result Http.Error (List User))
  | SearchUser String
  | SearchButton


init : () -> (Model, Cmd Msg)
init _ =
    ( { users = [], error = "", searchUser = ""}, Http.get { url = "/e/alkersho/account/accounts/"
    , expect = Http.expectJson GetResponce decodeResponce })

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
        GetResponce result ->
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
            expect = Http.expectJson GetResponce decodeResponce
          })

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

view : Model -> Html Msg
view model =
  Grid.container [] [
    CDN.stylesheet,
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
    ("TCHR", "Teacher"),
    ("STD", "Student"),
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
