#if USING_SQLCIPHER
    import GRDBCipher
#else
    import GRDB
#endif
import ReactiveKit

final class FetchTokensObservable : SignalProtocol {
    typealias Element = FetchToken
    typealias Error = AnyError
    let writer: DatabaseWriter
    let startImmediately: Bool
    let scheduler: FetchTokenExecutionContext
    let observedRegion: (Database) throws -> DatabaseRegion
    
    /// Creates an observable that emits `.change` fetch tokens on the database
    /// writer queue when a transaction has modified the database in a way that
    /// impacts a database region.
    ///
    /// When the `startImmediately` argument is true, the observable also emits
    /// one `.databaseSubscription` and one `.subscription` token upon
    /// subscription.
    ///
    /// The `.databaseSubscription` token is emitted from the database writer
    /// queue, and the `.subscription` token is emitted from the subscription
    /// dispatch queue.
    ///
    /// It is possible for concurrent threads to commit database transactions
    /// that modify the database between the `.databaseSubscription` token and
    /// the `.subscription` token. When this happens, `.change` tokens are
    /// emitted after `.databaseSubscription`, and before `.subscription`.
    init(
        writer: DatabaseWriter,
        startImmediately: Bool,
        scheduler: FetchTokenExecutionContext,
        observedRegion: @escaping (Database) throws -> DatabaseRegion)
    {
        self.writer = writer
        self.startImmediately = startImmediately
        self.scheduler = scheduler
        self.observedRegion = observedRegion
    }

    func observe(with observer: @escaping (Event<FetchToken, AnyError>) -> ()) -> Disposable {
        // A mutex that protects access to transactionObserver and disposed flag
        let mutex = PThreadMutex()
        var transactionObserver: DatabaseRegionObserver? = nil
        var disposed: Bool = false

        let writer = self.writer
        let startImmediately = self.startImmediately
        let scheduler = self.scheduler
        let observedRegion = self.observedRegion

        scheduler.schedule {
            do {
                try mutex.lock {
                    guard !disposed else {
                        return
                    }

                    transactionObserver = try writer.unsafeReentrantWrite { db -> DatabaseRegionObserver in
                        if startImmediately {
                            observer(.next(FetchToken(kind: .databaseSubscription(db))))
                        }

                        let transactionObserver = try DatabaseRegionObserver(
                            observedRegion: observedRegion(db),
                            onChange: { observer(.next(FetchToken(kind: .change(writer, scheduler)))) })
                        db.add(transactionObserver: transactionObserver)
                        return transactionObserver
                    }

                    if startImmediately {
                        observer(.next(FetchToken(kind: .subscription)))
                    }
                }

            } catch {
                observer(.failed(AnyError(error)))
            }
        }

        return BlockDisposable {
            mutex.lock {
                disposed = true

                if let transactionObserver = transactionObserver {
                    writer.unsafeReentrantWrite { db in
                        db.remove(transactionObserver: transactionObserver)
                    }
                }
            }
        }
    }
}
