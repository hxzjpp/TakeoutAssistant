//
//  ViewController.h
//  TakeoutAssistant_Team3_ios
//
//  Created by Z J on 7/28/15.
//  Copyright (c) 2015 Z J. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>

@interface ViewController : UIViewController<G8TesseractDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate> {
    UIImagePickerController *mediaPicker;
}
@property (nonatomic, retain) IBOutlet UIButton *chooseButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageToRecognize;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)AddNew:(id)sender;


@end

