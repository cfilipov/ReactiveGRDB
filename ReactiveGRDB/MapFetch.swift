#if USING_SQLCIPHER
    import GRDBCipher
#else
    import GRDB
#endif
import ReactiveKit

/// An observable that fetches results from database connections
class MapFetch<ResultType, Error: Swift.Error> : SignalProtocol {

    typealias Element = ResultType
    
    private let fetchTokens: Signal<FetchToken, Error>
    private let fetch: (Database) throws -> ResultType
    
    /// Creates a MapFetch observable.
    ///
    /// - parameters:
    ///   - source: An observable sequence of FetchToken
    ///   - fetch: A closure that fetches elements
    init(
        source fetchTokens: Signal<FetchToken, Error>,
        fetch: @escaping (Database) throws -> ResultType)
    {
        self.fetchTokens = fetchTokens
        self.fetch = fetch
    }

    func observe(with observer: @escaping (Event<ResultType, Error>) -> ()) -> Disposable {
        let serialDisposable = SerialDisposable(otherDisposable: nil)
        let observer = AtomicObserver(disposable: serialDisposable, observer: observer)

        // The value eventually fetched on subscription
        var initialResult: Result<ResultType, Error>? = nil

        // Makes sure elements are emitted in the same order as tokens
        let orderingQueue = DispatchQueue(label: "ReactiveGRDB.MapFetch")

        serialDisposable.otherDisposable = fetchTokens.observe(with: { event in
            switch event {
            case .failed(let error): observer.failed(error)
            case .completed: observer.completed()
            case .next(let fetchToken):
                switch fetchToken.kind {

                case .databaseSubscription(let db):
                    // Current dispatch queue: the database writer
                    // dispatch queue.
                    //
                    // This token is emitted upon subscription.
                    initialResult = Result { try self.fetch(db) }

                case .subscription:
                    // Current dispatch queue: the dispatch queue of the
                    // scheduler used to create the source observable of
                    // fetch tokens.
                    //
                    // This token is emitted upon subscription,
                    // after `databaseSubscription`.
                    //
                    // NB: this code executes concurrently with database writes.
                    // Several `change` token may have already been received.
                    observer.onResult(initialResult!)

                case .change(let writer, let scheduler):
                    // Current dispatch queue: the database writer
                    // dispatch queue.
                    //
                    // This token is emitted after a transaction has
                    // been committed.
                    //
                    // We need a read access to fetch values, and we should
                    // release the writer queue as soon as possible.
                    //
                    // This is the exact job of the writer.concurrentRead
                    // method.
                    //
                    // Fetched elements must be emitted in the same order as the
                    // tokens: the serial orderingQueue takes care of
                    // FIFO ordering.
                    let future = writer.concurrentRead { try self.fetch($0) }
                    orderingQueue.async {
                        let result = Result<ResultType, Error> { try future.wait() }
                        scheduler.schedule {
                            if !serialDisposable.isDisposed {
                                observer.onResult(result)
                            }
                        }
                    }
                }
            }
        })
        return observer.disposable
    }

}
