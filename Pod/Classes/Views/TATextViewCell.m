//
// Created by Jan on 14/09/15.
//

#import "TATextViewCell.h"


@implementation TATextViewCell {

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.valueTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        self.valueTextView.scrollEnabled = YES;


        [self.contentView addSubview:self.valueTextView];
        [self.titleLabel removeFromSuperview];

        [self setupAutoLayout];
    }

    return self;
}

#pragma mark - Private

-(void) setupAutoLayout
{
    self.valueTextView.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *metrics = @{};
    NSDictionary *views = @{
            @"valueTextView" : self.valueTextView
    };

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[valueTextView]-|"
                                                                             options:(NSLayoutFormatOptions) 0
                                                                             metrics:metrics
                                                                               views:views]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[valueTextView(>=70)]-|"
                                                                             options:(NSLayoutFormatOptions) 0
                                                                             metrics:metrics
                                                                               views:views]];

}

#pragma mark - UIAppearanceContainer


- (void)setValueTextFieldFont:(UIFont *)valueTextFieldFont
{
    _valueTextFieldFont = valueTextFieldFont;
    self.valueTextView.font = valueTextFieldFont;
}

@end