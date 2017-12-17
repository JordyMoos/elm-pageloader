module PageLoader.DependencyStatus
    exposing
        ( Status(..)
        , isSuccess
        , isFailed
        , isPending
        , addFinished
        , reduce
        )

{-| `PageLoader.DependencyStatus.Status` holds the status of one or more dependencies.

A dependency can be everything like some `HTTP`, `RemoteData` or any `Cmd` that expects an answer.
For all of those we need to know if they are succeeded or not. Therefor a smaller type of record is needed that hold only the status of the dependency.

Any dependency should be able to convert to a `Status` which is used by the `PageLoader`.


# DependencyStatus

@docs Status
@docs isFailed, isSuccess, isPending
@docs reduce, addFinished

-}

import PageLoader.Progression as Progression


{-| `Status` represents the types a dependency can be in.
It can either be `Success` if the dependency is fulfilled.
`Failed` if something went wrong and it won't be fixed automatically.
`Pending` if the dependency is not yet success or failed.

The `Pending` status also holds a `Progression`.
see `PageLoader.Progression`

-}
type Status
    = Success
    | Failed
    | Pending Progression.Progression


{-| Returns `True` if the `Status` is `Failed`
-}
isFailed : Status -> Bool
isFailed =
    (==) Failed


{-| Returns `True` if the `Status` is `Success`
-}
isSuccess : Status -> Bool
isSuccess =
    (==) Success


{-| Returns `True` if the `Status` is `Pending`
-}
isPending : Status -> Bool
isPending status =
    case status of
        Pending _ ->
            True

        _ ->
            False


{-| addFinished adds 1 to the finished property of the progression.

This is useful when you have a dependency with a `Progression.total` higher then 1.
Then whenever something for it is resolved, you can call `addFinished`.
And when `total` is the same as `finished` then the status will me converted to a `Success` status.

If the given status was already success of failed then the return value will be the same as the given value.

-}
addFinished : Status -> Status
addFinished status =
    case status of
        Pending progression ->
            if progression.total == progression.finished + 1 then
                Success
            else
                Pending (Progression.add progression { total = 0, finished = 1 })

        _ ->
            status


{-| Reduces a `List Status` to a single `Status`.

If any of the `Status` are `Failed` then the result is also `Failed`.
If all of the `Status` are `Success` then the result is also `Success`.
Else the `Progression` of the `Pending` statuses are added together for the `Pending` result.

-}
reduce : List Status -> Status
reduce statuses =
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
