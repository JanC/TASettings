//
// Created by Jan on 20/08/15.
//

#import <Foundation/Foundation.h>


@interface TASwitchCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *valueSwitch;

@property (nonatomic, strong) UI_APPEARANCE_SELECTOR UIFont *titleLabelFont;

@end