module Account exposing (main)

import Browser as Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Encode as Encode
import Json.Decode as Decode
import Bootstrap.Grid as Grid
import Bootstrap.Table as Table
import Bootstrap.Form.Input as Input
import Bootstrap.ListGroup as Lists
import Bootstrap.Utilities.Spacing as Spacing
import Bootstrap.Button as Button
import FontAwesome exposing (..)

main =
  Browser.element {
    init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
  }

-- will contain account details
type alias Model = {
    fName : String,
    lName : String,
    userType : String,
    userName : String,
    email : String,
    editingEmail : Bool,
    emailEdit : String,
    currentPass : String,
    passwordEdit : String,
    editingPass : Bool,
    gender : String,
    classes : List String,
    dob : String,
    error : String
  }

type Msg = Email String
         | EditEmail Bool
         | Password String
         | CPass String
         | EditPass Bool
         | EmailResponce (Result Http.Error String)
         | PassResponce (Result Http.Error String)

type alias Flag = {
    fName : String,
    lName : String,
    userType : String,
    userName : String,
    email : String,
    gender : String,
    classes : List String,
    dob : String
  }

type alias Responce = {
  email : String,
  password : String
  }

init : Flag -> (Model, Cmd Msg)
init flag =
  (Model
    flag.fName
    flag.lName
    flag.userType
    flag.userName
    flag.email
    False
    ""
    ""
    ""
    False
    flag.gender
    flag.classes
    flag.dob
    "", Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Email string ->
          ({model | emailEdit = string}, Cmd.none)
        EditEmail bool ->
          case bool of
            True ->
              ({model | editingEmail = True}, Cmd.none)
            False ->
              (model, Http.post {
                  url = "/e/alkersho/account/"
                  , body = Http.jsonBody <| encodeEmail model.emailEdit
                  , expect = Http.expectString EmailResponce
                })
        Password string ->
          ({model | passwordEdit = string}, Cmd.none)
        CPass string ->
          ({model | currentPass = string}, Cmd.none)
        EditPass bool ->
          case bool of
            True ->
              ({model | editingPass = True}, Cmd.none)
            False ->
              (model, Http.post {
                  url = "/e/alkersho/account/"
                  , body = Http.jsonBody <| encodePass model.currentPass model.passwordEdit
                  , expect = Http.expectString PassResponce
                })
        EmailResponce result ->
          case result of
            Ok val ->
              case val of
                "" ->
                  ({model | email = model.emailEdit, editingEmail = False, error = ""}, Cmd.none)
                _ ->
                  ({model | error = val}, Cmd.none)
            Err val ->
              (errorHandler model val, Cmd.none)
        PassResponce result ->
          case result of
            Ok val ->
              case val of
                "" ->
                  ({model | editingPass = False, error = ""}, Cmd.none)
                _ ->
                  ({model | error = val}, Cmd.none)
            Err val ->
              (errorHandler model val, Cmd.none)

view : Model -> Html Msg
view model =
    Grid.container [] [
      -- useCss,
      Table.table { options = [Table.striped, Table.responsiveMd]
      , thead = Table.simpleThead []
      , tbody = Table.tbody [] <| [
        Table.tr [] [
          Table.td [] [text "First Name:"],
          Table.td [] [text model.fName]
        ],
        Table.tr [] [
          Table.td [] [text "Last Name:"],
          Table.td [] [text model.lName]
        ],
        Table.tr [] [
          Table.td [] [text "User Name:"],
          Table.td [] [text model.userName]
        ],
        Table.tr [] [
          Table.td [] [text "User Type:"],
          Table.td [] [text model.userType]
        ],
        Table.tr [] [
          Table.td [] [text "Email:"],
          Table.td [Table.cellAttr (style "display" "flex")] <| editingEmail model
        ],
        Table.tr [] [
          Table.td [] [text "Date of Birth:"],
          Table.td [] [text model.dob]
        ],
        Table.tr [] [
          Table.td [] [text "Gender:"],
          Table.td [] [text model.gender]
        ],
        Table.tr [] [
          Table.td [] [text "Classes:"],
          Table.td [] [Lists.ul <| classes model.classes]
        ]
      ] ++ changePass model ++ [errorMsg model] }
    ]


errorMsg : Model -> Table.Row Msg
errorMsg model =
  if model.error == "" then
      Table.tr [] []
  else
      Table.tr [Table.rowDanger] [
        Table.td [Table.cellAttr <| style "colspan" "2"] [text model.error]
      ]

sendNewPassword : Model -> Cmd Msg
sendNewPassword model =
    Http.post {
      url = "/e/alkersh/account/edit/",
      body = Http.jsonBody <| encodePass model.currentPass model.passwordEdit,
      expect = Http.expectString PassResponce
  }

changePass : Model -> List (Table.Row Msg)
changePass model =
  if model.editingPass then
    [Table.tr [] [
      Table.td [] [text "Current Passowrd:"],
      Table.td [] [Input.password [Input.onInput CPass]]
    ],
    Table.tr [] [
      Table.td [] [text "New Password:"],
      Table.td [] [Input.password [Input.onInput Password]]
    ],
    Table.tr [] [
      Table.td [Table.cellAttr <| style "colspan" "2"]
      [Button.button [Button.primary, Button.onClick <| EditPass False] [text "Change Passowrd"]]
    ]
    ]
  else
    [Table.tr [] [
      Table.td [] [Button.button [Button.secondary, Button.onClick (EditPass True)] [text "Edit Password"]]
    ]]

encodePass : String -> String -> Encode.Value
encodePass string string2 =
    Encode.object [
      ("currentPass", Encode.string string),
      ("newPass", Encode.string string2)
    ]

sendEmail : Model -> Cmd Msg
sendEmail model =
    Http.post {
      url = "/e/alkersh/account/edit/",
      body = Http.jsonBody <| encodeEmail model.emailEdit,
      expect = Http.expectString EmailResponce
  }

encodeEmail : String -> Encode.Value
encodeEmail v =
    Encode.object [
      ("email", Encode.string v)
    ]

editingEmail : Model -> List (Html Msg)
editingEmail model =
    case model.editingEmail of
        True ->
            [Input.email [Input.onInput Email, Input.value model.emailEdit], iconWithOptions check Solid [] [style "cursor" "pointer", onClick <| EditEmail False, Spacing.myAuto]]
        False ->
            [text model.email, iconWithOptions edit Solid [HtmlTag Span] [style "cursor" "pointer", onClick <| EditEmail True, Spacing.mlAuto]]

classes : List String -> List (Lists.Item Msg)
classes strs =
    case strs of
      x::[] ->
        [Lists.li [] [text x]]
      x::xs ->
        Lists.li [] [text x] :: classes xs
      [] ->
        [Lists.li [] [text "No Classes!"]]

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
