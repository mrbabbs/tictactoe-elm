module MainCss exposing (..)

import Css exposing (..)
import Css.Elements
    exposing
        ( article
        , aside
        , body
        , footer
        , header
        , menu
        , nav
        , ol
        , section
        , ul
        )
import Css.Namespace exposing (namespace)


type CssClasses
    = Button


resetStyles =
    [ everything
        [ margin zero
        , border zero
        , padding zero
        , fontSize (pct 100)
        , fontStyle inherit
        , verticalAlign baseline
        , boxSizing borderBox
        ]
    , body [ lineHeight (num 1) ]
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


appNamespace =
    "tictactoe"


css =
    (stylesheet << namespace appNamespace)
        (List.concat
            [ resetStyles
            , [ class Button
                    []
              ]
            ]
        )


primaryAccentColor =
    hex "ccffaa"
