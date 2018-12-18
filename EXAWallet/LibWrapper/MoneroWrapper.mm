//
// Created by Igor Efremov on 15/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

#import <iostream>
#import <future>
#import "MoneroWrapper.h"
#import "wallet2_api.h"
#import "InnerMoneroTransaction.h"
#import "callback_cpp.h"

#import "NSData+Hex.h"

using namespace Monero;

NSString * toUTF8(std::string value) {
    return [NSString stringWithCString: value.c_str() encoding: NSUTF8StringEncoding];
}

NSString * signMessage(NSString *message, NSString *secretKey) {
    std::string msg = [message cStringUsingEncoding:NSUTF8StringEncoding];
    std::string key = [secretKey cStringUsingEncoding:NSUTF8StringEncoding];
    return toUTF8(signMessage(msg, key));
}

@implementation TransactionWrapper {
    ::PendingTransaction *_transaction;
}

- (instancetype)init:(::PendingTransaction *)transaction {
    self = [super init];
    if (self) {
        _transaction = transaction;
    }

    return self;
}

- (bool)commit {
    _transaction->commit();
    return ::PendingTransaction::Status::Status_Ok == _transaction->status();
}

- (NSString *)signedData {
    if(_transaction != nil) {
        return toUTF8(_transaction->multisigSignData());
    }

    return nil;
}

@end

struct WalletListenerImpl: public ::WalletListener {
    std::atomic<bool> active_;
    std::unique_ptr<std::promise<void>> promise_;

    std::atomic<uint64_t > height_;

    std::unique_ptr<objc_callback<void(uint64_t)>> cbb = nil;

    std::atomic<bool> has_unconfirmed_;

    WalletListenerImpl() : active_(false), height_(0), has_unconfirmed_(false) {}

    WalletListenerImpl(const WalletListener &w) = delete;

    virtual ~WalletListenerImpl() {
        std::cout << "Destruct WalletListener" << std::endl;
    }
    virtual void moneySpent(const std::string &txId, uint64_t amount) {}
    virtual void moneyReceived(const std::string &txId, uint64_t amount) {
        std::cout << "moneyReceived" << std::endl;
    }
    virtual void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount) {
        std::cout << "unconfirmedMoneyReceived: " << txId << std::endl;
        has_unconfirmed_ = true;
    }
    virtual void newBlock(uint64_t height) {
        std::cout << "GOT new block: " << height << std::endl;
        height_ = height;
    }
    virtual void updated() {
        std::cout << "updated" << std::endl;
    }
    virtual void refreshed() {
        std::cout << "refreshed" << std::endl;
        if (active_) {
            promise_->set_value();
        }
    }
    void waitRefresh() {
        promise_.reset(new std::promise<void>());
        auto future = promise_->get_future();
        active_ = true;

        future.wait();

        active_ = false;
    }

    uint64_t currentBlock() {
        return height_;
    };

    bool hasUnconfirmed() {
        return has_unconfirmed_;
    };
};

@implementation MoneroWalletWrapper {
    std::unique_ptr<::Wallet> _wallet;
    std::unique_ptr<WalletListenerImpl> listener;

    ::WalletManagerFactory *_factory;
}

- (instancetype)init:(::WalletManagerFactory *)factory {
    self = [super init];
    if (self) {
        _factory = factory;
    }

    return self;
}

- (bool)create:(const std::string)path pass:(const std::string)pass
      language:(const std::string)language networkType:(::NetworkType)networkType {
    auto wallet = std::unique_ptr<::Wallet>(_factory->getWalletManager()->createWallet(path, pass, language, networkType));

    int status = 0;
    std::string error;
    wallet->statusWithErrorString(status, error);

    _wallet = ::std::move(wallet);

    return status == ::Wallet::Status::Status_Ok;
}

- (bool)open:(const std::string)path pass:(const std::string)pass networkType:(::NetworkType)networkType error:(NSString **)error {
    auto wallet = std::unique_ptr<::Wallet>(_factory->getWalletManager()->openWallet(path, pass, networkType));

    int status = 0;
    std::string err;
    wallet->statusWithErrorString(status, err);

    _wallet = ::std::move(wallet);
    *error = toUTF8(err);

    return status == ::Wallet::Status::Status_Ok;
}

- (bool)restore:(const std::string)path pass:(const std::string)pass mnemonic:(const std::string)mnemonic
     networkType:(::NetworkType)networkType blockHeight:(uint64_t)blockHeight {
    auto wallet = std::unique_ptr<::Wallet>(_factory->getWalletManager()->recoveryWallet(path, pass, mnemonic, networkType, blockHeight));

    int status = 0;
    std::string error;
    wallet->statusWithErrorString(status, error);

    _wallet = ::std::move(wallet);

    return status == ::Wallet::Status::Status_Ok;
}

- (bool)status {
    if(_wallet != nullptr) {
        return _wallet->status() == ::Wallet::Status::Status_Ok;
    } else {
        std::cout << "status: wallet is nil";
        return false;
    }
}

- (NSString *)publicAddress {
    if(_wallet != nullptr) {
        return [NSString stringWithCString: _wallet->address().c_str() encoding: NSUTF8StringEncoding];
    }

    return nil;
}

- (NSString *)publicSpendKey {
    if(_wallet != nullptr) {
        return [NSString stringWithCString: _wallet->publicSpendKey().c_str() encoding: NSUTF8StringEncoding];
    }

    return nil;
}

- (NSString *)secretSpendKey {
    if(_wallet != nullptr) {
        return [NSString stringWithCString: _wallet->secretSpendKey().c_str() encoding: NSUTF8StringEncoding];
    }

    return nil;
}

- (NSString *)publicMultiSpendKey {
    if(_wallet != nullptr) {
        return [NSString stringWithCString: _wallet->publicMultisigSignerKey().c_str() encoding: NSUTF8StringEncoding];
    }

    return nil;
}

- (NSString *)multisigInfo {
    if(_wallet != nullptr) {
        return toUTF8(_wallet->getMultisigInfo());
    }

    return nil;
}

- (bool)isReadyMultiSigWallet {
    if(_wallet != nullptr) {
        MultisigState state = _wallet->multisig();
        return state.isMultisig && state.isReady;
    }

    return false;
}

- (bool)isTransformedToMultiSigWallet {
    if(_wallet != nullptr) {
        MultisigState state = _wallet->multisig();
        return state.isMultisig;
    }

    return false;
}

- (bool)isFinalizeMultiSigNeeded {
    if(_wallet != nullptr) {
        MultisigState state = _wallet->multisig();
        return state.isMultisig && !state.isReady && (state.threshold < state.total);
    }

    return false;
}

- (bool)isWalletFinalized {
    if(_wallet != nullptr) {
        MultisigState state = _wallet->multisig();
        return state.isMultisig && state.isReady && (state.threshold < state.total);
    }

    return false;
}

- (NSString *)exchangeMultisigKeys:(nonnull NSArray<NSString *> *)extraInfo {
    if(_wallet != nullptr) {
        std::vector<std::string> infos;
        for(int i = 0; i < extraInfo.count; i++) {
            std::string item = [extraInfo[i] cStringUsingEncoding:NSUTF8StringEncoding];
            infos.push_back(item);
        }

        std::string result = _wallet->exchangeMultisigKeys(infos);
        int status = 0;
        std::string error;
        _wallet->statusWithErrorString(status, error);

        return toUTF8(result);
    }

    return @"";
}

- (bool)finalizeMultisig:(NSArray<NSString *> *)extraInfo {
    if(_wallet != nullptr) {
        std::vector<std::string> infos;
        for(int i = 0; i < extraInfo.count; i++) {
            std::string item = [extraInfo[i] cStringUsingEncoding:NSUTF8StringEncoding];
            infos.push_back(item);
        }

        return _wallet->finalizeMultisig(infos);
    }

    return false;
}

- (nonnull NSString *)makeSharedWallet:(NSArray<NSString *> *)info signers:(NSUInteger)signers {
    std::vector<std::string> infos;
    for(int i = 0; i < info.count; i++) {
        std::string item = [info[i] cStringUsingEncoding:NSUTF8StringEncoding];
        infos.push_back(item);
    }

    std::string result = _wallet->makeMultisig(infos, uint32_t(signers));
    std::cout << result << std::endl;

    return toUTF8(result);
}

- (bool)hasMultisigPartialKeyImages {
    if(_wallet != nullptr) {
        return _wallet->hasMultisigPartialKeyImages();
    }

    return false;
}

- (nullable NSString*)exportMultisigPartialKeyImages {
    std::string images;
    bool result =_wallet->exportMultisigImages(images);
    if (result) {
        return toUTF8(images);
    }

    return nil;
}

- (bool)importMultisigPartialKeyImages:(NSArray <NSString *> *)parts {
    std::vector<std::string> partialKeyImages;
    for(int i = 0; i < parts.count; i++) {
        std::string item = [parts[i] cStringUsingEncoding:NSUTF8StringEncoding];
        partialKeyImages.push_back(item);
    }

    if(_wallet != nullptr) {
        size_t result =_wallet->importMultisigImages(partialKeyImages);
        return result > 0;
    } else {
        return false;
    }
}

- (NSString *)signMessage:(NSString *)message {
    if(_wallet != nullptr) {
        std::string msg = [message cStringUsingEncoding:NSUTF8StringEncoding];
        return toUTF8(_wallet->signMessage(msg));
    }

    return nil;
}

+ (NSString *)signMessage:(NSString *)message withKey:(NSString *)key {
    return signMessage(message, key);
}

- (NSString *)signMultiMessage:(NSString *)message {
    if(_wallet != nullptr) {
        std::string msg = [message cStringUsingEncoding:NSUTF8StringEncoding];
        std::string sign = _wallet->signMultisigParticipant(msg);
        return toUTF8(sign);
    }

    return nil;
}

- (bool)verifySignedMessage:(NSString *)message publicKey:(NSString *)publicKey signature:(NSString *)signature {
    std::string msg = [message cStringUsingEncoding:NSUTF8StringEncoding];
    std::string pubKey = [publicKey cStringUsingEncoding:NSUTF8StringEncoding];
    std::string sign = [signature cStringUsingEncoding:NSUTF8StringEncoding];

    bool result = _wallet->verifyMessageWithPublicKey(msg, pubKey, sign);
    if(!result) {
        std::string errorStr = _wallet->errorString();
    }

    return result;
}

- (NSString *)decodeBase58Info:(NSString *)source {
    /*std::string encoded = [source cStringUsingEncoding:NSUTF8StringEncoding];
    std::string decoded;
    if (!tools::base58::decode(encoded, decoded)) {
        std::cerr << "Decoding error";
        return nil;
    }

    NSData *data = [[NSData alloc] initWithBytes:decoded.data() length:decoded.length()];
    NSString *hex = [data hexString];

    return hex;*/
    return nil;
}

- (NSString *)errorString {
    if(_wallet != nullptr) {
        int status = 0;
        std::string error;
        _wallet->statusWithErrorString(status, error);

        return toUTF8(error);
    }

    return @"";
}

- (NSString *)seed {
    if(_wallet != nullptr) {
        return [NSString stringWithCString: _wallet->seed().c_str() encoding: NSUTF8StringEncoding];
    }

    return nil;
}

- (bool)isSynchronized {
    if(_wallet != nullptr) {
        return _wallet->synchronized();
    }

    return false;
}

- (bool)isConnected {
    // TODO: and check other status (ConnectionStatus_WrongVersion)
    if(_wallet != nullptr) {
        ::Wallet::ConnectionStatus status = _wallet->connected();
        return status == ::Wallet::ConnectionStatus::ConnectionStatus_Connected;
    }

    return false;
}

- (bool)initializeSync:(NSString *)node {
    const char *nodeCStr = [node cStringUsingEncoding:NSUTF8StringEncoding];
    if(_wallet != nullptr) {
        _wallet->init(nodeCStr);
        return true;
    }

    return false;
}

- (bool)sync:(uint64_t)fromBlock {
    ::tools::set_max_concurrency(1);

    listener.reset(new WalletListenerImpl());
    _wallet->setListener(listener.get());

    _wallet->setRefreshFromBlockHeight(fromBlock);
    _wallet->setTrustedDaemon(true);
    _wallet->connectToDaemon();
    _wallet->startRefresh();
    listener->waitRefresh();

    return [self isSynchronized];
}

- (void)cancelSync {
    if(![self isSynchronized]) {
        listener->promise_->set_value();
    } else {
        [self clear];
    }

    //_wallet.reset();
}

- (void) update:(uint64_t)amount {
    NSLog(@"%llu", amount);
}

- (uint64_t)currentSyncBlock {
    if(listener != nullptr){
        return listener->currentBlock();
    }

    return 0;
}

- (bool)hasUnconfirmed {
    if(listener != nullptr){
        bool result = listener->hasUnconfirmed();
        if(result){
            listener->has_unconfirmed_ = false;
        }

        return result;
    }

    return false;
}

- (void)pauseSync {
    // TODO: check for repeat call after break sync!
    if(_wallet != nullptr) {
        _wallet->pauseRefresh();
    } else {
        NSLog(@"_wallet is nullptr");
    }
}

- (void)clear {
    std::cout << "clear" << std::endl;
    _wallet.reset();
    listener.reset(nullptr);
}

//RemoteMoneroNodesList.shared.defaultNode

- (void)connectToDaemon:(NSString *)node {
    if(_wallet != nullptr) {
        if (![self isConnected]) {
            const char *defaultNode = [node cStringUsingEncoding:NSUTF8StringEncoding];
            _wallet->init(defaultNode);
            _wallet->setTrustedDaemon(true);
            _wallet->connectToDaemon();
        }
    }
}

- (u_int64_t)amount {
    if(_wallet != nullptr) {
        return _wallet->unlockedBalanceAll();
    } else {
        NSLog(@"_wallet is nullptr");
        return 0;
    }
}

- (u_int64_t)unconfirmedAmount {
    if(_wallet != nullptr) {
        if(_wallet->balanceAll() >= _wallet->unlockedBalanceAll()) {
            return _wallet->balanceAll() - _wallet->unlockedBalanceAll();
        } else {
            return _wallet->balanceAll();
        }
    } else {
        NSLog(@"_wallet is nullptr");
        return 0;
    }
}

- (NSString *)formatAmount:(u_int64_t)amount {
    if(_wallet != nullptr) {
        return [NSString stringWithCString: _wallet->displayAmount(amount).c_str() encoding: NSUTF8StringEncoding];
    }
    return nil;
}

- (u_int64_t)amountFromDouble:(double)amount {
    if(_wallet != nullptr) {
        return _wallet->amountFromDouble(amount);
    }

    return 0;
}

- (NSArray <InnerMoneroTransaction *> *)transactionsHistory {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if(_wallet != nullptr) {
        TransactionHistory *history = _wallet->history();
        if(history == NULL) {
            return [arr copy];
        }

        history->refresh();
        std::vector<TransactionInfo *> items = history->getAll();

        for (auto &item : items) {
            if(0 == item->amount()) {
                continue;
            }

            std::cout << "== TRANSACTION: " << item->hash() << std::endl;
            std::cout << "\t\tAmount: " << item->amount() << std::endl;
            std::cout << "\t\tDirection: " << item->direction() << std::endl;
            std::cout << "\t\tBlock: " << item->blockHeight() << std::endl;
            std::cout << "\t\tPayment Id: " << item->paymentId() << std::endl;
            std::cout << "\t\tTimestamp: " << item->timestamp() << std::endl;
            std::cout << "\t\tFee: " << item->fee() << std::endl;
            std::cout << "\t\tConfirmations: " << item->confirmations() << std::endl;

            std::vector<TransactionInfo::Transfer> transfers = item->transfers();

            InnerMoneroTransaction *tx = [[InnerMoneroTransaction alloc] init];
            tx.txHash = toUTF8(item->hash());
            if(transfers.size() > 0) {
                tx.destination = toUTF8(transfers[0].address);
            } else{
                tx.destination = @"";
            }

            tx.amountString = [self formatAmount: item->amount()];
            tx.feeString = [self formatAmount: item->fee()];
            tx.paymentId = toUTF8(item->paymentId());
            tx.timestamp = item->timestamp();
            tx.direction = item->direction();
            tx.confirmations = item->confirmations();

            [arr addObject: tx];
        }
    }

    return [arr copy];
}

- (void)store {
    if(_wallet != nullptr) {
        _wallet->store([@"" cStringUsingEncoding:NSUTF8StringEncoding]);
    } else {
        // TODO: check this place
        NSLog(@"_wallet is nullptr in store()");
    }
}

- (TransactionWrapper *)createTransaction:(NSString *)toAddress paymentId:(NSString *)paymentId amount:(u_int64_t)amount {
    ::PendingTransaction *transaction = [self createPendingTransaction: toAddress paymentId: paymentId amount: amount];
    if(transaction != nil) {
        TransactionWrapper *wrapper = [[TransactionWrapper alloc] init: transaction];
        return wrapper;
    }

    return nil;
}

- (NSString *)createTransactionProposal:(NSString *)toAddress paymentId:(NSString *)paymentId amount:(u_int64_t)amount {
    ::PendingTransaction *transaction = [self createPendingTransaction: toAddress paymentId: paymentId amount: amount];
    if(transaction != nil) {
        return toUTF8(transaction->multisigSignData());
    }

    return nil;
}

- (bool)createTransactionProposal:(NSString *)toAddress paymentId:(NSString *)paymentId amount:(u_int64_t)amount result:(NSString **)result {
    ::PendingTransaction *transaction = [self createPendingTransaction: toAddress paymentId: paymentId amount: amount];
    if(transaction != nil) {
        if(::PendingTransaction::Status::Status_Ok == transaction->status()) {
            if(transaction->txCount() == 0) {
                *result = toUTF8("Transaction is empty. Maybe wallet isn't in sync state");
                return false;
            }

            *result = toUTF8(transaction->multisigSignData());
            return true;
        } else {
            *result = toUTF8(transaction->errorString());
            return false;
        }
    }

    *result = toUTF8("Transaction is nil. Maybe wallet isn't in sync state");
    return false;
}

- (nullable NSString *)signedTransactionProposal:(nonnull NSString *)transactionData {
    ::PendingTransaction *transaction = [self restoreMultisigTransaction: transactionData];
    transaction->signMultisigTx();
#if TEST // TODO: move to tests
    NSString *test = toUTF8(transaction->multisigSignData());
    ::PendingTransaction *testTransaction = [self restoreMultisigTransaction: test];
#endif
    return toUTF8(transaction->multisigSignData());
}

- (bool)signMultisigTransaction:(NSString *)transactionData wrapper:(TransactionWrapper **)wrapper error:(NSString **)errorString {
    ::PendingTransaction *transaction = [self restoreMultisigTransaction: transactionData];
    transaction->signMultisigTx();

    if(transaction != nil) {
        if(::PendingTransaction::Status::Status_Ok == transaction->status()) {
            *wrapper = [[TransactionWrapper alloc] init: transaction];
            return true;
        } else {
            *errorString = toUTF8(transaction->errorString());
            return false;
        }
    }

    *errorString = toUTF8("Transaction is nil");
    return false;
}

- (TransactionWrapper *)createTransactionProposal:(NSString *)transactionData {
    ::PendingTransaction *transaction = [self restoreMultisigTransaction: transactionData];
    if(transaction != nil) {
        TransactionWrapper *wrapper = [[TransactionWrapper alloc] init: transaction];
        return wrapper;
    }

    return nil;
}

- (::PendingTransaction *)createPendingTransaction:(NSString *)toAddress paymentId:(NSString *)paymentId amount:(u_int64_t)amount {
    if(_wallet != nullptr) {
        const char *toAddressCStr = [toAddress cStringUsingEncoding:NSUTF8StringEncoding];
        const char *paymentIdCStr = [paymentId cStringUsingEncoding:NSUTF8StringEncoding];

        // TODO: change params
        ::PendingTransaction *transaction = _wallet->createTransaction(toAddressCStr, paymentIdCStr, amount, 11,
                PendingTransaction::Priority_Default);
        return transaction;
    }

    return nil;
}

- (::PendingTransaction *)restoreMultisigTransaction:(NSString *)transactionData {
    if(_wallet != nullptr) {
        std::string transactionDataString = [transactionData cStringUsingEncoding:NSUTF8StringEncoding];
        ::PendingTransaction *transaction = _wallet->restoreMultisigTransaction(transactionDataString);

        return transaction;
    }

    return nil;
}

- (uint64_t)walletBlockHeight {
    if(_wallet != nullptr) {
        return _wallet->getRefreshFromBlockHeight();
    } else {
        // TODO: check this place
        NSLog(@"_wallet is nullptr in walletBlockHeight()");
        return 0;
    }
}

- (uint64_t)networkBlockHeight {
    if(_wallet != nullptr) {
        return _wallet->daemonBlockChainHeight();
    } else {
        // TODO: check this place
        NSLog(@"_wallet is nullptr in networkBlockHeight()");
        return 0;
    }
}

- (NSString *)generatePaymentId {
    std::string emptyString;
    if(_wallet != nullptr) {
        return toUTF8(_wallet->integratedAddress(emptyString));
    }

    return @"";
}

- (bool)isAddressValid:(NSString *)value {
    if(_wallet != nullptr) {
        std::string addressValue = [value cStringUsingEncoding:NSUTF8StringEncoding];
        return _wallet->addressValid(addressValue, _wallet->nettype());
    }

    return false;
}

- (::Wallet *)walletInnerObject {
    if(_wallet != nullptr) {
        return _wallet.release();
    }
    return nil;
}

@end

@implementation MoneroWrapper {
    ::NetworkType _network;
}

- (nonnull instancetype)init {
    self = [super init];
    return self;
}

- (nonnull instancetype)init:(bool)mainNet {
    self = [super init];
    if(mainNet) {
        _network = ::NetworkType::MAINNET;
    } else {
        _network = ::NetworkType::STAGENET;
    }

    return self;
}

- (bool)testTrue {
    return ::Utils::isAddressLocal([@"localhost" cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (bool)testFalse {
    return ::Utils::isAddressLocal([@"abcd" cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (MoneroWalletWrapper *)createWallet:(NSString *)walletPath password:(NSString *)password {
    const std::string path = [walletPath cStringUsingEncoding:NSUTF8StringEncoding];
    const std::string pass = [password cStringUsingEncoding:NSUTF8StringEncoding];
    const std::string lang = [@"English" cStringUsingEncoding:NSUTF8StringEncoding];

    ::WalletManagerFactory *factory = new ::WalletManagerFactory();
    factory->setLogLevel(::WalletManagerFactory::LogLevel::LogLevel_Max);
    MoneroWalletWrapper *wallet = [[MoneroWalletWrapper alloc] init: factory];
    bool result = [wallet create: path pass: pass language: lang networkType: _network];
    if(result) {
        return wallet;
    }

    return nil;
}

//- (MoneroWalletWrapper *)openWallet:(NSString *)walletPath password:(NSString *)password {
- (nullable MoneroWalletWrapper *)openWallet:(nonnull NSString *)walletPath password:(nonnull NSString *)password error:(NSString **)error {
    const std::string path = [walletPath cStringUsingEncoding:NSUTF8StringEncoding];
    const std::string pass = [password cStringUsingEncoding:NSUTF8StringEncoding];

    ::WalletManagerFactory *factory = new ::WalletManagerFactory();
    factory->setLogLevel(::WalletManagerFactory::LogLevel::LogLevel_Max);
    MoneroWalletWrapper *wallet = [[MoneroWalletWrapper alloc] init: factory];
    bool result = [wallet open:path pass:pass networkType:_network error: error];
    if(result) {
        return wallet;
    }

    return nil;
}

- (bool)closeWallet:(MoneroWalletWrapper *)walletWrapper {
    ::WalletManagerFactory *factory = new ::WalletManagerFactory();
    factory->setLogLevel(::WalletManagerFactory::LogLevel::LogLevel_Max);
    Wallet* wp = [walletWrapper walletInnerObject];

    bool result = factory->getWalletManager()->closeWallet(wp);
    [walletWrapper clear];
    
    delete factory;
    return result;
}

- (MoneroWalletWrapper *)restoreWallet:(NSString *)walletPath mnemonic:(NSString *)mnemonicPhrase password:(NSString *)password blockHeight:(uint64_t)blockHeight {
    const std::string path = [walletPath cStringUsingEncoding:NSUTF8StringEncoding];
    const std::string mnemonic = [mnemonicPhrase cStringUsingEncoding:NSUTF8StringEncoding];
    const std::string pass = [password cStringUsingEncoding:NSUTF8StringEncoding];
    uint64_t restoreHeight = blockHeight;

    ::WalletManagerFactory *factory = new ::WalletManagerFactory();
    factory->setLogLevel(::WalletManagerFactory::LogLevel::LogLevel_Max);

    MoneroWalletWrapper *wallet = [[MoneroWalletWrapper alloc] init: factory];
    [wallet restore: path pass: pass mnemonic: mnemonic networkType: _network blockHeight: restoreHeight];

    return wallet;
}

// TODO: Using this method after repair, returns "" now
- (NSString *)signMessage:(NSString *)message key:(NSString *)secretKey {
    std::string msg = [message cStringUsingEncoding:NSUTF8StringEncoding];
    std::string key = [secretKey cStringUsingEncoding:NSUTF8StringEncoding];

    return toUTF8(signMessage(msg, key));
}

- (nonnull NSString *)commonKey:(nonnull NSString *)publicKey secretKey:(nonnull NSString *)secretKey {
    std::string B = [publicKey cStringUsingEncoding:NSUTF8StringEncoding];
    std::string b = [secretKey cStringUsingEncoding:NSUTF8StringEncoding];

    return toUTF8(multiplyKeys(b, B));
}

- (nonnull NSString *)ephemeralKey:(nonnull NSString *)commonKey seed:(UInt32)seed {
    std::string ck = [commonKey cStringUsingEncoding:NSUTF8StringEncoding];

    return toUTF8(ephemeralKey(ck, seed));
}

- (nonnull NSString *)encryptMessage:(nonnull NSString *)message key:(nonnull NSString *)key {
    std::string msg = [message cStringUsingEncoding:NSUTF8StringEncoding];
    std::string k = [key cStringUsingEncoding:NSUTF8StringEncoding];

    std::string encrypted = chachaEncrypt(msg, k);
    NSData *data = [[NSData alloc] initWithBytes:encrypted.data() length:encrypted.length()];
    return [data base64EncodedStringWithOptions: 0];
}

- (nonnull NSString *)decryptMessage:(nonnull NSString *)cipherText key:(nonnull NSString *)key {
    NSData *data = [[NSData alloc] initWithBase64EncodedString: cipherText options: 0];
    std::string encrypted(reinterpret_cast<const char *>(data.bytes), data.length);
    std::string k = [key cStringUsingEncoding:NSUTF8StringEncoding];

    std::string source = chachaDecrypt(encrypted, k);

    return toUTF8(source);
}


@end
