module Main exposing (..)

import Array exposing (Array)
import Html exposing (Html, button, div, h1, input, label, p, span, text)
import Html.Attributes exposing (disabled, placeholder, value)
import Html.CssHelpers
import Html.Events exposing (onClick, onInput)
import MainCss as Styles


{ id, class, classList } =
    Html.CssHelpers.withNamespace Styles.appNamespace


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


emptyBoard : Board
emptyBoard =
    Array.repeat 9 Nothing


model : Model
model =
    Model "" "" New emptyBoard X Nothing 9



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
            setBoard model emptyBoard
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
    Array.initialize 3 ((*) 3 >> (+) idx) |> Array.toList


horizontalSolutions idx =
    Array.initialize 3 ((*) 3 idx |> (+)) |> Array.toList


diagonalSolutions : List (List Cell)
diagonalSolutions =
    List.append
        [ generateSolution ((*) 4) ]
        [ generateSolution ((*) 2 >> (+) 2) ]


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
view ({ status, player1, player2, current } as model) =
    let
        classesCurrentX =
            if current == X && status == Start then
                [ Styles.TextField_InputText__CurrentX ]
            else
                []

        classesCurrentO =
            Styles.TextField_InputText__PlayerO
                :: (if current == O && status == Start then
                        [ Styles.TextField_InputText__CurrentO ]
                    else
                        []
                   )
    in
    div [ class (containerClasses status) ]
        [ div []
            [ textField player1 classesCurrentX "Player X" UpdatePlayer1 (status /= New)
            , div [ class [ Styles.VSLabel ] ] [ text "VS" ]
            , textField player2 classesCurrentO "Player O" UpdatePlayer2 (status /= New)
            , if status == New then
                div
                    [ class
                        (validateName player1
                            && validateName player2
                            |> newGameSubmitClasses
                        )
                    ]
                    [ button
                        [ class [ Styles.Button, Styles.Button__FullWidth ]
                        , onClick (UpdateStatus Start)
                        ]
                        [ text "Start" ]
                    ]
              else
                text ""
            ]
        , viewBoard status model.board
        , div []
            [ if status == End then
                viewLeaderBoard model.winner
              else
                text ""
            ]
        ]


viewBoard : Status -> Board -> Html Msg
viewBoard status board =
    div
        [ class
            (if status == Start then
                [ Styles.Container_BoardGame, Styles.Container_BoardGame__Active ]
             else
                [ Styles.Container_BoardGame ]
            )
        ]
        [ if status == Start then
            createBoard board
          else
            text ""
        ]


containerClasses : Status -> List Styles.CssClasses
containerClasses status =
    (case status of
        New ->
            [ Styles.Container__NewGameView ]

        Start ->
            [ Styles.Container__BoardGameView ]

        End ->
            []
    )
        |> (++) [ Styles.Container ]


newGameSubmitClasses : Bool -> List Styles.CssClasses
newGameSubmitClasses ready =
    (if ready == True then
        []
     else
        [ Styles.NewGameSubmit__Hidden ]
    )
        |> List.append [ Styles.NewGameSubmit ]


textField :
    String
    -> List Styles.CssClasses
    -> String
    -> (String -> Msg)
    -> Bool
    -> Html Msg
textField val classes placeholderLabel onInputMsg isDisabled =
    div [ class [ Styles.TextField ] ]
        [ input
            [ class
                (List.append
                    [ Styles.TextField_InputText
                    ]
                    classes
                )
            , value val
            , onInput onInputMsg
            , placeholder placeholderLabel
            , disabled isDisabled
            ]
            []
        ]


createBoard : Array (Maybe Marker) -> Html Msg
createBoard =
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
