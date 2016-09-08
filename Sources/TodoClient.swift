import Foundation
import Alamofire
import SwiftyJSON

public class TodoClient {
    public init() {}

    public func getTodoList(url: NSURL, success: (TodoList) -> Void, error: () -> Void) -> Void {
        makeCall(
            url,
            success: { (jsonObj) in
                success(TodoList(jsonObj))
            },
            error: error
        )
    }

    public func getTodoItem(todoItemUrl: NSURL, success: (TodoItem) -> Void, error: () -> Void) -> Void {
        makeCall(
            todoItemUrl,
            success: { (jsonObj) in
                success(TodoItem(jsonObj))
            },
            error: error
        )
    }

    public func createTodoItem(url: NSURL, todoItemData: [String: AnyObject], success: (TodoItem) -> Void, error: () -> Void) -> Void {
        let headers = [
            "Accept": "application/json"
        ]

        Alamofire.request(.POST, url, headers: headers, parameters: todoItemData, encoding: .JSON)
          .validate()
          .responseJSON { response in
            guard response.result.isSuccess else {
                print("error while performing post: \(response.result.error)")
                error()
                return
            }

            if let value = response.result.value {
                success(TodoItem(JSON(value)))
            }
        }
    }

    public func updateTodoItem(url: NSURL, todoItemData: JSON, success: (TodoItem) -> Void, error: () -> Void) -> Void {
        let headers = [
            "Accept": "application/json"
        ]

        Alamofire.request(.PATCH, url, headers: headers, parameters: todoItemData.dictionaryObject, encoding: .JSON)
          .validate()
          .responseJSON { response in
            guard response.result.isSuccess else {
                print("error while performing patch: \(response.result.error)")
                error()
                return
            }

            if let value = response.result.value {
                success(TodoItem(JSON(value)))
            }
        }
    }

    public func deleteTodoItem(todoItemUrl: NSURL, success: () -> Void, error: () -> Void) -> Void {
        let headers = [
            "Accept": "application/json"
        ]

        Alamofire.request(.DELETE, todoItemUrl, headers: headers)
          .validate()
          .response { request, response, data, reqerror in
                      guard reqerror == nil else {
                          print("error while deleting product: \(reqerror)")
                          error()
                          return
                      }

                      success()
        }
    }

    private func makeCall(url: NSURL, success: (JSON) -> Void, error: () -> Void) -> Void {
        let headers = [
            "Accept": "application/json"
        ]

        Alamofire.request(.GET, url, headers: headers)
          .validate()
          .responseJSON { response in
            guard response.result.isSuccess else {
                print("error while performing get: \(url) : \(response.result.error)")
                error()
                return
            }

            if let value = response.result.value {
                success(JSON(value))
            }
        }
    }
}
