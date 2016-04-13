//
//  NIMUpdateMyUserInfoValidator.m
//  NIMLib
//
//  Created by chris on 15/11/4.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NIMUpdateMyUserInfoValidator.h"
#import "NIMUserManagerProtocol.h"
#import "NIMUser.h"

@implementation NIMUpdateMyUserInfoValidator

- (BOOL)isValid
{
    NSDictionary *values = [self.object nim_asObject:[NSDictionary class]];

    BOOL valid = values != nil;
    if (valid) {
        for (NSNumber *key in values) {
            if (![key isKindOfClass:[NSNumber class]]) {
                valid = NO;
                break;
            }
            id value = values[key];
            switch ([key integerValue]) {
                case NIMUserInfoUpdateTagGender:{
                    valid = [self isValidUpdateGender:value];
                    break;
                }
                case NIMUserInfoUpdateTagEmail:{
                    valid = [self isValidUpdateEmail:value];
                    break;
                }
                case NIMUserInfoUpdateTagBirth:{
                    valid = [self isValidUpdateBirth:value];
                    break;
                }
                case NIMUserInfoUpdateTagMobile:{
                    valid = [self isValidUpdateMobile:value];
                    break;
                }
                default:
                    valid = [value isKindOfClass:[NSString class]];
                    break;
            }
            if (!valid) {
                break;
            }
        }
    }
    return valid;
}



- (BOOL)isValidUpdateGender:(id)value{
    return [value isKindOfClass:[NSNumber class]] && ([value integerValue] >= NIMUserGenderUnknown) && ([value integerValue] <= NIMUserGenderFemale);
}

- (BOOL)isValidUpdateEmail:(id)value{
    BOOL valid = NO;
    if ([value isKindOfClass:[NSString class]]) {
        NSString *text = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *regex = @"^\\S+@\\S+$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        valid = [text isEqualToString:@""] || [predicate evaluateWithObject:text];
    }
    return valid;
}

- (BOOL)isValidUpdateMobile:(id)value{
    BOOL valid = NO;
    if ([value isKindOfClass:[NSString class]]) {
        NSString *text = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *regex = @"^[+\\-\\(\\)\\d]+$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        valid = [text isEqualToString:@""] || [predicate evaluateWithObject:text];
    }
    return valid;
}

- (BOOL)isValidUpdateBirth:(id)value{
    BOOL valid = NO;
    if ([value isKindOfClass:[NSString class]]) {
        NSString *text = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *regex = @"^(\\d{4})-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        valid = [text isEqualToString:@""] || [predicate evaluateWithObject:text];
    }
    return valid;
}

@end
