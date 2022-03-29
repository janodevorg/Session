[![Swift](https://github.com/janodevorg/Session/actions/workflows/swift.yml/badge.svg)](https://github.com/janodevorg/Session/actions/workflows/swift.yml)

A Session protocol that mimics URLSession, so we can stub responses. 

Example: go from
```swift
let client = YourAPIClient(session: URLSession.shared)
client.people(page: 0, pageSize: 10) { result in ... }
```
to
```swift
let sessionStub = JSONSessionStub.success(data: "{...10 users...}".data(using: .utf8), url: someURL)
let client = YourAPIClient(session: sessionStub)
client.people(page: 0, pageSize: 10) { result in ... }
```
