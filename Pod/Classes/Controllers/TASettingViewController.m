//
// Created by Jan on 20/08/15.
//

#import "TASettingViewController.h"
#import "TATextFieldCell.h"
#import "TASwitchCell.h"
#import "TADetailValueCell.h"
#import "TAMultiValueSetting.h"
#import "TAMultiValueViewController.h"
#import "TAActionCell.h"
#import "TASettingViewController+CellConfiguration.h"
#import "TASettingViewController+Keyboard.h"
#import "TASettingViewController+KVO.h"
#import "TATextViewCell.h"


@interface TASettingViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) NSArray *sections;

@end

@implementation TASettingViewController {

}

#pragma mark - View Life Cycle

- (instancetype)initWithSettings:(TASetting *)settings
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _settings = settings;
        _showCancelButton = YES;
        _showDoneButton = YES;

    }
    return self;
}

-(instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [self initWithSettings:nil];
    return self;
}
-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [self initWithSettings:nil];
    return self;
}


- (void)viewDidLoad
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.tableView.estimatedRowHeight = 70.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self.tableView registerClass:[TATextFieldCell class] forCellReuseIdentifier:[self cellIdentifierForSettingType:TASettingTypeTextField]];
    [self.tableView registerClass:[TATextViewCell class] forCellReuseIdentifier:[self cellIdentifierForSettingType:TASettingTypeTextView]];
    [self.tableView registerClass:[TASwitchCell class] forCellReuseIdentifier:[self cellIdentifierForSettingType:TASettingTypeSwitch]];
    [self.tableView registerClass:[TADetailValueCell class] forCellReuseIdentifier:[self cellIdentifierForSettingType:TASettingTypeMultiValue]];
    [self.tableView registerClass:[TADetailValueCell class] forCellReuseIdentifier:[self cellIdentifierForSettingType:TASettingTypeChild]];
    [self.tableView registerClass:[TAActionCell class] forCellReuseIdentifier:[self cellIdentifierForSettingType:TASettingTypeAction]];

    if(self.backgroundImage)
    {
        UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:self.backgroundImage];
        
        [backgroundImageView setFrame:self.view.frame];
        [backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];

        [self.view addSubview:backgroundImageView];
        
        [self.tableView setBackgroundColor:[UIColor clearColor]];
    }

    [self.view addSubview:self.tableView];

    [self startObservingSettings:self.settings];
    [self startObservingKeyboard];

    self.sections = [self.settings.children filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TASetting *setting, NSDictionary *bindings) {
        return setting.settingType == TASettingTypeGroup;
    }]];

    self.title = self.settings.title;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addDoneButtonIfNecessary];
    [self addCancelButtonIfNecessary];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    TASetting *settings = [self settingsForSection:section];

    return settings.title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections ? self.sections.count : 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self settingsForSection:section].children.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TASetting *setting = [self settingForIndexPath:indexPath];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierForSettingType:setting.settingType] forIndexPath:indexPath];

    switch (setting.settingType) {
        case TASettingTypeChild:
            [self configureChildCell:cell withSetting:setting];
            break;
        case TASettingTypeTextField:
            [self configureTextFieldCell:cell withSetting:setting];
            break;
        case TASettingTypeMultiValue:
            [self configureMultiValueCell:cell withSetting:setting];
            break;
        case TASettingTypeSwitch:
            [self configureSwitchCell:cell withSetting:setting];
            break;
        case TASettingTypeAction:
            [self configureActionCell:cell withSetting:setting];
            break;
        case TASettingTypeGroup:
            break;
        case TASettingTypeTextView:
            [self configureTextViewCell:cell withSetting:setting];
            break;
    }

    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    TASetting *setting = [self settingForIndexPath:indexPath];
    if (setting.settingType == TASettingTypeMultiValue) {
        TAMultiValueViewController *multiValueViewController = [[TAMultiValueViewController alloc] initWithSetting:(TAMultiValueSetting *) setting];
        multiValueViewController.delegate = self.delegate;
        [self.navigationController pushViewController:multiValueViewController animated:YES];
    }

    if (setting.settingType == TASettingTypeChild) {
        // todo the casting is wrong here :(
        TASettingViewController *multiValueViewController = [[TASettingViewController alloc] initWithSettings:setting];
        multiValueViewController.delegate = self.delegate;
        [self.navigationController pushViewController:multiValueViewController animated:YES];
    }
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if(!self.sectionHeaderTint)
        return;
    
    if([view isKindOfClass:[UITableViewHeaderFooterView class]])
    {
        [[(UITableViewHeaderFooterView*)view textLabel] setTextColor:self.sectionHeaderTint];
    }
}

#pragma mark - Public

- (TASetting *)settingForIndexPath:(NSIndexPath *)indexPath
{
    TASetting *settings = [self settingsForSection:indexPath.section];
    TASetting *setting = settings.children[indexPath.row];
    return setting;
}


#pragma mark - Actions

- (void)doneButtonPressed:(id)doneButton
{
    [self.view endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(settingViewController:didRequestSaveSettings:)]) {
        [self.delegate settingViewController:self didRequestSaveSettings:self.settings];
    }
}

-(void )cancelButtonPressed:(id) cancelButton
{
    [self.view endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(settingViewController:willDismissSettings:)]) {
        [self.delegate settingViewController:self willDismissSettings:self.settings];
    }
}

#pragma mark - Helpers

- (TASetting *)settingsForSection:(NSInteger)section
{
    return self.sections ? self.sections[section] : self.settings;
}

- (NSString *)cellIdentifierForSettingType:(TASettingType)settingType
{
    static NSDictionary *mapping;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
        mapping = @{
                @(TASettingTypeTextField) : @"TASettingTypeTextFieldCellId",
                @(TASettingTypeTextView) : @"TASettingTypeTextViewCellId",
                @(TASettingTypeMultiValue) : @"TASettingTypeDetailCellId",
                @(TASettingTypeChild) : @"TASettingTypeDetailCellId",
                @(TASettingTypeSwitch) : @"TASettingTypeSwitchCellId",
                @(TASettingTypeAction) : @"TASettingTypeActionCellId"
        };
    });

    NSString *cellId = mapping[@(settingType)];
    NSAssert(cellId, @"Must provide a mapping for setting type  %@", @(settingType));
    return cellId;
}

- (void)addDoneButtonIfNecessary
{
    if (self.showDoneButton) {
        NSAssert(self.navigationController, @"If you sent the propery showDoneButton, you must embedd in a navigation controller");

        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(doneButtonPressed:)];

        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

- (void)addCancelButtonIfNecessary
{
    if (self.showCancelButton) {
        NSAssert(self.navigationController, @"If you sent the propery showCancelButton, you must embedd in a navigation controller");

        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                    target:self
                                                                                    action:@selector(cancelButtonPressed:)];

        self.navigationItem.leftBarButtonItem = buttonItem;
    }
}


#pragma mark - KVO

- (void)dealloc
{
    [self stopObservingSettings:self.settings];
    [self stopObservingKeyboard];
}

@end