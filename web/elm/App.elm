module App exposing (..)

import Html exposing (text, button, textarea, div, h3)
import Html.Attributes exposing (class, id, type', rows, placeholder)

main : Html.Html a
main = view


view : Html.Html a
view =
  div [class "col-sm-5"] [
    commentsViewPanel,
    commentsInputPanel
  ]


commentsViewPanel : Html.Html a
commentsViewPanel =
  div [class "panel panel-default"] [
    div [class "panel-heading"]
      [h3 [class "panel-title"] [text "Annotations Elm Widget"]
    ],
    div [class "panel-body annotations", id "msg-container"] []
  ]


commentsInputPanel : Html.Html a
commentsInputPanel =
  div [class "panel-footer"] [
    textarea [class "form-control", id "msg-input", rows 3, placeholder "Commment..."] []
    ,
    button [class "btn btn-primary form-control", id "msg-submit", type' "submit"]
      [text "Post"]
  ]
