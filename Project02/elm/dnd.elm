module Main exposing (..)

import Html.Attributes exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (at)
import Json.Decode.Pipeline exposing (custom)
import Browser
import Maybe exposing (withDefault)

main : Program () Model Msg
main =
  Browser.element {
    init = init,
    update = update,
    subscriptions = \_ ->Sub.none,
    view = view
  }

--Model
type alias Model = {
    stage : Int,
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
    skills : Skills,
    weaponSelection : List String,
    armorSelection : List String,
    weaponType : String,
    armorType : String,
    selectedWeapon : Weapon,
    selectedArmor : Armor
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
    weapons : List Weapon,
    starterEq: List String,
    cantrips : List String,
    spells : List String,
    dice : String,
    feautes: List String,
    imgUrl: String
  }
nullClassAttr : ClassAttr
nullClassAttr =
    { proBunus = 0, hp = 0, hpMode = "", proArmour = [], proWeapon = [], proTools = [], savingThrows = [], skills = [], weapons = [], starterEq = [], cantrips = [], spells = [], dice = "", feautes = [], imgUrl = "" }

type alias RaceAttr = {
    speed : Int,
    bigness : String,
    features : List String,
    strength : Int,
    dextrerity : Int,
    constitution : Int,
    intelligence : Int,
    wisdom : Int,
    charisma : Int,
    imgUrl : String
  }
nullRaceAttr : RaceAttr
nullRaceAttr =
    { speed = 0, bigness = "", features = [], strength = 0, dextrerity = 0, constitution = 0, intelligence = 0, wisdom = 0, charisma = 0, imgUrl = "" }

type alias BackgroundAttr = {
  languages : String,
  money : Float,
  skills : List String,
  feature: String,
  equipment: String
  }

nullBackgroundAttr : BackgroundAttr
nullBackgroundAttr =
    { languages = "", money = 0, skills = [], feature = "", equipment = "" }

type alias Weapon = {
    name : String,
    cost : Float,
    dmg : String,
    dmgType : String,
    weight : Int,
    prop : String
  }

nullWeapon : Weapon
nullWeapon =
    { name = "", cost = 0, dmg = "", dmgType = "", weight = 0, prop = "" }

type alias Armor = {
    name : String,
    baseAC : Int,
    stealthDis : Bool,
    cost : Float,
    weight : Int,
    statMod : String,
    modMax : Int
  }

nullArmor : Armor
nullArmor =
    { name = "", baseAC = 0, stealthDis = False, cost = 0, weight = 0, statMod = "", modMax = 0 }
--msgs
type Msg = Name String
         | ClassStr String
         | RaceStr String
         | Background String
         | Alignment String
         | WeaponString String
         | ArmorString String
         | SelectWeapon String
         | SelectArmor String
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
         | GetWeaponString (Result Http.Error (List String))
         | GetArmorString (Result Http.Error (List String))
         | GetWeapon (Result Http.Error Weapon)
         | GetArmor (Result Http.Error Armor)
         | NextStep

--init
init : () -> (Model, Cmd Msg)
init _ =
    ( { stage = 0,
    name = "",
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
    skills = nullSkills,
    weaponSelection = [],
    armorSelection = [],
    weaponType = "",
    armorType = "",
    selectedWeapon = nullWeapon,
    selectedArmor = nullArmor}, Cmd.none)

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
        WeaponString str ->
          ({model | weaponType = str}, (Http.get { url = "data.json", expect = Http.expectJson GetWeaponString (getWeaponNames str) }))
        ArmorString str ->
          ({model | armorType = str}, (Http.get { url = "data.json", expect = Http.expectJson GetArmorString (getArmorNames str) }))
        SelectWeapon str ->
          (model, Http.get { url = "data.json", expect = Http.expectJson GetWeapon <| decodeWeapon  (withDefault 0 <| String.toInt str) model.weaponType })
        SelectArmor i ->
          (model, Http.get { url = "data.json", expect = Http.expectJson GetArmor (decodeArmor (withDefault 0 <|  String.toInt i) model.armorType) })
        StrDn ->
          if model.strength == 8 then
            (model, Cmd.none)
          else if model.strength < 14 then
            ({model | strength = model.strength - 1, skillPts = model.skillPts + 1}, Cmd.none)
          else
            ({model | strength = model.strength - 1, skillPts = model.skillPts + 2}, Cmd.none)
        StrUp ->
          if model.strength < 13 then
            if model.skillPts - 1 >= 0 then
              ({model | strength = model.strength + 1, skillPts =  model.skillPts - 1}, Cmd.none)
            else
              (model, Cmd.none)
          else if model.strength == 15 then
              (model, Cmd.none)
          else
            if model.skillPts - 2 >= 0 then
                ({model | strength = model.strength + 1, skillPts = model.skillPts - 2}, Cmd.none)
            else
                (model, Cmd.none)
        DexDn ->
          if model.dextrerity == 8 then
            (model, Cmd.none)
          else if model.dextrerity < 14 then
            ({model | dextrerity = model.dextrerity - 1, skillPts = model.skillPts + 1}, Cmd.none)
          else
            ({model | dextrerity = model.dextrerity - 1, skillPts = model.skillPts + 2}, Cmd.none)
        DexUp ->
          if model.dextrerity < 13 then
            if model.skillPts - 1 >= 0 then
              ({model | dextrerity = model.dextrerity + 1, skillPts =  model.skillPts - 1}, Cmd.none)
            else
              (model, Cmd.none)
          else if model.dextrerity == 15 then
              (model, Cmd.none)
          else
            if model.skillPts - 2 >= 0 then
                ({model | dextrerity = model.dextrerity + 1, skillPts = model.skillPts - 2}, Cmd.none)
            else
                (model, Cmd.none)
        ConDn ->
          if model.constitution == 8 then
            (model, Cmd.none)
          else if model.constitution < 14 then
            ({model | constitution = model.constitution - 1, skillPts = model.skillPts + 1}, Cmd.none)
          else
            ({model | constitution = model.constitution - 1, skillPts = model.skillPts + 2}, Cmd.none)
        ConUp ->
          if model.constitution < 13 then
            if model.skillPts - 1 >= 0 then
              ({model | constitution = model.constitution + 1, skillPts =  model.skillPts - 1}, Cmd.none)
            else
              (model, Cmd.none)
          else if model.constitution == 15 then
              (model, Cmd.none)
          else
            if model.skillPts - 2 >= 0 then
                ({model | constitution = model.constitution + 1, skillPts = model.skillPts - 2}, Cmd.none)
            else
                (model, Cmd.none)
        IntDn ->
          if model.intelligence == 8 then
            (model, Cmd.none)
          else if model.intelligence < 14 then
            ({model | intelligence = model.intelligence - 1, skillPts = model.skillPts + 1}, Cmd.none)
          else
            ({model | intelligence = model.intelligence - 1, skillPts = model.skillPts + 2}, Cmd.none)
        IntUp ->
          if model.intelligence < 13 then
            if model.skillPts - 1 >= 0 then
              ({model | intelligence = model.intelligence + 1, skillPts =  model.skillPts - 1}, Cmd.none)
            else
              (model, Cmd.none)
          else if model.intelligence == 15 then
              (model, Cmd.none)
          else
            if model.skillPts - 2 >= 0 then
                ({model | intelligence = model.intelligence + 1, skillPts = model.skillPts - 2}, Cmd.none)
            else
                (model, Cmd.none)
        WisDn ->
          if model.wisdom == 8 then
            (model, Cmd.none)
          else if model.wisdom < 14 then
            ({model | wisdom = model.wisdom - 1, skillPts = model.skillPts + 1}, Cmd.none)
          else
            ({model | wisdom = model.wisdom - 1, skillPts = model.skillPts + 2}, Cmd.none)
        WisUp ->
          if model.wisdom < 13 then
            if model.skillPts - 1 >= 0 then
              ({model | wisdom = model.wisdom + 1, skillPts =  model.skillPts - 1}, Cmd.none)
            else
              (model, Cmd.none)
          else if model.wisdom == 15 then
              (model, Cmd.none)
          else
            if model.skillPts - 2 >= 0 then
                ({model | wisdom = model.wisdom + 1, skillPts = model.skillPts - 2}, Cmd.none)
            else
                (model, Cmd.none)
        ChaDn ->
          if model.charisma == 8 then
            (model, Cmd.none)
          else if model.charisma < 14 then
            ({model | charisma= model.charisma - 1, skillPts = model.skillPts + 1}, Cmd.none)
          else
            ({model | charisma = model.charisma - 1, skillPts = model.skillPts + 2}, Cmd.none)
        ChaUp ->
          if model.charisma < 13 then
            if model.skillPts - 1 >= 0 then
              ({model | charisma = model.charisma + 1, skillPts =  model.skillPts - 1}, Cmd.none)
            else
              (model, Cmd.none)
          else if model.charisma == 15 then
              (model, Cmd.none)
          else
            if model.skillPts - 2 >= 0 then
                ({model | charisma = model.charisma + 1, skillPts = model.skillPts - 2}, Cmd.none)
            else
                (model, Cmd.none)
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
        GetWeaponString result ->
          case result of
            Ok val ->
              ({model | weaponSelection = val}, Cmd.none)
            Err val ->
              ((errorHandler model val), Cmd.none)
        GetArmorString result ->
          case result of
            Ok val ->
              ({model | armorSelection = val}, Cmd.none)
            Err val ->
              ((errorHandler model val), Cmd.none)
        GetWeapon result ->
          case result of
            Ok val ->
              ({model | selectedWeapon = val}, Cmd.none)
            Err error ->
              (errorHandler model error, Cmd.none)
        GetArmor result ->
          case result of
            Ok val ->
              ({model | selectedArmor = val}, Cmd.none)
            Err error ->
              (errorHandler model error, Cmd.none)
        NextStep ->
          if model.stage == 0 then
              if model.classAttr /= nullClassAttr && model.raceAttr /= nullRaceAttr && model.backgroundAttr /= nullBackgroundAttr then
                ({model | stage = 1, skills = (calcSkill model), armorType = "light", weaponType = "Simple Melee"}, Cmd.batch [
                (Http.get { url = "data.json", expect = Http.expectJson GetWeaponString (getWeaponNames "Simple Melee") }),
                (Http.get { url = "data.json", expect = Http.expectJson GetArmorString (getArmorNames "light") })])
              else
                ({model | error = "Please choose a Class, Race and Background."}, Cmd.none)
          else if model.stage == 1 then
              if model.backgroundAttr.money - (model.selectedArmor.cost + model.selectedWeapon.cost) < 0 then
                ({model | error = "Not enough money to buy items!"}, Cmd.none)
              else
                ({model | stage = 2}, Cmd.none)
          else
              ({model | error = "WTF HAPPENED!!! " ++ String.fromInt model.stage}, Cmd.none)

--decoders
decodeClass : String -> Decode.Decoder ClassAttr
decodeClass str =
  let
      decodeWeaponClass = Decode.succeed Weapon
        |> custom (at ["name"] Decode.string)
        |> custom (at ["cost"] Decode.float)
        |> custom (at ["dmg"] Decode.string)
        |> custom (at ["dmgtp"] Decode.string)
        |> custom (at ["weight"] Decode.int)
        |> custom (at ["prop"] Decode.string)
  in
   Decode.succeed ClassAttr
    |> custom (at ["classes", str, "proBunus"] Decode.int)
    |> custom (at ["classes", str, "hp"] Decode.int)
    |> custom (at ["classes", str, "hpMode"] Decode.string)
    |> custom (at ["classes", str, "proArmor"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "proWeapon"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "proTools"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "savingThrows"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "skills"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "weapons"] (Decode.list decodeWeaponClass))
    |> custom (at ["classes", str, "starterEq"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "cantrips"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "spells"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "dice"] Decode.string)
    |> custom (at ["classes", str, "features"] (Decode.list Decode.string))
    |> custom (at ["classes", str, "img-url"] Decode.string)

decodeRace : String -> Decode.Decoder RaceAttr
decodeRace string =
    Decode.succeed RaceAttr
        |> custom (at ["races", string, "speed"] Decode.int)
        |> custom (at ["races", string, "size"] Decode.string)
        |> custom (at ["races", string, "features"] (Decode.list Decode.string))
        |> custom (at ["races", string, "strength"] Decode.int)
        |> custom (at ["races", string, "dextrerity"] Decode.int)
        |> custom (at ["races", string, "constitution"] Decode.int)
        |> custom (at ["races", string, "intelligence"] Decode.int)
        |> custom (at ["races", string, "wisdom"] Decode.int)
        |> custom (at ["races", string, "charisma"] Decode.int)
        |> custom (at ["races", string, "img-url"] Decode.string)

decodeBackground : String -> Decode.Decoder BackgroundAttr
decodeBackground string =
    Decode.map5 BackgroundAttr
        (at ["backgrounds", string, "languages"] Decode.string)
        (at ["backgrounds", string, "money"] Decode.float)
        (at ["backgrounds", string, "skills"] (Decode.list Decode.string))
        (at ["backgrounds", string, "feature"] Decode.string)
        (at ["backgrounds", string, "equipment"] Decode.string)

decodeWeapon : Int -> String -> Decode.Decoder Weapon
decodeWeapon i str = Decode.succeed Weapon
  |> custom (at ["Weapons", str] (Decode.index i (Decode.field "name" Decode.string)))
  |> custom (at ["Weapons", str] (Decode.index i (Decode.field "cost" Decode.float)))
  |> custom (at ["Weapons", str] (Decode.index i (Decode.field "dmg" Decode.string)))
  |> custom (at ["Weapons", str] (Decode.index i (Decode.field "dmgtp" Decode.string)))
  |> custom (at ["Weapons", str] (Decode.index i (Decode.field "weight" Decode.int)))
  |> custom (at ["Weapons", str] (Decode.index i (Decode.field "prop" Decode.string)))

decodeArmor : Int -> String -> Decode.Decoder Armor
decodeArmor i str =
  Decode.succeed Armor
    |> custom (at ["armours", str] (Decode.index i (Decode.field "name" Decode.string)))
    |> custom (at ["armours", str] (Decode.index i (Decode.field "baseAC" Decode.int)))
    |> custom (at ["armours", str] (Decode.index i (Decode.field "stealthDis" Decode.bool)))
    |> custom (at ["armours", str] (Decode.index i (Decode.field "cost" Decode.float)))
    |> custom (at ["armours", str] (Decode.index i (Decode.field "weight" Decode.int)))
    |> custom (at ["armours", str] (Decode.index i (Decode.field "mod" Decode.string)))
    |> custom (at ["armours", str] (Decode.index i (Decode.field "modMax" Decode.int)))

--view
--temp layout
-- view : Model -> Html Msg
-- view model =
--     div [] [
--       table [] [
--         tr [] [
--           td [] [ label [for "name"] [text "Name"]],
--           td [] [input [type_ "text", placeholder "Name", value model.name, onInput Name] []]
--           ],
--         tr [] [
--           td [] [ label [for "class"] [text "Class:"]],
--           td [] [select [name "class", onInput ClassStr][
--             option [value "Barbarian"] [text "Barbarian"],
--             option [value "", selected True] [text ""]
--             ]]
--           ],
--         tr [] [
--           td [] [label [for "race"] [text "Race:"]],
--           td [] [select [name "race", onInput RaceStr] [
--             option [value "", selected True] [text ""],
--             option [value "Dwarf"] [text "Dwarf"]
--             ]]
--           ],
--         tr [] [
--           td [] [label [for "bg"] [text "Background:"]],
--           td [] [select [name "bg", onInput Background][
--             option [value "", selected True] [text ""],
--             option [value "Acolyte"] [text "Acolyte"]
--             ]]
--           ],
--         tr [] [
--           td [] [label [] [text "Str:"]],
--           td [] [button [onClick StrUp] [text "+"], text (String.fromInt model.strength), button [onClick StrDn] [text "-"],text <| String.fromInt <| (model.strength-10) //2 ]
--           ],
--         tr [] [
--           td [] [text "Points remaining:"],
--           td [] [text (String.fromInt model.skillPts)]
--           ]
--         ],
--       table [] [
--           tr [] [
--             td [] [text "Name"],
--             td [] [text model.name]
--           ],
--           tr [] [
--             td [] [text "Class"],
--             td [] [text model.classStr]
--             ],
--           tr [] [
--             td [] [text "HP"],
--             td [] [text (String.fromInt model.classAttr.hp)]
--             ],
--           tr [] [
--             td [] [text "Race:"],
--             td [] [text model.raceStr]
--             ],
--           tr [] [
--             td [] [text "Speed:"],
--             td [] [text (String.fromInt model.raceAttr.speed)]
--             ],
--           tr [] [
--             td [] [button [onClick CreateButton] [text "Test Create"]]
--             ]
--           ],
--           --
--           table [] [
--             tr [] [
--               td [] [text "Athletics"],
--               td [] [text <| String.fromInt model.skills.athletics]
--               ],
--             tr [] [
--               td [] [text "Acrobats"],
--               td [] [text <| String.fromInt model.skills.acrobats]
--               ],
--             tr [] [
--               td [] [text "Slieght Of Hand"],
--               td [] [text <| String.fromInt model.skills.slieghtOfHand]
--               ],
--             tr [] [
--               td [] [text "Stealth"],
--               td [] [text <| String.fromInt model.skills.stealth]
--               ],
--             tr [] [
--               td [] [text "Arcana"],
--               td [] [text <| String.fromInt model.skills.arcana]
--               ],
--             tr [] [
--               td [] [text "History"],
--               td [] [text <| String.fromInt model.skills.history]
--               ],
--             tr [] [
--               td [] [text "Investigation"],
--               td [] [text <| String.fromInt model.skills.investigation]
--               ],
--             tr [] [
--               td [] [text "Nature "],
--               td [] [text <| String.fromInt model.skills.nature]
--               ],
--             tr [] [
--               td [] [text "Religion"],
--               td [] [text <| String.fromInt model.skills.religion]
--               ],
--             tr [] [
--               td [] [text "Animal Handling"],
--               td [] [text <| String.fromInt model.skills.animalHandling]
--               ],
--             tr [] [
--               td [] [text "Insight"],
--               td [] [text <| String.fromInt model.skills.insight]
--               ],
--             tr [] [
--               td [] [text "Medicine"],
--               td [] [text <| String.fromInt model.skills.medicine]
--               ],
--             tr [] [
--               td [] [text "Perception"],
--               td [] [text <| String.fromInt model.skills.perception]
--               ],
--             tr [] [
--               td [] [text "Survival"],
--               td [] [text <| String.fromInt model.skills.survival]
--               ],
--             tr [] [
--               td [] [text "Deception"],
--               td [] [text <| String.fromInt model.skills.deception]
--               ],
--             tr [] [
--               td [] [text "Intimidation"],
--               td [] [text <| String.fromInt model.skills.intimidation]
--               ],
--             tr [] [
--               td [] [text "Performance"],
--               td [] [text <| String.fromInt model.skills.performance]
--               ],
--             tr [] [
--               td [] [text "Persuasion"],
--               td [] [text <| String.fromInt model.skills.persuasion]
--               ]
--           ],
--           text model.error
--
--     ]

view : Model -> Html Msg
view model =
    case model.stage of
        0 ->
            chrView model
        1 ->
          eqView model
        2 ->
          finalView model
        _ ->
          text "Out of bounds"

chrView : Model -> Html Msg
chrView model =
  div [] [
    node "link" [rel "stylesheet", href "https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"] []
    ,div
      [ class "container" ]
      [ div
        [ class "container-fluid" ]
        [ table
          []
          [ tr
            []
            [ td
              []
              [ label
                [ for "name" ]
                [ text "Name:" ]
              ]
            , td
              []
              [ input
                [ type_ "text", placeholder "Name", onInput Name ]
                []
              ]
            ]
          ]
        ]
      , div
        [ class "row" ]
        [ div
          [ class "col-md-4" ]

          [
            text "Class:"
            , select
            [ name "class", onInput ClassStr ]
            [ option
              [ value "", selected True ]
              []
            , option
              [ value "Barbarian" ]
              [ text "Barbarian" ]
            ]
          ]
        , div
          [ class "col-md-8" ]
          [ img [src model.classAttr.imgUrl, style "max-height" "250px"] [] ]
        ]
      , div
        [ class "row" ]
        [ div
          [ class "col-md-4" ]
          [ text "Race:"
            , select
            [ name "race", onInput RaceStr]
            [ option
              [ value "", selected True ]
              []
            , option
              [ value "Dwarf" ]
              [ text "Dwarf" ]
            ]
          ]
        , div
          [ class "col-md-8" ]
          [ img [src model.raceAttr.imgUrl, style "max-height" "250px"] [] ]
        ]
      , div
        [class "row"]
        [ div
          [class "col-md-4"]
          [ text "Background:"
          , select
          [ name "bg", onInput Background ]
          [ option
            [ value "", selected True ]
            []
          , option
            [ value "Acolyte" ]
            [ text "Acolyte" ]
          ]
          ]
        ]
      , table
        [style "width" "75%", style "margin-right" "auto", style "margin-left" "auto"]
        [ tr
          []
          [ td
            []
            [ text "Str" ]
          , td
            []
            [ text "Dex" ]
          , td
            []
            [ text "Con" ]
          , td
            []
            [ text "Int" ]
          , td
            []
            [ text "Wis" ]
          , td
            []
            [ text "Cha" ]
          ]
        , tr
          []
          [ td [] [ button [onClick StrUp] [text "⋀"] ]
          , td [] [ button [onClick DexUp] [text "⋀"] ]
          , td [] [ button [onClick ConUp] [text "⋀"] ]
          , td [] [ button [onClick IntUp] [text "⋀"] ]
          , td [] [ button [onClick WisUp] [text "⋀"] ]
          , td [] [ button [onClick ChaUp] [text "⋀"] ]
          ]
        , tr
          []
          [ td
            []
            [ text <| String.fromInt model.strength ]
          , td
            []
            [ text <| String.fromInt model.dextrerity ]
          , td
            []
            [ text <| String.fromInt model.constitution ]
          , td
            []
            [ text <| String.fromInt model.intelligence ]
          , td
            []
            [ text <| String.fromInt model.wisdom ]
          , td
            []
            [ text <| String.fromInt model.charisma ]
          ]
        , tr [] [ td [] [ button [onClick StrDn] [text "⋁"] ]
          , td [] [ button [onClick DexDn] [text "⋁"] ]
          , td [] [ button [onClick ConDn] [text "⋁"] ]
          , td [] [ button [onClick IntDn] [text "⋁"] ]
          , td [] [ button [onClick WisDn] [text "⋁"] ]
          , td [] [ button [onClick ChaDn] [text "⋁"] ]
          ]
        ],
        text <| "Remaining Skill Points: " ++ String.fromInt model.skillPts
      , button [onClick NextStep] [text "Next ->"]
      , text model.error
      ]
  ]

eqView : Model -> Html Msg
eqView model =
    div [] [
      node "link" [rel "stylesheet", href "https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"] []
      , div [class "container"] [
        table [][
          tr [] [td [] [],td [] [],td [] []
            ,td [] [text "Cost: "]
            ],
          tr [] [
            td [] [text "Weapon:"],
            td [] [select [onInput WeaponString] [
              option [value "Simple Melee"] [text "Simple Melee"],
              option [value "Simple Ranged"] [text "Simple Ranged"],
              option [value "Martial Melee"] [text "Martial Melee"],
              option [value "Martial Ranged"] [text "Martial Ranged"]
            ]],
            td [] [select [onInput SelectWeapon] (weaponsOptions model.weaponSelection)],
            td [] [text <| String.fromFloat model.selectedWeapon.cost]
        ],
        tr [] [
          td [] [text "Armor:"],
          td [] [select [onInput ArmorString] [
            option [value "light"] [text "Light"],
            option [value "medium"] [text "Medium"],
            option [value "heavy"] [text "Heavy"]
          ]],
          td [] [select [onInput SelectArmor] (armorOptions model.armorSelection)],
          td [] [text <| String.fromFloat model.selectedArmor.cost]

        ],
        tr [] [
          td [] [text <| "Money Available: " ++ String.fromFloat model.backgroundAttr.money]
        ]
      ],
        text "Equipment From Class:",
        ul [] (classEq model),
        button [onClick NextStep] [text "Create!"],
        text model.error
      ]
    ]

classEq : Model -> List (Html Msg)
classEq model =
    let
        classAux ls =
          case ls of
            s::l ->
              li [] [text s]:: classAux l
            [] ->
              []
    in classAux model.classAttr.starterEq

finalView : Model -> Html Msg
finalView model =
    div [] [
      node "link" [rel "stylesheet", href "https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"] [],
      table [style "width" "75%", style "margin-right" "auto", style "margin-left" "auto", style "text-align" "center"] [
        tr [] [
          td [] [text model.name],
          td [] [text model.classStr],
          td [] [text model.raceStr],
          td [] [text model.background]
        ]
      ],
      --stats and images
      div [class "row"] [
        div [class "col-lg"] [
          table [style "width" "75%", style "margin-right" "25%"] [
            tr [] [
              td [] [
                table [] [
                  tr [] [
                    td [] [text "Max HP:"], td [] [text <| getHP model]
                  ],
                  tr [] [
                    td [] [text "Attack:"], td [] [text model.classAttr.dice]
                  ],
                  tr [] [
                    td [] [text "Defence:"], td [] [text <| getDef model]
                  ],
                  tr [] [
                    td [] [text "Speed:"], td [] [text <| String.fromInt model.raceAttr.speed]
                  ],
                  tr [] [
                    td [] [text "Money:"] ,  td [] [text <| String.fromFloat <| model.backgroundAttr.money - model.selectedArmor.cost - model.selectedWeapon.cost]
                  ]
                ]
              ],
              td [] [
                table [] [
                  tr [] [
                    td [] [text "Strength"], td [] [text <| (String.fromInt model.strength) ++ " (" ++ (String.fromInt ((model.strength - 10) //2)) ++")" ]
                  ],
                  tr [] [
                    td [] [text "Dextrerity"], td [] [text <| (String.fromInt model.dextrerity) ++ " (" ++ (String.fromInt ((model.dextrerity - 10) //2)) ++")" ]
                  ],
                  tr [] [
                    td [] [text "Intelligence"], td [] [text <| (String.fromInt model.intelligence) ++ " (" ++ (String.fromInt ((model.intelligence - 10) //2)) ++")" ]
                  ],
                  tr [] [
                    td [] [text "Wisdom"], td [] [text <| (String.fromInt model.wisdom) ++ " (" ++ (String.fromInt ((model.wisdom - 10) //2)) ++")" ]
                  ],
                  tr [] [
                    td [] [text "Constitution"], td [] [text <| (String.fromInt model.constitution) ++ " (" ++ (String.fromInt ((model.constitution - 10) //2)) ++")" ]
                  ],
                  tr [] [
                    td [] [text "Charisma"], td [] [text <| (String.fromInt model.charisma) ++ " (" ++ (String.fromInt ((model.charisma - 10) //2)) ++")" ]
                  ]
                ]
              ],
              td [] [
                table [] [
                  tr [] [
                    td [] [text "Athletics"], td [] [text <| String.fromInt model.skills.athletics]
                  ],
                  tr [] [
                    td [] [text "Acrobats"], td [] [text <| String.fromInt model.skills.acrobats]
                  ],
                  tr [] [
                    td [] [text "Slieght of Hand"], td [] [text <| String.fromInt model.skills.slieghtOfHand]
                  ],
                  tr [] [
                    td [] [text "Stealth"], td [] [text <| String.fromInt model.skills.stealth]
                  ],
                  tr [] [
                    td [] [text "Arcana"], td [] [text <| String.fromInt model.skills.arcana]
                  ],
                  tr [] [
                    td [] [text "History"], td [] [text <| String.fromInt model.skills.history]
                  ],
                  tr [] [
                    td [] [text "Investigation"], td [] [text <| String.fromInt model.skills.investigation]
                  ],
                  tr [] [
                    td [] [text "Nature"], td [] [text <| String.fromInt model.skills.nature]
                  ],
                  tr [] [
                    td [] [text "Religion"], td [] [text <| String.fromInt model.skills.religion]
                  ],
                  tr [] [
                    td [] [text "Animal Handling"], td [] [text <| String.fromInt model.skills.animalHandling]
                  ],
                  tr [] [
                    td [] [text "Insight"], td [] [text <| String.fromInt model.skills.insight]
                  ],
                  tr [] [
                    td [] [text "Medicine"], td [] [text <| String.fromInt model.skills.medicine]
                  ],
                  tr [] [
                    td [] [text "Perception"], td [] [text <| String.fromInt model.skills.perception]
                  ],
                  tr [] [
                    td [] [text "Survival"], td [] [text <| String.fromInt model.skills.survival]
                  ],
                  tr [] [
                    td [] [text "Deception"], td [] [text <| String.fromInt model.skills.deception]
                  ],
                  tr [] [
                    td [] [text "Intimidation"], td [] [text <| String.fromInt model.skills.intimidation]
                  ],
                  tr [] [
                    td [] [text "Performance"], td [] [text <| String.fromInt model.skills.performance]

                  ],
                  tr [] [
                    td [] [text "Persuasion"], td [] [text <| String.fromInt model.skills.persuasion]
                  ]
                ]
              ]
            ]
          ]
        ],
        div [class "col-lg"] [
          img [src model.classAttr.imgUrl, style "max-width" "250px"] [],
          img [src model.raceAttr.imgUrl, style "max-width" "250px"] []
        ]
      ],
      --Features and Proficiencies
      div [class "row"] [
        div [class "col-lg"] [
          text "Armor Proficiency",
          ul [] <| List.map (\a -> li [] [text a]) model.classAttr.proArmour,
          text "Weapon Proficiency",
          ul [] <| List.map (\x -> li [] [text x]) model.classAttr.proWeapon,
          text "Tools Proficiency",
          ul [] <| List.map (\x -> li [] [text x]) model.classAttr.proTools,
          text "Class Features",
          ul [] <| List.map (\x -> li [] [text x]) model.classAttr.feautes,
          text "Race Features",
          ul [] <| List.map (\x -> li [] [text x]) model.raceAttr.features,
          text "Background Features",
          ul [] [li [] [text model.backgroundAttr.feature]]
        ],
        div [class "col-lg"] [
          text "Equipment",
          ul [] <| List.map (\x -> li [] [text x]) model.classAttr.starterEq ++ [li [] [text model.backgroundAttr.equipment]]
        ]
      ]
  ]

getHP : Model -> String
getHP model =
    case model.classAttr.hpMode of
        "str" ->
            String.fromInt <| model.classAttr.hp + (model.strength - 10) //2
        "dex" ->
            String.fromInt <| model.classAttr.hp + (model.dextrerity - 10) //2
        "int" ->
            String.fromInt <| model.classAttr.hp + (model.intelligence - 10) //2
        "wis" ->
            String.fromInt <| model.classAttr.hp + (model.wisdom - 10) //2
        "con" ->
            String.fromInt <| model.classAttr.hp + (model.constitution - 10) //2
        "cha" ->
            String.fromInt <| model.classAttr.hp + (model.charisma - 10) //2

        _ ->
          String.fromInt model.classAttr.hp

getDef : Model -> String
getDef model =
    case model.selectedArmor.statMod of
        "str" ->
          String.fromInt <| model.selectedArmor.baseAC + (model.strength - 10) //2 + model.classAttr.proBunus
        "dex" ->
          String.fromInt <| model.selectedArmor.baseAC + (model.dextrerity - 10) //2 + model.classAttr.proBunus
        "int" ->
          String.fromInt <| model.selectedArmor.baseAC + (model.intelligence - 10) //2 + model.classAttr.proBunus
        "wis" ->
          String.fromInt <| model.selectedArmor.baseAC + (model.wisdom - 10) //2 + model.classAttr.proBunus
        "con" ->
          String.fromInt <| model.selectedArmor.baseAC + (model.constitution - 10) //2 + model.classAttr.proBunus
        "cha" ->
          String.fromInt <| model.selectedArmor.baseAC + (model.charisma - 10) //2 + model.classAttr.proBunus
        _ ->
            String.fromInt <| model.selectedArmor.baseAC + model.classAttr.proBunus

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

--weapon list handling
getWeaponNames : String -> Decode.Decoder (List String)
getWeaponNames str =
  at ["Weapons", str] <| Decode.list weaponNamesDecoder

weaponNamesDecoder : Decode.Decoder String
weaponNamesDecoder =
  Decode.field "name" Decode.string

weaponsOptions : (List String) -> List (Html Msg)
weaponsOptions xs =
  let
    weaponsOptionsAux n ys =
      case ys of
        y::zs ->
          option [value (String.fromInt n)] [text y]:: weaponsOptionsAux (n+1) zs
        [] ->
          []
  in weaponsOptionsAux 0 xs

--Armor lists handling
getArmorNames : String -> Decode.Decoder (List String)
getArmorNames string =
    at ["armours", string] <| Decode.list armorNamesDecoder

armorNamesDecoder : Decode.Decoder String
armorNamesDecoder =
    Decode.field "name" Decode.string

armorOptions : (List String) -> List (Html Msg)
armorOptions xs =
  let
    weaponsOptionsAux n ys =
      case ys of
        y::zs ->
          option [value (String.fromInt n)] [text y]:: weaponsOptionsAux (n+1) zs
        [] ->
          []
  in weaponsOptionsAux 0 xs

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
