//
//  CustomObject.h
//  Ambassadoor
//
//  Created by K Saravana Kumar on 13/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface CustomObject : NSObject
@property (strong, nonatomic) id someProperty;

- (void)backgroundImage:(NSData *)backgroundImage
         attributionURL:(NSString *)attributionURL;
@end

NS_ASSUME_NONNULL_END
