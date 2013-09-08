//
//  PAFilesViewController.m
//  put.io adder
//
//  Created by Thomas Kollbach on 08.09.13.
//  Copyright (c) 2013 343max. All rights reserved.
//

#import "PAPutIOController.h"
#import "PAFilesViewController.h"

@interface PAFilesViewController ()

@property (nonatomic) NSArray *files;

@end

@implementation PAFilesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(reloadFiles)
                  forControlEvents:UIControlEventValueChanged];
}


#pragma mark Actions

- (IBAction)reloadFiles;
{
    [[PAPutIOController sharedController] reloadFilesAndFolders:^(NSError *error) {
        self.files = [[PAPutIOController sharedController] files];
#warning Error handling
        NSLog(@"eror %@", error);
    }];
}


@end
