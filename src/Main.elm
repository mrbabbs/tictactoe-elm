module Main exposing (..)

import Html exposing (Html, text, div, p, input, h1, button, span)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput, onClick)


main =
    Html.beginnerProgram { model = model, update = update, view = view }


type alias Model =
    { player1 : String
    , player2 : String
    , status : Status
    , board : List (Maybe Marker)
    , current : Marker
    }


type Status
    = New
    | Start


type Marker
    = X
    | O


type Msg
    = UpdatePlayer1 String
    | UpdatePlayer2 String
    | UpdateStatus Status
    | MarkCell Int Int


emptyBorder =
    List.repeat 9 Nothing


model =
    Model "" "" New emptyBorder X


mark currPlayer idx currIdx cellValue =
    if idx == currIdx then
        (Just currPlayer)
    else
        cellValue


switchPlayer current =
    if current == X then
        O
    else
        X


update msg model =
    case msg of
        UpdatePlayer1 value ->
            { model | player1 = value }

        UpdatePlayer2 value ->
            { model | player2 = value }

        UpdateStatus status ->
            { model | status = status }

        MarkCell rIdx cIdx ->
            { model
                | board =
                    (.board
                        >> List.indexedMap (mark model.current <| rIdx + cIdx)
                    )
                    <|
                        model
                , current = .current >> switchPlayer <| model
            }


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


viewCell board rIdx cIdx =
    getItem (rIdx + cIdx) board
        |> Maybe.withDefault ( 0, Nothing )
        |> Tuple.second
        |> Maybe.map
            (\x -> button [] [ text (toString x) ])
        |> Maybe.withDefault
            (button
                [ onClick (MarkCell rIdx cIdx) ]
                [ text " - " ]
            )


viewRow board idx =
    div [] <| List.map (viewCell board (idx * 3)) <| List.range 0 2


viewBorder board =
    div [] <| List.map (viewRow <| List.indexedMap (,) board) <| List.range 0 2


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
                viewBorder <| .board model
        ]
