//
//  ProjectInfoVC.m
//  sema2
//
//  Created by Ashemah Harrison on 15/04/2015.
//  Copyright (c) 2015 Starehe Harrison. All rights reserved.
//

#import "ProgramInfoVC.h"
#import "DemoSurveyVC.h"
#import "InfoCell.h"
#import "UIAlertView+Blocks.h"

@interface ProgramInfoVC ()

@end

@implementation ProgramInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.program = [Program objectForPrimaryKey:[NSNumber numberWithInteger:self.programId]];
    
    BHBlockTableWeakSelf weakSelf = self;
    
    self.blockTable = [[BHBlockTable alloc] initWithTableView:self.tableView];
    
    self.blocks = [self.blockTable staticSectionWithCellIdentifiers:@[@"InfoCell"] headerViewClass:nil andVisibility:YES];
    
    self.blocks.configureCellForRow =^(BHBlockTableInfo *info) {
        
        InfoCell *cell = info.cell;
        cell.displayName.text = weakSelf.program.displayName;
        cell.desc.text = weakSelf.program.desc;
        cell.contactName.text = [NSString stringWithFormat:@"Name: %@", weakSelf.program.contactName];
        cell.contactPhone.text = [NSString stringWithFormat:@"Phone: %@", weakSelf.program.contactNumber];
        cell.contactEmail.text = [NSString stringWithFormat:@"Email: %@", weakSelf.program.contactEmail];
        
        if (!info.isCalculatingHeight) {
            [cell.demoButton addTarget:weakSelf action:@selector(demoTapped) forControlEvents:UIControlEventTouchUpInside];
            [cell.callButton addTarget:weakSelf action:@selector(callTapped) forControlEvents:UIControlEventTouchUpInside];
            [cell.emailButton addTarget:weakSelf action:@selector(emailTapped) forControlEvents:UIControlEventTouchUpInside];
        }
    };
    
    [self.blockTable refresh];
}

- (void)demoTapped {
    
    if ([self.program.surveys count] == 0) {
        
        [UIAlertView showWithTitle:@"Cannot start demo" message:@"You do not have any surveys assigned for this program. Please contact your program manager for more information." cancelButtonTitle:@"Close" otherButtonTitles:nil tapBlock:nil];
    }
    else {
        
        [self performSegueWithIdentifier:@"StartDemoSurvey" sender:self];
    }
}

- (void)callTapped {
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:self.program.contactNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)emailTapped {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:[NSString stringWithFormat:@"SEMA - %@", self.program.displayName]];
        
        [mailer setToRecipients:@[self.program.contactEmail]];
        
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
            [self presentViewController:mailer animated:YES completion:nil];
        } else {
            [self presentModalViewController:mailer animated:YES];
//            [mailer release];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)unwindToInfo:(UIStoryboardSegue*)segue {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"StartDemoSurvey"]) {
        if ([self.program.surveys count] > 0) {
            DemoSurveyVC *demoSurveyVC = (DemoSurveyVC*)[[segue destinationViewController] topViewController];
            demoSurveyVC.survey = [self.program.surveys objectAtIndex:0];
        }
    }
}

@end
