import SwiftyJSON
import Quick
import Nimble
import PactConsumerSwift
import TodoClient

class TodoClientContractSpec: QuickSpec {

    override func spec() {
        describe("contract tests") {
            var todoBackendService: MockService?
            var todoClient: TodoClient?

            beforeEach {
                todoBackendService = MockService(
                        provider: "TodoBackendService",
                        consumer: "TodoiOSClient")

                todoClient = TodoClient()
            }

            it("get all the todos") {
                let expectedResponse = Matcher.eachLike([
                                           "title": Matcher.somethingLike("blah"),
                                           "url": Matcher.somethingLike("http://localhost/todos/1"),
                                           "completed": Matcher.somethingLike(false),
                                           "order": Matcher.somethingLike(1)
                                       ])

                let expectedTodoList = TodoList(JSON([[
                                "title": "blah",
                                "url": "http://localhost/todos/1",
                                "completed": false,
                                "order": 1
                            ]]))

                let url = NSURL(string: "\(todoBackendService!.baseUrl)/todos")!

                todoBackendService!
                  .given("some todoitems exist")
                  .uponReceiving("a request for all todos")
                  .withRequest(
                      method: .GET,
                      path: "/todos",
                      headers: ["Accept": "application/json"])
                  .willRespondWith(
                      status: 200,
                      headers: ["Content-Type": "application/json; charset=utf-8"],
                      body: expectedResponse)

                todoBackendService!.run { (testComplete) -> Void in
                    todoClient!.getTodoList(url,
                                            success: { (todoList) in
                                                expect(todoList).to(equal(expectedTodoList))
                                                testComplete()
                                            },
                                            error: {
                                                expect(true).to(equal(false))
                                                testComplete()
                                            }
                    )
                }
            }

            it("creates a todoitem") {
                let todosPath = "/todos"

                let expectedResponse = [
                    "title": Matcher.somethingLike("blah"),
                    "url": Matcher.somethingLike("http://localhost/todos/1"),
                    "completed": Matcher.somethingLike(false),
                    "order": Matcher.somethingLike(1)
                ]

                let expectedTodoItem = TodoItem(JSON([
                            "title": "blah",
                            "url": "http://localhost/todos/1",
                            "completed": false,
                            "order": 1
                        ]))

                let postBody = [
                    "title": "blah",
                    "completed": false,
                    "order": 1
                ]

                let url = NSURL(string: "\(todoBackendService!.baseUrl)\(todosPath)")!

                todoBackendService!
                  .uponReceiving("a request to create a todoitem")
                  .withRequest(
                      method: .POST,
                      path: todosPath,
                      headers: ["Content-Type": "application/json"],
                      body: postBody)
                  .willRespondWith(
                      status: 201,
                      headers: ["Content-Type": "application/json; charset=utf-8"],
                      body: expectedResponse)

                todoBackendService!.run { (testComplete) -> Void in
                    todoClient!.createTodoItem(url,
                                               todoItemData: postBody,
                                               success: { (todoItem) in
                                                   expect(todoItem).to(equal(expectedTodoItem))
                                                   testComplete()
                                               },
                                               error: { (_) in
                                                   expect(true).to(equal(false))
                                                   testComplete()
                                               }
                    )
                }
            }

            it("gets one todoitem") {
                let todoItemId = 1
                let todoItemPath = "/todos/\(todoItemId)"

                let expectedResponse = [
                    "title": Matcher.somethingLike("blah"),
                    "url": Matcher.somethingLike("http://localhost\(todoItemPath)"),
                    "completed": Matcher.somethingLike(false),
                    "order": Matcher.somethingLike(1)
                ]

                let expectedTodoItem = TodoItem(JSON([
                            "title": "blah",
                            "url": "http://localhost\(todoItemPath)",
                            "completed": false,
                            "order": 1
                        ]))

                let url = NSURL(string: "\(todoBackendService!.baseUrl)\(todoItemPath)")!

                todoBackendService!
                  .given("a todoitem with id \(todoItemId) exists")
                  .uponReceiving("a request for a todoitem")
                  .withRequest(
                      method: .GET,
                      path: todoItemPath,
                      headers: ["Accept": "application/json"])
                  .willRespondWith(
                      status: 200,
                      headers: ["Content-Type": "application/json; charset=utf-8"],
                      body: expectedResponse)

                todoBackendService!.run { (testComplete) -> Void in
                    todoClient!.getTodoItem(url,
                                            success: { (todoItem) in
                                                expect(todoItem).to(equal(expectedTodoItem))
                                                testComplete()
                                            },
                                            error: { (_) in
                                                expect(true).to(equal(false))
                                                testComplete()
                                            }
                    )
                }
            }

            it("delete an item") {
                let todoItemId = 1
                let todoItemPath = "/todos/\(todoItemId)"

                let url = NSURL(string: "\(todoBackendService!.baseUrl)/\(todoItemPath)")!

                todoBackendService!
                  .given("a todoitem with id \(todoItemId) exists")
                  .uponReceiving("a request to delete a todo item")
                  .withRequest(
                      method: .DELETE,
                      path: todoItemPath,
                      headers: ["Accept": "application/json"])
                  .willRespondWith(
                      status: 200,
                      headers: nil)

                todoBackendService!.run { (testComplete) -> Void in
                    todoClient!.deleteTodoItem(url,
                                               success: { () in
                                                   testComplete()
                                               },
                                               error: {
                                                   expect(true).to(equal(false))
                                                   testComplete()
                                               }
                    )
                }
            }

            describe("zzz") {
                it("zzz") {
                }
            }

        }
    }
}
