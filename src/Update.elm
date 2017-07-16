module Update exposing (..)

import Array exposing (Array)
import Model exposing (..)


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdatePlayer1 value ->
            { model | player1 = value }

        UpdatePlayer2 value ->
            { model | player2 = value }

        UpdateStatus status ->
            { model | status = status }

        MarkCell idx ->
            markCell idx model
                |> setBoard model
                |> nextTurn
                |> validateBoard
                |> switchPlayer

        Restart ->
            setBoard model emptyBoard
                |> setStatus Start
                |> setWinner Nothing
                |> resetRemainingTurn


switchPlayer : Model -> Model
switchPlayer model =
    case model.current of
        X ->
            { model | current = O }

        O ->
            { model | current = X }


nextTurn : Model -> Model
nextTurn model =
    { model | remainingTurns = model.remainingTurns - 1 }


isFinished : Int -> Status
isFinished currentTurn =
    if currentTurn > 0 then
        Start
    else
        End


checkSolution : List Cell -> ( Cell, Maybe Marker ) -> Bool
checkSolution idxs cellAndMarker =
    List.filter (Tuple.first cellAndMarker |> (==)) idxs
        |> List.isEmpty
        |> not


verticalSolutions : Cell -> List Cell
verticalSolutions idx =
    generateSolution ((*) 3 >> (+) idx)


horizontalSolutions : Cell -> List Cell
horizontalSolutions idx =
    generateSolution ((*) 3 idx |> (+))


diagonalSolutions : List (List Cell)
diagonalSolutions =
    List.append
        [ generateSolution ((*) 4) ]
        [ generateSolution ((*) 2 >> (+) 2) ]


generateSolution : (Int -> a) -> List a
generateSolution =
    Array.initialize 3 >> Array.toList


filterByMarker :
    Marker
    -> Array ( Cell, Maybe Marker )
    -> Array ( Cell, Maybe Marker )
filterByMarker marker =
    Array.filter (Tuple.second >> (==) (Just marker))


filterbySolution :
    List Cell
    -> Array ( Cell, Maybe Marker )
    -> Array ( Cell, Maybe Marker )
filterbySolution solution =
    Array.filter (checkSolution solution)


verifySolution : Marker -> Board -> List Cell -> Bool
verifySolution marker board solution =
    Array.indexedMap (,) board
        |> filterByMarker marker
        |> filterbySolution solution
        |> Array.length
        |> (==) 3


gameSolutions : List (List Cell)
gameSolutions =
    List.concat
        [ generateSolution verticalSolutions
        , generateSolution horizontalSolutions
        , diagonalSolutions
        ]


checkHasSolution : Marker -> Board -> Bool
checkHasSolution marker board =
    List.any (verifySolution marker board) <| gameSolutions


validateStatus : Model -> Model
validateStatus ({ remainingTurns, winner } as model) =
    case winner of
        Just player ->
            setStatus End model

        Nothing ->
            setStatus (isFinished remainingTurns) model


chooseWinner : Model -> Bool -> Model
chooseWinner ({ player1, player2, current } as model) hasWinner =
    if hasWinner == True then
        case current of
            X ->
                setWinner (Just player1) model

            O ->
                setWinner (Just player2) model
    else
        setWinner Nothing model


setStatus : Status -> Model -> Model
setStatus status model =
    { model | status = status }


setWinner : Maybe Player -> Model -> Model
setWinner winner model =
    { model | winner = winner }


setBoard : Model -> Board -> Model
setBoard model newBoard =
    { model | board = newBoard }


markBoard : Cell -> Marker -> Board -> Board
markBoard idx =
    Just >> Array.set idx


markCell : Cell -> Model -> Board
markCell idx { current, board } =
    markBoard idx current board


validateBoard : Model -> Model
validateBoard ({ current, board, remainingTurns, player1, player2 } as model) =
    checkHasSolution current board
        |> chooseWinner model
        |> validateStatus


resetRemainingTurn : Model -> Model
resetRemainingTurn model =
    { model | remainingTurns = 9 }
