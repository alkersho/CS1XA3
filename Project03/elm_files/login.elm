module Login exposing (main)

import Bootstrap.Form as F
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Alert as Alert
import Html exposing (..)
import Html.Attributes exposing (..)
import Browser as Browser
import Browser.Navigation as Nav
import Json.Encode as Encode
import Json.Decode as Decode
import Http

main =
  Browser.element {
  init = init,
  update = update,
  view = view,
  subscriptions = \_ -> Sub.none
  }

type alias Model = {
  userName : String,
  password : String,
  error : String
  }

type Msg = UserName String
         | Password String
         | Login
         | Register
         | PostResponse (Result Http.Error String)

init : () -> (Model, Cmd Msg)
init () =
    ( {userName = "", password = "", error = ""}, Cmd.none )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        UserName string ->
            ({model | userName = string}, Cmd.none)
        Password string ->
            ({model | password = string}, Cmd.none)
        Register ->
          (model, Nav.load "/e/alkersho/account/register/")
        Login ->
            (model, sendLogin model)
        PostResponse result ->
          case result of
            Ok val ->
              if val == "" then
                  (model, Nav.load "/e/alkersho/account/")
              else
                ({model | error = val}, Cmd.none)
            Err val ->
              (errorHandler model val, Cmd.none)

view : Model -> Html Msg
view model =
    Grid.container [] [
      errorMsg model,
      F.label [] [text "Username:"],
      Input.text [ Input.onInput UserName, Input.attrs [ style "max-width" "300px"] ],
      F.label [] [text "Passowrd:"],
      Input.password [ Input.onInput Password, Input.attrs [ style "max-width" "300px"] ],
      Button.button [ Button.primary, Button.onClick Login] [ text "Login!" ],
      Button.button [ Button.roleLink, Button.onClick Register] [ text "Register"]
    ]

sendLogin : Model -> Cmd Msg
sendLogin model =
    Http.post { url = "/e/alkersho/account/login/"
    , body = Http.jsonBody <| encodeModel model
    , expect = Http.expectString PostResponse }

encodeModel : Model -> Encode.Value
encodeModel v =
    Encode.object
        [ ( "userName", Encode.string v.userName )
        , ( "password", Encode.string v.password )
        ]

errorMsg : Model -> Html Msg
errorMsg model =
  if model.error == "" then
      div [] []
  else
      div [] [Alert.simpleDanger [] [text model.error]]

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
