//
//  TodoAPIServiceTests.swift
//  ToDoAppTests
//
//  Created by Сергей Скориков on 06.04.2026.
//

import XCTest
@testable import ToDoApp

final class TodoAPIServiceTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        URLProtocol.registerClass(URLProtocolMock.self)
    }

    override class func tearDown() {
        URLProtocol.unregisterClass(URLProtocolMock.self)
        super.tearDown()
    }

    override func setUp() {
        super.setUp()
        URLProtocolMock.requestHandler = nil
    }

    func test_fetchTodos_whenResponseIsValid_returnsDecodedTodos() {
        let json = """
        {
          "todos": [
            { "id": 1, "todo": "Buy milk", "completed": false, "userId": 10 },
            { "id": 2, "todo": "Walk dog", "completed": true, "userId": 20 }
          ],
          "total": 2,
          "skip": 0,
          "limit": 2
        }
        """.data(using: .utf8)!

        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, json)
        }

        let sut = makeSUT()
        let exp = expectation(description: "fetch todos success")

        sut.fetchTodos { result in
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 2)
                XCTAssertEqual(todos[0].id, 1)
                XCTAssertEqual(todos[0].todo, "Buy milk")
                XCTAssertEqual(todos[0].completed, false)
                XCTAssertEqual(todos[0].userId, 10)

                XCTAssertEqual(todos[1].id, 2)
                XCTAssertEqual(todos[1].todo, "Walk dog")
                XCTAssertEqual(todos[1].completed, true)
                XCTAssertEqual(todos[1].userId, 20)

            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_fetchTodos_whenNetworkError_returnsNetworkFailed() {
        URLProtocolMock.requestHandler = { _ in
            throw NSError(domain: "test.network", code: 1)
        }

        let sut = makeSUT()
        let exp = expectation(description: "network failure")

        sut.fetchTodos { result in
            guard case .failure(let error) = result else {
                XCTFail("Expected failure")
                return
            }

            guard case AppError.networkFailed = error else {
                XCTFail("Expected AppError.networkFailed, got \(error)")
                return
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_fetchTodos_whenStatusCodeIsNot2xx_returnsNetworkFailed() {
        let json = """
        {
          "todos": [],
          "total": 0,
          "skip": 0,
          "limit": 0
        }
        """.data(using: .utf8)!

        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, json)
        }

        let sut = makeSUT()
        let exp = expectation(description: "bad status code")

        sut.fetchTodos { result in
            guard case .failure(let error) = result else {
                XCTFail("Expected failure")
                return
            }

            guard case AppError.networkFailed = error else {
                XCTFail("Expected AppError.networkFailed, got \(error)")
                return
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_fetchTodos_whenJSONIsInvalid_returnsDecodingFailed() {
        let invalidJSON = """
        {
          "todos": [
            { "id": "wrong_type", "todo": "Buy milk", "completed": false, "userId": 10 }
          ],
          "total": 1,
          "skip": 0,
          "limit": 1
        }
        """.data(using: .utf8)!

        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidJSON)
        }

        let sut = makeSUT()
        let exp = expectation(description: "decoding failed")

        sut.fetchTodos { result in
            guard case .failure(let error) = result else {
                XCTFail("Expected failure")
                return
            }

            guard case AppError.decodingFailed = error else {
                XCTFail("Expected AppError.decodingFailed, got \(error)")
                return
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func makeSUT() -> TodoAPIService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: configuration)
        return TodoAPIService(session: session, decoder: JSONDecoder())
    }
}

private final class URLProtocolMock: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = URLProtocolMock.requestHandler else {
            client?.urlProtocol(
                self,
                didFailWithError: NSError(domain: "URLProtocolMock", code: 0)
            )
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let data {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
