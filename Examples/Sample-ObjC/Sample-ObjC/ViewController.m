//
//  ViewController.m
//  Sample-ObjC
//
//  Created by Marc Bauer on 19.02.20.
//  Copyright © 2020 Crisp IM SAS. All rights reserved.
//

#import "ViewController.h"
#import <Crisp/Crisp.h>

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (IBAction)presentChat:(id)sender {
  [self presentViewController:[[CRSPChatViewController alloc] init] animated:YES completion:nil];
}
@end
