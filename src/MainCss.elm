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
    | Container__LeaderBoardView
    | Container_NewGame
    | Container__LeaderBoard
    | Container__LeaderBoard__Active
    | VSLabel
    | Button
    | Button__FullWidth
    | NewGameSubmit
    | NewGameSubmit__Hidden
    | LeaderBoard
    | LeaderBoard__O
    | LeaderBoard__X
    | LeaderBoard_Winner
    | LeaderBoard_Trofy
    | Board
    | Board_Row
    | Tile
    | Tile_Marker
    | Tile_Marker__X
    | Tile_Marker__O


css =
    (stylesheet << namespace appNamespace)
        (List.concat
            [ resetStyles
            , continerStyle
            , textFieldStyle
            , vsLabelStyle
            , newGameSubmit
            , buttonStyle
            , boardStyle
            , leaderBoardStyle
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
        , paddingTop (em 0.6)
        , transition Property "padding-top"
        , transition Duration "0.4s"
        , transition TimingFunction "ease"
        ]
    , class Container__NewGameView
        [ property "padding-top" "calc(50vh - 5em)"
        ]
    , class Container__LeaderBoardView
        [ property "padding-top" "calc(50vh - 7.5em)"
        ]
    , class Container_BoardGame
        [ opacity zero
        , property "transition-property" "opacity"
        , property "transition-duration" "1s"
        , property "transition-timing-function" "ease"
        , width (pct 100)
        , displayFlex
        , justifyContent center
        ]
    , class Container_BoardGame__Active
        [ opacity (num 1), paddingTop (em 6.5) ]
    , class Container__LeaderBoard
        [ opacity zero
        , property "transition-property" "opacity"
        , property "transition-duration" "1s"
        , property "transition-timing-function" "ease"
        , width (pct 100)
        , displayFlex
        , justifyContent center
        ]
    , class Container__LeaderBoard__Active
        [ opacity (num 1), paddingTop (em 1) ]
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


leaderBoardStyle =
    [ class LeaderBoard
        [ width (em 21)
        , displayFlex
        , flexDirection column
        , alignItems center
        ]
    , class LeaderBoard_Trofy
        [ important (fontSize (em 3))
        , paddingBottom (em 0.5)
        ]
    , class LeaderBoard_Winner [ padding (em 0.5) ]
    , class LeaderBoard__O [ color vividTangelo ]
    , class LeaderBoard__X [ color mediumAcquamarine ]
    ]


boardStyle =
    [ class Board
        [ maxWidth (em 25)
        , displayFlex
        , flexDirection column
        ]
    , class Tile
        [ display block
        , width (em 7)
        , height (em 7)
        , backgroundColor white
        , nthChild "3n+1"
            [ borderRight3 borderTileWidth borderTileStyle borderTileColor
            ]
        , nthChild "3n"
            [ borderLeft3 borderTileWidth borderTileStyle borderTileColor
            ]
        ]
    , class Tile_Marker
        [ fontSize (em 5)
        , cursor pointer
        , display block
        ]
    , class Tile_Marker__X
        [ color mediumAcquamarine
        , fontSize (em 6)
        , transform (rotate (deg 45))
        , after [ property "content" (toString "+") ]
        ]
    , class Tile_Marker__O
        [ color vividTangelo
        , after [ property "content" (toString "o") ]
        , paddingBottom (em 0.1)
        ]
    , class Board_Row
        [ displayFlex
        , justifyContent center
        , nthChild "1"
            [ borderBottom3 borderTileWidth borderTileStyle borderTileColor
            ]
        , nthChild "2"
            [ borderBottom3 borderTileWidth borderTileStyle borderTileColor
            ]
        ]
    ]


textFieldStyle =
    [ class TextField
        [ display inlineBlock
        ]
    , class TextField_InputText
        [ borderBottom3 (em 0.1) solid grayColor100
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
            [ color grayColor200
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


grayColor100 =
    hex "eeeeee"


grayColor200 =
    hex "bbbbbb"


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


borderTileColor =
    grayColor200


borderTileWidth =
    em 0.05


borderTileStyle =
    solid
