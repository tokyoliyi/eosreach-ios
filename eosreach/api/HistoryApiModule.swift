import Foundation
import eosswift

class HistoryApiModule {
    static func create() -> HistoryApi {
        switch TargetSwitch.api() {
        case .stub:
            return HistoryApiFactory.create(
                rootUrl: EosEndpoint().get(),
                urlSession: StubUrlSession.shared.urlSession,
                useLogger: true)
        case .prod:
            return HistoryApiFactory.create(rootUrl: EosEndpoint().get())
        }
    }
}
