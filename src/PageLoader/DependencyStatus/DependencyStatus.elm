module PageLoader.DependencyStatus.DependencyStatus
    exposing
        ( Progression
        , singlePendingProgression
        , Status(..)
        , isSuccess
        , isFailed
        , isPending
        , combine
        )


type Status
    = Success
    | Failed
    | Pending Progression


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


type alias Progression =
    { total : Int
    , finished : Int
    }


singlePendingProgression : Progression
singlePendingProgression =
    Progression 1 0


emptyProgression : Progression
emptyProgression =
    Progression 0 0


sumProgressions : List Status -> Progression
sumProgressions statuses =
    List.filterMap asMaybeProgression statuses
        |> List.foldl combineProgression emptyProgression


asMaybeProgression : Status -> Maybe Progression
asMaybeProgression status =
    case status of
        Pending progression ->
            Just progression

        _ ->
            Nothing


combineProgression : Progression -> Progression -> Progression
combineProgression a b =
    { total = a.total + b.total
    , finished = a.finished + b.finished
    }
