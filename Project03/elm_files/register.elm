module Register exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
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
  emailError : String,
  dob : String,
  dobError : String,
  password : String,
  passwordError : String,
  passwordAgain : String,
  passwordAgainError : String,
  userName : String,
  userNameError : String,
  gender : String,
  error_response : String
  }

type Msg = FirstName String
         | LastName String
         | Gender String
         | Email String
         | ValEmail
         | Dob String
         | ValDob
         | Password String
         | ValPassword
         | PasswordAgain String
         | ValPasswordAgain
         | UserName String
         | ValUserName
         | Create
         | PostResponse (Result Http.Error String)

init : () -> (Model, Cmd Msg)
init () =
    ( { nameFirst = "", nameLast = "", email = "", emailError = "", dob = "", dobError = "", password = "", passwordError = "", passwordAgain = "", passwordAgainError = "", userName = "", userNameError = "", gender = "", error_response = "" }, Cmd.none )

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
        ({model | email = string}, Cmd.none)
      ValEmail ->
        (model, Cmd.none)
      Dob string ->
        ({model | dob = string}, Cmd.none)
      ValDob ->
        (model, Cmd.none)
      Password string ->
        ({model | password = string}, Cmd.none)
      ValPassword ->
        (model, Cmd.none)
      PasswordAgain string ->
        ({model | passwordAgain = string}, Cmd.none)
      ValPasswordAgain ->
        (model, Cmd.none)
      UserName string ->
        ({model | userName = string}, Cmd.none)
      ValUserName ->
        (model, Cmd.none)
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
            Input.text [Input.attrs [style "max-width" "200px"], Input.onInput UserName]
          ]
        ],
        F.row [] [
          F.colLabel [Col.sm2] [text "Gender:"],
          F.col [Col.sm10] [
            Select.select [Select.onChange Gender, Select.attrs [style "max-width" "200px"]] [
              Select.item [] [text "Select..."],
              Select.item [value "M"] [text "Male"],
              Select.item [value "F"] [text "Female"]
            ]
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Email:"],
          F.col [ Col.sm10 ] [
            Input.email [Input.attrs [style "max-width" "200px"], Input.onInput Email]
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Date of Birth:"],
          F.col [ Col.sm10 ] [
            Input.date [Input.attrs [style "max-width" "200px"], Input.onInput Dob]
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Password:"],
          F.col [ Col.sm10 ] [
            Input.password [Input.attrs [style "max-width" "200px"], Input.onInput Password]
          ]
        ],
        F.row [] [
          F.colLabel [ Col.sm2 ] [text "Password Again:"],
          F.col [ Col.sm10 ] [
            Input.password [Input.attrs [style "max-width" "200px"], Input.onInput PasswordAgain]
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
