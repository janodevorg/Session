import Foundation

/// A protocol that mimics URLSession.
public protocol Session {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionDataTask
}
