//
// Created by Igor Efremov on 16/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

#pragma once
#ifndef _OBJC_CALLBACK_H_
#define _OBJC_CALLBACK_H_

#import <objc/objc.h>
#import <Foundation/Foundation.h>

template<typename Signature> class objc_callback;

template<typename R, typename... Ts>
class objc_callback<R(Ts...)>
{
public:
    typedef R (*func)(id, SEL, Ts...);

    objc_callback(SEL sel, id obj)
            : sel_(sel)
            , obj_(obj)
            , fun_((func)[obj methodForSelector:sel])
    {
    }

    inline R operator ()(Ts... vs)
    {
        return fun_(obj_, sel_, vs...);
    }
private:
    SEL sel_;
    id obj_;
    func fun_;
};

#endif // _OBJC_CALLBACK_H
