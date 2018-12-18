//
// Created by Igor Efremov on 16/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

#import "NSData+Hex.h"

@implementation NSData (Hex)

- (NSString*)hexString {
    return [self hexStringImpl];
}
- (NSString*)hexStringImpl {
    const char *hex = "0123456789abcdef";
    char *hexString = malloc(self.length*2);
    const uint8_t *bytes = self.bytes;
    for (size_t i = 0; i < self.length; i++) {
        hexString[2*i] = hex[(bytes[i] & 0xF0) >> 4];
        hexString[2*i+1] = hex[bytes[i] & 0x0F];
    }
    return [[NSString alloc] initWithBytesNoCopy:hexString length:self.length*2 encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

@end
