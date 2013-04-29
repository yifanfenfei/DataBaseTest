//
//  ViewController.h
//  DataBaseTest
//
//  Created by sun jianfeng on 2/26/13.
//  Copyright (c) 2013 sun jianfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    IBOutlet UIButton* inserBtn;
    IBOutlet UIButton * selectBtn;
    IBOutlet UIButton * deleteBtn;
    IBOutlet UIImageView* imageView;
}
@property(nonatomic,strong)UIButton* inserBtn,* selectBtn,* deleteBtn;
@property(nonatomic,strong)UIImageView* imageView;
-(IBAction)btnPressed:(UIButton*)sender;
@end
