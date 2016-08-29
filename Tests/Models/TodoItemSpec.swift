import Foundation
import SwiftyJSON
import Quick
import Nimble

class TodoItemSpec: QuickSpec {
    override func spec() {
        describe("create") {
            it("should parse JSON") {
                let todoItem = TodoItem(JSON([
                        "title": "blah",
                        "order": 523,
                        "completed": false,
                        "url": "http://localhost/todos/1"
                        ]))

                expect(todoItem.title).to(equal("blah"))
                expect(todoItem.order).to(equal(523))
                expect(todoItem.completed).to(beFalse())
                expect(todoItem.url).to(equal(NSURL.init(string: "http://localhost/todos/1")))
            }
        }

        describe("isEqual") {
            it("should be equal for same JSON") {
                let data = [
                    "title": "blah",
                    "order": 523,
                    "completed": false,
                    "url": "http://localhost/todos/1"
                    ]

                let todoItem = TodoItem(JSON(data))

                expect(todoItem).to(equal(TodoItem(JSON(data))))
            }

            it("should not be equal for different title") {
                let data1 = [
                    "title": "blah1",
                    "order": 523,
                    "completed": false,
                    "url": "http://localhost/todos/1"
                ]
                let data2 = [
                    "title": "blah2",
                    "order": 523,
                    "completed": false,
                    "url": "http://localhost/todos/1"
                    ]

                let item1 = TodoItem(JSON(data1))
                let item2 = TodoItem(JSON(data2))

                expect(item1).toNot(equal(item2))
            }
        }

        describe("zzz") {
            it("zzz") {
            }
        }
    }

}
