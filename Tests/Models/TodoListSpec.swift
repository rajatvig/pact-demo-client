import Foundation
import SwiftyJSON
import Quick
import Nimble
import TodoClient

class TodoListSpec: QuickSpec {
    override func spec() {
        describe("create") {
            it("should parse JSON") {
                let todoItem1 = [
                    "title": "blah",
                    "order": 523,
                    "completed": false,
                    "url": "http://localhost/todos/1"
                    ]
                let todoItem2 = [
                    "title": "blah",
                    "order": 524,
                    "completed": true,
                    "url": "http://localhost/todos/2"
                    ]
                let todoList = TodoList(JSON([todoItem1, todoItem2]))

                expect(todoList.todoItems).to(haveCount(2))
                expect(todoList.todoItems).to(contain(TodoItem(JSON(todoItem1))))
                expect(todoList.todoItems).to(contain(TodoItem(JSON(todoItem2))))
            }
        }

        describe("isEqual") {
            it("should be equal for same JSON") {
                let todoItem1 = [
                    "title": "blah",
                    "order": 523,
                    "completed": false,
                    "url": "http://localhost/todos/1"
                ]
                let todoItem2 = [
                    "title": "blah",
                    "order": 524,
                    "completed": true,
                    "url": "http://localhost/todos/2"
                ]
                let todoList = TodoList(JSON([todoItem1, todoItem2]))

                expect(todoList).to(equal(TodoList(JSON([todoItem1, todoItem2]))))
            }

            it("should not be equal for different JSON") {
                let todoItem1 = [
                    "title": "blah",
                    "order": 523,
                    "completed": false,
                    "url": "http://localhost/todos/1"
                ]
                let todoItem2 = [
                    "title": "blah",
                    "order": 524,
                    "completed": true,
                    "url": "http://localhost/todos/2"
                ]
                let todoList = TodoList(JSON([todoItem1, todoItem2]))

                expect(todoList).toNot(equal(TodoList(JSON([todoItem1]))))
            }

        }

        describe("zzz") {
            it("zzz") {
            }
        }

    }
}
