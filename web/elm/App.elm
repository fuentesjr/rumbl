port module App exposing (..)

import Html.App as App
import Html exposing (Html, text, button, textarea, div, h3)
import Html.Attributes exposing (class, id, type', rows, placeholder, value)
import Html.Events exposing (onClick, onInput)


main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { playerReady : Bool
  , newAnnotation : String
  , annotations : List String
  }


type alias VideoInfo =
  { domElemId : String
  , ytVideoId : String
  }


init : (Model, Cmd Msg)
init =
  let
    vidInfo = { domElemId = "video", ytVideoId = "STO-uN0xHDQ" }
  in
    (Model False "" [], prepVideoPlayer vidInfo)


-- UPDATE

type Msg
  = NewAnnotation String
  | PlayerReady Bool
  | PostAnnotation


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewAnnotation text ->
      (Model model.playerReady text model.annotations, Cmd.none)
    PlayerReady isReady ->
      (Model isReady model.newAnnotation model.annotations, Cmd.none)
    PostAnnotation ->
      (Model model.playerReady "" (model.newAnnotation :: model.annotations), Cmd.none)



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  playerReady PlayerReady




-- PORTS

-- port for sending VideoInfo records out to JavaScript
port prepVideoPlayer : VideoInfo -> Cmd msg


-- port for listening for suggestions from JavaScript
port playerReady : (Bool -> msg) -> Sub msg



-- VIEW

view : Model -> Html Msg
view model =
  div [class "col-sm-5"] [
    annotationsViewPanel model.annotations,
    annotationsInputPanel model.newAnnotation
  ]


annotationsViewPanel annots =
  div [class "panel panel-default"] [
    div [class "panel-heading"]
      [h3 [class "panel-title"] [text "Annotations Elm Widget"]
    ],
    annots
      |> List.reverse
      |> List.map renderAnnotation
      |> div [class "panel-body annotations"]
  ]


renderAnnotation annot =
  div [] [text annot]


annotationsInputPanel annotField =
  div [class "panel-footer"] [
    textarea
      [ class "form-control"
      , id "msg-input"
      , rows 3
      , placeholder "Commment..."
      , value annotField
      , onInput NewAnnotation ] []
    ,
    button
      [ class "btn btn-primary form-control"
      , id "msg-submit"
      , type' "submit"
      , onClick PostAnnotation
      ]

      [text "Post"]
  ]
