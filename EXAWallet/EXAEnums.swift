//
// Created by Igor Efremov on 21/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

enum EXALocalizedString: String {
    case exantech = "EXANTECH",
         commonAppTitle = "COMMON_APP_TITLE",
         commonCopiedToClipboard = "COMMON_COPIED_TO_CLIPBOARD",
         commonSafeNote = "COMMON_SAFE_NOTE",
         commonClose = "COMMON_CLOSE",
         commonCancel = "COMMON_CANCEL",
         commonSkip = "COMMON_SKIP",
         commonContinue = "COMMON_CONTINUE",
         commonMiss = "COMMON_MISS",
         commonSetup = "COMMON_SETUP",
         commonSend = "COMMON_SEND",
         commonJoin = "COMMON_JOIN",
         commonOk = "COMMON_OK",
         commonApply = "COMMON_APPLY",
         commonError = "COMMON_ERROR",
         commonResetToDefault = "COMMON_RESET_TO_DEFAULT",
         commonWarning = "COMMON_WARNING",
         commonPassphrase = "COMMON_PASSPHRASE",
         commonPassphraseEnter = "COMMON_PASSPHRASE_ENTER",
         commonEnterPassword = "COMMON_ENTER_PASSWORD",
         commonEnable = "COMMON_ENABLE",
         personal = "COMMON_PERSONAL",
         shared = "COMMON_SHARED",
         syncBtn = "SYNC_BTN",
         checkSyncStateBtn = "CHECK_SYNC_STATE_BTN",
         prepareSync = "PREPARE_SYNC",
         connectingNode = "CONNECTING_NODE",
         nodeConnectionError = "NODE_CONNECTION_ERROR",
         syncingState = "SYNCING",
         syncedState = "SYNCED",
         viewInBlockchain = "VIEW_IN_BLOCKCHAIN",
         settingsTitle = "SETTINGS_TITLE",
         settingsTabTitle = "SETTINGS_TAB_TITLE",
         settingsAbout = "SETTINGS_ABOUT",

         settingsEditMeta = "SETTINGS_EDIT_META",
         settingsNodeAddress = "SETTINGS_NODE_ADDRESS",
         settingsEnterNodeAddress = "SETTINGS_ENTER_NODE_ADDRESS",
         settingsHideBalance = "SETTINGS_HIDE_BALANCE",
         settingsRequestPasswordWhenOpening = "SETTINGS_REQUEST_PASSWORD_WHEN_OPENING",
         settingsRememberPassphrase = "SETTINGS_REMEMBER_PASSPHRASE",
         settingsPasswordRequired = "SETTINGS_PASSWORD_REQUIRED",
         settingsChangeWalletPassword = "SETTINGS_CHANGE_WALLET_PASSWORD",
         settingsDeleteWalletOption = "SETTINGS_DELETE_WALLET_OPTION",

         dashboardTitle = "DASHBOARD_TITLE",
         dashboardTabTitle = "DASHBOARD_TAB_TITLE",
         sendTitle = "SEND_TITLE",
         sendTabTitle = "SEND_TAB_TITLE",
         createPersonalWallet = "CREATE_PERSONAL_WALLET",
         createPersonalWalletTitle = "CREATE_PERSONAL_WALLET_TITLE",
         createCommonWalletTitle = "CREATE_COMMON_WALLET_TITLE",
         createExplanationTitle = "CREATE_EXPLANATION_TITLE",
         createVcTitle = "CREATE_VC_TITLE",
         setupPassExplanationTitle = "SETUP_PASS_EXPLANATION_TITLE",
         setupPassEnterPass = "SETUP_PASS_ENTER_PASS",
         setupPassVerifyPass = "SETUP_PASS_VERIFY_PASS",
         amountTitlePlaceholder = "AMOUNT_TITLE_PLACEHOLDER",
         amountValuePlaceholder = "AMOUNT_VALUE_PLACEHOLDER",
         transactionsTitle = "TRANSACTIONS_TITLE",
         transactionsEmpty = "TRANSACTIONS_EMPTY",
         receiveTitle = "RECEIVE_TITLE",
         receiveHeadTitle = "RECEIVE_HEAD_TITLE",
         receiveTabTitle = "RECEIVE_TAB_TITLE",

         sendAddressPlaceholder = "SEND_ADDRESS_PLACEHOLDER",

         walletHomeTransactions = "WALLET_HOME_TRANSACTIONS",
         walletHomeProposals = "WALLET_HOME_PROPOSALS",

         chooseOption = "WALLET_CHOOSE_OPTION",
         createOptionPersonalWallet = "CREATE_OPTION_PERSONAL_WALLET",
         createOptionCommonWallet = "CREATE_OPTION_COMMON_WALLET",
         createOptionJoinCommonWallet = "CREATE_OPTION_JOIN_COMMON_WALLET",
         createOptionRestoreWallet = "CREATE_OPTION_RESTORE_WALLET",
         walletPersonal = "WALLET_PERSONAL",
         walletCommon = "WALLET_COMMON",

         paymentIdTitle = "PAYMENT_ID_TITLE",
         paymentIdDescription = "PAYMENT_ID_DESCRIPTION",
         paymentIdGenerate = "PAYMENT_ID_GENERATE",

         scanTitle = "SCAN_TITLE",
         scanCameraUnavailable = "SCAN_CAMERA_UNAVAILABLE",

         validatePassphrase = "VALIDATE_PASSPHRASE",
         invalidPassphrase = "INVALID_PASSPHRASE",

         setEmptyPass       = "SET_EMPTY_PASS",
         skipVerifyPassNote = "SKIP_VERIFY_PASS_NOTE",

         restoreWallet = "RESTORE_WALLET",
         joinWallet = "JOIN_TITLE",

         restoreEnterBlockHeight = "RESTORE_ENTER_BLOCK_HEIGHT",
         restoreBlockHeightOptional = "RESTORE_BLOCK_HEIGHT_OPTIONAL",
         restoreWarning = "RESTORE_WARNING",

         enterRemoteNodeAddress = "ENTER_REMOTE_NODE_ADDRESS",
         remoteNode = "REMOTE_NODE",

         invitesVcTitle = "INVITES_VC_TITLE",

         shareNote = "SHARE_NOTE",
         shareInvitation = "SHARE_INVITATION",

         proposalCreate = "PROPOSAL_CREATE",
         proposalApprove = "PROPOSAL_APPROVE",
         proposalReject = "PROPOSAL_REJECT",

         sharedWalletReady = "SHARED_WALLET_READY",

         pinCodeCreate = "PIN_CREATE_SECURITY_CODE",
         pinCodeEnter = "PIN_ENTER_SECURITY_CODE",
         pinCodeConfirm = "PIN_CONFIRM_SECURITY_CODE",

         authBioTouchId = "AUTH_BIO_TOUCH_ID_STRING",
         authBioFaceId = "AUTH_BIO_FACE_ID_STRING",
         authBioEnterPassword = "AUTH_BIO_ENTER_PASSWORD",

         auth_error_base = "AUTH_ERROR_BASE",
         authErrorBioLockout = "AUTH_ERROR_BIO_LOCKOUT",
         auth_error_bio_notallowed = "AUTH_ERROR_BIO_NOTALLOWED",
         authErrorPasscodeNotSet = "AUTH_ERROR_PASSCODE_NOT_SET",

         auth_bio_touch_message_setup = "AUTH_BIO_TOUCH_MESSAGE_SETUP",
         auth_bio_face_message_setup = "AUTH_BIO_FACE_MESSAGE_SETUP",
    
         wrongWalletPassword = "WRONG_WALLET_PASSWORD",
         sorryTryLater = "SORRY_TRY_LATER",

         aboutText = "ABOUT_TEXT",
         aboutFirstHeader = "ABOUT_TEXT_FIRST_HEADER",
         aboutFirstSubHeader = "ABOUT_TEXT_FIRST_SUB_HEADER",
         aboutSecondHeader = "ABOUT_TEXT_SECOND_HEADER",
         aboutSecondSubHeader = "ABOUT_TEXT_SECOND_SUB_HEADER",
         aboutThirdHeader = "ABOUT_TEXT_THIRD_HEADER",
         aboutTextThirdSubHeader = "ABOUT_TEXT_THIRD_SUB_HEADER"

    var l10n: String {
        return EXACommon.l10n(self.rawValue)
    }
}

enum EXADialogMessage: Int {
    case WalletSuccessfullyCreated
    case CommonWalletSuccessfullyCreated
    case WalletSuccessfullyRestored
    case WalletsSuccessfullyDeleted
    case CreateTxProposal
    case InviteCodeAccepted

    var description: String {
        switch self {
        case .WalletSuccessfullyCreated: return "New wallet successfully created"
        case .CommonWalletSuccessfullyCreated: return "Shared wallet successfully created"
        case .WalletSuccessfullyRestored: return "Exist wallet successfully restored"
        case .WalletsSuccessfullyDeleted: return "All wallets successfully deleted"
        case .CreateTxProposal: return "Create Tx Proposal"
        case .InviteCodeAccepted: return "Invite code accepted"
        }
    }

    var title: String {
        switch self {
            default:
                return EXAAppInfoService.appTitle
        }
    }

    var buttonTitle: String {
        switch self {
        default:
            return l10n(.commonOk)
        }
    }
}

enum EXAError: Error {
    case CommonError(message: String)
    case WalletCreatingError(message: String)
    case WalletRestoringError(message: String)
    case WalletOpeningError(message: String)
    case WalletNotInitialized
    case AmountNotSetup
    case TransactionSendFailed(message: String)
    case WrongPassword

    var description: String {
        switch self {
            case let .CommonError(message): return "Error: \(message)"
            case let .WalletCreatingError(message): return "\(message)".capitalizedOnlyFirst
            case let .WalletRestoringError(message): return "\(message)".capitalizedOnlyFirst
            case let .WalletOpeningError(message): return "Wallet couldn't be opened:\n\(message)"
            case .WalletNotInitialized: return "Wallet is not initialized"
            case .AmountNotSetup: return "Amount value is not setup"
            case let .TransactionSendFailed(message): return "\(message)".capitalizedOnlyFirst
            case .WrongPassword: return l10n(.sorryTryLater)
        }
    }

    var title: String {
        switch self {
            case .WalletCreatingError(_): return "Wallet Creating Error"
            case .WalletRestoringError(_): return "Wallet Restoring Error"
            case .TransactionSendFailed(_): return "Transaction Sending Error"
            case .WrongPassword: return l10n(.wrongWalletPassword)
        default:
            return "Error"
        }
    }
}

enum TransactionType: Int, Codable {
    case received = 0, sent

    var description: String {
        switch self {
        case .sent: return "Sent"
        case .received: return "Received"
        }
    }
}

enum WalletType: Int, Codable{
    case personal = 0, shared

    var description: String {
        switch self {
        case .personal: return l10n(.walletPersonal)
        case .shared: return l10n(.walletCommon)
        }
    }
}

enum EXAWalletMetaMode: Int {
    case create, edit
}

enum EXAWalletPassPhraseMode: Int {
    case normal, remember
}

enum EXAMoneroWalletCreateOption: Int {
    case createPersonal = 0, createShared, joinShared, restore
    static let all = [createPersonal, createShared, joinShared, restore]

    var isActive: Bool {
        return true
    }

    var description: String {
        switch self {
        case .createPersonal: return l10n(.createOptionPersonalWallet)
        case .createShared: return l10n(.createOptionCommonWallet)
        case .joinShared: return l10n(.createOptionJoinCommonWallet)
        case .restore: return l10n(.createOptionRestoreWallet)
        }
    }

    var screenTitle: String {
        switch self {
        case .createPersonal: return l10n(.createPersonalWalletTitle)
        case .createShared: return l10n(.createCommonWalletTitle)
        case .joinShared: return l10n(.joinWallet)
        case .restore: return l10n(.restoreWallet)
        }
    }

    var imageName: String {
        switch self {
        case .createPersonal: return "create_personal_wallet"
        case .createShared: return "create_common_wallet"
        case .joinShared: return "join_wallet"
        case .restore: return "restore_wallet"
        }
    }
}

enum EXAWalletDefaults: String {
    case moneroWalletsList = "exaMoneroWalletsList"
    case sessionId = "sharedWalletSessionId"
    case inviteCode = "sharedWalletInviteCode"
    case sentOutputForTransactionsCount = "sentOutputForTransactionsCount"
    case lastImportedOutputsHash = "lastImportedOutputsHash"
    case lastImportedOutputsHashes = "lastImportedOutputsHashes"
    case sharedPubKeys = "sharedPubKeys"
    case extraMultiInfo = "extraMultiInfo"
    case walletTransformationCurrentLevel = "walletTransformationCurrentLevel"
    case changedKey = "changedKey"
    case exaWalletDeviceUid = "exaWalletDeviceUid"

    case oldPersonalKey = "oldPersonalKey"

    case oldPubKey = "oldPubKey"
    case oldSecretKey = "oldSecretKey"
}

enum EXATableCellInfoType: Int {
    case content, action
}

enum EXAValidatorResult: Int {
    case ok, failure
}

extension NSNotification.Name {

    static let WalletNameChanged = "WalletNameChanged"
    static let ProposalsReloadNeeded = "ProposalsReloadNeeded"
    static let CurrentBlockHeightChanged = "CurrentBlockHeightChanged"
    static let CloseCurrentWallet = "CloseCurrentWallet"
}

