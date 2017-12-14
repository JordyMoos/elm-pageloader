module PageLoader.DependencyStatus
    exposing
        ( Status(..)
        , isSuccess
        , isFailed
        , isPending
        , combine
        )

import PageLoader.Progression as Progression


type Status
    = Success
    | Failed
    | Pending Progression.Progression


isFailed : Status -> Bool
isFailed =
    (==) Failed


isSuccess : Status -> Bool
isSuccess =
    (==) Success


isPending : Status -> Bool
isPending status =
    case status of
        Pending _ ->
            True

        _ ->
            False


combine : List Status -> Status
combine statuses =
    if List.any isFailed statuses then
        Failed
    else if List.all isSuccess statuses then
        Success
    else
        Pending (sumProgressions statuses)


sumProgressions : List Status -> Progression.Progression
sumProgressions statuses =
    List.filterMap mapAsProgression statuses
        |> List.foldl Progression.add Progression.empty


mapAsProgression : Status -> Maybe Progression.Progression
mapAsProgression status =
    case status of
        Pending progression ->
            Just progression

        _ ->
            Nothing
