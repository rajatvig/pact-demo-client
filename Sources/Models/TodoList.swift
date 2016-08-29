import Foundation
import SwiftyJSON

public class TodoList: CustomStringConvertible, Equatable {
    let todoItems: [TodoItem]

    public init(_ jsonData: JSON) {
        self.todoItems = jsonData.arrayValue.map { return TodoItem($0) }
    }

    public var description: String {
        return "\(todoItems)"
    }

}

public func == (lhs: TodoList, rhs: TodoList) -> Bool {
    return lhs.todoItems == rhs.todoItems
}
