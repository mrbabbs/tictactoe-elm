module Main exposing (..)

import Html exposing (Html, text, div, p, input, h1, button, span)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput, onClick)
import Array exposing (Array)


main =
    Html.beginnerProgram { model = model, update = update, view = view }



-- MODEL


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


emptyBorder : Board
emptyBorder =
    Array.repeat 9 Nothing


model : Model
model =
    Model "" "" New emptyBorder X Nothing 9



-- UPDATE


type Msg
    = UpdatePlayer1 Player
    | UpdatePlayer2 Player
    | UpdateStatus Status
    | MarkCell Cell
    | Restart


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
            setBoard model emptyBorder
                |> setStatus Start
                |> setWinner Nothing
                |> resetRemainingTurn
                |> switchPlayer


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


checkSolution idxs cell =
    List.filter (Tuple.first cell |> (==)) idxs
        |> List.isEmpty
        |> not


verticalSolutions idx =
    (Array.initialize 3 ((*) 3 >> (+) idx)) |> Array.toList


horizontalSolutions idx =
    (Array.initialize 3 ((*) 3 idx |> (+))) |> Array.toList


diagonalSolutions : List (List Cell)
diagonalSolutions =
    List.append
        [ (generateSolution ((*) 4)) ]
        [ (generateSolution ((*) 2 >> (+) 2)) ]


generateSolution : (Int -> a) -> List a
generateSolution =
    Array.initialize 3 >> Array.toList


filterByMarker : Marker -> Array ( Cell, Maybe Marker ) -> Array ( Cell, Maybe Marker )
filterByMarker marker =
    Array.filter (Tuple.second >> (==) (Just marker))


filterbySolution : List Cell -> Array ( Cell, Maybe Marker ) -> Array ( Cell, Maybe Marker )
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



-- VIEW


view : Model -> Html Msg
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


viewNewGame : Model -> Html Msg
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


viewBorder : Array (Maybe Marker) -> Html Msg
viewBorder =
    createTiles >> createRows >> div []


viewLeaderBoard : Maybe Player -> Html Msg
viewLeaderBoard winner =
    div []
        [ h1 [] [ text (Maybe.withDefault "Draw" winner) ]
        , button [ onClick Restart ] [ text "Restart" ]
        ]


validateName : String -> Bool
validateName name =
    String.length name > 2


createTile : Cell -> Maybe Marker -> Html Msg
createTile idx =
    Maybe.map (\x -> button [] [ text (toString x) ])
        >> Maybe.withDefault
            (button
                [ onClick (MarkCell idx) ]
                [ text " - " ]
            )


createTiles : Array (Maybe Marker) -> Array (Html Msg)
createTiles =
    Array.indexedMap createTile


splitRow : Array (Html Msg) -> Int -> Html Msg
splitRow list idx =
    Array.slice (idx * 3) ((idx + 1) * 3) list |> Array.toList |> div []


createRows : Array (Html Msg) -> List (Html Msg)
createRows list =
    Array.map (splitRow list) (Array.fromList [ 0, 1, 2 ]) |> Array.toList
