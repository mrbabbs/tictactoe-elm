module Model exposing (..)

import Array exposing (Array)


type alias Player =
    String


type alias Model =
    { player1 : Player
    , player2 : Player
    , status : Status
    , board : Board
    , current : Marker
    , winner : Maybe Player
    , remainingTurns : Int
    }


type alias Cell =
    Int


type alias Board =
    Array (Maybe Marker)


type Status
    = New
    | Start
    | End


type Marker
    = X
    | O


type Msg
    = UpdatePlayer1 Player
    | UpdatePlayer2 Player
    | UpdateStatus Status
    | MarkCell Cell
    | Restart


emptyBoard : Board
emptyBoard =
    Array.repeat 9 Nothing


model : Model
model =
    Model "" "" New emptyBoard X Nothing 9
