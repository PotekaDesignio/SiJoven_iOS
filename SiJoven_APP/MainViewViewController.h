//
//  MainViewViewController.h
//  BanAppgrario2
//
//  Created by Alejandro Moreno on 24/07/14.
//  Copyright (c) 2014 Poteka Designio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainViewViewController : UIViewController<UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    IBOutlet UIView *viewFacebook;
}

@end

