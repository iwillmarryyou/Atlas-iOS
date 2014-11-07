//
//  LYRUIParticipantPickerController.m
//  
//
//  Created by Kevin Coleman on 8/29/14.
//
//

#import "LYRUIParticipantPickerController.h"

@interface LYRUIParticipantPickerController () <LYRUIParticipantTableViewControllerDelegate>

@property (nonatomic) NSSet *participants;
@property (nonatomic) NSDictionary *sortedParticipants;
@property (nonatomic) LYRUIParticipantTableViewController *participantTableViewController;
@property (nonatomic) BOOL isOnScreen;

@end

@implementation LYRUIParticipantPickerController

@synthesize allowsMultipleSelection = _allowsMultipleSelection;

+ (instancetype)participantPickerWithDataSource:(id<LYRUIParticipantPickerDataSource>)dataSource sortType:(LYRUIParticipantPickerSortType)sortType
{
    NSAssert(dataSource, @"Data Source cannot be nil");
    return [[self alloc] initWithDataSource:dataSource sortType:sortType];
}

- (id)initWithDataSource:(id<LYRUIParticipantPickerDataSource>)dataSource sortType:(LYRUIParticipantPickerSortType)sortType
{
    LYRUIParticipantTableViewController *controller = [[LYRUIParticipantTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self = [super initWithRootViewController:controller];
    if (self) {
        controller.delegate = self;
        controller.sortType = sortType;
        controller.participants = [dataSource participants];
        
        _sortType = sortType;
        _participantTableViewController = controller;
        _dataSource = dataSource;
    }
    return self;
}

- (id)init
{
    [NSException raise:@"Invalid" format:@"Failed to call designated initializer"];
    return nil;
}

#pragma mark - VC Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Configure default picker configuration
    self.allowsMultipleSelection = YES;
    self.cellClass = [LYRUIParticipantTableViewCell class];
    self.rowHeight = 40;
    self.title = @"Participants";
    self.accessibilityLabel = @"Participants";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Configure ParticipantTableViewController Appearance
    self.participantTableViewController.allowsMultipleSelection = self.allowsMultipleSelection;
    self.participantTableViewController.participantCellClass = self.cellClass;
    self.participantTableViewController.rowHeight = self.rowHeight;
    self.participantTableViewController.sortType = self.sortType;
    self.isOnScreen = TRUE;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isOnScreen = FALSE;
}

#pragma mark Public Picker Configuration Options

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change multiple selection mode after view has been loaded" userInfo:nil];
    }
    _allowsMultipleSelection = allowsMultipleSelection;
}

- (void)setCellClass:(Class<LYRUIParticipantPresenting>)cellClass
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change cell class after view has been loaded" userInfo:nil];
    }
    _cellClass = cellClass;
}

- (void)setRowHeight:(CGFloat)rowHeight
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change row height after view has been loaded" userInfo:nil];
    }
    _rowHeight = rowHeight;
}

- (void)setParticipantPickerSortType:(LYRUIParticipantPickerSortType)participantPickerSortType
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change sort type after view has been loaded" userInfo:nil];
    }
    _sortType = participantPickerSortType;
}

#pragma mark - Participant Table View Controller Delegate Methods

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<LYRUIParticipant>)participant
{
    [self.participantPickerDelegate participantSelectionViewController:self didSelectParticipant:participant];
}

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    [self.dataSource searchForParticipantsMatchingText:searchText completion:^(NSSet *participants) {
        completion (participants);
    }];
}

- (void)participantTableViewControllerDidSelectCancelButton
{
    [self.participantPickerDelegate participantSelectionViewControllerDidCancel:self];
}

@end
