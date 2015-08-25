//
// Created by Jan on 20/08/15.
//

#import <Foundation/Foundation.h>

@class TASettingValue;
@protocol TASettingValidator;

typedef NS_ENUM(NSUInteger , TASettingType) {
    TASettingTypeGroup,
    TASettingTypeChild,
    TASettingTypeTextField,
    TASettingTypeSwitch,
    TASettingTypeMultiValue,
    TASettingTypeAction,
};

@interface TASetting : NSObject

@property(nonatomic, assign) TASettingType settingType;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic, copy) NSString *footerText;
@property(nonatomic, strong, readonly) TASettingValue *settingValue;
@property(nonatomic, strong) NSArray *settings; // Array of NSSettings

@property (nonatomic, strong) id<TASettingValidator> validator;

- (instancetype)initWithSettingType:(TASettingType)settingType title:(NSString *)title NS_DESIGNATED_INITIALIZER;

#pragma mark - Factory Methods

+ (instancetype)settingWithSettingType:(TASettingType)settingType localizedTitle:(NSString *)localizedTitle;
+ (instancetype)settingWithSettingType:(TASettingType)settingType;

+ (instancetype)switchSettingWithTitle:(NSString *)title settingValue:(TASettingValue *) settingValue;


@end