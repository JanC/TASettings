//
//  TAViewController.m
//  TASetting
//
//  Created by Jan Chaloupecky on 08/20/2015.
//  Copyright (c) 2015 Jan Chaloupecky. All rights reserved.
//

#import "TAViewController.h"
#import "TADateTransformer.h"

#import <TASettings/TASettings.h>

@interface TAViewController () <TASettingViewControllerDelegate>

@property(nonatomic, strong) TASettingViewController *settingViewController;
@end

@implementation TAViewController


#pragma mark - Actions

- (IBAction)showSettings:(id)sender
{

    self.settingViewController = [[TASettingViewController alloc] initWithSettings:[self settings]];

    self.settingViewController.delegate = self;
    self.settingViewController.showDoneButton = YES;
    self.settingViewController.showCancelButton = YES;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.settingViewController];


    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Helper

- (TASetting *)settings
{
    TASetting *settings = [[TASetting alloc] initWithSettingType:TASettingTypeChild title:@"Account Setting"];


    NSArray *sslValues = @[
            [TASettingValue valueWithTitle:@"Auto" value:@1 selected:NO],
            [TASettingValue valueWithTitle:@"Clear" value:@2 selected:NO],
            [TASettingValue valueWithTitle:@"START TLS" value:@3 selected:YES],
            [TASettingValue valueWithTitle:@"SSL" value:@4 selected:NO]];


    TASetting *generalSection = [TASetting settingWithSettingType:TASettingTypeGroup localizedTitle:@"General"];

    TASetting *settingGeneralAccountName = [[TATextFieldSetting alloc] initWithTitle:@"Account Name" placeholderValue:@"Gmail" secure:NO keyboardType:UIKeyboardTypeAlphabet];
    settingGeneralAccountName.settingValue.value = @"Steve Jobs";
    generalSection.children = @[
            settingGeneralAccountName,
            [[TATextFieldSetting alloc] initWithTitle:@"Sender Name" placeholderValue:@"John Doe" secure:NO keyboardType:UIKeyboardTypeAlphabet],
            [TASetting switchSettingWithTitle:@"Copy to sent messages" settingValue:[TASettingValue valueWithValue:nil defaultValue:@YES]],
    ];

    TASetting *oauthSection = [TASetting settingWithSettingType:TASettingTypeGroup localizedTitle:@"OAuth"];
    oauthSection.footerText = @"";
    oauthSection.children = @[
            [[TAActionSetting alloc] initWithTitle:@"Disconnect" actionBlock:self.oauthActionBlock]
    ];


    TASetting *portSetting = [[TATextFieldSetting alloc] initWithTitle:@"Port" placeholderValue:@"993" secure:NO keyboardType:UIKeyboardTypeNamePhonePad];
    portSetting.validator = [[TANumberValidator alloc] init];

    TASetting *incomingSection = [TASetting settingWithSettingType:TASettingTypeGroup localizedTitle:@"Incoming"];

    TASetting *passwordSetting = [[TATextFieldSetting alloc] initWithTitle:@"Password" placeholderValue:nil secure:YES keyboardType:UIKeyboardTypeAlphabet];
    TASetting *dateSetting = [[TATextFieldSetting alloc] initWithTitle:@"Date" placeholderValue:nil secure:NO keyboardType:UIKeyboardTypeAlphabet];


    dateSetting.settingValue.value = [NSDate date];

    [NSValueTransformer setValueTransformer:[[TADateTransformer alloc] init] forName:@"TADateTransformer"];
    dateSetting.settingValue.valueTransformerName = @"TADateTransformer";


    passwordSetting.enabled = NO;
    incomingSection.children = @[
            [TATextFieldSetting settingWithSettingType:TASettingTypeTextField localizedTitle:@"User Name"],
            passwordSetting,
            [[TATextFieldSetting alloc] initWithTitle:@"Host" placeholderValue:@"imap.google.com" secure:NO keyboardType:UIKeyboardTypeAlphabet],
            portSetting,
            dateSetting,
            [TAMultiValueSetting settingWithTitle:@"SSL" values:sslValues],
    ];

    TASetting *outgoingSection = [TASetting settingWithSettingType:TASettingTypeGroup localizedTitle:@"Outgoing"];
    outgoingSection.children = @[
            [TATextFieldSetting settingWithSettingType:TASettingTypeTextField localizedTitle:@"User Name"],
            [[TATextFieldSetting alloc] initWithTitle:@"Password" placeholderValue:nil secure:YES keyboardType:UIKeyboardTypeAlphabet],
            [[TATextFieldSetting alloc] initWithTitle:@"Host" placeholderValue:@"smtp.google.com" secure:NO keyboardType:UIKeyboardTypeAlphabet],
            [[TATextFieldSetting alloc] initWithTitle:@"Port" placeholderValue:@"587" secure:NO keyboardType:UIKeyboardTypeNamePhonePad],
            [TAMultiValueSetting settingWithTitle:@"SSL" values:sslValues],
    ];


    TASetting *deleteSection = [TASetting settingWithSettingType:TASettingTypeGroup];
    deleteSection.footerText = @"";
    deleteSection.children = @[
            [[TAActionSetting alloc] initWithTitle:@"Delete Account" actionBlock:self.deleteActionBlock]
    ];

    TASetting *childSection = [TASetting settingWithSettingType:TASettingTypeGroup];
    childSection.children = @[ settings ];


    settings.children = @[ generalSection, oauthSection, incomingSection, outgoingSection, deleteSection ];

    return settings;
}

- (TAActionSettingBlock)oauthActionBlock
{
    return ^(TASettingViewController *controller, TASetting *setting) {
        setting.title = [setting.title isEqualToString:@"Connect"] ? @"Disconnect" : @"Connect";
    };

}

- (TAActionSettingBlock)deleteActionBlock
{
    return ^(TASettingViewController *controller, TASetting *setting) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete Account" message:@"Are you sure you want to continue? All account information will be deleted." preferredStyle:UIAlertControllerStyleActionSheet];

        [alertController addAction:[UIAlertAction actionWithTitle:@"Delete Account" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSLog(@"action %@", action.title);
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"action %@", action.title);
        }]];

        [controller presentViewController:alertController animated:YES completion:nil];
    };

}

#pragma mark - TASettingViewControllerDelegate

- (void)settingViewController:(TASettingViewController *)controller didChangeSetting:(TASetting *)setting
{
    NSLog(@"Setting value changed: %@", setting);
}

- (void)settingViewController:(TASettingViewController *)controller didRequestSaveSettings:(TASetting *)setting
{
    NSLog(@"%s", sel_getName(_cmd));
    self.settingViewController = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingViewController:(TASettingViewController *)controller willDismissSettings:(TASetting *)setting
{
    self.settingViewController = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingViewController:(TASettingViewController *)controller didSelectValue:(TASettingValue *)settingValue inSettings:(TAMultiValueSetting *)setting
{
    NSLog(@"%s %@", sel_getName(_cmd), settingValue.title);
    // deselect the previously selected
    [setting.values enumerateObjectsUsingBlock:^(TASettingValue *currentSettingValue, NSUInteger idx, BOOL *stop) {
        if (currentSettingValue != settingValue && currentSettingValue.selected) {
            currentSettingValue.selected = NO;
        }
    }];

    [controller.navigationController popViewControllerAnimated:YES];
}


@end
