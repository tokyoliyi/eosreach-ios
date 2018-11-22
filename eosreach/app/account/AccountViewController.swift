import UIKit
import RxSwift
import RxCocoa
import Material
import SideMenu

class AccountViewController: MxViewController<AccountIntent, AccountResult, AccountViewState, AccountViewModel>, TabBarDelegate, AccountViewLayout, AccountNavigationDelegate, AccountDelegate {

    @IBOutlet weak var toolbar: ReachToolbar!
    @IBOutlet weak var balancesContainer: UIView!
    @IBOutlet weak var availableBalanceValueLabel: UILabel!
    @IBOutlet weak var availableBalanceLabel: UILabel!
    @IBOutlet weak var tabBar: ReachTabBar!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicator: ReachActivityIndicator!
    @IBOutlet weak var errorView: ErrorView!
    
    private let navigationMenuItem = IconButton(image: Icon.cm.menu, tintColor: .white)
    private let navigationExploreItem = IconButton(image: Icon.cm.search, tintColor: .white)
    private let balanceTabItem = TabItem()
    private let resourcesTabItem = TabItem()
    private let voteTabItem = TabItem()
    private var loaded = false
    
    private var balanceViewController: BalanceViewController?
    private var resourcesViewController: ResourcesViewController?
    private var voteViewController: VoteViewController?
    
    private lazy var accountBundle = {
        return self.getDestinationBundle()!.model as! AccountBundle
    }()
    
    private lazy var accountRenderer: AccountRenderer = {
        return AccountRenderer(accountViewLayout: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        balanceTabItem.title = R.string.accountStrings.account_tab_balance()
        resourcesTabItem.title = R.string.accountStrings.account_tab_resources()
        voteTabItem.title = R.string.accountStrings.account_tab_vote()
        tabBar.tabItems = [balanceTabItem,resourcesTabItem,voteTabItem]
        tabBar.setup()
        tabBar.delegate = self
        
        if (accountBundle.readOnly) {
            setToolbar(toolbar: toolbar)
        } else {
            toolbar.leftViews.removeAll()
            toolbar.leftViews.append(navigationMenuItem)
            toolbar.rightViews.append(navigationExploreItem)
        }
    }

    override func intents() -> Observable<AccountIntent> {
        return Observable.merge(
            Observable.just(AccountIntent.start(accountBundle: accountBundle)),
            errorView.retryClick().map {
                return AccountIntent.retry(accountBundle: self.accountBundle)
            },
            navigationMenuItem.rx.tap.map {
                AccountIntent.openNavigation
            },
            navigationExploreItem.rx.tap.map {
                AccountIntent.navigateToExplore
            },
            self.rx.methodInvoked(#selector(AccountViewController.importKeyNavigationSelected)).map { _ in
                return AccountIntent.navigateToImportKey
            },
            self.rx.methodInvoked(#selector(AccountViewController.createAccountNavigationSelected)).map { _ in
                return AccountIntent.navigateToCreateAccount
            },
            self.rx.methodInvoked(#selector(AccountViewController.settingsNavigationSelected)).map { _ in
                return AccountIntent.navigateToSettings
            },
            self.rx.methodInvoked(#selector(AccountViewController.accountsNavigationSelected(accountName:))).map { accountNameInArgs in
                self.loaded = false
                return AccountIntent.refresh(accountBundle: AccountBundle(
                    accountName: accountNameInArgs[0] as! String,
                    readOnly: false,
                    accountPage: AccountPage.balances))
            },
            self.rx.methodInvoked(#selector(AccountViewController.refreshAccount)).map { _ in
                return AccountIntent.refresh(accountBundle: self.accountBundle)
            }
        )
    }

    override func idleIntent() -> AccountIntent {
        return AccountIntent.idle
    }
    
    override func render(state: AccountViewState) {
        accountRenderer.render(state: state)
    }

    override func provideViewModel() -> AccountViewModel {
        return AccountViewModel(initialState: AccountViewState(view: AccountViewState.View.idle))
    }
    
    private func replaceChildViewController(viewController: UIViewController) {
        addChild(viewController)
        containerView.addSubview(viewController.view)
        
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    @objc func tabBar(tabBar: TabBar, willSelect tabItem: TabItem) {
        if (tabItem == balanceTabItem) {
            replaceChildViewController(viewController: balanceViewController!)
        } else if (tabItem == resourcesTabItem) {
            replaceChildViewController(viewController: resourcesViewController!)
        } else if (tabItem == voteTabItem) {
            replaceChildViewController(viewController: voteViewController!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination is UISideMenuNavigationController) {
            let sideMenuNavigationController = (segue.destination as! UISideMenuNavigationController)
            (sideMenuNavigationController.topViewController as! AccountNavigationViewController).delegate = self
            super.prepare(for: segue, sender: sender)
        }
    }
    
    //
    // MARK :- AccountDelegate
    //
    @objc dynamic func refreshAccount() {
    }
    
    //
    // MARK :- AccountNavigationDelegate
    //
    @objc dynamic func importKeyNavigationSelected() {
    }
    
    @objc dynamic func createAccountNavigationSelected() {
    }
    
    @objc dynamic func settingsNavigationSelected() {
    }
    
    @objc dynamic func accountsNavigationSelected(accountName: String) {
    }
    
    //
    // MARK :- AccountViewLayout
    //
    func populate(accountView: AccountView, page: AccountPage) {
        loaded = true
        toolbar.title = accountView.eosAccount!.accountName
        tabBar.select(at: 0)
        activityIndicator.stop()
        balancesContainer.visible()
        tabBar.visible()
        containerView.visible()
        
        let contractAccountBalance = createContractAccountBalance(accountView: accountView)
        
        balanceViewController = R.storyboard.main.balanceViewController()
        balanceViewController!.accountName = accountView.eosAccount!.accountName
        balanceViewController!.accountBalanceList = accountView.balances!
        
        voteViewController = R.storyboard.main.voteViewController()
        voteViewController!.eosAccount = accountView.eosAccount
        voteViewController!.readOnly = self.accountBundle.readOnly
        voteViewController!.accountDelegate = self
        
        resourcesViewController = R.storyboard.main.resourcesViewController()
        resourcesViewController!.eosAccount = accountView.eosAccount!
        resourcesViewController!.contractAccountBalance = contractAccountBalance
        resourcesViewController!.readOnly = self.accountBundle.readOnly
        
        switch page {
        case .balances:
            replaceChildViewController(viewController: balanceViewController!)
        case .resources:
            replaceChildViewController(viewController: resourcesViewController!)
        case .vote:
            replaceChildViewController(viewController: voteViewController!)
        }
    }
    
    func populateTitle(title: String) {
        toolbar.title = title
    }
    
    func showPriceUnavailable() {
        availableBalanceValueLabel.text = R.string.accountStrings.account_available_balance_unavailable_value()
        availableBalanceLabel.text = R.string.accountStrings.account_available_balance_unavailable_label()
    }
    
    func showPrice(formattedPrice: String) {
        availableBalanceValueLabel.text = formattedPrice
    }
    
    func showProgress() {
        activityIndicator.start()
        containerView.gone()
        errorView.gone()
        balancesContainer.gone()
        tabBar.gone()
    }
    
    func showGetAccountError() {
        activityIndicator.stop()
        
        if (!loaded) {
            errorView.visible()
            errorView.populate(
                title: R.string.accountStrings.account_error_get_account_title(),
                body: R.string.accountStrings.account_error_get_account_body())
        } else {
            showOKDialog(title: R.string.accountStrings.account_error_get_account_title(), message: R.string.accountStrings.account_error_get_account_body())
        }
    }
    
    func showGetBalancesError() {
        activityIndicator.stop()
        errorView.visible()
        errorView.populate(
            title: R.string.accountStrings.account_error_get_balances_title(),
            body: R.string.accountStrings.account_error_get_balances_body())
    }
    
    func openNavigation() {
        performSegue(withIdentifier: R.segue.accountViewController.accountToNavigationDrawer, sender: self)
    }
    
    func navigateToExplore() {
        performSegue(withIdentifier: R.segue.accountViewController.accountToExplore, sender: self)
    }
    
    func navigateToImportKey() {
        performSegue(withIdentifier: R.segue.accountViewController.accountToImportKey, sender: self)
    }
    
    func navigateToCreateAccount() {
        performSegue(withIdentifier: R.segue.accountViewController.accountToCreateAccount, sender: self)
    }
    
    func navigateToSettings() {
        performSegue(withIdentifier: R.segue.accountViewController.accountToSettings, sender: self)
    }
    
    private func createContractAccountBalance(accountView: AccountView) -> ContractAccountBalance {
        if let accountBalanceList = accountView.balances {
            if (accountBalanceList.balances.isNotEmpty()) {
                return accountBalanceList.balances[0]
            } else {
                return ContractAccountBalance.unavailable()
            }
        } else {
            return ContractAccountBalance.unavailable()
        }
    }
}
