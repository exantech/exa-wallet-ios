//
// Created by Igor Efremov on 15/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InnerMoneroTransaction;

@interface TransactionWrapper : NSObject
- (bool)commit;
- (nullable NSString *)signedData;
@end

@interface MoneroWalletWrapper : NSObject
- (nullable NSString*)publicAddress;

- (nullable NSString *)publicSpendKey;
- (nullable NSString *)secretSpendKey;

// Multisig methods
- (nullable NSString *)publicMultiSpendKey;
- (nullable NSString *)multisigInfo;
- (bool)isTransformedToMultiSigWallet;
- (bool)isReadyMultiSigWallet;
- (bool)isFinalizeMultiSigNeeded;
- (bool)isWalletFinalized;
- (NSString *)exchangeMultisigKeys:(nonnull NSArray<NSString *> *)extraInfo;
- (bool)finalizeMultisig:(nonnull NSArray<NSString *> *)extraInfo;

- (nonnull NSString *)makeSharedWallet:(nonnull NSArray<NSString *> *)info signers:(NSUInteger)signers;

- (bool)hasMultisigPartialKeyImages;

- (nullable NSString*)exportMultisigPartialKeyImages;
- (bool)importMultisigPartialKeyImages:(nonnull NSArray <NSString *> *)parts;

- (nullable NSString *)signMessage:(nonnull NSString *)message;
- (nullable NSString *)signMultiMessage:(nonnull NSString *)message;
- (bool)verifySignedMessage:(nonnull NSString *)message publicKey:(nonnull NSString *)publicKey signature:(nonnull NSString *)signature;

//
+ (nullable NSString *)signMessage:(nonnull NSString *)message withKey:(nonnull NSString *)key;

- (nullable NSString *)decodeBase58Info:(nonnull NSString *)source;

- (bool)status;
- (nonnull NSString *)errorString;
- (nullable NSString *)seed;
- (bool)isSynchronized;
- (bool)initializeSync:(nonnull NSString *)node;
- (bool)isConnected;
- (bool)sync:(uint64_t)fromBlock;
- (void)cancelSync;
- (uint64_t)currentSyncBlock;
- (bool)hasUnconfirmed;
- (void)pauseSync;
- (void)clear;
- (u_int64_t)amount;
- (u_int64_t)unconfirmedAmount;
- (nullable NSString *)formatAmount:(u_int64_t)amount;
- (u_int64_t)amountFromDouble:(double)amount;
- (nonnull NSArray <InnerMoneroTransaction *> *)transactionsHistory;
- (void)store;

// Transactions
- (nullable TransactionWrapper *)createTransaction:(nonnull NSString *)toAddress paymentId:(nullable NSString *)paymentId amount:(u_int64_t)amount;

// Transaction proposals
- (bool)createTransactionProposal:(nonnull NSString *)toAddress paymentId:(nullable NSString *)paymentId amount:(u_int64_t)amount result:(NSString *_Nullable* _Nullable)result;
- (nullable NSString *)signedTransactionProposal:(nonnull NSString *)transactionData;
- (bool)signMultisigTransaction:(nonnull NSString *)transactionData wrapper:(TransactionWrapper *_Nullable* _Nullable)wrapper error:(NSString *_Nullable* _Nullable)errorString;

- (nullable TransactionWrapper *)createTransactionProposal:(nonnull NSString *)transactionData;

- (void)connectToDaemon:(nonnull NSString *)node;

- (uint64_t)walletBlockHeight;
- (uint64_t)networkBlockHeight;

- (nonnull NSString *)generatePaymentId;

- (bool)isAddressValid:(nonnull NSString *)value;

@end

@interface MoneroWrapper : NSObject

- (nonnull instancetype)init;
- (nonnull instancetype)init:(bool)mainNet;

- (bool)testTrue;
- (bool)testFalse;

- (nullable MoneroWalletWrapper *)createWallet:(nonnull NSString *)walletPath password:(nonnull NSString *)password;
- (nullable MoneroWalletWrapper *)openWallet:(nonnull NSString *)walletPath password:(nonnull NSString *)password error:(NSString **)error;
- (bool)closeWallet:(nullable MoneroWalletWrapper *)walletWrapper;
- (nullable MoneroWalletWrapper *)restoreWallet:(nonnull NSString *)walletPath mnemonic:(nonnull NSString *)mnemonicPhrase password:(nonnull NSString *)password blockHeight:(uint64_t)blockHeight;

- (nullable NSString *)signMessage:(nonnull NSString *)message key:(nonnull NSString *)secretKey;

- (nonnull NSString *)commonKey:(nonnull NSString *)publicKey secretKey:(nonnull NSString *)secretKey;
- (nonnull NSString *)ephemeralKey:(nonnull NSString *)commonKey seed:(UInt32)seed;
- (nonnull NSString *)encryptMessage:(nonnull NSString *)message key:(nonnull NSString *)key;
- (nonnull NSString *)decryptMessage:(nonnull NSString *)message key:(nonnull NSString *)key;

@end

