//
//  TrafficLightViewController.m
//  Crossroads
//
//  Created by Morris Chen on 2017-10-20.
//  Copyright © 2017 Morris Chen. All rights reserved.
//

#import "TrafficLightViewController.h"

#import "NetworkManager.h"

#import <UIView+Toast.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import <Spark-SDK.h>

@interface TrafficLightViewController ()
{
    AVAudioPlayer *_audioPlayer;
}

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) __block SparkDevice *myPhoton;
@property (nonatomic) bool braked;

@end

@implementation TrafficLightViewController

- (void) viewDidLoad {
    self.braked = false;
    
    [[SparkCloud sharedInstance] loginWithUser:@"kevinhk.zhang@mail.utoronto.ca" password:@"telushacks" completion:^(NSError *error) {
        if (!error) {
            NSLog(@"Logged in to cloud");
        } else {
            NSLog(@"Wrong credentials or no internet connectivity, please try again");
        }
    }];
    
    [[SparkCloud sharedInstance] getDevices:^(NSArray *sparkDevices, NSError *error) {
        NSLog(@"%@",sparkDevices.description); // print all devices claimed to user
        
        for (SparkDevice *device in sparkDevices)
        {
            if ([device.name isEqualToString:@"Traffic_Light"]) {
                self.myPhoton = device;
                NSLog(@"Device found");
                
                self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                              target:self
                                                            selector:@selector(checkVar:)
                                                            userInfo:nil
                                                             repeats:YES];
                break;
            }
        }
    }];
    
    // Construct URL to sound file
    NSString *path = [NSString stringWithFormat:@"%@/Ultimate.m4r", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    // Create audio player object and initialize with URL to sound
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
}

- (IBAction)checkVar:(id)sender {
    NSLog(@"Request");
    [self.myPhoton getVariable:@"Brake" completion:^(id result, NSError *error) {
        if (!error) {
            NSLog(@"Return: %@", result);
            if(!self.braked && [result intValue] == 1) {
                self.braked = true;
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                [_audioPlayer play];
            } else {
                self.braked = false;
            }
        }
        else {
            NSLog(@"Failed reading led from Photon device");
        }
    }];
}

- (IBAction)trafficLightChanged:(id)sender {
    UISegmentedControl *seg = (UISegmentedControl *) sender;
    switch ([seg selectedSegmentIndex]) {
        case 0:
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            
            // present the toast with the new style
            [self.trafficLightView makeToast:@"RED LIGHT!!!"
                        duration:3.0
                        position:CSToastPositionBottom
                           style:nil];
            [self.trafficLightImageView setImage:[UIImage imageNamed:@"TrafficRed"]];
            break;
        case 1:
            [self.trafficLightImageView setImage:[UIImage imageNamed:@"TrafficYellow"]];
            {
                NSDictionary *inventory = @{
                    @"name" : @"penis"
                };
                
                NSDictionary *data = [NetworkManager getDataFrom:@"https://pubsub.pubnub.com/v1/blocks/sub-key/sub-c-f6c13fb2-b601-11e7-a150-5e56acef67bd/getDistance" postData:inventory];
                NSString *callback = [data objectForKey:@"Callback"];
                
                NSLog(@"Callback: %@", callback);
            }
            break;
        case 2:
            [self.trafficLightImageView setImage:[UIImage imageNamed:@"TrafficGreen"]];
            break;
        default:
            break;
    }
}

@end
