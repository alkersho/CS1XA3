module Main exposing (..)

import Html.Attributes exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (at)
import Json.Decode.Pipeline exposing (custom)
import Browser

-- main : Program flags  model msg
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
    created : Bool,
    skills : Skills
  }

type alias Skills = {
  --str
  athletics : Int,

  --dex
  acrobats : Int,
  slieghtOfHand : Int,
  stealth : Int,

  --int
  arcana : Int,
  history : Int,
  investigation : Int,
  nature : Int,
  religion : Int,

  --wis
  animalHandling : Int,
  insight : Int,
  medicine : Int,
  perception : Int,
  survival : Int,

  --cha
  deception : Int,
  intimidation : Int,
  performance : Int,
  persuasion : Int
  }
nullSkills : Skills
nullSkills =
    { athletics = 0, acrobats = 0, slieghtOfHand = 0, stealth = 0, arcana = 0, history = 0, investigation = 0, nature = 0, religion = 0, animalHandling = 0, insight = 0, medicine = 0, perception = 0, survival = 0, deception = 0, intimidation = 0, performance = 0, persuasion = 0 }

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
    created = False,
    skills = nullSkills}, Cmd.none)


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
          if model.classStr /= "" && model.raceStr /= "" && model.background /= "" then
            ({model | skills = (calcSkill model)}, Cmd.none)
          else
            ({model | error = "Please choose class, race and bg first"}, Cmd.none)


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
          td [] [button [onClick StrUp] [text "+"], text (String.fromInt model.strength), button [onClick StrDn] [text "-"],text <| String.fromInt <| (model.strength-10) //2 ]
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
            ],
          tr [] [
            td [] [button [onClick CreateButton] [text "Test Create"]]
            ]
          ],
          --
          table [] [
            tr [] [
              td [] [text "Athletics"],
              td [] [text <| String.fromInt model.skills.athletics]
              ],
            tr [] [
              td [] [text "Acrobats"],
              td [] [text <| String.fromInt model.skills.acrobats]
              ],
            tr [] [
              td [] [text "Slieght Of Hand"],
              td [] [text <| String.fromInt model.skills.slieghtOfHand]
              ],
            tr [] [
              td [] [text "Stealth"],
              td [] [text <| String.fromInt model.skills.stealth]
              ],
            tr [] [
              td [] [text "Arcana"],
              td [] [text <| String.fromInt model.skills.arcana]
              ],
            tr [] [
              td [] [text "History"],
              td [] [text <| String.fromInt model.skills.history]
              ],
            tr [] [
              td [] [text "Investigation"],
              td [] [text <| String.fromInt model.skills.investigation]
              ],
            tr [] [
              td [] [text "Nature "],
              td [] [text <| String.fromInt model.skills.nature]
              ],
            tr [] [
              td [] [text "Religion"],
              td [] [text <| String.fromInt model.skills.religion]
              ],
            tr [] [
              td [] [text "Animal Handling"],
              td [] [text <| String.fromInt model.skills.animalHandling]
              ],
            tr [] [
              td [] [text "Insight"],
              td [] [text <| String.fromInt model.skills.insight]
              ],
            tr [] [
              td [] [text "Medicine"],
              td [] [text <| String.fromInt model.skills.medicine]
              ],
            tr [] [
              td [] [text "Perception"],
              td [] [text <| String.fromInt model.skills.perception]
              ],
            tr [] [
              td [] [text "Survival"],
              td [] [text <| String.fromInt model.skills.survival]
              ],
            tr [] [
              td [] [text "Deception"],
              td [] [text <| String.fromInt model.skills.deception]
              ],
            tr [] [
              td [] [text "Intimidation"],
              td [] [text <| String.fromInt model.skills.intimidation]
              ],
            tr [] [
              td [] [text "Performance"],
              td [] [text <| String.fromInt model.skills.performance]
              ],
            tr [] [
              td [] [text "Persuasion"],
              td [] [text <| String.fromInt model.skills.persuasion]
              ]
          ],
          text model.error

    ]


addSkillFromStringList : Skills -> List String -> Int -> Skills
addSkillFromStringList sk s i =
  case s of
    "Athletics"::ss ->
      addSkillFromStringList {sk | athletics = sk.athletics + i} ss i
    "Acrobats"::ss ->
      addSkillFromStringList {sk | acrobats = sk.acrobats + i} ss i
    "Slieght Of Hand"::ss ->
      addSkillFromStringList {sk | slieghtOfHand = sk.slieghtOfHand + i} ss i
    "Stealth"::ss ->
      addSkillFromStringList {sk | stealth = sk.stealth + i} ss i
    "Arcana"::ss ->
      addSkillFromStringList {sk | arcana = sk.arcana + i} ss i
    "History"::ss ->
      addSkillFromStringList {sk | history = sk.history + i} ss i
    "Investigation"::ss ->
      addSkillFromStringList {sk | investigation = sk.investigation + i} ss i
    "Nature"::ss ->
      addSkillFromStringList {sk | nature = sk.nature + i} ss i
    "Religion"::ss ->
      addSkillFromStringList {sk | religion = sk.religion + i} ss i
    "Animal Handling"::ss ->
      addSkillFromStringList {sk | animalHandling = sk.animalHandling + i} ss i
    "Insight"::ss ->
      addSkillFromStringList {sk | insight = sk.insight + i} ss i
    "Medicine"::ss ->
      addSkillFromStringList {sk | medicine = sk.medicine + i} ss i
    "Perception"::ss ->
      addSkillFromStringList {sk | perception = sk.perception + i} ss i
    "Survival"::ss ->
      addSkillFromStringList {sk | survival = sk.survival + i} ss i
    "Deception"::ss ->
      addSkillFromStringList {sk | deception = sk.deception + i} ss i
    "Intimidation"::ss ->
      addSkillFromStringList {sk | intimidation = sk.intimidation + i} ss i
    "Performance"::ss ->
      addSkillFromStringList {sk | performance = sk.performance + i} ss i
    "Persuasion"::ss ->
      addSkillFromStringList {sk | persuasion = sk.persuasion + i} ss i
    [] ->
      sk
    _::ss ->
      addSkillFromStringList sk ss i

calcSkill : Model -> Skills
calcSkill model =
  let
    sk = { athletics = (model.strength - 10) // 2,
      acrobats = (model.dextrerity - 10) // 2,
      slieghtOfHand = (model.dextrerity - 10) // 2,
      stealth = (model.dextrerity - 10) // 2,
      arcana = (model.intelligence - 10) // 2,
      history = (model.intelligence - 10) // 2,
      investigation = (model.intelligence - 10) // 2,
      nature = (model.intelligence - 10) // 2,
      religion = (model.intelligence - 10) // 2,
      animalHandling = (model.wisdom - 10) // 2,
      insight = (model.wisdom - 10) // 2,
      medicine = (model.wisdom - 10) // 2,
      perception = (model.wisdom - 10) // 2,
      survival = (model.wisdom - 10) // 2,
      deception = (model.charisma - 10) // 2,
      intimidation = (model.charisma - 10) // 2,
      performance = (model.charisma - 10) // 2,
      persuasion = (model.charisma - 10) // 2 }
    skillsClass = model.classAttr.skills
    skillsBG = model.backgroundAttr.skills
  in addSkillFromStringList (addSkillFromStringList sk skillsClass model.classAttr.proBunus) skillsBG model.classAttr.proBunus
