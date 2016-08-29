import SwiftyJSON
import Quick
import Nimble
import PactConsumerSwift

class TodoClientContractSpec: QuickSpec {

    override func spec() {
        describe("contract tests") {
            var todoBackendService: MockService?
            var todoClient: TodoClient?

            beforeEach {
                todoBackendService = MockService(
                        provider: "TodoBackendService",
                        consumer: "TodoiOSClient",
                        done: { result in
                            expect(result).to(equal(PactVerificationResult.Passed))
                        })

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

                let url = NSURL.init(string: "\(todoBackendService!.baseUrl)/todos")!

                var complete: Bool = false

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
                                                complete = true
                                                testComplete()
                                                expect(todoList).to(equal(expectedTodoList))
                                            },
                                            error: {
                                                complete = true
                                                testComplete()
                                                expect(true).to(equal(false))
                                            }
                    )
                }

                expect(complete).toEventually(beTrue())
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

                let url = NSURL.init(string: "\(todoBackendService!.baseUrl)\(todoItemPath)")!

                var complete: Bool = false

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
                                               complete = true
                                               testComplete()
                                               expect(todoItem).to(equal(expectedTodoItem))
                                           },
                                           error: { (_) in
                                               complete = true
                                               testComplete()
                                               expect(true).to(equal(false))
                                           }
                    )
                }

                expect(complete).toEventually(beTrue())
            }

            it("delete an item") {
                let todoItemId = NSUUID().UUIDString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = NSURL.init(string: "\(todoBackendService!.baseUrl)/\(todoItemPath)")!

                var complete: Bool = false

                todoBackendService!.uponReceiving("a request to delete a todo item")
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
                                                  complete = true
                                                  testComplete()
                                              },
                                              error: {
                                                  complete = true
                                                  testComplete()
                                                  expect(true).to(equal(false))
                                              }
                    )
                }

                expect(complete).toEventually(beTrue())
            }

            describe("zzz") {
                it("zzz") {
                }
            }

        }
    }
}
