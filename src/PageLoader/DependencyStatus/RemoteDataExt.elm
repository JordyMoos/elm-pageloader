module PageLoader.DependencyStatus.RemoteDataExt exposing (asStatus)

{-| Convert a `RemoteData` to a `PageLoader.DependencyStatus.Status`

This is only useful when you use the `RemoteData` library, but this will add `RemoteData` as a dependency.
Therefor this should be moved to an additional optional dependency.


# RemoteDataExt

@docs asStatus

-}

import PageLoader.DependencyStatus as DependencyStatus
import PageLoader.Progression as Progression
import RemoteData


{-| Converts a `RemoteData` to `PageLoader.DependencyStatus.Status`.
-}
asStatus : RemoteData.RemoteData e a -> DependencyStatus.Status
asStatus remoteData =
    if RemoteData.isFailure remoteData then
        DependencyStatus.Failed
    else if RemoteData.isSuccess remoteData then
        DependencyStatus.Success
    else
        DependencyStatus.Pending Progression.singlePending
