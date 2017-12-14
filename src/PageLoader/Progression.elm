module PageLoader.Progression exposing (Progression, singlePending, empty, combine)


type alias Progression =
    { total : Int
    , finished : Int
    }


singlePending : Progression
singlePending =
    { total = 1
    , finished = 0
    }


empty : Progression
empty =
    { total = 0
    , finished = 0
    }


combine : Progression -> Progression -> Progression
combine a b =
    { total = a.total + b.total
    , finished = a.finished + b.finished
    }
