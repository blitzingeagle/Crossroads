//
//  AppDelegate.m
//  Crossroads
//
//  Created by Morris Chen on 2017-10-20.
//  Copyright © 2017 Morris Chen. All rights reserved.
//

#import "AppDelegate.h"

#import <AudioToolbox/AudioServices.h>
#import <PubNub/PubNub.h>

@import GoogleMaps;

@interface AppDelegate () <PNObjectEventListener>

// Stores reference on PubNub client to make sure what it won't be released.
@property (nonatomic, strong) PubNub *client;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [GMSServices provideAPIKey:@"AIzaSyC4mKJxSjIbJlZbh5eXhU-O7osphdySg_w"];
    
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"pub-c-6483848d-4ca0-487f-badd-3824ae4be081"
                                                                     subscribeKey:@"sub-c-f6c13fb2-b601-11e7-a150-5e56acef67bd"];
    self.client = [PubNub clientWithConfiguration:configuration];
    [self.client addListener:self];
    
    // Subscribe to demo channel with presence observation
    [self.client subscribeToChannels: @[@"my_channel"] withPresence:YES];
    
    /**
     Subscription process results arrive to listener which should adopt to PNObjectEventListener protocol
     and registered using:
     */
    [self.client subscribeToChannels: @[@"my_channel1", @"my_channel2"] withPresence:NO];
    [self.client publish: @"Hello from PubNub iOS!" toChannel: @"my_channel" storeInHistory:YES
          withCompletion:^(PNPublishStatus *status) {
              
              if (!status.isError) {
                  
                  // Message successfully published to specified channel.
              }
              else {
                  
                  /**
                   Handle message publish error. Check 'category' property to find
                   out possible reason because of which request did fail.
                   Review 'errorData' property (which has PNErrorData data type) of status
                   object to get additional information about issue.
                   
                   Request can be resent using: [status retry];
                   */
              }
          }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma PNObjectEventListener

// Handle new message from one of channels on which client has been subscribed.
- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
    // Handle new message stored in message.data.message
    if (![message.data.channel isEqualToString:message.data.subscription]) {
        
        // Message has been received on channel group stored in message.data.subscription.
    }
    else {
        
        // Message has been received on channel stored in message.data.channel.
    }
    
    NSLog(@"Received message: %@ on channel %@ at %@", message.data.message,
          message.data.channel, message.data.timetoken);
    
    NSString *key = [NSString stringWithFormat:@"%@", message.data.message];
    
    if([key isEqualToString:@"1"]) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
}

// New presence event handling.
- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    
    if (![event.data.channel isEqualToString:event.data.subscription]) {
        
        // Presence event has been received on channel group stored in event.data.subscription.
    }
    else {
        
        // Presence event has been received on channel stored in event.data.channel.
    }
    
    if (![event.data.presenceEvent isEqualToString:@"state-change"]) {
        
        NSLog(@"%@ \"%@'ed\"\nat: %@ on %@ (Occupancy: %@)", event.data.presence.uuid,
              event.data.presenceEvent, event.data.presence.timetoken, event.data.channel,
              event.data.presence.occupancy);
    }
    else {
        
        NSLog(@"%@ changed state at: %@ on %@ to: %@", event.data.presence.uuid,
              event.data.presence.timetoken, event.data.channel, event.data.presence.state);
    }
}

// Handle subscription status change.
- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
    if (status.operation == PNSubscribeOperation) {
        
        // Check whether received information about successful subscription or restore.
        if (status.category == PNConnectedCategory || status.category == PNReconnectedCategory) {
            
            // Status object for those categories can be casted to `PNSubscribeStatus` for use below.
            PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
            if (subscribeStatus.category == PNConnectedCategory) {
                
                // This is expected for a subscribe, this means there is no error or issue whatsoever.
                
                // Select last object from list of channels and send message to it.
                NSString *targetChannel = [client channels].lastObject;
                [self.client publish: @"Hello from the PubNub Objective-C SDK"
                           toChannel: targetChannel withCompletion:^(PNPublishStatus *publishStatus) {
                               
                               // Check whether request successfully completed or not.
                               if (!publishStatus.isError) {
                                   
                                   // Message successfully published to specified channel.
                               }
                               else {
                                   
                                   /**
                                    Handle message publish error. Check 'category' property to find out
                                    possible reason because of which request did fail.
                                    Review 'errorData' property (which has PNErrorData data type) of status
                                    object to get additional information about issue.
                                    
                                    Request can be resent using: [publishStatus retry];
                                    */
                               }
                           }];
            }
            else {
                
                /**
                 This usually occurs if subscribe temporarily fails but reconnects. This means there was
                 an error but there is no longer any issue.
                 */
            }
        }
        else if (status.category == PNUnexpectedDisconnectCategory) {
            
            /**
             This is usually an issue with the internet connection, this is an error, handle
             appropriately retry will be called automatically.
             */
        }
        // Looks like some kind of issues happened while client tried to subscribe or disconnected from
        // network.
        else {
            
            PNErrorStatus *errorStatus = (PNErrorStatus *)status;
            if (errorStatus.category == PNAccessDeniedCategory) {
                
                /**
                 This means that PAM does allow this client to subscribe to this channel and channel group
                 configuration. This is another explicit error.
                 */
            }
            else {
                
                /**
                 More errors can be directly specified by creating explicit cases for other error categories
                 of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,
                 `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                 or `PNNetworkIssuesCategory`
                 */
            }
        }
    }
}

@end
