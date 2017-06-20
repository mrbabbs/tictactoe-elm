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
    , board : List (List (Maybe Marker))
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
    [ [ Nothing, Nothing, Nothing ]
    , [ Nothing, Nothing, Nothing ]
    , [ Nothing, Nothing, Nothing ]
    ]


model =
    Model "" "" New emptyBorder X


mapCell m c idx value =
    if c == idx then
        (Just m)
    else
        value


mapRow m r c idx row =
    if r == idx then
        List.indexedMap (mapCell c)
    else
        row


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
                    (List.indexedMap (mapRow model.current rIdx cIdx) model.board)
                , current =
                    if model.current == X then
                        O
                    else
                        X
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


viewCell rIdx cIdx row =
    row
        |> Maybe.map
            (\x -> button [] [ text (toString x) ])
        |> Maybe.withDefault
            (button
                [ onClick (MarkCell rIdx cIdx) ]
                [ text " - " ]
            )


viewRow idx =
    div [] << List.indexedMap (viewCell idx)


viewBorder =
    div [] << List.indexedMap viewRow << .board


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
                viewBorder model
        ]
