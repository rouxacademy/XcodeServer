//
//  MainViewController.m
//  rps
//
//  Created by Ron Buencamino on 6/19/13.
//  Copyright (c) 2013 Animatronic Gopher Inc. All rights reserved.
//

#import "MainViewController.h"
#import "RecordsViewController.h"
#import "FMDatabase.h"

#define kDBName @"rps.sqlite"


@interface MainViewController ()
{
    IBOutlet UILabel *compResultLabel;
}

@property (nonatomic, assign) int compChoice;
@property (nonatomic, assign) int userChoice;

- (IBAction)showScore;
- (IBAction)rollOne;
- (IBAction)rollTwo;
- (IBAction)rollThree;


@end

@implementation MainViewController
@synthesize compChoice, userChoice;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showScore
{
    RecordsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordsView"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)rollOne
{
    userChoice = 1;
    [self performGameLogic];
}

- (IBAction)rollTwo
{
    userChoice = 2;
    [self performGameLogic];
}

- (IBAction)rollThree
{
    userChoice = 3;
    [self performGameLogic];
}

- (void)performGameLogic
{
    compChoice = (arc4random() %3) + 1;
    NSLog(@"compChoice: %i", (unsigned)compChoice);
    
    switch (userChoice) {
        case 1:
            //User rolls Rock
            switch (compChoice) {
                case 1:
                    //Push
                    NSLog(@"Push round");
                    [self performSelector:@selector(updateLabelPush:) withObject:@"Rock"];
                    break;
                case 2:
                    //Computer rolls Paper
                    NSLog(@"Computer rolls %i - you lose.", (unsigned)compChoice);
                    [self performSelector:@selector(updateLabelLose:) withObject:@"Paper"];
                    break;
                case 3:
                    //Computer rolls Scissors
                    NSLog(@"Computer rolls %i - you win.", (unsigned)compChoice);
                    [self performSelector:@selector(updateLabelWin:) withObject:@"Scissors"];
                    break;
                default:
                    break;
            }
            
            break;
        case 2:
            //User rolls Paper
            switch (compChoice) {
                case 1:
                    //Computer rolls Rock
                    NSLog(@"Computer rolls %i - you win.", (unsigned)compChoice);
                    [self performSelector:@selector(updateLabelWin:) withObject:@"Rock"];
                    break;
                case 2:
                    //Push
                    NSLog(@"Push round");
                    [self performSelector:@selector(updateLabelPush:) withObject:@"Paper"];
                    break;
                case 3:
                    //Computer rolls Scissors
                    NSLog(@"Computer rolls %i - you lose.", (unsigned)compChoice);
                    [self performSelector:@selector(updateLabelLose:) withObject:@"Scissors"];
                    break;
                default:
                    break;
            }
            break;
        case 3:
            //User rolls Scissors
            switch (compChoice) {
                case 1:
                    //Computer rolls Rock
                    NSLog(@"Computer rolls %i - you lose.", (unsigned)compChoice);
                    [self performSelector:@selector(updateLabelLose:) withObject:@"Rock"];
                    break;
                case 2:
                    //Computer rolls Paper
                    NSLog(@"Computer rolls %i - you win.", (unsigned)compChoice);
                    [self performSelector:@selector(updateLabelWin:) withObject:@"Paper"];
                    break;
                case 3:
                    //Push
                    NSLog(@"Push round");
                    [self performSelector:@selector(updateLabelPush:) withObject:@"Scissors"];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
}

- (void)updateLabelWin:(NSString *)compResult
{
    compResultLabel.text = [NSString stringWithFormat:@"The computer rolled %@\nYou Win!", compResult];
    BOOL result = YES;
    [self updateScoreCount:result];
}

- (void)updateLabelLose:(NSString *)compResult
{
    compResultLabel.text = [NSString stringWithFormat:@"The computer rolled %@\nYou Lose!", compResult];
    BOOL result = NO;
    [self updateScoreCount:result];
}

- (void)updateLabelPush:(NSString *)compResult
{
    compResultLabel.text = [NSString stringWithFormat:@"You and the computer both rolled %@\nIt's a push!  Try again!", compResult];
}

- (NSString *)getDocumentsPath
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    
    return documentDir;
}

- (void)updateScoreCount:(BOOL)matchResult
{
    NSString *documentsPath = [self getDocumentsPath];
    NSString *databasePath = [documentsPath stringByAppendingPathComponent:kDBName];
    
    int wins;
    int losses;
    
    FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
    
    if (db) {
        [db open];
        
        FMResultSet *results = [db executeQuery:@"SELECT * FROM record"];
        
        while ([results next]) {
            wins = [results intForColumn:@"win"];
            losses = [results intForColumn:@"loss"];
        }
        
        BOOL result = matchResult;
        
        if (result) {
            int winInc = wins + 1;
            NSString *winIncString = [NSString stringWithFormat:@"%i", winInc];
            BOOL success = [db executeUpdate:@"UPDATE record SET win = (?) where id = '1'", winIncString];
            
            if (success) {
                NSLog(@"Score Database updated: %i %@", [db lastErrorCode], [db lastErrorMessage]);
            } else {
                NSLog(@"Database update failed.  Reason: %i %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            
        } else {
            int lossInc = losses +1;
            NSString *lossIncString = [NSString stringWithFormat:@"%i", lossInc];
            BOOL success = [db executeUpdate:@"UPDATE record SET loss = (?) where id = '1'", lossIncString];
            
            if (success) {
                NSLog(@"Score Database updated: %i %@", [db lastErrorCode], [db lastErrorMessage]);
            } else {
                NSLog(@"Database update failed.  Reason: %i %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Error loading database" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alertView show];
    }
    
    [db close];
}

- (void)updateLossCount
{
    
}


@end
