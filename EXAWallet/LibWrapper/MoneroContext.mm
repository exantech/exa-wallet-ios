//
// Created by Igor Efremov on 25/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

#import "MoneroContext.h"
#import "wallet2_api.h"

using namespace Monero;

@implementation MoneroContext {
    ::WalletListener *_listener;
}

- (instancetype)init {
    self = [super init];
    /*if (self) {
        _listener = new WalletListenerImpl();
    }*/

    return self;
}

@end
