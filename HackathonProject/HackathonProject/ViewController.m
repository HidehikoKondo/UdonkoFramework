//
//  ViewController.m
//  HackathonProject
//
//  Created by UDONKONET on 2017/05/14.
//  Copyright © 2017年 UDONKONET. All rights reserved.
//

#import "ViewController.h"
@import MaBeeeSDK;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma -mark MaBeee用
- (IBAction)scanButtonPressed:(UIButton *)sender {
    MaBeeeScanViewController *vc = MaBeeeScanViewController.new;
    [vc show:self];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    for (MaBeeeDevice *device in MaBeeeApp.instance.devices) {
        device.pwmDuty = (int)(slider.value * 100);
    }
}




@end
