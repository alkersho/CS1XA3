module Register exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Form as F
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Button as Button
import Bootstrap.Alert as Alert
import Json.Encode as Encode
import Json.Decode as Decode
import Browser
import Browser.Navigation as Nav
-- import Time exposing (Time)
-- import Task

main = Browser.element { init = init,
                         view = view,
                         update = update,
                         subscriptions = \_ -> Sub.none }

-- model
type alias Model = {
  userName : String,
  nameFirst : String,
  nameLast : String,
  email : String,
  emailError : List String,
  dob : String,
  dobError : List String,
  password : String,
  passwordError : List String,
  passwordAgain : String,
  passwordAgainError : List String,
  gender : String,
  genderError : List String,
  error_response : String
  }

type Msg = UserName String
         | FirstName String
         | LastName String
         | Gender String
         | Email String
         | Dob String
         | Password String
         | PasswordAgain String
         | Create
         | PostResponse (Result Http.Error String)

init : () -> (Model, Cmd Msg)
init () =
    ( { userName = ""
    , nameFirst = ""
    , nameLast = ""
    , email = ""
    , emailError = []
    , dob = ""
    , dobError = []
    , password = ""
    , passwordError = []
    , passwordAgain = ""
    , passwordAgainError = []
    , gender = ""
    , genderError = []
    , error_response = "" }, Cmd.none )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
      UserName string ->
        ({model | userName = string}, Cmd.none)
      FirstName string ->
        ({model | nameFirst = string}, Cmd.none)
      LastName string ->
        ({model | nameLast = string}, Cmd.none)
      Gender string ->
        ({model | gender = string}, Cmd.none)
      Email string ->
        (emailValidate {model | email = string}, Cmd.none)
      Dob string ->
        (dobValidate {model | dob = string}, Cmd.none)
      Password string ->
        (passAgainValidate <| passValidate {model | password = string}, Cmd.none)
      PasswordAgain string ->
        (passAgainValidate {model | passwordAgain = string}, Cmd.none)
      Create ->
        if model.password == model.passwordAgain then
          (model, sendData model)
        else
          ({model | error_response = "Passwords Do Not Match!"}, Cmd.none)
      PostResponse result ->
        case result of
          Ok val ->
            if val == "" then
              -- go to homepage
              (model, Nav.load "/e/alkersho/account/")
            else
              ({model | error_response = val}, Cmd.none)
          Err val ->
            (handleError model val, Cmd.none)

view : Model -> Html Msg
view model =
    Grid.container [] [
      errorMsg model,
      F.form [] [
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Username:"],
          F.col [ Col.sm10 ] [
            Input.text [Input.attrs [style "max-width" "200px", required True], Input.onInput UserName]
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "First Name:"],
          F.col [ Col.sm10 ] [
            Input.text [Input.attrs [style "max-width" "200px", required True], Input.onInput FirstName]
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Last Name:"],
          F.col [ Col.sm10 ] [
            Input.text [Input.attrs [style "max-width" "200px"], Input.onInput LastName]
          ]
        ],
        F.row [] [
          F.colLabel [Col.sm2] [text "Gender:"],
          F.col [Col.sm10] [
            Select.select [Select.onChange Gender, Select.attrs [style "max-width" "200px"]] [
              Select.item [] [text "Select..."],
              Select.item [value "M"] [text "Male"],
              Select.item [value "F"] [text "Female"]
            ],
            genderError model
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Email:"],
          F.col [ Col.sm10 ] [
            Input.email [Input.attrs [style "max-width" "200px"], Input.onInput Email, emailValidHtml model],
            emailError model
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Date of Birth:"],
          F.col [ Col.sm10 ] [
            Input.date [Input.attrs [style "max-width" "200px"], Input.onInput Dob, dobValidHtml model],
            dobError model
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Password:"],
          F.col [ Col.sm10 ] [
            Input.password [Input.attrs [style "max-width" "200px"], Input.onInput Password, passValidHtml model],
            passError model
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Password Again:"],
          F.col [ Col.sm10 ] [
            Input.password [Input.attrs [style "max-width" "200px"], Input.onInput PasswordAgain, passAgainValidHtml model],
            passAgainError model
          ]
        ],
        Button.button [Button.primary, Button.onClick Create] [text "Submit"]
      ]
    ]

sendData : Model -> Cmd Msg
sendData model =
    Http.post { url = "",
      body = Http.jsonBody <| modelEncode model,
      expect = Http.expectString PostResponse }

--server error message viewing
errorMsg : Model -> Html Msg
errorMsg model =
  if model.error_response == "" then
      div [] []
  else
      div [] [Alert.simpleDanger [] [text model.error_response]]

modelEncode : Model -> Encode.Value
modelEncode model =
    Encode.object [
        ("UserName", Encode.string model.userName),
        ("First Name", Encode.string model.nameFirst),
        ("Last Name", Encode.string model.nameLast),
        ("Password", Encode.string model.password),
        ("Email", Encode.string model.email),
        ("Date of Birth", Encode.string model.dob),
        ("Gender" , Encode.string model.gender)
      ]

handleError : Model -> Http.Error -> Model
handleError model error =
    case error of
        Http.BadUrl url ->
            { model | error_response = "bad url: " ++ url }

        Http.Timeout ->
            { model | error_response = "timeout" }

        Http.NetworkError ->
            { model | error_response = "network error" }

        Http.BadStatus i ->
            { model | error_response = "bad status " ++ String.fromInt i }

        Http.BadBody body ->
            { model | error_response = "bad body " ++ body }

-- validation fucntions
passValidate : Model -> Model
passValidate model =
    let
        lengthError =
          if String.length model.password < 10 then
            ["Password is too short, atleast 10 chatacters"]
          else
            []
    in
        {model | passwordError = lengthError}

passAgainValidate : Model -> Model
passAgainValidate model =
    if model.password == model.passwordAgain then
        {model | passwordAgainError = []}
    else
        {model | passwordAgainError = ["Passwords Do Not Match!"]}

emailValidate : Model -> Model
emailValidate model =
    let
      -- add validation methods that add errors to list
        errorMsgs = []
    in
        {model | emailError = errorMsgs}

dobValidate : Model -> Model
dobValidate model =
    let
      -- add validation methods that add errors to list
        errorMsgs = []
    in
        {model | dobError = errorMsgs}

-- error viewing functions
passError : Model -> Html Msg
passError model =
    let
        errorLists : List String -> List (ListGroup.Item Msg)
        errorLists errors =
          case errors of
            [] ->
              []
            x::xs ->
              ListGroup.li [ListGroup.danger] [text x] :: errorLists xs
    in if model.passwordError == [] then
        div [] []
    else
        div [] [ListGroup.ul <| errorLists model.passwordError]

passAgainError : Model -> Html Msg
passAgainError model =
    let
        errorLists : List String -> List (ListGroup.Item Msg)
        errorLists errors =
          case errors of
            [] ->
              []
            x::xs ->
              ListGroup.li [ListGroup.danger] [text x] :: errorLists xs
    in if model.passwordAgainError == [] then
        div [] []
    else
        div [] [ListGroup.ul <| errorLists model.passwordAgainError]

emailError : Model -> Html Msg
emailError model =
    let
        errorLists : List String -> List (ListGroup.Item Msg)
        errorLists errors =
          case errors of
            [] ->
              []
            x::xs ->
              ListGroup.li [] [text x] :: errorLists xs
    in if model.emailError == [] then
        div [] []
    else
        div [] [Alert.simpleDanger [] [ListGroup.ul <| errorLists model.emailError]]

dobError : Model -> Html Msg
dobError model =
    let
        errorLists : List String -> List (ListGroup.Item Msg)
        errorLists errors =
          case errors of
            [] ->
              []
            x::xs ->
              ListGroup.li [] [text x] :: errorLists xs
    in if model.dobError == [] then
        div [] []
    else
        div [] [Alert.simpleDanger [] [ListGroup.ul <| errorLists model.dobError]]

genderError : Model -> Html Msg
genderError model =
    let
        errorLists : List String -> List (ListGroup.Item Msg)
        errorLists errors =
          case errors of
            [] ->
              []
            x::xs ->
              ListGroup.li [] [text x] :: errorLists xs
    in if model.genderError == [] then
        div [] []
    else
        div [] [Alert.simpleDanger [] [ListGroup.ul <| errorLists model.genderError]]

--html input valide

passValidHtml : Model -> Input.Option Msg
passValidHtml model =
    if model.passwordError == [] then
        Input.attrs []
    else
        Input.danger

passAgainValidHtml : Model -> Input.Option Msg
passAgainValidHtml model =
    if model.passwordAgainError == [] then
        Input.attrs []
    else
        Input.danger

emailValidHtml : Model -> Input.Option Msg
emailValidHtml model =
    if model.emailError == [] then
        Input.attrs []
    else
        Input.danger

dobValidHtml : Model -> Input.Option Msg
dobValidHtml model =
    if model.dobError == [] then
        Input.attrs []
    else
        Input.danger

genderValidHtml : Model -> Input.Option Msg
genderValidHtml model =
    if model.genderError == [] then
        Input.attrs []
    else
        Input.danger
