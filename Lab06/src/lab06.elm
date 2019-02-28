import Html exposing (Html, div, input, text)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onInput)
import Browser exposing (sandbox)


main = sandbox{ init = init, update = update, view = view}

--Model
type alias Model =
  {
    string1 : String,
    string2 : String
  }

--msg
type Msg = Text1 String
         | Text2 String

--init
init : Model
init = Model "" ""

--update
update : Msg -> Model -> Model
update msg model =
  case msg of
    Text1 txt1 ->
      { model | string1 = txt1}
    Text2 txt2 ->
      { model | string2 = txt2}

--view
view : Model -> Html Msg
view model = div [] [
    input [placeholder "String 1", onInput Text1, value model.string1] [],
    input [placeholder "String 2", onInput Text2, value model.string2] [],
    div [] [text (model.string1++":"++model.string2)]
  ]
