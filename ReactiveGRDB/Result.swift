import ReactiveKit

public extension Result {
    public init(value: () throws -> T) {
        do {
            self = try .success(value())
        } catch {
            self = .failure(error as! E)
        }
    }

    public func map<V>(_ transform: (T) -> V) -> Result<V, E> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension ObserverProtocol {
    func onResult(_ result: Result<Element, Error>) {
        switch result {
        case .success(let element):
            next(element)
        case .failure(let error):
            failed(error)
        }
    }
}
