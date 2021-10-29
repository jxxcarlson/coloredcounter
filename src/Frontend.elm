module Frontend exposing (Model, app)

import Html exposing (Html, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Lamdera exposing (sendToBackend)
import Types exposing (..)
import Element exposing(..)
import Element.Font as Font
import Element.Background as Background
import Element.Input as Input

type alias Model =
    FrontendModel


{-| Lamdera applications define 'app' instead of 'main'.

Lamdera.frontend is the same as Browser.application with the
additional update function; updateFromBackend.

-}
app =
    Lamdera.frontend
        { init = \_ _ -> init
        , update = update
        , updateFromBackend = updateFromBackend
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlChange = \_ -> FNoop
        , onUrlRequest = \_ -> FNoop
        }


init : ( Model, Cmd FrontendMsg )
init =
    ( { counter = 0, clientId = "" }, Cmd.none )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }, sendToBackend CounterIncremented )

        Decrement ->
            ( { model | counter = model.counter - 1 }, sendToBackend CounterDecremented )

        FNoop ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        CounterNewValue newValue clientId ->
            ( { model | counter = newValue, clientId = clientId }, Cmd.none )


--view : Model -> Html FrontendMsg
--view model =
--    Html.div [ style "padding" "30px" ]
--        [ Html.button [ onClick Increment ] [ text "+" ]
--        , Html.text (String.fromInt model.counter)
--        , Html.button [ onClick Decrement ] [ text "-" ]
--        , Html.div [] [ Html.text "Click me then refresh me!" ]
--        ]

mainColumn model =
    column [centerX, centerY, spacing 8]
      [
         incrementButton
       , display (String.fromInt model.counter)
       , decrementButton

      ]

view : Model -> { title : String, body : List (Html.Html FrontendMsg) }
view model =
    { title = "Counter"
    , body =
        [ layout model ]
    }


layout : Model -> Html FrontendMsg
layout model =
    layoutWith { options = [ focusStyle noFocus ] }
        [ bg 0.9, clipX, clipY ]
        (mainColumn model)
-- STYLE


noFocus : Element.FocusStyle
noFocus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }


incrementButton = buttonTemplate [width (px 80)] Increment "+"

decrementButton = buttonTemplate [width (px 80)] Decrement "-"

display str = el [width (px 80)] (el [centerX] (Element.text str))

buttonTemplate : List (Attribute msg) -> msg -> String -> Element msg
buttonTemplate attrList msg label_ =
    row ([ bg 0.2, pointer, mouseDown [ mouseDownColor ] ] ++ attrList)
        [ Input.button buttonStyle
            { onPress = Just msg
            , label = el [ centerX, centerY, Font.size 14 ] (Element.text label_)
            }
        ]

bg g = Background.color (rgb g g g)
mouseDownColor = Background.color (rgb 0.8 0 0)

buttonStyle : List (Attr () msg)
buttonStyle =
    [ Font.color (rgb255 255 255 255)
    , paddingXY 15 8
    ]
