module Main exposing (..)

import Html exposing (Html, text, div, p, input, h1, button, span)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput, onClick)
import Array exposing (Array)


main =
    Html.beginnerProgram { model = model, update = update, view = view }


type alias Player =
    String


type alias Model =
    { player1 : Player
    , player2 : Player
    , status : Status
    , board : Array (Maybe Marker)
    , current : Marker
    , winner : Maybe Player
    , remainingTurn : Int
    }


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
    | MarkCell Int
    | Restart


emptyBorder =
    Array.repeat 9 Nothing


model =
    Model "" "" New emptyBorder X Nothing 9


markBoard idx =
    Just >> Array.set idx


switchPlayer model =
    case model.current of
        X ->
            { model | current = O }

        O ->
            { model | current = X }


nextTurn model =
    { model | remainingTurn = model.remainingTurn - 1 }


isFinished currentTurn =
    if currentTurn > 0 then
        Start
    else
        End


checkSolution idxs cell =
    List.filter (Tuple.first cell |> (==)) idxs
        |> List.isEmpty
        |> not


verticalSolutions idx =
    (Array.initialize 3 ((*) 3 >> (+) idx)) |> Array.toList


horizontalSolutions idx =
    (Array.initialize 3 ((*) 3 idx |> (+))) |> Array.toList


diagonalSolutions =
    List.append
        [ (generateSolution ((*) 4)) ]
        [ (generateSolution ((*) 2 >> (+) 2)) ]


generateSolution =
    Array.initialize 3 >> Array.toList


filterByMarker marker =
    Array.filter (Tuple.second >> (==) (Just marker))


filterbySolution solution =
    Array.filter (checkSolution solution)


verifySolution marker board solution =
    Array.indexedMap (,) board
        |> filterByMarker marker
        |> filterbySolution solution
        |> Array.length
        |> (==) 3


gameSolutions =
    List.concat
        [ generateSolution verticalSolutions
        , generateSolution horizontalSolutions
        , diagonalSolutions
        ]


checkHasSolution marker board =
    List.any (verifySolution marker board) <| gameSolutions


checkStatus ({ remainingTurn, winner } as model) =
    case winner of
        Just player ->
            setStatus End model

        Nothing ->
            setStatus (isFinished remainingTurn) model


chooseWinner ({ player1, player2, current } as model) hasWinner =
    if hasWinner == True then
        case current of
            X ->
                setWinner (Just player1) model

            O ->
                setWinner (Just player2) model
    else
        setWinner Nothing model


setStatus status model =
    { model | status = status }


setWinner winner model =
    { model | winner = winner }


setBoard model newBoard =
    { model | board = newBoard }


markCell idx { current, board } =
    markBoard idx current board


validateBoard ({ current, board, remainingTurn, player1, player2 } as model) =
    checkHasSolution current board
        |> chooseWinner model
        |> checkStatus


resetRemainingTurn model =
    { model | remainingTurn = 9 }


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
            setBoard model emptyBorder
                |> setStatus Start
                |> setWinner Nothing
                |> resetRemainingTurn
                |> switchPlayer


validateName name =
    String.length name > 2


viewNewGame model =
    div []
        [ p []
            [ input [ value model.player1, onInput UpdatePlayer1 ] []
            ]
        , p []
            [ input [ value model.player2, onInput UpdatePlayer2 ] []
            ]
        , if validateName model.player1 && validateName model.player2 then
            button [ onClick (UpdateStatus Start) ] [ text "Start" ]
          else
            text ""
        ]


isCell idx el =
    if Tuple.first el == idx then
        True
    else
        False


getItem idx =
    (List.take (idx + 1) << List.drop idx) >> List.head


tile idx =
    Maybe.map (\x -> button [] [ text (toString x) ])
        >> Maybe.withDefault
            (button
                [ onClick (MarkCell idx) ]
                [ text " - " ]
            )


splitRow list idx =
    Array.slice (idx * 3) ((idx + 1) * 3) list |> Array.toList |> div []


createRows list =
    Array.map (splitRow list) (Array.fromList [ 0, 1, 2 ]) |> Array.toList


viewBorder board =
    Array.indexedMap tile board |> createRows |> div []


viewLeaderBoard winner =
    div []
        [ h1 [] [ text (Maybe.withDefault "Draw" winner) ]
        , button [ onClick Restart ] [ text "Restart" ]
        , button [ onClick New ] [ text "New" ]
        ]


view model =
    div []
        [ h1 []
            [ text
                (model.player1 ++ " vs " ++ model.player2)
            ]
        , case model.status of
            New ->
                viewNewGame model

            Start ->
                viewBorder model.board

            End ->
                viewLeaderBoard model.winner
        ]
