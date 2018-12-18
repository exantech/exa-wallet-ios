//
// Created by Igor Efremov on 28/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InnerMoneroTransaction: NSObject
@property (nonatomic) NSString *txHash;
@property (nonatomic) NSString *destination;
@property (nonatomic) NSString *amountString;
@property (nonatomic) NSString *feeString;
@property (nonatomic) NSString *paymentId;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) NSInteger direction;
@property (nonatomic, assign) UInt64 confirmations;

@end
