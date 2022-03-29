# Testing a network client

## What to test in a network client?

A network client interacts with the world to send and receive information. Then it processes that information and outputs a result. We are interested in testing that “processing information” part, so we are going to replace the rest with test objects.

![networking](networking1)

Things to test here:
- Resource → URLRequest
- Response → Decodable

## Abstracting dependencies 

How to test with protocols?
1. Replace dependencies with protocols. 
2. Point dependencies to test objects.
3. Run the code under test providing known values through your test objects.
4. Assert the behavior of the tested code.

Here is a network request in a typical client:

```swift
import Foundation

let session = URLSession(configuration: URLSessionConfiguration.default)
let request = URLRequest(url: URL(string: "https://google.com")!)
let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in 
    print(response as Any) 
})
task.resume()

RunLoop.current.run(mode: RunLoop.Mode.default, before: NSDate(timeIntervalSinceNow: 1) as Date)
```

![networking2](networking2)

The objects that provide I/O are URLSession and URLSessionDataTask. Let’s write protocols to replace them:

```swift
protocol Session {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionDataTask
}

protocol SessionDataTask {
    func resume()
}
```

Once we replace the specific objects with the protocols, we will be able to provide two implementations:
- Apple’s URLSession, URLSessionDataTask
- Our test objects 

But first, we need to conform the real objects to our protocols:

```swift
extension URLSessionDataTask: SessionDataTask {}

extension URLSession: Session {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionDataTask {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }
}
```

Now our client depends on protocols, not on the original objects:

![networking3](networking3)

## Usage example

If you implement an API, you probably group the network calls in a network client
that uses `URLSession.shared`. But for unit tests, you need the network to have deterministic conditions, 
so you have to replace that shared session with one that stubs hardcoded results.

To switch the session for that client you need to inject the session through a init parameter. Something like this:
```swift
let client = WeatherClient(session: URLSession.shared)
client.weather(city: "London") { result in /* ... */ }
```
Now you are able to replace the session with a stubbed one in your unit tests:
```swift
let url = URL(string: "https://example.com")! 
let data = "{ ... a json response ... }".data(using: .utf8)
let sessionStub = JSONSessionStub.success(data: data, url: url)

let client = WeatherClient(session: sessionStub)
```

The example above uses JSONSessionStub to stub a JSON response. To stub something else
use the SessionStub superclass with the parameters data, response, and error that you prefer:
```swift
let data: Data? = nil
let response: URLResponse? = nil
let error: Error? = nil
let sessionStub = SessionStub(data: data, response: response, error: error)

let client = WeatherClient(session: sessionStub)
```

## What is a *stub* anyway?

A **stub** is an object without logic that simply returns fixed values. 

A stub is one kind of test double. A **test double** is an object that stands for a real object in a test. The name comes from the term stunt double used in cinema. There are five kinds:

- **Dummy**: an object that fills a space but doesn't actually do anything.
- **Fake**: an object with a simple implementation. It behaves like a real object but it is not suitable for production. For example, an in-memory database in place of a real one.
- **Mock**: an object with expectations on how it should be called. The test fails if it is not called that way. Mocks say "I expect you to call foo() with bar, and if you don't there's an error"
- **Spy**: an object that records the calls received and asserts those calls.
- **Stub**: an object without logic that simply returns fixed values.
