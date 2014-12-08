//
//  DARNationsTableViewController.h
//  DARCountryFinder
//
//  Created by Alessio Roberto on 08/12/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DARNationsTableViewControllerCallback)(NSString *country);

@interface DARNationsTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *nationsList;
@property (nonatomic, strong) DARNationsTableViewControllerCallback countrySelected;

@end
