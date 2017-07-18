module Main exposing (..)

import Array exposing (Array)
import Html exposing (beginnerProgram)
import Model exposing (..)
import Update exposing (update)
import View exposing (view)


main =
    beginnerProgram { model = model, update = update, view = view }
