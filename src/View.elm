module View exposing (view)

import Array exposing (Array)
import Html
    exposing
        ( Html
        , a
        , button
        , div
        , footer
        , h1
        , i
        , img
        , input
        , label
        , span
        , text
        )
import Html.Attributes exposing (disabled, href, placeholder, src, value)
import Html.CssHelpers
import Html.Events exposing (onClick, onInput)
import MainCss as Styles
import Model exposing (..)
import Update exposing (update)
import Util exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace Styles.appNamespace


view : Model -> Html Msg
view ({ status, player1, player2, current } as model) =
    div [ class (containerClasses status) ]
        [ viewHeader model
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
        , footer [ class [ Styles.Footer ] ]
            [ text "written in "
            , img
                [ class [ Styles.Footer_Img ]
                , src "http://package.elm-lang.org/assets/favicon.ico"
                ]
                []
            , a [ href "http://elm-lang.org", class [ Styles.Link ] ]
                [ text "elm"
                ]
            , text ", source code "
            , a
                [ href "https://github.com/mrbabbs/tictactoe-elm"
                , class [ Styles.Link ]
                ]
                [ text "github" ]
            ]
        ]


viewHeader : Model -> Html Msg
viewHeader { current, player1, player2, status } =
    let
        currentXClasses =
            classesIf
                [ Styles.TextField_InputText__CurrentX ]
                (current == X && status == Start)

        currentOClasses =
            Styles.TextField_InputText__PlayerO
                :: classesIf
                    [ Styles.TextField_InputText__CurrentO ]
                    (current == O && status == Start)

        ready =
            validateName player1 && validateName player2

        submitButtonClasses =
            Styles.NewGameSubmit
                :: classesIf
                    [ Styles.NewGameSubmit__Hidden ]
                    (not ready)
    in
    div
        [ class
            (classesIf [ Styles.Container_NewGame__Active ] (status == New))
        ]
        [ textField player1
            currentXClasses
            "Player X"
            UpdatePlayer1
            (status /= New)
        , div [ class [ Styles.VSLabel ] ] [ text "VS" ]
        , textField player2
            currentOClasses
            "Player O"
            UpdatePlayer2
            (status /= New)
        , viewIf
            (div
                [ class submitButtonClasses ]
                [ button
                    [ class [ Styles.Button, Styles.Button__FullWidth ]
                    , onClick (UpdateStatus Start)
                    ]
                    [ text "Start" ]
                ]
            )
            (status == New)
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
