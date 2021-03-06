import UIKit
import RxSwift
import RxCocoa

class CurrencyPairingViewController: MxViewController<CurrencyPairingIntent, CurrencyPairingResult, CurrencyPairingViewState, CurrencyPairingViewModel> {

    @IBOutlet weak var toolbar: ReachToolbar!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var currencyPairTextField: ReachTextField!
    @IBOutlet weak var updatePairButton: ReachPrimaryButton!
    @IBOutlet weak var activityIndicator: ReachActivityIndicator!

    var delegate: SettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.title = R.string.settingsStrings.settings_currency_pairing_title()
        currencyPairTextField.placeholder = R.string.settingsStrings.settings_currency_pairing_placeholder()
        noteLabel.text = R.string.settingsStrings.settings_currency_pairing_note()
        updatePairButton.setTitle(R.string.settingsStrings.settings_currency_pairing_cta(), for: .normal)
        setToolbar(toolbar: toolbar)
    }

    override func intents() -> Observable<CurrencyPairingIntent> {
        return Observable.merge(
            Observable.just(CurrencyPairingIntent.idle),
            Observable.merge(
                updatePairButton.rx.tap.asObservable(),
                currencyPairTextField.rx.controlEvent(.editingDidEndOnExit).asObservable()
            ).map {
                CurrencyPairingIntent.currencyPair(currencyPair: self.currencyPairTextField.text!)
            }
        )
    }

    override func idleIntent() -> CurrencyPairingIntent {
        return CurrencyPairingIntent.idle
    }

    override func render(state: CurrencyPairingViewState) {
        switch state {
        case .idle:
            break
        case .onProgress:
            activityIndicator.start()
            updatePairButton.gone()
        case .onError(let message):
            activityIndicator.stop()
            updatePairButton.visible()
            showOKDialog(
                title: R.string.appStrings.app_dialog_error_default_title(),
                message: message)
        case .onSuccess(let symbol):
            activityIndicator.stop()
            updatePairButton.visible()
            if let delegate = delegate {
                delegate.currencyUpdate(symbol: symbol)
            }
            close()
        }
    }

    override func provideViewModel() -> CurrencyPairingViewModel {
        return CurrencyPairingViewModel(initialState: CurrencyPairingViewState.idle)
    }
}
