import Foundation

enum AccountResult: MxResult {
    case idle
    case balanceTabIdle
    case resourceTabIdle
    case voteTabIdle
    case onProgress(accountName: String)
    case onProgressWithStartingTab(accountName: String, page: AccountPage)
    case onSuccess(accountView: AccountView)
    case onErrorFetchingAccount
    case onErrorFetchingBalances
    case openNavigation
    case navigateToExplore
    case navigateToImportKey
    case navigateToCreateAccount
    case navigateToSettings
}
