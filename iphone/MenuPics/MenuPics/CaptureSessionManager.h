//
//  CaptureSessionManager.h
//  MenuPics
//
//  Created by Christian Deonier on 5/23/12.
//  Copyright (c) 2012 InfoIt Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@interface CaptureSessionManager : NSObject

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;

- (void)addVideoPreviewLayer;
- (void)addVideoInput;

@end
