//
//  TrafficLightViewController.h
//  Crossroads
//
//  Created by Morris Chen on 2017-10-20.
//  Copyright © 2017 Morris Chen. All rights reserved.
//

#ifndef TrafficLightViewController_h
#define TrafficLightViewController_h

#import "ViewController.h"

@interface TrafficLightViewController : ViewController

@property (strong, nonatomic) IBOutlet UIView *trafficLightView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *trafficLightSelector;
@property (strong, nonatomic) IBOutlet UIImageView *trafficLightImageView;

@end


#endif /* TrafficLightViewController_h */
