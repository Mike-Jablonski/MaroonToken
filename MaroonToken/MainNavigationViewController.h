//
//  MainNavigationViewController.h
//  MaroonToken
//
//  Created by Mike Jablonski on 9/4/14.
//  Copyright (c) 2014 Mike Jablonski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "Player.h"

@interface MainNavigationViewController : UINavigationController <GameDelegate>

@property (nonatomic, strong) Player* player;

@end
