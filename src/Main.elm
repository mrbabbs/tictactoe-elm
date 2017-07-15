module Main exposing (..)

import Array exposing (Array)
import Html exposing (Html, button, div, h1, i, input, label, p, span, text)
import Html.Attributes exposing (disabled, placeholder, src, value)
import Html.CssHelpers
import Html.Events exposing (onClick, onInput)
import MainCss as Styles
import Util exposing (..)


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
            classesIf
                [ Styles.TextField_InputText__CurrentX ]
                (current == X && status == Start)

        classesCurrentO =
            Styles.TextField_InputText__PlayerO
                :: classesIf
                    [ Styles.TextField_InputText__CurrentO ]
                    (current == O && status == Start)

        ready =
            validateName player1 && validateName player2
    in
    div [ class (containerClasses status) ]
        [ div []
            [ textField player1
                classesCurrentX
                "Player X"
                UpdatePlayer1
                (status /= New)
            , div [ class [ Styles.VSLabel ] ] [ text "VS" ]
            , textField player2
                classesCurrentO
                "Player O"
                UpdatePlayer2
                (status /= New)
            , viewIf
                (div
                    [ class
                        (Styles.NewGameSubmit
                            :: classesIf
                                [ Styles.NewGameSubmit__Hidden ]
                                (not ready)
                        )
                    ]
                    [ button
                        [ class [ Styles.Button, Styles.Button__FullWidth ]
                        , onClick (UpdateStatus Start)
                        ]
                        [ text "Start" ]
                    ]
                )
                (status == New)
            ]
        , viewBoard status model.board
        , div
            [ class
                (Styles.Container__LeaderBoard
                    :: classesIf
                        [ Styles.Container__LeaderBoard__Active ]
                        (status == End)
                )
            ]
            [ viewIf (viewLeaderBoard current model.winner) (status == End) ]
        ]


viewBoard : Status -> Board -> Html Msg
viewBoard status board =
    div
        [ class
            (Styles.Container_BoardGame
                :: classesIf
                    [ Styles.Container_BoardGame__Active ]
                    (status == Start)
            )
        ]
        [ viewIf (createBoard board) (status == Start) ]


containerClasses : Status -> List Styles.CssClasses
containerClasses status =
    (case status of
        New ->
            [ Styles.Container__NewGameView ]

        Start ->
            [ Styles.Container__BoardGameView ]

        End ->
            [ Styles.Container__LeaderBoardView ]
    )
        |> (++) [ Styles.Container ]


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
    createTiles >> createRows >> div [ class [ Styles.Board ] ]


viewLeaderBoard : Marker -> Maybe Player -> Html Msg
viewLeaderBoard marker winner =
    let
        winnerClasses =
            case marker of
                X ->
                    [ Styles.LeaderBoard__O ]

                O ->
                    [ Styles.LeaderBoard__X ]

        leaderBoardClasses =
            Styles.LeaderBoard
                :: (case winner of
                        Nothing ->
                            []

                        Just player ->
                            winnerClasses
                   )
    in
    div [ class leaderBoardClasses ]
        [ h1 [ class [ Styles.LeaderBoard_Winner ] ]
            [ text (Maybe.withDefault "Draw" winner) ]
        , div [ class [ Styles.LeaderBoard_Trofy ] ]
            [ i
                [ Html.Attributes.class "fa"
                , Html.Attributes.class "fa-trophy"
                ]
                []
            ]
        , button
            [ class [ Styles.Button, Styles.Button__FullWidth ]
            , onClick Restart
            ]
            [ text "Restart" ]
        ]


validateName : String -> Bool
validateName name =
    String.length name > 2


createTile : Cell -> Maybe Marker -> Html Msg
createTile idx =
    Maybe.map
        (\marker ->
            let
                markerClasses =
                    Styles.Tile_Marker
                        :: (case marker of
                                X ->
                                    [ Styles.Tile_Marker__X ]

                                O ->
                                    [ Styles.Tile_Marker__O ]
                           )
            in
            button [ class [ Styles.Tile ] ]
                [ span [ class markerClasses ]
                    [ text "" ]
                ]
        )
        >> Maybe.withDefault
            (button
                [ class [ Styles.Tile ], onClick (MarkCell idx) ]
                [ text "" ]
            )


createTiles : Array (Maybe Marker) -> Array (Html Msg)
createTiles =
    Array.indexedMap createTile


splitRow : Array (Html Msg) -> Int -> Html Msg
splitRow list idx =
    Array.slice (idx * 3) ((idx + 1) * 3) list
        |> Array.toList
        |> div [ class [ Styles.Board_Row ] ]


createRows : Array (Html Msg) -> List (Html Msg)
createRows list =
    Array.map (splitRow list) (Array.fromList [ 0, 1, 2 ]) |> Array.toList
