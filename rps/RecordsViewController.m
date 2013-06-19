//
//  RecordsViewController.m
//  rps
//
//  Created by Ron Buencamino on 6/19/13.
//  Copyright (c) 2013 Animatronic Gopher Inc. All rights reserved.
//

#import "RecordsViewController.h"
#import "FMDatabase.h"

#define kDBName @"rps.sqlite"

@interface RecordsViewController ()
{
    IBOutlet UILabel *winLabel;
    IBOutlet UILabel *lossLabel;
}

@property (nonatomic, weak) IBOutlet UITableView *dataTableView;
@property (nonatomic, assign) int winCount;
@property (nonatomic, assign) int lossCount;

- (IBAction)closeRecordsWindow:(id)sender;

@end

@implementation RecordsViewController
@synthesize dataTableView = _dataTableView;
@synthesize winCount, lossCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self getDatabaseResults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeRecordsWindow:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:Nil];
}


- (NSString *)getDocumentsPath
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    
    return documentDir;
}

- (void)getDatabaseResults
{
    NSLog(@"Fetching database results..");
    NSString *docmentsDir = [self getDocumentsPath];
    NSString *databasePath = [docmentsDir stringByAppendingPathComponent:kDBName];
    
    FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
    if (db) {
        
        [db open];
        
        FMResultSet *results = [db executeQuery:@"SELECT * FROM record"];
        NSLog(@"results: %@", results);
        
        while ([results next]) {
            winCount = [results intForColumn:@"win"];
            lossCount = [results intForColumn:@"loss"];
            
            NSLog(@"Current Record:\nWins: %i\nLosses:%i", (unsigned)winCount, (unsigned)lossCount);
            
            winLabel.text = [NSString stringWithFormat:@"%i", winCount];
            lossLabel.text = [NSString stringWithFormat:@"%i", lossCount];
            
            
        }
        
        [db close];
    }
    
    
}

@end
