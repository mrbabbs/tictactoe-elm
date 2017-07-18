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
    | Container_NewGame__Active
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
    | Footer
    | Footer_Img
    | Link


type Transition
    = Property
    | Duration
    | TimingFunction
    | Delay


appNamespace =
    "tictactoe"


css : Stylesheet
css =
    (stylesheet << namespace appNamespace)
        (List.concat
            [ resetStyles
            , continerStyles
            , textFieldStyles
            , vsLabelStyles
            , newGameSubmits
            , buttonStyles
            , boardStyles
            , leaderBoardStyles
            , footerStyles
            , linkStyles
            ]
        )


transition : Transition -> String -> Style
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


resetStyles : List Snippet
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


continerStyles : List Snippet
continerStyles =
    [ class Container
        [ displayFlex
        , flexDirection column
        , minHeight (pct 100)
        , fontSize (px 20)
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
        , alignItems center
        ]
    , class Container_BoardGame__Active
        [ opacity (num 1)
        , flexGrow (num 1)
        , padding2 (em 1) zero
        ]
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
        [ opacity (num 1)
        , padding2 (em 1) zero
        , flexGrow (num 1)
        ]
    , class Container_NewGame__Active [ flexGrow (num 1) ]
    , mediaQuery "(max-width: 472px)"
        [ class Container [ fontSize (px 14) ]
        ]
    , mediaQuery "(max-height: 420px)"
        [ class Container [ fontSize (px 14) ]
        ]
    ]


footerStyles : List Snippet
footerStyles =
    [ class Footer
        [ flexGrow zero
        , flexShrink zero
        , padding2 (em 0.5) (em 5)
        , color grayColor200
        , fontSize (em 0.9)
        , borderTop3 (em 0.05) solid grayColor200
        ]
    , class Footer_Img
        [ height (em 0.9)
        , paddingRight (em 0.3)
        ]
    ]


linkStyles : List Snippet
linkStyles =
    [ class Link
        [ color grayColor200
        , visited [ color grayColor200 ]
        , hover [ color blueColor100 ]
        , textDecoration none
        ]
    ]


vsLabelStyles : List Snippet
vsLabelStyles =
    [ class VSLabel
        [ display inlineBlock
        , width (em 5)
        , textAlign center
        , textTransform uppercase
        , fontWeight bold
        ]
    ]


buttonStyles : List Snippet
buttonStyles =
    [ class Button
        [ backgroundColor blueColor100
        , padding (em 0.4)
        , color whiteColor
        ]
    , class Button__FullWidth
        [ width (pct 100)
        , cursor pointer
        ]
    ]


leaderBoardStyles : List Snippet
leaderBoardStyles =
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
    , class LeaderBoard__O [ color playerOColor ]
    , class LeaderBoard__X [ color playerXColor ]
    ]


boardStyles : List Snippet
boardStyles =
    [ class Board
        [ maxWidth (em 25)
        , displayFlex
        , flexDirection column
        ]
    , class Tile
        [ display block
        , width (em 7)
        , height (em 7)
        , backgroundColor whiteColor
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
        [ color playerXColor
        , fontSize (em 6)
        , transform (rotate (deg 45))
        , after [ property "content" (toString "+") ]
        ]
    , class Tile_Marker__O
        [ color playerOColor
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


textFieldStyles : List Snippet
textFieldStyles =
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
            [ borderColor playerXColor
            ]
        , pseudoElement "placeholder"
            [ color grayColor200
            ]
        , disabled [ backgroundColor whiteColor ]
        ]
    , class TextField_InputText__PlayerO
        [ focus
            [ borderColor playerOColor
            ]
        ]
    , class TextField_InputText__CurrentO
        [ borderColor playerOColor
        ]
    , class TextField_InputText__CurrentX
        [ borderColor playerXColor
        ]
    ]


newGameSubmits : List Snippet
newGameSubmits =
    [ class NewGameSubmit
        [ width (pct 100)
        , marginTop (em 1)
        ]
    , class NewGameSubmit__Hidden
        [ property "visibility" "hidden"
        ]
    ]


whiteColor : Color
whiteColor =
    hex "ffffff"


grayColor100 : Color
grayColor100 =
    hex "eeeeee"


grayColor200 : Color
grayColor200 =
    hex "bbbbbb"


greenColor100 : Color
greenColor100 =
    hex "5dd39e"


orangeColor100 : Color
orangeColor100 =
    hex "f77022"


blueColor100 : Color
blueColor100 =
    hex "33A1FD"


playerXColor : Color
playerXColor =
    greenColor100


playerOColor : Color
playerOColor =
    orangeColor100


borderTileColor : Color
borderTileColor =
    grayColor200


borderTileWidth : Em
borderTileWidth =
    em 0.05


borderTileStyle =
    solid
