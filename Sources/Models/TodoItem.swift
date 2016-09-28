import Foundation
import SwiftyJSON

public struct TodoItem: CustomStringConvertible, Equatable {
    public let title: String
    public let completed: Bool
    public let order: Int?
    public let url: URL?

    public init(_ jsonData: JSON) {
        self.title = jsonData["title"].stringValue
        self.completed = jsonData["completed"].boolValue
        self.order = jsonData["order"].int
        self.url = URL.init(string: jsonData["url"].stringValue)
    }

    public var description: String {
        return "title=\(self.title),completed=\(self.completed),order=\(self.order),url=\(self.url)"
    }
}

public func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
    return lhs.url == rhs.url && lhs.title == rhs.title && lhs.order == rhs.order && lhs.completed == rhs.completed
}
