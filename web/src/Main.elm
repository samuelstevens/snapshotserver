module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode
import Task
import Time



-- MODEL


type alias Model =
    { currentPhase : TimePhase
    , temperature : Int
    , currentQuote : String
    }


type TimePhase
    = Dawn
    | Morning
    | Midday
    | Afternoon
    | Evening
    | Night


type alias PhaseConfig =
    { name : String
    , phaseLabel : String
    , weatherPoetry : List String
    , wisdomSource : String
    , attribution : String
    , symbol : String
    }


type alias Snapshot =
    { unix_ms : Int
    , quote : String
    , phase : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { currentPhase = Dawn
      , temperature = 22
      , currentQuote = ""
      }
    , Cmd.batch
        [ Task.perform GotTime Time.now
        , fetchSnapshot
        ]
    )



-- UPDATE


type Msg
    = GotTime Time.Posix
    | Tick Time.Posix
    | GotSnapshot (Result Http.Error Snapshot)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTime time ->
            ( { model | currentPhase = timeToPhase time }
            , Cmd.none
            )

        Tick time ->
            ( { model | currentPhase = timeToPhase time }
            , fetchSnapshot
            )

        GotSnapshot result ->
            case result of
                Ok snapshot ->
                    ( { model | currentQuote = snapshot.quote }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )


timeToPhase : Time.Posix -> TimePhase
timeToPhase time =
    let
        hour =
            Time.toHour Time.utc time
    in
    if hour >= 5 && hour < 7 then
        Dawn

    else if hour >= 7 && hour < 11 then
        Morning

    else if hour >= 11 && hour < 15 then
        Midday

    else if hour >= 15 && hour < 18 then
        Afternoon

    else if hour >= 18 && hour < 21 then
        Evening

    else
        Night



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every (60 * 1000) Tick



-- Check every minute
-- HTTP


fetchSnapshot : Cmd Msg
fetchSnapshot =
    Http.get
        { url = "/api/snapshot"
        , expect = Http.expectJson GotSnapshot snapshotDecoder
        }


snapshotDecoder : Decode.Decoder Snapshot
snapshotDecoder =
    Decode.map3 Snapshot
        (Decode.field "unix_ms" Decode.int)
        (Decode.field "quote" Decode.string)
        (Decode.field "phase" Decode.string)



-- VIEW


view : Model -> Html Msg
view model =
    let
        config =
            getPhaseConfig model.currentPhase

        phaseClasses =
            getPhaseClasses model.currentPhase
    in
    div [ class <| "min-h-screen transition-all duration-2000 ease-in-out " ++ phaseClasses.container ]
        [ -- Background overlay
          div [ class <| "absolute inset-0 pointer-events-none transition-all duration-2000 " ++ phaseClasses.overlay ] []

        -- Main container
        , div [ class "relative z-10 h-screen grid grid-rows-[1fr_auto_1fr] p-10" ]
            [ -- Weather section
              div [ class "flex items-center justify-center text-center" ]
                [ div []
                    [ -- Phase indicator
                      div [ class <| "transition-all duration-2000 mb-8 opacity-60 " ++ phaseClasses.phaseLabel ]
                        [ text config.phaseLabel ]

                    -- Temperature with symbol
                    , div [ class "relative mb-8" ]
                        [ span [ class <| "absolute -top-10 left-1/2 -translate-x-1/2 text-3xl opacity-30" ]
                            [ text config.symbol ]
                        , div [ class <| "transition-all duration-2000 " ++ phaseClasses.temperature ]
                            [ text (String.fromInt model.temperature ++ "°") ]
                        ]

                    -- Weather conditions
                    , div [ class <| "text-base leading-relaxed opacity-70 " ++ phaseClasses.conditions ]
                        (List.map (\line -> div [] [ text line ]) config.weatherPoetry)
                    ]
                ]

            -- Separator
            , div [ class "my-10" ]
                [ div [ class <| "h-px opacity-30 " ++ phaseClasses.separator ] [] ]

            -- Wisdom section
            , div [ class "flex items-center justify-center text-center" ]
                [ div [ class "max-w-4xl" ]
                    [ -- Wisdom source
                      div [ class <| "mb-8 text-xs uppercase tracking-wider opacity-50 transition-all duration-2000 " ++ phaseClasses.wisdomSource ]
                        [ text config.wisdomSource ]

                    -- Wisdom text
                    , div [ class <| "mb-8 italic opacity-90 transition-all duration-2000 " ++ phaseClasses.wisdomText ]
                        [ text
                            (if String.isEmpty model.currentQuote then
                                ""

                             else
                                model.currentQuote
                            )
                        ]

                    -- Attribution
                    , div [ class "text-sm opacity-40 italic" ]
                        [ text config.attribution ]
                    ]
                ]
            ]
        ]


getPhaseConfig : TimePhase -> PhaseConfig
getPhaseConfig phase =
    case phase of
        Dawn ->
            { name = "dawn"
            , phaseLabel = "Dawn Protocol"
            , weatherPoetry =
                [ "Mist dissolves into light"
                , "First breath of the waking world"
                , "Potential unfolds"
                ]
            , wisdomSource = "Morning Meditation"
            , attribution = "— Liminal teaching"
            , symbol = "☽"
            }

        Morning ->
            { name = "morning"
            , phaseLabel = "Solar Alignment"
            , weatherPoetry =
                [ "Golden current flows"
                , "Wave sets building"
                , "Perfect glass"
                ]
            , wisdomSource = "Dawn Patrol Wisdom"
            , attribution = "— Ocean teaching"
            , symbol = "☀"
            }

        Midday ->
            { name = "midday"
            , phaseLabel = "Peak Consciousness"
            , weatherPoetry =
                [ "Full spectrum saturation"
                , "Photosynthesis optimal"
                , "Growth state active"
                ]
            , wisdomSource = "Meridian Truth"
            , attribution = "— Solar philosophy"
            , symbol = "◉"
            }

        Afternoon ->
            { name = "afternoon"
            , phaseLabel = "Golden Hour"
            , weatherPoetry =
                [ "Amber light cascades"
                , "Thermal winds rise"
                , "Contemplation time"
                ]
            , wisdomSource = "Siesta Wisdom"
            , attribution = "— Desert saying"
            , symbol = "◐"
            }

        Evening ->
            { name = "evening"
            , phaseLabel = "Twilight Gateway"
            , weatherPoetry =
                [ "Purple synthesis"
                , "Day dissolves to dream"
                , "Threshold moment"
                ]
            , wisdomSource = "Vespers Transmission"
            , attribution = "— Hermetic principle"
            , symbol = "◑"
            }

        Night ->
            { name = "night"
            , phaseLabel = "Deep Field Mode"
            , weatherPoetry =
                [ "Star frequencies active"
                , "Void state initialized"
                , "Regeneration cycle"
                ]
            , wisdomSource = "Night Transmission"
            , attribution = "— Void teaching"
            , symbol = "☾"
            }


type alias PhaseClasses =
    { container : String
    , overlay : String
    , phaseLabel : String
    , temperature : String
    , conditions : String
    , separator : String
    , wisdomSource : String
    , wisdomText : String
    }


getPhaseClasses : TimePhase -> PhaseClasses
getPhaseClasses phase =
    case phase of
        Dawn ->
            { container = "bg-gradient-to-br from-[#1a1a2e] to-[#2d2d44] text-[#ffd93d]"
            , overlay = "bg-gradient-radial from-[#ff6b6b] via-transparent to-transparent opacity-20"
            , phaseLabel = "text-[11px] tracking-[6px] text-[#ff6b6b] font-serif"
            , temperature = "text-[140px] font-thin font-serif"
            , conditions = "italic font-serif"
            , separator = "bg-gradient-to-r from-transparent via-[#ff6b6b] to-transparent"
            , wisdomSource = "text-[#ff6b6b]"
            , wisdomText = "text-[26px] leading-[1.8] font-serif"
            }

        Morning ->
            { container = "bg-gradient-to-br from-[#fff5e1] to-[#ffe0b2] text-[#5d4037]"
            , overlay = "bg-gradient-radial from-[#ffb74d] via-transparent to-transparent opacity-40"
            , phaseLabel = "text-xs tracking-[3px] text-[#ff8a65] font-sans"
            , temperature = "text-[120px] font-light font-sans"
            , conditions = "font-sans"
            , separator = "bg-gradient-to-r from-transparent via-[#ff8a65] to-transparent"
            , wisdomSource = "text-[#ff8a65]"
            , wisdomText = "text-[28px] leading-[1.6] font-sans"
            }

        Midday ->
            { container = "bg-gradient-to-br from-[#e8f5e9] to-[#c8e6c9] text-[#1b5e20]"
            , overlay = "bg-gradient-to-b from-transparent to-[#4caf50] opacity-10"
            , phaseLabel = "text-[13px] tracking-[2px] text-[#4caf50] font-sans capitalize"
            , temperature = "text-[160px] font-bold font-sans"
            , conditions = "font-sans"
            , separator = "bg-gradient-to-r from-transparent via-[#4caf50] to-transparent"
            , wisdomSource = "text-[#4caf50]"
            , wisdomText = "text-[32px] leading-[1.5] font-sans"
            }

        Afternoon ->
            { container = "bg-gradient-to-br from-[#fff3e0] to-[#ffe0b2] text-[#5d4037]"
            , overlay = "bg-gradient-radial from-[#ff9800] via-transparent to-transparent opacity-30"
            , phaseLabel = "text-xs tracking-[4px] text-[#ff9800] font-serif lowercase"
            , temperature = "text-[130px] font-light font-serif"
            , conditions = "italic font-serif"
            , separator = "bg-gradient-to-r from-transparent via-[#ff9800] to-transparent"
            , wisdomSource = "text-[#ff9800]"
            , wisdomText = "text-[30px] leading-[1.7] font-serif"
            }

        Evening ->
            { container = "bg-gradient-to-br from-[#311b92] to-[#512da8] text-[#f3e5f5]"
            , overlay = "bg-gradient-radial from-[#e91e63] via-transparent to-transparent opacity-40"
            , phaseLabel = "text-[11px] tracking-[5px] text-[#e91e63] font-serif"
            , temperature = "text-[110px] font-thin font-serif"
            , conditions = "font-serif"
            , separator = "bg-gradient-to-r from-transparent via-[#e91e63] to-transparent"
            , wisdomSource = "text-[#e91e63]"
            , wisdomText = "text-[24px] leading-[1.9] font-serif"
            }

        Night ->
            { container = "bg-gradient-to-br from-[#0a0a0a] to-[#1a1a1a] text-[#b8860b]"
            , overlay = ""
            , phaseLabel = "text-[10px] tracking-[6px] text-[#00ffff] font-mono"
            , temperature = "text-[120px] font-normal font-mono"
            , conditions = "font-mono"
            , separator = "bg-gradient-to-r from-transparent via-[#00ffff] to-transparent"
            , wisdomSource = "text-[#00ffff]"
            , wisdomText = "text-[22px] leading-[2] font-mono"
            }



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
