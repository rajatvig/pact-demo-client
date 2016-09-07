iOS, Docker and Consumer Driven Contract Testing with Pact
-------

Over the past few weeks, I worked on an iOS Application which used a swarm of MicroServices developed in multiple languages with the only commonality being they all run in the cloud in Docker Containers.
This post is inspired off some of the efforts to write consumer driven contract tests for the iOS Application which use Services exposing a HTTP+JSON API.

Example source code for the iOS Project can be found [here](https://github.com/rajatvig/pact-demo-client). The code is intended as a demo and guide for developers working on iOS Applications and struggling with similar concerns.

## What is Consumer Driven Contract Testing

At the most basic level, the *Consumer* runs a suite of *integration* tests against a *Provider* of services. The end result of the suite is a *contract* that the *provider* can then use to verify that it obeys the expected *contract*.
The [Pact]() Website does a great job explaining Consumer Driven Contract Testing, recommend very strongly reading those. Here's links to the [Wiki](), [FAQ]() and even more [documentation]().
There are more articles that explain the nuances in further detail. [1](), [2]().

## Why Pact

There are other tools that work equally well, notably [Pacto](), [Mountebank](). [Pact]() has a *consumer* implementation in [Swift]() which makes it a lot more suitable for iOS Applications. There also exists a Docker Image to help verify *contracts* on the *provider* end using proxies.

### What do you need

0. Xcode

1. Docker

    > Docker Images avoid the direct dependency on Ruby and RubyGems used by almost all Pact based tools, thus limiting them to just Docker.
Using Docker Compose allows us to have commands run list on the Docker Images while providing the relevant runtime environment variables and disk volumes in a more structured manner.
To install Docker

    ```bash
    brew cask install docker
    ```

2. Make

    > `make` is ubiquitous, is readable when used correctly, has task dependencies and simplifies tasks CI/CD environments which traditionally have been done inside opaque, long winding shell scripts.
It should already be installed if you've Xcode.

### What are we building?

The primary intent of the post is to help write good contract tests, not build an iOS Application.
The [code]() at Github is akin to a Client SDK that communicates with the backend service. As it stands, the demo project can be used by CocoaPods or Carthage when making the iOS Application.

### What Provider are we using?

The provider is akin to the many [Todo Backend](http://todobackend.com/) Services provided in multiple languages using different storage providers and frameworks to implement a HTTP+JSON API to manage Todos. I'm using a [fork](https://github.com/rajatvig/todo-backend-node-koa-redis) of a JavaScript backend which uses [Koa and Redis](https://github.com/selvakn/todo-backend-node-koa-redis). Feel free to use another but you will have to add support for [Provider States]() as expected by the iOS Client.

The specific bit of the contract we are interested in is as follows

1. Get a list of Todo Items at `/todos`
2. Get a specific Todo Item at `/todo/:id`
3. Deletes a specific Todo Item at `/todo/:id`

A JSON representation of the TodoItem is

```json
{
  "title": "blah",
  "completed": false,
  "order": 1,
  "url": "http://localhost/todos/1"
}
```

The [Todo Backend](http://todobackend.com/) project documents a lot more endpoints but this is a good enough subset to get going.

### Consumer code walkthrough

The model classes use [SwiftyJSON]() to parse the JSON to Swift types.
The client uses [Alamofire]() to make the HTTP calls and uses the Model classes to parse the JSON to Swift types.

Primary classes in the Consumer are outlined below.

##### [Sources/Models/TodoItem.swift](https://github.com/rajatvig/pact-demo-client/blob/master/Sources/Models/TodoItem.swift)

>```swift
>public class TodoItem: CustomStringConvertible, Equatable {
>    let title: String
>    let completed: Bool
>    let order: Int?
>    let url: NSURL?
>
>    public init(_ jsonData: JSON) {
>        self.title = jsonData["title"].stringValue
>        self.completed = jsonData["completed"].boolValue
>        self.order = jsonData["order"].int
>        self.url = NSURL.init(string: jsonData["url"].stringValue)
>    }
>...
>```

##### [Sources/Models/TodoList.swift](https://github.com/rajatvig/pact-demo-client/blob/master/Sources/Models/TodoList.swift)

>```swift
>public class TodoList: CustomStringConvertible, Equatable {
>    let todoItems: [TodoItem]
>
>    public init(_ jsonData: JSON) {
>        self.todoItems = jsonData.arrayValue.map { return TodoItem($0) }
>    }
>...
>```

##### [Sources/TodoClient.swift](https://github.com/rajatvig/pact-demo-client/blob/master/Sources/TodoClient.swift)

>```swift
>public class TodoClient {
>    public func getTodoList(url: NSURL, success: (TodoList) -> Void, error: () -> Void) -> Void {
> ...
>    public func getTodoItem(todoItemUrl: NSURL, success: (TodoItem) -> Void, error: () -> Void) -> Void {
> ...
>    public func deleteTodoItem(todoItemUrl: NSURL, success: () -> Void, error: () -> Void) -> Void {
        let headers = [
            "Accept": "application/json"
        ]
>
        Alamofire.request(.DELETE, todoItemUrl, headers: headers)
          .validate()
          .response { request, response, data, reqerror in
                      guard reqerror == nil else {
                          print("error while deleting product: \(reqerror)")
                          error()
                          return
                      }
>
                      success()
        }
> ...
>```

#### Targets
Two schemes are available to run,

1. [TodoClient](https://github.com/rajatvig/pact-demo-client/blob/master/TodoClient.xcodeproj/xcshareddata/xcschemes/TodoClient.xcscheme) which runs all the Unit Tests using [Quick](), [Nimble]() and [OHHTTPStubs]().
2. [TodoClientContractTests](https://github.com/rajatvig/pact-demo-client/blob/master/TodoClient.xcodeproj/xcshareddata/xcschemes/TodoClientContractTests.xcscheme) which runs all the contract tests using [Quick](), [Nimble]() and [Pact Consumer Swift](https://github.com/DiUS/pact-consumer-swift)

#### [Contract Spec](https://github.com/rajatvig/pact-demo-client/blob/master/Tests/TodoClientContractSpec.swift)

##### Contract for Get all Todo Items


####

### Generating the Contract

### Publishing the Contract

### Verifying the Contract

### Provider changes walkthrough


### Extras
1. The project uses [Fastlane](https://fastlane.tools/) to define lanes and uses appropriate Fastlane Tools. [Fastfile](https://github.com/rajatvig/pact-demo-client/blob/master/fastlane/Fastfile)
2. The project has a valid [PodSpec](https://github.com/rajatvig/pact-demo-client/blob/master/TodoClient.podspec) that can be published to CocoaPods.

###### Disclaimer
