import Foundation

struct AccountBundle: BundleModel {
    let accountName: String
    let readOnly: Bool
    let accountPage: AccountPage
}
