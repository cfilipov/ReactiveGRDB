#if USING_SQLCIPHER
    import GRDBCipher
#else
    import GRDB
#endif
import ReactiveKit

// TypedRequest
extension AdaptedFetchRequest {
    public var reactive: Reactive<AdaptedFetchRequest> {
        return Reactive(self)
    }
}

extension AnyFetchRequest {
    public var reactive: Reactive<AnyFetchRequest> {
        return Reactive(self)
    }
}
extension QueryInterfaceRequest {
    public var reactive: Reactive<QueryInterfaceRequest> {
        return Reactive(self)
    }
}
extension SQLRequest {
    public var reactive: Reactive<SQLRequest> {
        return Reactive(self)
    }
}

extension AdaptedFetchRequest : DatabaseRegionConvertible { }
extension AnyFetchRequest : DatabaseRegionConvertible { }
extension QueryInterfaceRequest : DatabaseRegionConvertible { }
extension SQLRequest : DatabaseRegionConvertible { }

// DatabaseWriter
extension DatabasePool : ReactiveExtensionsProvider { }
extension DatabaseQueue : ReactiveExtensionsProvider { }
extension AnyDatabaseWriter : ReactiveExtensionsProvider { }
