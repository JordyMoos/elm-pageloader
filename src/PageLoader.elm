module PageLoader
    exposing
        ( PageState(..)
        , TransitionStatus(..)
        , visualPage
        , defaultDependencyStatusHandler
        , defaultDependencyStatusListHandler
        , defaultTransitionStatusHandler
        )

import PageLoader.DependencyStatus as DependencyStatus
import PageLoader.Progression as Progression


type PageState page loader
    = Loaded page
    | Transitioning page loader


visualPage : PageState page loader -> page
visualPage pageState =
    case pageState of
        Loaded page ->
            page

        Transitioning page _ ->
            page


type TransitionStatus model msg data
    = Pending ( model, Cmd msg ) Progression.Progression
    | Success data
    | Failed String


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


defaultTransitionStatusHandler :
    TransitionStatus loadingModel loadingMsg newData
    -> page
    -> (loadingModel -> loader)
    -> (loadingMsg -> msg)
    -> (newData -> page)
    -> (String -> page)
    -> ( PageState page loader, Cmd msg )
defaultTransitionStatusHandler transitionStatus oldPage loader loadingMsgTagger newPage errorPage =
    case transitionStatus of
        Pending ( model, cmd ) progression ->
            ( Transitioning oldPage (loader model), Cmd.map loadingMsgTagger cmd )

        Success newData ->
            ( Loaded (newPage newData), Cmd.none )

        Failed error ->
            ( Loaded (errorPage error), Cmd.none )
