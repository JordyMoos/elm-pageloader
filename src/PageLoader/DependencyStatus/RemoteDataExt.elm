module PageLoader.DependencyStatus.RemoteDataExt exposing (asStatus)

import PageLoader.DependencyStatus as DependencyStatus
import RemoteData


asStatus : RemoteData.RemoteData e a -> DependencyStatus.Status
asStatus remoteData =
    if RemoteData.isFailure remoteData then
        DependencyStatus.Failed
    else if RemoteData.isSuccess remoteData then
        DependencyStatus.Success
    else
        DependencyStatus.Pending DependencyStatus.singlePendingProgression
