# Elm PageLoader
Utility library for SPA pages that have dependencies/

## The idea

The pages in a SPA can have dependencies resolved before the pages makes any sense. With dependencies i mean api requests or any kind of command that you need answered like getting a random number. If your page has dependencies than you can either move to the new page and work with Maybe's in your model. Or handle the dependencies before transitioning to the new page.

I personally do not like testing for Maybe's all the time, and neither do i like blank places that gets filled in over time.

If you want to go for the handle the dependencies before transitioning method, then you do not need to worry about Maybe's in your page. You know that you have the data because it is already given to you before you transitioned to your new page. That will keep your pages code cleaner and easier to argue about.

If you only have one dependency that you could send a command to resolve that dependency. And when it comes back as a message then you set your page as the new page with the resolved dependency data.

That works pretty easy but it gets a bit harder when you have multiple dependencies. Then you have to track all those dependencies before you can switch pages. You can argue that all the data should be resolved in one api request. But sometimes you might need something from the api and something from the elm program like the time. Or from two different api's. It is all possible. And with http/2 and service workers splitting my api requests into more specific requests can be lucrative.

Handling based on the status of the dependencies is where this library comes in. Hopefully it helps you setup a clean way of managing your dependencies and transitions between pages.

A demo site implementing this library can be found in the [demo site repository](https://github.com/JordyMoos/elm-pageloader-demo-site).

A description about the types and functions can be found on [package.elm-lang.org](http://package.elm-lang.org/packages/JordyMoos/elm-pageloader/latest).

## Basic concepts

Coming soon. [Please see the demo's source code for now.](https://github.com/JordyMoos/elm-pageloader-demo-site).
