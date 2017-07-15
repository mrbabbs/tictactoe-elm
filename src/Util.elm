module Util exposing (..)

import Html exposing (Html, text)
import MainCss as Styles


classesIf : List Styles.CssClasses -> Bool -> List Styles.CssClasses
classesIf classes condition =
    if condition == True then
        classes
    else
        []


viewIf : Html msg -> Bool -> Html msg
viewIf content condition =
    if condition == True then
        content
    else
        text ""
