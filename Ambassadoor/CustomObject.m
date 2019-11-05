//
//  CustomObject.m
//  Ambassadoor
//
//  Created by K Saravana Kumar on 13/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

#import "CustomObject.h"
#import <UIKit/UIKit.h>

@implementation CustomObject


- (void)backgroundImage:(NSData *)backgroundImage
         attributionURL:(NSString *)attributionURL{
    
    // Verify app can open custom URL scheme, open if able
    NSURL *urlScheme = [NSURL URLWithString:@"instagram-stories://share"];
    if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {

        // Assign background image asset and attribution link URL to pasteboard
        NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.backgroundImage" : backgroundImage,
                                       @"com.instagram.sharedSticker.contentURL" : attributionURL}];
        NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
        // This call is iOS 10+, can use 'setItems' depending on what versions you support
        [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];

        [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:^(BOOL success) {



        }];
    } else {
        // Handle older app versions or app not installed case

    }
    
    
}
@end
