import SwiftyJSON
import Quick
import Nimble
import OHHTTPStubs
import TodoClient

class TodoClientSpec: QuickSpec {
    override func spec() {
        afterEach {
            OHHTTPStubs.removeAllStubs()
        }

        describe("todo client") {
            it("gets all the todos") {
                let filePath = Bundle.init(for: type(of: self))
                               .path(forResource: "todo_list", ofType: "json")!

                let data: NSData = NSData(contentsOfFile: filePath)!
                let url = URL(string: "http://localhost/todos")!

                stub(condition: isHost("localhost") && isPath("/todos") && isMethodGET()) { _ in
                    return OHHTTPStubsResponse(data: data as Data, statusCode: 200, headers: ["Content-Type": "application/json"])
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.getTodoList(url: url,
                                       success: { (todoList) in
                                           completionCalled = true
                                           expect(todoList.todoItems).to(haveCount(11))
                                       },
                                       error: {
                                           completionCalled = true
                                           expect(true).to(equal(false))
                                       }
                )

                expect(completionCalled).toEventually(beTrue(), timeout: 10)
            }

            it("returns error when if fails get all the todos") {
                let url = URL(string: "http://localhost/todos")!

                stub(condition: isHost("localhost") && isPath("/todos") && isMethodGET()) { _ in
                    return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.getTodoList(url: url,
                                       success: { (_) in
                                           completionCalled = true
                                           expect(true).to(equal(false))
                                       },
                                       error: {
                                           completionCalled = true
                                       }
                )

                expect(completionCalled).toEventually(beTrue(), timeout: 10)
            }

            it("gets the todoitem") {
                let todoItemId = NSUUID().uuidString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = URL(string: "http://localhost\(todoItemPath)")!
                let jsonObj: [String: Any] = [
                    "title": "blah",
                    "order": 523,
                    "completed": false,
                    "url": "http://localhost\(todoItemPath)"
                ]

                stub(condition: isHost("localhost") && isPath(todoItemPath) && isMethodGET()) { _ in
                    return OHHTTPStubsResponse(jsonObject: jsonObj, statusCode: 200, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.getTodoItem(url: url,
                                       success: { (todoItem) in
                                           completionCalled = true
                                           expect(todoItem).to(equal(TodoItem(JSON(jsonObj))))
                                       },
                                       error: {
                                           completionCalled = true
                                           expect(true).to(equal(false))
                                       }
                )

                expect(completionCalled).toEventually(beTrue(), timeout: 10)
            }

            it("returns error when if fails get the todo") {
                let todoItemId = NSUUID().uuidString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = URL(string: "http://localhost/\(todoItemPath)")!

                stub(condition: isHost("localhost") && isPath(todoItemPath) && isMethodGET()) { _ in
                    return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.getTodoItem(url: url,
                                       success: { (_) in
                                           completionCalled = true
                                           expect(true).to(equal(false))
                                       },
                                       error: {
                                           completionCalled = true
                                       }
                )

                expect(completionCalled).toEventually(beTrue(), timeout: 10)
            }

            it("creates the todoitem") {
                let url = URL(string: "http://localhost/todos")!
                let jsonObj: [String: Any] = [
                    "name": "todo1",
                    "order": 543
                ]

                let responseJsonObj: [String: Any] = [
                    "name": "todo1",
                    "order": 543,
                    "completed": false,
                    "url": "http://localhost/todos/1"
                ]

                let expectedTodoItem = TodoItem(JSON(responseJsonObj))

                stub(condition: isHost("localhost") && isPath("/todos") && isMethodPOST()) { req in
                    let request = req as NSURLRequest
                    let postData = JSON(data: request.ohhttpStubs_HTTPBody())
                    expect(postData).to(equal(JSON(jsonObj)))
                    return OHHTTPStubsResponse(jsonObject: responseJsonObj, statusCode: 201, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.createTodoItem(url: url,
                                          todoItemData: jsonObj,
                                          success: { (todoItem) in
                                              expect(todoItem).to(equal(expectedTodoItem))
                                              completionCalled = true
                                          },
                                          error: {
                                              completionCalled = true
                                              expect(true).to(equal(false))
                                          }
                )

                expect(completionCalled).toEventually(beTrue(), timeout: 10)
            }

            it("returns error when if fails to create the todoitem") {
                let url = URL(string: "http://localhost/todos")!

                stub(condition: isHost("localhost") && isPath("/todos") && isMethodPOST()) { _ in
                    return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.createTodoItem(url: url,
                                          todoItemData: [:],
                                          success: { (_) in
                                              completionCalled = true
                                              expect(true).to(equal(false))
                                          },
                                          error: {
                                              completionCalled = true
                                          }
                )

                expect(completionCalled).toEventually(beTrue(), timeout: 10)
            }

            it("updates the todoitem") {
                let todoItemId = NSUUID().uuidString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = URL(string: "http://localhost\(todoItemPath)")!

                let jsonObj: [String: Any] = [
                    "title": "blah is good",
                    "order": 523,
                    "completed": true
                ]

                let responseJsonObj: [String: Any] = [
                    "name": "blah is good",
                    "order": 4523,
                    "completed": true,
                    "url": "http://localhost/todos/1"
                ]

                let expectedTodoItem = TodoItem(JSON(responseJsonObj))

                stub(condition: isHost("localhost") && isPath(todoItemPath) && isMethodPATCH()) { req in
                    let request = req as NSURLRequest
                    let postData = JSON(data: request.ohhttpStubs_HTTPBody())
                    expect(postData).to(equal(JSON(jsonObj)))
                    return OHHTTPStubsResponse(jsonObject: responseJsonObj, statusCode: 200, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.updateTodoItem(url: url,
                                          todoItemData: jsonObj,
                                          success: { (todoItem) in
                                              expect(todoItem).to(equal(expectedTodoItem))
                                              completionCalled = true
                                          },
                                          error: {
                                              completionCalled = true
                                              expect(true).to(equal(false))
                                          }
                )

                expect(completionCalled).toEventually(beTrue(), timeout: 10)
            }

            it("returns error when if fails to update the todoitem") {
                let todoItemId = NSUUID().uuidString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = URL(string: "http://localhost\(todoItemPath)")!

                stub(condition: isHost("localhost") && isPath(todoItemPath) && isMethodPATCH()) { _ in
                    return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.updateTodoItem(url: url,
                                          todoItemData: [:] as [String: Any],
                                          success: { (_) in
                                              completionCalled = true
                                              expect(true).to(equal(false))
                                          },
                                          error: {
                                              completionCalled = true
                                          }
                )

                expect(completionCalled).toEventually(beTrue(), timeout: 10)
            }

            it("deletes the todoitem") {
                let todoItemId = NSUUID().uuidString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = URL(string: "http://localhost\(todoItemPath)")!

                stub(condition: isHost("localhost") && isPath(todoItemPath) && isMethodDELETE()) { _ in
                    return OHHTTPStubsResponse(jsonObject: [], statusCode: 202, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.deleteTodoItem(url: url,
                                          success: { (todoItem) in
                                              completionCalled = true
                                          },
                                          error: {
                                              completionCalled = true
                                              expect(true).to(equal(false))
                                          }
                )

                expect(completionCalled).toEventually(beTrue(), timeout: 10)
            }

            it("returns error when if fails delete the todo") {
                let todoItemId = NSUUID().uuidString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = URL(string: "http://localhost/\(todoItemPath)")!

                stub(condition: isHost("localhost") && isPath(todoItemPath) && isMethodDELETE()) { _ in
                    return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.deleteTodoItem(url: url,
                                          success: { (_) in
                                              completionCalled = true
                                              expect(true).to(equal(false))
                                          },
                                          error: {
                                              completionCalled = true
                                          }
                )

                expect(completionCalled).toEventually(beTrue(), timeout: 10)
            }
        }

        describe("zzz") {
            it("zzz") {
            }
        }
    }
}
