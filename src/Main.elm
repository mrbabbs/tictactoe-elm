module Main exposing (..)

import Html exposing (Html, text, div, p, input, h1, button, span)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput, onClick)
import Array exposing (Array)


main =
    Html.beginnerProgram { model = model, update = update, view = view }


type alias Model =
    { player1 : String
    , player2 : String
    , status : Status
    , board : Array (Maybe Marker)
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
    | MarkCell Int


emptyBorder =
    Array.repeat 9 Nothing


model =
    Model "" "" New emptyBorder X


markBoard idx value =
    Array.set idx (Just value)


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

        MarkCell idx ->
            { model
                | board = markBoard idx model.current model.board
                , current = model.current |> switchPlayer
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
