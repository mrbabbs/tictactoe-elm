module MainCss exposing (..)

import Css exposing (..)
import Css.Elements
    exposing
        ( article
        , aside
        , body
        , footer
        , header
        , html
        , menu
        , nav
        , ol
        , section
        , ul
        )
import Css.Namespace exposing (namespace)


type CssClasses
    = TextField
    | TextField_InputText
    | TextField_InputText__PlayerO
    | TextField_InputText__CurrentX
    | TextField_InputText__CurrentO
    | Container
    | Container_BoardGame
    | Container_BoardGame__Active
    | Container__NewGameView
    | Container__BoardGameView
    | Container_NewGame
    | VSLabel
    | Button
    | Button__FullWidth
    | NewGameSubmit
    | NewGameSubmit__Hidden


css =
    (stylesheet << namespace appNamespace)
        (List.concat
            [ resetStyles
            , continerStyle
            , textFieldStyle
            , vsLabelStyle
            , newGameSubmit
            , buttonStyle
            ]
        )


type Transition
    = Property
    | Duration
    | TimingFunction
    | Delay


appNamespace =
    "tictactoe"


transition kind =
    case kind of
        Property ->
            property "transition-property"

        Duration ->
            property "transition-duration"

        TimingFunction ->
            property "transition-timing-function"

        Delay ->
            property "transition-delay"


resetStyles =
    [ everything
        [ margin zero
        , border zero
        , padding zero
        , fontSize (pct 100)
        , fontStyle inherit
        , verticalAlign baseline
        , boxSizing borderBox
        , outline none
        ]
    , html
        [ height (pct 100)
        ]
    , body
        [ lineHeight (num 1)
        , fontFamily sansSerif
        , fontSize (px 20)
        , height (pct 100)
        ]
    , each
        [ article
        , aside
        , selector "details"
        , selector "figcaption"
        , selector "figure"
        , footer
        , header
        , selector "hgroup"
        , menu
        , nav
        , section
        ]
        [ display block
        ]
    , each [ ol, ul ] [ listStyle none ]
    , Css.Elements.table
        [ borderCollapse collapse
        , property "border-spacing" "0"
        ]
    ]


continerStyle =
    [ class Container
        [ displayFlex
        , flexDirection column
        , height (pct 100)
        , alignItems center
        , position relative
        , paddingTop (px 10)
        , transition Property "padding-top"
        , transition Duration "0.4s"
        , transition TimingFunction "ease"
        ]
    , class Container__NewGameView
        [ property "padding-top" "calc(50vh - 100px)"
        ]
    , class Container_BoardGame
        [ opacity zero
        , property "transition-property" "opacity"
        , property "transition-duration" "1s"
        , property "transition-timing-function" "ease"
        , paddingTop (pct 10)
        ]
    , class Container_BoardGame__Active
        [ opacity (num 1) ]
    ]


vsLabelStyle =
    [ class VSLabel
        [ display inlineBlock
        , width (em 5)
        , textAlign center
        , textTransform uppercase
        , fontWeight bold
        ]
    ]


buttonStyle =
    [ class Button
        [ backgroundColor lightKhaki
        , padding (em 0.4)
        , color white
        ]
    , class Button__FullWidth
        [ width (pct 100)
        , cursor pointer
        ]
    ]


textFieldStyle =
    [ class TextField
        [ display inlineBlock
        ]
    , class TextField_InputText
        [ borderBottom3 (em 0.1) solid lightGray
        , width (em 8)
        , padding (em 0.5)
        , textAlign center
        , property "transition-property" "border-color"
        , property "transition-duration" "0.1s"
        , property "transition-timing-function" "ease-in"
        , focus
            [ borderColor mediumAcquamarine
            ]
        , pseudoElement "placeholder"
            [ color (hex "bbbbbb")
            ]
        , disabled [ backgroundColor white ]
        ]
    , class TextField_InputText__PlayerO
        [ focus
            [ borderColor vividTangelo
            ]
        ]
    , class TextField_InputText__CurrentO
        [ borderColor vividTangelo
        ]
    , class TextField_InputText__CurrentX
        [ borderColor mediumAcquamarine
        ]
    ]


newGameSubmit =
    [ class NewGameSubmit
        [ width (pct 100)
        , marginTop (em 1)
        ]
    , class NewGameSubmit__Hidden
        [ property "visibility" "hidden"
        ]
    ]


white =
    hex "ffffff"


lightGray =
    hex "eeeeee"


mediumAcquamarine =
    hex "5dd39e"


mediumSpringBud =
    hex "bce784"


lightKhaki =
    hex "e6e18f"


vividTangelo =
    hex "f77022"


yellowGreen =
    hex "95c126"
