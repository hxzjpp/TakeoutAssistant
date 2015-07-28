//
//  ViewController.m
//  TakeoutAssistant_Team3_ios
//
//  Created by Z J on 7/28/15.
//  Copyright (c) 2015 Z J. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIImage* buttonImg =[UIImage imageNamed:@"greenplus_plus.jpg"];
    [_chooseButton setImage: buttonImg forState:UIControlStateNormal];
    
    
}

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}



- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}




- (IBAction)AddNew:(id)sender {
    mediaPicker = [[UIImagePickerController alloc] init];
    [mediaPicker setDelegate:self];
    mediaPicker.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take photo", @"Choose Existing", nil];
        [actionSheet showInView:self.view];
    } else {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:mediaPicker animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:mediaPicker animated:YES completion:nil];//
        
    } else if (buttonIndex == 1) {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentModalViewController:mediaPicker animated:YES];
    // [actionSheet release];
}




- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self recognizeImageWithTesseract:image];
}




-(void)recognizeImageWithTesseract:(UIImage *)image
{
    // Preprocess the image so Tesseract's recognition will be more accurate
    UIImage *bwImage = [image g8_blackAndWhite];
    
    // Animate a progress activity indicator
    [self.activityIndicator startAnimating];
    
    // Display the preprocessed image to be recognized in the view
    self.imageToRecognize.image = bwImage;
    
    // Create a new `G8RecognitionOperation` to perform the OCR asynchronously
    // It is assumed that there is a .traineddata file for the language pack
    // you want Tesseract to use in the "tessdata" folder in the root of the
    // project AND that the "tessdata" folder is a referenced folder and NOT
    // a symbolic group in your project
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng"];
    
    // Use the original Tesseract engine mode in performing the recognition
    // (see G8Constants.h) for other engine mode options
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    
    // Let Tesseract automatically segment the page into blocks of text
    // based on its analysis (see G8Constants.h) for other page segmentation
    // mode options
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOnly;
    
    // Optionally limit the time Tesseract should spend performing the
    // recognition
    //operation.tesseract.maximumRecognitionTime = 1.0;
    
    // Set the delegate for the recognition to be this class
    // (see `progressImageRecognitionForTesseract` and
    // `shouldCancelImageRecognitionForTesseract` methods below)
    operation.delegate = self;
    
    // Optionally limit Tesseract's recognition to the following whitelist
    // and blacklist of characters
    //operation.tesseract.charWhitelist = @"01234";
    //operation.tesseract.charBlacklist = @"56789";
    
    // Set the image on which Tesseract should perform recognition
    operation.tesseract.image = bwImage;
    
    // Optionally limit the region in the image on which Tesseract should
    // perform recognition to a rectangle
    //operation.tesseract.rect = CGRectMake(20, 20, 100, 100);
    
    // Specify the function block that should be executed when Tesseract
    // finishes performing recognition on the image
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        // Fetch the recognized text
        NSString *recognizedText = tesseract.recognizedText;
        
        NSLog(@"%@", recognizedText);
        
        // Remove the animated progress activity indicator
        [self.activityIndicator stopAnimating];
        
        // Spawn an alert with the recognized text
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OCR Result"
                                                        message:recognizedText
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    // Finally, add the recognition operation to the queue
    [self.operationQueue addOperation:operation];
}

@end
