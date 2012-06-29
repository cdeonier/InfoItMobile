//
//  ImageUtil.m
//  MenuPics
//
//  Created by Christian Deonier on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageUtil.h"

@implementation ImageUtil

+ (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);  
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();    
    
    return newImage;
}

+ (NSArray *)getSweepImageArray {
    return [NSArray arrayWithObjects:
            [UIImage imageNamed:@"sweep"],[UIImage imageNamed:@"sweep_2"],[UIImage imageNamed:@"sweep_3"],
            [UIImage imageNamed:@"sweep_4"],[UIImage imageNamed:@"sweep_5"],[UIImage imageNamed:@"sweep_6"],
            [UIImage imageNamed:@"sweep_7"],[UIImage imageNamed:@"sweep_8"],[UIImage imageNamed:@"sweep_9"],
            [UIImage imageNamed:@"sweep_10"],[UIImage imageNamed:@"sweep_11"],[UIImage imageNamed:@"sweep_12"],
            [UIImage imageNamed:@"sweep_13"],[UIImage imageNamed:@"sweep_14"],[UIImage imageNamed:@"sweep_15"],
            [UIImage imageNamed:@"sweep_16"],[UIImage imageNamed:@"sweep_17"],[UIImage imageNamed:@"sweep_18"],
            [UIImage imageNamed:@"sweep_19"],[UIImage imageNamed:@"sweep_20"],[UIImage imageNamed:@"sweep_21"],
            [UIImage imageNamed:@"sweep_22"],[UIImage imageNamed:@"sweep_23"],[UIImage imageNamed:@"sweep_24"],
            [UIImage imageNamed:@"sweep_25"],[UIImage imageNamed:@"sweep_26"],[UIImage imageNamed:@"sweep_27"],
            [UIImage imageNamed:@"sweep_28"],[UIImage imageNamed:@"sweep_29"],[UIImage imageNamed:@"sweep_30"],
            [UIImage imageNamed:@"sweep_31"],[UIImage imageNamed:@"sweep_32"],[UIImage imageNamed:@"sweep_33"],
            [UIImage imageNamed:@"sweep_34"],[UIImage imageNamed:@"sweep_35"],[UIImage imageNamed:@"sweep_36"],
            [UIImage imageNamed:@"sweep_37"],[UIImage imageNamed:@"sweep_38"],[UIImage imageNamed:@"sweep_39"],
            [UIImage imageNamed:@"sweep_40"],[UIImage imageNamed:@"sweep_41"],[UIImage imageNamed:@"sweep_42"],
            [UIImage imageNamed:@"sweep_43"],[UIImage imageNamed:@"sweep_44"],[UIImage imageNamed:@"sweep_45"],
            [UIImage imageNamed:@"sweep_46"],[UIImage imageNamed:@"sweep_47"],[UIImage imageNamed:@"sweep_48"],
            [UIImage imageNamed:@"sweep_49"],[UIImage imageNamed:@"sweep_50"],[UIImage imageNamed:@"sweep_51"],
            [UIImage imageNamed:@"sweep_52"],[UIImage imageNamed:@"sweep_53"],[UIImage imageNamed:@"sweep_54"],
            [UIImage imageNamed:@"sweep_55"],[UIImage imageNamed:@"sweep_56"],[UIImage imageNamed:@"sweep_57"],
            [UIImage imageNamed:@"sweep_58"],[UIImage imageNamed:@"sweep_59"],[UIImage imageNamed:@"sweep_60"],
            [UIImage imageNamed:@"sweep_61"],[UIImage imageNamed:@"sweep_62"],[UIImage imageNamed:@"sweep_63"],
            [UIImage imageNamed:@"sweep_64"], 
            [UIImage imageNamed:@"unsweep"],[UIImage imageNamed:@"unsweep_2"],[UIImage imageNamed:@"unsweep_3"],
            [UIImage imageNamed:@"unsweep_4"],[UIImage imageNamed:@"unsweep_5"],[UIImage imageNamed:@"unsweep_6"],
            [UIImage imageNamed:@"unsweep_7"],[UIImage imageNamed:@"unsweep_8"],[UIImage imageNamed:@"unsweep_9"],
            [UIImage imageNamed:@"unsweep_10"],[UIImage imageNamed:@"unsweep_11"],[UIImage imageNamed:@"unsweep_12"],
            [UIImage imageNamed:@"unsweep_13"],[UIImage imageNamed:@"unsweep_14"],[UIImage imageNamed:@"unsweep_15"],
            [UIImage imageNamed:@"unsweep_16"],[UIImage imageNamed:@"unsweep_17"],[UIImage imageNamed:@"unsweep_18"],
            [UIImage imageNamed:@"unsweep_19"],[UIImage imageNamed:@"unsweep_20"],[UIImage imageNamed:@"unsweep_21"],
            [UIImage imageNamed:@"unsweep_22"],[UIImage imageNamed:@"unsweep_23"],[UIImage imageNamed:@"unsweep_24"],
            [UIImage imageNamed:@"unsweep_25"],[UIImage imageNamed:@"unsweep_26"],[UIImage imageNamed:@"unsweep_27"],
            [UIImage imageNamed:@"unsweep_28"],[UIImage imageNamed:@"unsweep_29"],[UIImage imageNamed:@"unsweep_30"],
            [UIImage imageNamed:@"unsweep_31"],[UIImage imageNamed:@"unsweep_32"],[UIImage imageNamed:@"unsweep_33"],
            [UIImage imageNamed:@"unsweep_34"],[UIImage imageNamed:@"unsweep_35"],[UIImage imageNamed:@"unsweep_36"],
            [UIImage imageNamed:@"unsweep_37"],[UIImage imageNamed:@"unsweep_38"],[UIImage imageNamed:@"unsweep_39"],
            [UIImage imageNamed:@"unsweep_40"],[UIImage imageNamed:@"unsweep_41"],[UIImage imageNamed:@"unsweep_42"],
            [UIImage imageNamed:@"unsweep_43"],[UIImage imageNamed:@"unsweep_44"],[UIImage imageNamed:@"unsweep_45"],
            [UIImage imageNamed:@"unsweep_46"],[UIImage imageNamed:@"unsweep_47"],[UIImage imageNamed:@"unsweep_48"],
            [UIImage imageNamed:@"unsweep_49"],[UIImage imageNamed:@"unsweep_50"],[UIImage imageNamed:@"unsweep_51"],
            [UIImage imageNamed:@"unsweep_52"],[UIImage imageNamed:@"unsweep_53"],[UIImage imageNamed:@"unsweep_54"],
            [UIImage imageNamed:@"unsweep_55"],[UIImage imageNamed:@"unsweep_56"],[UIImage imageNamed:@"unsweep_57"],
            [UIImage imageNamed:@"unsweep_58"],[UIImage imageNamed:@"unsweep_59"],[UIImage imageNamed:@"unsweep_60"],
            [UIImage imageNamed:@"unsweep_61"],[UIImage imageNamed:@"unsweep_62"],[UIImage imageNamed:@"unsweep_63"],
            [UIImage imageNamed:@"unsweep_64"],nil];
}

/*
 * Assumes XIB file of outer scrollview with tag 1000, and view with tag 1001 acting as content container
 *
 */
+ (void) initializeProfileImage:(UIView *) view withUrl:(NSString *)url success:(void (^)(UIView *profileView))success
{
    if (![url isEqual:[NSNull null]] && [url length] > 0) {
        UIScrollView *scrollView = (UIScrollView *)[view viewWithTag:1000];
        UIView *contentContainer = [view viewWithTag:1001];
        
        UIImageView *placeholderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_loading"]];
        CGRect contentContainerFrame = contentContainer.frame;
        contentContainerFrame.origin.y += placeholderImage.frame.size.height;
        contentContainer.frame = contentContainerFrame;
        [scrollView insertSubview:placeholderImage atIndex:0];
        
        UIImageView *loadingAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [loadingAnimation setAnimationImages:[ImageUtil getSweepImageArray]];
        [loadingAnimation setAnimationDuration:4.0f];
        [loadingAnimation setAnimationRepeatCount:INFINITY];
        [loadingAnimation startAnimating];
        [loadingAnimation setCenter:CGPointMake(160, 120)];
        [scrollView addSubview:loadingAnimation];
        
        
        UIImageView *profileImage = [[UIImageView alloc] init];
        NSURL *profileImageUrl = [NSURL URLWithString:url];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:profileImageUrl]];
            [profileImage setImage:image];
            CGFloat ratio = image.size.height / image.size.width;
            CGFloat height = 320.0 * ratio;
            [profileImage setFrame:CGRectMake(0, 0, 320, height)];
            dispatch_async(dispatch_get_main_queue(), ^{
                [placeholderImage removeFromSuperview];
                [loadingAnimation removeFromSuperview];
                [scrollView insertSubview:profileImage atIndex:0];
                CGRect contentContainerFrame = contentContainer.frame;
                contentContainerFrame.origin.y -= placeholderImage.frame.size.height;
                contentContainerFrame.origin.y += profileImage.frame.size.height;
                contentContainer.frame = contentContainerFrame;
                
                if (success)
                    success(contentContainer);
            });
        });
    } else {
        UIScrollView *scrollView = (UIScrollView *)[view viewWithTag:1000];
        UIView *contentContainer = [view viewWithTag:1001];
        
        UIImageView *placeholderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_no_image.jpg"]];
        [placeholderImage setFrame:CGRectMake(0, 0, 320, 240)];
        CGRect contentContainerFrame = contentContainer.frame;
        contentContainerFrame.origin.y += placeholderImage.frame.size.height;
        contentContainer.frame = contentContainerFrame;
        [scrollView insertSubview:placeholderImage atIndex:0];
    }
}

+ (void) initializeProfileImageWithUrl:(NSString *)url success:(void (^)(UIView *))success
{
    
}

@end
