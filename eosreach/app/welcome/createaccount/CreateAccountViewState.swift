import Foundation
import StoreKit

enum CreateAccountViewState: MxViewState {
    case idle
    case startBillingConnection
    case onSKProductSuccess(formattedPrice: String, skProduct: SKProduct)
    case onAccountNameValidationFailed
    case onAccountNameValidationNumberStartFailed
    case onAccountNameValidationPassed
    case onCreateAccountProgress
    case onCreateAccountSuccess(transactionIdentifier: String)
    case onImportKeyProgress
    case onImportKeyError
    case navigateToAccounts
}
