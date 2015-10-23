//
//  RootViewController.m
//  PlaidLink
//
//  Created by Andres Ugarte on 10/22/15.
//  Copyright © 2015 Simon Levy. All rights reserved.
//

#import "RootViewController.h"

#import "Plaid.h"
#import "PLDLinkNavigationViewController.h"

@interface RootViewController ()<PLDLinkNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation RootViewController

- (IBAction)didTapConnect:(id)sender {
  PLDLinkNavigationViewController *plaidLink =
      [[PLDLinkNavigationViewController alloc] initWithEnvironment:PlaidEnvironmentTartan
                                                           product:PlaidProductConnect
                                                         publicKey:nil];

  plaidLink.linkDelegate = self;
  plaidLink.providesPresentationContextTransitionStyle = true;
  plaidLink.definesPresentationContext = true;
  plaidLink.modalPresentationStyle = UIModalPresentationCustom;

  [self presentViewController:plaidLink animated:YES completion:nil];
}

#pragma mark - PLDLinkNavigationControllerDelegate

- (void)linkNavigationContoller:(PLDLinkNavigationViewController *)navigationController
       didFinishWithAccessToken:(NSString *)accessToken {
  _titleLabel.text = @"Success!";
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)linkNavigationControllerCancelled:(PLDLinkNavigationViewController *)navigationController {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
