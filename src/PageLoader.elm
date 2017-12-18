module PageLoader
    exposing
        ( PageState(..)
        , TransitionStatus(..)
        , visualPage
        , defaultDependencyStatusHandler
        , defaultDependencyStatusListHandler
        , defaultProcessLoading
        )

{-| `PageLoader` is a utility library to make loading of pages with dependencies clearer.


# PageLoader

@docs PageState, visualPage
@docs TransitionStatus
@docs defaultDependencyStatusHandler, defaultDependencyStatusListHandler
@docs defaultProcessLoading

-}

import PageLoader.DependencyStatus as DependencyStatus
import PageLoader.Progression as Progression


{-| `PageState`
A page can either be `Loaded` or `Transitioning`.

`Loaded` has a `page` as payload.
`Loaded` is used to display a page when all dependencies are loaded.

`Transitioning` has a `page` (which usually is the previous page) and a `loader` (for the next page) as payload.
The `Transitioning`s job is wait wait until the loader is been promoted to the new page.
In the meantime the transition also holds a previous loaded page which can be used to display to the users.

-}
type PageState page loader
    = Loaded page
    | Transitioning page loader


{-| `visualPage` extracts the `page` from a `PageState`.
-}
visualPage : PageState page loader -> page
visualPage pageState =
    case pageState of
        Loaded page ->
            page

        Transitioning page _ ->
            page


{-| `TransitionStatus` is the result after an loader handles a msg.
The `TransitionStatus` holds the loading data when it is `Pending`.
It hold `data` (often the model of the new page) when the `TransitionStatus` is `Success`.
And it holds an `String` representing an error message when the `TransitionStatus` is `Failed`.
-}
type TransitionStatus model msg data
    = Pending ( model, Cmd msg ) Progression.Progression
    | Success data
    | Failed String


{-| `defaultDependencyStatusListHandler` is used by the loader to create a new `TransitionStatus` based on the data of the loader.

Given are:

  - A tuple of (Model, Cmd Msg) which is the model and cmd of the loader.
  - A list of `DependencyStatus.Status`
  - A closure that will be called to create the new data (often the Model of the page when loaded)

The function will return a new `TransitionStatus`.

-}
defaultDependencyStatusListHandler :
    ( model, Cmd msg )
    -> List DependencyStatus.Status
    -> (() -> successData)
    -> TransitionStatus model msg successData
defaultDependencyStatusListHandler ( model, cmd ) dependencyStatuses onSuccessCallback =
    defaultDependencyStatusHandler
        ( model, cmd )
        (DependencyStatus.reduce dependencyStatuses)
        onSuccessCallback


{-| `defaultDependencyStatusHandler` almost the same as `defaultDependencyStatusListHandler` with the only difference that this function received a single `DependencyStatus.Status` instead of a list.

@see defaultDependencyStatusListHandler

-}
defaultDependencyStatusHandler :
    ( model, Cmd msg )
    -> DependencyStatus.Status
    -> (() -> successData)
    -> TransitionStatus model msg successData
defaultDependencyStatusHandler ( model, cmd ) dependencyStatus onSuccessCallback =
    case dependencyStatus of
        DependencyStatus.Failed ->
            Failed "Some requests failed"

        DependencyStatus.Pending progression ->
            Pending ( model, cmd ) progression

        DependencyStatus.Success ->
            Success (onSuccessCallback ())


{-| `defaultProcessLoading`

The `defaultProcessLoading` takes the `TransitionStatus` and will convert that to a new `PageState`.
In order to do that it need a couple of configurations about the loader, the page you want to go to and the error page.

Given are:

  - errorPage. A page that requires a String which is the error description. And that will be set as the Loaded PageState is the TransitionStatus is Failed
  - loaderPage. The loader page required a loaders.Model and a Progression.Progression. Will be used when the TransitionStatus is still is Pending.
  - loaderMsg. The msg tagger for the loaderPage.
  - successPage. The page that used if the TransitionStatus is Success.
  - successPageInit. The init function of the successPage. The init function will be called with the result data of the loader. That is often the model of the successPage but that is not required.
  - successPageMsg. The msg tagger for the successPage.
  - oldPage. A page that is visual in the mean time.
  - TransitionStatus. The transition status returned by the loader or the page.

The function will return a new PageState based on all this information.

Please see <https://github.com/JordyMoos/elm-pageloader-demo-site/blob/master/src/Main.elm> for an example usage.

-}
defaultProcessLoading :
    (String -> page)
    -> (loadingModel -> Progression.Progression -> loader)
    -> (loadingMsg -> msg)
    -> (newModel -> page)
    -> (newData -> ( newModel, Cmd newMsg ))
    -> (newMsg -> msg)
    -> page
    -> TransitionStatus loadingModel loadingMsg newData
    -> ( PageState page loader, Cmd msg )
defaultProcessLoading errorPage loaderPage loaderMsg successPage successPageInit successPageMsg oldPage transitionStatus =
    case transitionStatus of
        Pending ( model, cmd ) progression ->
            ( Transitioning oldPage (loaderPage model progression), Cmd.map loaderMsg cmd )

        Success newData ->
            let
                ( model, cmd ) =
                    successPageInit newData
            in
                ( Loaded (successPage model), Cmd.map successPageMsg cmd )

        Failed error ->
            ( Loaded (errorPage error), Cmd.none )
