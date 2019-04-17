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

main = Browser.element { init = init,
                         view = view,
                         update = update,
                         subscriptions = \_ -> Sub.none }

-- model

type alias Model = {
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
  userName : String,
  userNameError : List String,
  gender : String,
  genderError : List String,
  error_response : String
  }

type Msg = FirstName String
         | LastName String
         | Gender String
         | Email String
         | Dob String
         | Password String
         | PasswordAgain String
         | UserName String
         | Create
         | PostResponse (Result Http.Error String)

init : () -> (Model, Cmd Msg)
init () =
    ( { nameFirst = "", nameLast = "", email = "", emailError = [], dob = "", dobError = [], password = "", passwordError = [], passwordAgain = "", passwordAgainError = [], userName = "", userNameError = [], gender = "", genderError = [], error_response = "" }, Cmd.none )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
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
        (passValidate {model | password = string}, Cmd.none)
      PasswordAgain string ->
        (passAgainValidate {model | passwordAgain = string}, Cmd.none)
      UserName string ->
        (userNameValidate {model | userName = string}, Cmd.none)
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
              ({model | error_response = "Success2"}, Nav.load "/class/")
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
          F.colLabel [ Col.sm2 ] [text "First Name:"],
          F.col [ Col.sm10 ] [
            Input.text [Input.attrs [style "max-width" "200px"], Input.onInput FirstName]
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Last Name:"],
          F.col [ Col.sm10 ] [
            Input.text [Input.attrs [style "max-width" "200px"], Input.onInput LastName]
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "User Name:"],
          F.col [ Col.sm10 ] [
            Input.text [Input.attrs [style "max-width" "200px"], Input.onInput UserName],
            userNameError model
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
            Input.email [Input.attrs [style "max-width" "200px"], Input.onInput Email],
            emailError model
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Date of Birth:"],
          F.col [ Col.sm10 ] [
            Input.date [Input.attrs [style "max-width" "200px"], Input.onInput Dob],
            dobError model
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Password:"],
          F.col [ Col.sm10 ] [
            Input.password [Input.attrs [style "max-width" "200px"], Input.onInput Password],
            passError model
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Password Again:"],
          F.col [ Col.sm10 ] [
            Input.password [Input.attrs [style "max-width" "200px"], Input.onInput PasswordAgain],
            passAgainError model
          ]
        ],
        Button.button [Button.primary, Button.onClick Create] [text "Submit"]
      ]
    ]
--
-- validateHtml : String -> Input.Option Msg
-- validateHtml string =
--     if string == "" then
--       Input.success
--     else
--       Input.danger
--
-- validatePassword : Model -> Model
-- validatePassword model =
--     let
--         -- valdatos that add text to finalVal
--         lengthVal =
--           if String.length model.password > 10 then
--             finalVal ++ ""
--           else
--             finalVal ++ "Password must be at least 10 chanracters."
--
--         finalVal = ""
--     in {model | passwordError = finalVal}
--
-- validatePasswordAgain : Model -> Model
-- validatePasswordAgain model =
--     let
--         matchVal =
--           if model.password == model.passwordAgain then
--               finalVal ++ ""
--           else
--               finalVal ++ "Passwords do not match!"
--         finalVal = ""
--     in {model | passwordAgainError = finalVal}
--
-- validateEmail : Model -> Model
-- validateEmail model =
--     let
--         -- valdatos that add text to finalVal
--         lengthVal =
--           if String.length model.password > 10 then
--             finalVal ++ ""
--           else
--             finalVal ++ "Password must be at least 10 chanracters."
--
--         finalVal = ""
--     in {model | emailError = finalVal}
--
-- validateDob : Model -> Model
-- validateDob model =
--     let
--         -- valdatos that add text to finalVal
--         lengthVal =
--           if String.length model.password > 10 then
--             finalVal ++ ""
--           else
--             finalVal ++ "Password must be at least 10 chanracters."
--
--         finalVal = ""
--     in {model | dobError = finalVal}
--
-- validateUserName : Model -> Model
-- validateUserName model =
--     let
--         -- valdatos that add text to finalVal
--         lengthVal =
--           if String.length model.password > 10 then
--             finalVal ++ ""
--           else
--             finalVal ++ "Password must be at least 10 chanracters."
--
--         finalVal = ""
--     in {model | userNameError = finalVal}

sendData : Model -> Cmd Msg
sendData model =
    Http.post { url = "/account/register/",
      body = Http.jsonBody <| modelEncode model,
      expect = Http.expectString PostResponse }

errorMsg : Model -> Html Msg
errorMsg model =
  if model.error_response == "" then
      div [] []
  else
      div [] [Alert.simpleDanger [] [text model.error_response]]

modelEncode : Model -> Encode.Value
modelEncode model =
    Encode.object [
        ("fName", Encode.string model.nameFirst),
        ("lName", Encode.string model.nameLast),
        ("usrnm", Encode.string model.userName),
        ("password", Encode.string model.password),
        ("email", Encode.string model.email),
        ("dob", Encode.string model.dob),
        ("gender" , Encode.string model.gender)
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

passValidate : Model -> Model
passValidate model =
    let
      -- add validation methods that add errors to list
        errorMsgs = []
    in
        {model | passwordError = errorMsgs}

passAgainValidate : Model -> Model
passAgainValidate model =
    if model.password == model.passwordAgain then
        model
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

userNameValidate : Model -> Model
userNameValidate model =
    let
      -- add validation methods that add errors to list
        errorMsgs = []
    in
        {model | userNameError = errorMsgs}

passError : Model -> Html Msg
passError model =
    let
        errorLists : List String -> List (ListGroup.Item Msg)
        errorLists errors =
          case errors of
            [] ->
              []
            x::xs ->
              ListGroup.li [] [text x] :: errorLists xs
    in if model.passwordError == [] then
        div [] []
    else
        div [] [Alert.simpleDanger [] [ListGroup.ul <| errorLists model.passwordError]]

passAgainError : Model -> Html Msg
passAgainError model =
    let
        errorLists : List String -> List (ListGroup.Item Msg)
        errorLists errors =
          case errors of
            [] ->
              []
            x::xs ->
              ListGroup.li [] [text x] :: errorLists xs
    in if model.passwordAgainError == [] then
        div [] []
    else
        div [] [Alert.simpleDanger [] [ListGroup.ul <| errorLists model.passwordAgainError]]

userNameError : Model -> Html Msg
userNameError model =
    let
        errorLists : List String -> List (ListGroup.Item Msg)
        errorLists errors =
          case errors of
            [] ->
              []
            x::xs ->
              ListGroup.li [] [text x] :: errorLists xs
    in if model.userNameError == [] then
        div [] []
    else
        div [] [Alert.simpleDanger [] [ListGroup.ul <| errorLists model.userNameError]]

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
