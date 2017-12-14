module PageLoader.Progression exposing (Progression, singlePending, empty, add)

{-| A simple Progression record that shows counts of how many dependencies there are, and how many are already finished.
Progression is hold by DependencyStatus.Pending and TransitionStatus.Pending, which gives you some information about the progression of the dependencies.
And thereby allows you to show some kind of feedback to the user.

You probably should not create a Progression on your own, but should try to use some kind of extension like RemoteDataExt to do the work for you.
If you are using something else than what is already supported, then off course you must do it on your own.


# Progression

@docs Progression
@docs singlePending, empty
@docs add

-}


{-| The Progression record which gives information about the dependency status to other parts of the program
-}
type alias Progression =
    { total : Int
    , finished : Int
    }


{-| Creates a Progression record with a total of 1 and a finished of 0.
This is what you use when creating a new dependencies that is not met yet.
-}
singlePending : Progression
singlePending =
    { total = 1
    , finished = 0
    }


{-| Creates an empty Progression record. The total and finished properties are both set to 0
-}
empty : Progression
empty =
    { total = 0
    , finished = 0
    }


{-| Adds two Progression records together
-}
add : Progression -> Progression -> Progression
add a b =
    { total = a.total + b.total
    , finished = a.finished + b.finished
    }
