// HexPriceManager.swift
// Copyright (c) 2022 Joe Blau

import Combine
import ComposableArchitecture
import EVMChain
import Foundation

public struct HexPriceManager {
    public enum Action: Equatable {
        case hexPrice(Data?, Chain)
    }

    var create: (AnyHashable) -> Effect<Action, Never> = { _ in _unimplemented("create") }

    var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("destroy") }

    var getPriceETH: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("getPriceETH") }
    
    var getPricePLS: (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("getPricePLS") }

    public func create(id: AnyHashable) -> Effect<Action, Never> {
        create(id)
    }

    public func destroy(id: AnyHashable) -> Effect<Never, Never> {
        destroy(id)
    }

    public func getPriceETH(id: AnyHashable) -> Effect<Never, Never> {
        getPriceETH(id)
    }
    
    public func getPricePLS(id: AnyHashable) -> Effect<Never, Never> {
        getPricePLS(id)
    }
}

public extension HexPriceManager {
    static let live: HexPriceManager = { () -> HexPriceManager in
        var manager = HexPriceManager()

        manager.create = { id in
            Effect.run { subscriber in
                let delegate = HexPriceManagerDelegate(subscriber)

                dependencies[id] = Dependencies(delegate: delegate,
                                                subscriber: subscriber)
                return AnyCancellable {
                    dependencies[id] = nil
                }
            }
        }

        manager.destroy = { id in
            .fireAndForget {
                dependencies[id]?.subscriber.send(completion: .finished)
                dependencies[id] = nil
            }
        }

        manager.getPriceETH = { id in
            .fireAndForget {
                let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)

                guard var URL = URL(string: "https://uniswapdataapi.azurewebsites.net/api/hexPrice") else { return }
                var request = URLRequest(url: URL)
                request.httpMethod = "GET"

                /* Start a new Task */
                let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    if error == nil {
                        let statusCode = (response as! HTTPURLResponse).statusCode
                        DispatchQueue.main.async {
                            dependencies[id]?.subscriber.send(.hexPrice(data, .ethereum))
                        }
                    }

                })
                task.resume()
                session.finishTasksAndInvalidate()
            }
        }
        
        manager.getPricePLS = { id in
            .fireAndForget {
                let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)

                guard var URL = URL(string: "https://graph.v2b.testnet.pulsechain.com/subgraphs/name/pulsechain/pulsex") else { return }
                var request = URLRequest(url: URL)
                request.httpMethod = "POST"

                // Headers

                request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

                // Body
                let bodyString = "{\n    \"query\": \"{pair(id:\\\"0x330c063ad9f681477b0f7a36aa3176ff3ce0bbb4\\\"){token0{id symbol name derivedPLS}token1{id symbol name derivedPLS}token0Price token1Price}}\",\n    \"variables\": {}\n}"

                request.httpBody = bodyString.data(using: .utf8, allowLossyConversion: true)

                /* Start a new Task */
                let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    if error == nil {
                        let statusCode = (response as! HTTPURLResponse).statusCode
                        DispatchQueue.main.async {
                            dependencies[id]?.subscriber.send(.hexPrice(data, .pulse))
                        }
                    }

                })
                task.resume()
                session.finishTasksAndInvalidate()
            }
        }

        return manager
    }()
}

private struct Dependencies {
    let delegate: HexPriceManagerDelegate
    let subscriber: Effect<HexPriceManager.Action, Never>.Subscriber
}

private var dependencies: [AnyHashable: Dependencies] = [:]

// MARK: - Delegate

private class HexPriceManagerDelegate: NSObject {
    let subscriber: Effect<HexPriceManager.Action, Never>.Subscriber

    init(_ subscriber: Effect<HexPriceManager.Action, Never>.Subscriber) {
        self.subscriber = subscriber
    }
}

#if DEBUG
    import Foundation

    public extension HexPriceManager {
        static func mock() -> Self { Self() }
    }

#endif

// MARK: - Unimplemented

public func _unimplemented(
    _ function: StaticString, file: StaticString = #file, line: UInt = #line
) -> Never {
    fatalError(
        """
        `\(function)` was called but is not implemented. Be sure to provide an implementation for
        this endpoint when creating the mock.
        """,
        file: file,
        line: line
    )
}
