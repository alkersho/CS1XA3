module CreatePost exposing (main)

import Bootstrap.Form as Form
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Alert as Alert
import Browser
import Browser.Navigation as Nav
import Http
import Html exposing (Html, div, text, br, a, p)
import Html.Attributes exposing (value, href, class)
import Json.Encode as Encode
import Json.Decode as Decode
import Maybe as Maybe

main =
  Browser.element
    {
    init = init
    , update = update
    , view = view
    , subscriptions = \_-> Sub.none
  }

type alias Model = {
    title : String
    , body : String
    , topic : String
    , topics : List TopicRecord
    , error : String
  }

type Msg = Title String
  | Body String
  | Topic String
  | Send
  | PostResponce (Result Http.Error String)

type alias TopicRecord =
  {
    id : Int
    , name : String
  }

type alias Flag = {
  topics : List TopicRecord
  }

init : Flag -> (Model, Cmd Msg)
init flag =
    ( { title = ""
    , body = ""
    , topic = String.fromInt (Maybe.withDefault {id=0,name=""} <| List.head flag.topics).id
    , topics = flag.topics
    , error = "" }, Cmd.none )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Title string ->
            ({model | title = string}, Cmd.none)

        Body string ->
            ({model | body = string}, Cmd.none)

        Topic string ->
            ({model | topic = string}, Cmd.none)

        Send ->
            (model, Http.post { url = "/e/alkersho/forum/create/"
            , body = Http.jsonBody <| encodeRequest model
            , expect = Http.expectString PostResponce })

        PostResponce result ->
            case result of
              Ok val ->
                case val of
                  "" ->
                    ({model | error = ""}, Nav.load "/e/alkersho/forum/")
                  _ ->
                    ({model | error = val}, Cmd.none)
              Err val ->
                (errorHandler model val, Cmd.none)

encodeRequest : Model -> Encode.Value
encodeRequest v =
    Encode.object
        [ ( "title", Encode.string v.title )
        , ( "body", Encode.string v.body )
        , ( "topic", Encode.string v.topic )
        ]

decodeTopics : Decode.Decoder (List String)
decodeTopics =
        (Decode.field "topics" (Decode.list Decode.string))


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

view : Model -> Html.Html Msg
view model =
  Grid.container [] [
    errorView model,
    Form.label [] [text "Topic:"],
    Select.select [Select.onChange Topic] <| topicsList model.topics,
    Form.label [] [text "Title:"],
    Input.text [Input.onInput Title, Input.value model.title, Input.placeholder "Title"],
    Form.label [] [text "Body:"],
    Textarea.textarea [ Textarea.rows 20, Textarea.onInput Body ],
    p [class "text-muted"] [ text "Markdown Enabled"],
    a [ href "https://www.markdownguide.org/basic-syntax/"] [ text "Basics." ]
    , br [] []
    , Button.button [Button.primary, Button.onClick Send] [text "Create!"]
  ]

topicsList : List TopicRecord -> List (Select.Item Msg)
topicsList list =
    case list of
      [] ->
        [Select.item [] [text "No Topics Available now!"]]
      [x] ->
        [Select.item [value <| String.fromInt x.id ] [text x.name]]
      x::xs ->
        Select.item [ value <| String.fromInt x.id ] [text x.name] :: topicsList xs

errorView : Model -> Html Msg
errorView model =
    case model.error of
      "" ->
        div [] []
      _ ->
        Alert.simpleDanger [] [text model.error]
