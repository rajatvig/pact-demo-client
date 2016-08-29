import SwiftyJSON
import Quick
import Nimble
import OHHTTPStubs

class TodoClientSpec: QuickSpec {
    override func spec() {
        afterEach {
            OHHTTPStubs.removeAllStubs()
        }

        describe("todo client") {
            it("gets all the todos") {
                let filePath = NSBundle.init(forClass: self.dynamicType)
                               .pathForResource("todo_list", ofType: "json")!

                let data: NSData = NSData(contentsOfFile: filePath)!
                let url = NSURL.init(string: "http://localhost/todos")!

                stub(isHost("localhost") && isPath("/todos") && isMethodGET()) { _ in
                    return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json"])
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.getTodoList(url,
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
                let url = NSURL.init(string: "http://localhost/todos")!

                stub(isHost("localhost") && isPath("/todos") && isMethodGET()) { _ in
                    return OHHTTPStubsResponse(JSONObject: [], statusCode: 500, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.getTodoList(url,
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
                let todoItemId = NSUUID().UUIDString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = NSURL.init(string: "http://localhost\(todoItemPath)")!
                let jsonObj = [
                    "title": "blah",
                    "order": 523,
                    "completed": false,
                    "url": "http://localhost\(todoItemPath)"
                ]

                stub(isHost("localhost") && isPath(todoItemPath) && isMethodGET()) { _ in
                    return OHHTTPStubsResponse(JSONObject: jsonObj, statusCode: 200, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.getTodoItem(url,
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
                let todoItemId = NSUUID().UUIDString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = NSURL.init(string: "http://localhost/\(todoItemPath)")!

                stub(isHost("localhost") && isPath(todoItemPath) && isMethodGET()) { _ in
                    return OHHTTPStubsResponse(JSONObject: [], statusCode: 500, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.getTodoItem(url,
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
                let url = NSURL.init(string: "http://localhost/todos")!
                let jsonObj = [
                    "name": "todo1",
                    "order": 543
                ]

                let responseJsonObj = [
                    "name": "todo1",
                    "order": 543,
                    "completed": false,
                    "url": "http://localhost/todos/1"
                ]

                let expectedTodoItem = TodoItem(JSON(responseJsonObj))

                stub(isHost("localhost") && isPath("/todos") && isMethodPOST()) { req in
                    let postData = JSON(data: req.OHHTTPStubs_HTTPBody())
                    expect(postData).to(equal(JSON(jsonObj)))
                    return OHHTTPStubsResponse(JSONObject: responseJsonObj, statusCode: 201, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.createTodoItem(url,
                                          todoItemData: JSON(jsonObj),
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
                let url = NSURL.init(string: "http://localhost/todos")!

                stub(isHost("localhost") && isPath("/todos") && isMethodPOST()) { _ in
                    return OHHTTPStubsResponse(JSONObject: [], statusCode: 500, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.createTodoItem(url,
                                   todoItemData: JSON([]),
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
                let todoItemId = NSUUID().UUIDString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = NSURL.init(string: "http://localhost\(todoItemPath)")!

                let jsonObj = [
                    "title": "blah is good",
                    "order": 523,
                    "completed": true
                ]

                let responseJsonObj = [
                    "name": "blah is good",
                    "order": 4523,
                    "completed": true,
                    "url": "http://localhost/todos/1"
                ]

                let expectedTodoItem = TodoItem(JSON(responseJsonObj))

                stub(isHost("localhost") && isPath(todoItemPath) && isMethodPATCH()) { req in
                    let postData = JSON(data: req.OHHTTPStubs_HTTPBody())
                    expect(postData).to(equal(JSON(jsonObj)))
                    return OHHTTPStubsResponse(JSONObject: responseJsonObj, statusCode: 200, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.updateTodoItem(url,
                                          todoItemData: JSON(jsonObj),
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
                let todoItemId = NSUUID().UUIDString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = NSURL.init(string: "http://localhost\(todoItemPath)")!

                stub(isHost("localhost") && isPath(todoItemPath) && isMethodPATCH()) { _ in
                    return OHHTTPStubsResponse(JSONObject: [], statusCode: 500, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.updateTodoItem(url,
                                          todoItemData: JSON([]),
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
                let todoItemId = NSUUID().UUIDString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = NSURL.init(string: "http://localhost\(todoItemPath)")!

                stub(isHost("localhost") && isPath(todoItemPath) && isMethodDELETE()) { _ in
                    return OHHTTPStubsResponse(JSONObject: [], statusCode: 202, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.deleteTodoItem(url,
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
                let todoItemId = NSUUID().UUIDString
                let todoItemPath = "/todos/\(todoItemId)"

                let url = NSURL.init(string: "http://localhost/\(todoItemPath)")!

                stub(isHost("localhost") && isPath(todoItemPath) && isMethodDELETE()) { _ in
                    return OHHTTPStubsResponse(JSONObject: [], statusCode: 500, headers: nil)
                }

                let todoClient = TodoClient()

                var completionCalled = false

                todoClient.deleteTodoItem(url,
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
