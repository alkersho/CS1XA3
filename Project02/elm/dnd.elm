module Main exposing (..)

import Html.Attributes exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (at)
import Json.Decode.Pipeline exposing (custom)
import Browser

main =
  Browser.element {
    init = init,
    update = update,
    subscriptions = \_ ->Sub.none,
    view = view
  }

--Model
type alias Model = {
    name : String,
    classStr : String,
    raceStr : String,
    background :  String,
    alignment : String,
    classAttr : ClassAttr,
    raceAttr : RaceAttr,
    backgroundAttr : BackgroundAttr,
    strength : Int,
    dextrerity : Int,
    constitution : Int,
    intelligence : Int,
    wisdom : Int,
    charisma : Int,
    skillPts : Int,
    error : String,
    created : Bool
  }

--Attr types
type alias ClassAttr = {
    proBunus : Int,
    hp : Int,
    hpMode : String,
    proArmour : List String,
    proWeapon : List String,
    proTools : List String,
    savingThrows : List String,
    skills : List String,
    weapons : List String,
    starterEq: List String,
    cantrips : List String,
    spells : List String,
    dice : String,
    feautes: List String
  }
nullClassAttr : ClassAttr
nullClassAttr =
    { proBunus = 0, hp = 0, hpMode = "", proArmour = [], proWeapon = [], proTools = [], savingThrows = [], skills = [], weapons = [], starterEq = [], cantrips = [], spells = [], dice = "", feautes = [] }


type alias RaceAttr = {
    bigness : String,
    speed : Int,
    strength : Int,
    dextrerity : Int,
    constitution : Int,
    intelligence : Int,
    wisdom : Int,
    charisma : Int
  }
nullRaceAttr : RaceAttr
nullRaceAttr =
    { bigness = "", speed = 0, strength = 0, dextrerity = 0, constitution = 0, intelligence = 0, wisdom = 0, charisma = 0 }

type alias BackgroundAttr = {
  languages : String,
  money : Int,
  skills : List String,
  feature: String,
  equipment: String
  }

nullBackgroundAttr : BackgroundAttr
nullBackgroundAttr =
    { languages = "", money = 0, skills = [], feature = "", equipment = "" }
--msgs
type Msg = Name String
         | ClassStr String
         | RaceStr String
         | Background String
         | Alignment String
         | StrUp
         | StrDn
         | DexUp
         | DexDn
         | ConUp
         | ConDn
         | IntUp
         | IntDn
         | WisUp
         | WisDn
         | ChaUp
         | ChaDn
         | GetClass (Result Http.Error ClassAttr)
         | GetRace (Result Http.Error RaceAttr)
         | GetBackground (Result Http.Error BackgroundAttr)
         | CreateButton

--init
init : () -> (Model, Cmd Msg)
init _ =
    ( { name = "",
    classStr = "",
    raceStr = "",
    background = "",
    alignment = "",
    classAttr = nullClassAttr,
    raceAttr = nullRaceAttr,
    backgroundAttr = nullBackgroundAttr,
    strength = 8,
    dextrerity =  8,
    constitution =  8,
    intelligence =  8,
    wisdom =  8,
    charisma =  8,
    skillPts =  27,
    error = "",
    created = False}, Cmd.none)


--update
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Name string ->
            ({model | name = string}, Cmd.none )
        ClassStr string ->
          if string == "" then
            (model, Cmd.none)
          else
            ({model | classStr = string}, (Http.get { url = "data.json", expect = Http.expectJson GetClass (decodeClass string)}))
        RaceStr string ->
          if string == "" then
            (model, Cmd.none)
          else
            ({model | raceStr = string}, (Http.get { url = "data.json", expect = Http.expectJson GetRace (decodeRace string) }))
        Background string ->
          if string == "" then
            (model, Cmd.none)
          else
            ({model | background = string}, (Http.get { url = "data.json", expect = (Http.expectJson GetBackground (decodeBackground string)) }))
        Alignment string ->
          ({model | alignment = string}, Cmd.none)
        StrUp ->
          if model.strength < 14 then
            ({model | strength = model.strength + 1, skillPts =  model.skillPts - 1}, Cmd.none)
          else if model.strength == 15 then
              (model, Cmd.none)
          else
            ({model | strength = model.strength + 1, skillPts = model.skillPts - 2}, Cmd.none)
        StrDn ->
          if model.strength == 8 then
            (model, Cmd.none)
          else if model.strength < 15 then
            ({model | strength = model.strength - 1, skillPts = model.skillPts + 1}, Cmd.none)
          else
            ({model | strength = model.strength - 1, skillPts = model.skillPts + 2}, Cmd.none)
        DexUp ->
          if model.dextrerity < 14 then
            ({model | dextrerity = model.dextrerity + 1, skillPts = model.skillPts - 1}, Cmd.none)
          else if model.dextrerity == 15 then
              (model, Cmd.none)
          else
            ({model | dextrerity = model.dextrerity + 1, skillPts = model.skillPts - 2}, Cmd.none)
        DexDn ->
          if model.dextrerity == 8 then
            (model, Cmd.none)
          else if model.dextrerity < 14 then
            ({model | dextrerity = model.dextrerity - 1, skillPts = model.skillPts + 1}, Cmd.none)
          else
            ({model | dextrerity = model.dextrerity - 1, skillPts = model.skillPts + 2}, Cmd.none)
        ConUp ->
          if model.constitution < 14 then
            ({model | constitution = model.constitution + 1, skillPts = model.skillPts - 1}, Cmd.none)
          else if model.constitution == 15 then
              (model, Cmd.none)
          else
            ({model | constitution = model.constitution + 1, skillPts = model.skillPts - 2}, Cmd.none)
        ConDn ->
          if model.constitution == 8 then
            (model, Cmd.none)
          else if model.constitution < 15 then
            ({model | constitution = model.constitution - 1, skillPts = model.skillPts + 1}, Cmd.none)
          else
            ({model | constitution = model.constitution - 1, skillPts = model.skillPts + 2}, Cmd.none)
        IntUp ->
          if model.intelligence < 14 then
            ({model | intelligence = model.intelligence + 1, skillPts = model.skillPts - 1}, Cmd.none)
          else if model.intelligence == 15 then
              (model, Cmd.none)
          else
            ({model | intelligence = model.intelligence + 1, skillPts = model.skillPts - 2}, Cmd.none)
        IntDn ->
          if model.intelligence == 8 then
            (model, Cmd.none)
          else if model.intelligence < 15 then
            ({model | intelligence = model.intelligence - 1, skillPts = model.skillPts + 1}, Cmd.none)
          else
            ({model | intelligence = model.intelligence - 1, skillPts = model.skillPts + 2}, Cmd.none)
        WisUp ->
          if model.wisdom < 14 then
            ({model | wisdom = model.wisdom + 1, skillPts = model.skillPts - 1}, Cmd.none)
          else if model.wisdom == 15 then
              (model, Cmd.none)
          else
            ({model | wisdom = model.wisdom + 1, skillPts = model.skillPts - 2}, Cmd.none)
        WisDn ->
          if model.wisdom == 8 then
            (model, Cmd.none)
          else if model.wisdom < 15 then
            ({model | wisdom = model.wisdom - 1, skillPts = model.skillPts + 1}, Cmd.none)
          else
            ({model | wisdom = model.wisdom - 1, skillPts = model.skillPts + 2}, Cmd.none)
        ChaUp ->
          if model.charisma < 14 then
            ({model | charisma = model.charisma + 1, skillPts = model.skillPts - 1}, Cmd.none)
          else if model.charisma == 15 then
              (model, Cmd.none)
          else
            ({model | charisma = model.charisma + 1, skillPts = model.skillPts - 2}, Cmd.none)
        ChaDn ->
          if model.charisma == 8 then
            (model, Cmd.none)
          else if model.charisma < 15 then
            ({model | charisma= model.charisma - 1, skillPts = model.skillPts + 1}, Cmd.none)
          else
            ({model | charisma = model.charisma - 1, skillPts = model.skillPts + 2}, Cmd.none)
        GetClass result ->
          case result of
            Ok val ->
              ({model | classAttr = val}, Cmd.none)
            Err error ->
              (errorHandler model error, Cmd.none)
        GetRace result ->
          case result of
            Ok val ->
              ({model | raceAttr = val}, Cmd.none)
            Err error ->
              (errorHandler model error, Cmd.none)
        GetBackground result ->
          case result of
            Ok val ->
              ({model | backgroundAttr=val}, Cmd.none)
            Err error ->
              (errorHandler model error, Cmd.none)
        CreateButton ->
          (model, Cmd.none)

--decoders
decodeClass : String -> Decode.Decoder ClassAttr
decodeClass str =
  Decode.succeed ClassAttr
    |> custom (at ["classes", str, "proBunus"] Decode.int)
    |> custom (at ["classes", str, "hp"] Decode.int)
    |> custom (at ["classes", str, "hpMode"] Decode.string)
    |> custom (at ["classes", str, "proArmor"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "proWeapon"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "proTools"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "savingThrows"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "skills"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "weapons"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "starterEq"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "cantrips"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "spells"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "dice"] Decode.string)
    |> custom (at ["classes", str, "features"] (Decode.list Decode.string))

decodeRace : String -> Decode.Decoder RaceAttr
decodeRace string =
    Decode.map8 RaceAttr
        (at ["races", string, "size"] Decode.string)
        (at ["races", string, "speed"] Decode.int)
        (at ["races", string, "strength"] Decode.int)
        (at ["races", string, "dextrerity"] Decode.int)
        (at ["races", string, "constitution"] Decode.int)
        (at ["races", string, "intelligence"] Decode.int)
        (at ["races", string, "wisdom"] Decode.int)
        (at ["races", string, "charisma"] Decode.int)

decodeBackground : String -> Decode.Decoder BackgroundAttr
decodeBackground string =
    Decode.map5 BackgroundAttr
        (at ["backgrounds", string, "languages"] Decode.string)
        (at ["backgrounds", string, "money"] Decode.int)
        (at ["backgrounds", string, "skills"] (Decode.list Decode.string))
        (at ["backgrounds", string, "feature"] Decode.string)
        (at ["backgrounds", string, "equipment"] Decode.string)


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

--view
view : Model -> Html Msg
view model =
    div [] [
      table [] [
        tr [] [
          td [] [ label [for "name"] [text "Name"]],
          td [] [input [type_ "text", placeholder "Name", value model.name, onInput Name] []]
          ],
        tr [] [
          td [] [ label [for "class"] [text "Class:"]],
          td [] [select [name "class", onInput ClassStr][
            option [value "Barbarian"] [text "Barbarian"],
            option [value "", selected True] [text ""]
            ]]
          ],
        tr [] [
          td [] [label [for "race"] [text "Race:"]],
          td [] [select [name "race", onInput RaceStr] [
            option [value "", selected True] [text ""],
            option [value "Dwarf"] [text "Dwarf"]
            ]]
          ],
        tr [] [
          td [] [label [for "bg"] [text "Background:"]],
          td [] [select [name "bg", onInput Background][
            option [value "", selected True] [text ""],
            option [value "Acolyte"] [text "Acolyte"]
            ]]
          ],
        tr [] [
          td [] [label [] [text "Str:"]],
          td [] [button [onClick StrUp] [text "+"], text (String.fromInt model.strength), button [onClick StrDn] [text "-"]]
          ],
        tr [] [
          td [] [text "Points remaining:"],
          td [] [text (String.fromInt model.skillPts)]
          ]
        ],
      table [] [
          tr [] [
            td [] [text "Name"],
            td [] [text model.name]
          ],
          tr [] [
            td [] [text "Class"],
            td [] [text model.classStr]
            ],
          tr [] [
            td [] [text "HP"],
            td [] [text (String.fromInt model.classAttr.hp)]
            ],
          tr [] [
            td [] [text "Race:"],
            td [] [text model.raceStr]
            ],
          tr [] [
            td [] [text "Speed:"],
            td [] [text (String.fromInt model.raceAttr.speed)]
            ]
          ],

          text model.error

    ]
