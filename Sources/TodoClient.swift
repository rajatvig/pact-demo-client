import Foundation
import Alamofire
import SwiftyJSON

public class TodoClient {
    public init() {}

    public func getTodoList(url: URL, success: @escaping (TodoList) -> Void, error: @escaping () -> Void) -> Void {
        makeCall(
            url: url,
            success: { (jsonObj) in
                success(TodoList(jsonObj))
            },
            error: error
        )
    }

    public func getTodoItem(url: URL, success: @escaping (TodoItem) -> Void, error: @escaping () -> Void) -> Void {
        makeCall(
            url: url,
            success: { (jsonObj) in
                success(TodoItem(jsonObj))
            },
            error: error
        )
    }

    public func createTodoItem(url: URL, todoItemData: [String: Any], success: @escaping (TodoItem) -> Void, error: @escaping () -> Void) -> Void {
        let headers = [
            "Accept": "application/json"
        ]

        Alamofire.request(url, method: .post, parameters: todoItemData, encoding: JSONEncoding.default, headers: headers)
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

    public func updateTodoItem(url: URL, todoItemData: [String: Any], success: @escaping (TodoItem) -> Void, error: @escaping () -> Void) -> Void {
        let headers = [
            "Accept": "application/json"
        ]

        Alamofire.request(url, method: .patch, parameters: todoItemData, encoding: JSONEncoding.default, headers: headers)
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

    public func deleteTodoItem(url: URL, success: @escaping () -> Void, error: @escaping () -> Void) -> Void {
        let headers = [
            "Accept": "application/json"
        ]

        Alamofire.request(url, method: .delete, headers: headers)
          .validate()
          .response { response in
                      guard response.error == nil else {
                          print("error while deleting product: \(response.error)")
                          error()
                          return
                      }

                      success()
        }
    }

    private func makeCall(url: URL, success: @escaping (JSON) -> Void, error: @escaping () -> Void) -> Void {
        let headers = [
            "Accept": "application/json"
        ]

        Alamofire.request(url, headers: headers)
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
