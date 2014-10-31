//
//  MainViewViewController.m
//  SiJovenAPP
//
//  Created by Yortz Alvarado.
//  Copyright (c) 2014 Poteka Designio. All rights reserved.
//

#import "MainViewViewController.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface MainViewViewController ()

@end

@implementation MainViewViewController

NSString *FACEBOOK_KEY = @"FACEBOOK";
NSString *TWITTER_KEY = @"TWITTER";
NSString *FINAL_MODULO = @"FINAL-MODULO";
NSString *LINK_KEY = @"LINK";
NSArray *NOMBRE_MODULO;



- (void)viewDidLoad
{
    [super viewDidLoad];
  
    //[self showConfirmationAlert];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"www"]];
    
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    webView.scrollView.bounces = false;
    
    [webView setDelegate:self];
    
    
    /*
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
     */
    NSString *path = [[NSBundle mainBundle] bundlePath];
    
    NSString *htmlPath = [path stringByAppendingPathComponent:@"www/images"];
    NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:htmlPath];
    NSLog(@"%@", dirContents);
    
    [webView setDelegate:self];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *url = [request URL];
    NSString *urlStr = url.absoluteString;
    
    return [self processURL:urlStr];
    
}

- (BOOL) processURL:(NSString *) url
{
    NSString *urlStr = [NSString stringWithString:url];
    
    NSString *protocolPrefix = @"js2ios://";
    
    //process only our custom protocol
    if ([[urlStr lowercaseString] hasPrefix:protocolPrefix])
    {
        //strip protocol from the URL. We will get input to call a native method
        urlStr = [urlStr substringFromIndex:protocolPrefix.length];
        
        //Decode the url string
        urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSError *jsonError;
        
        //parse JSON input in the URL
        NSDictionary *callInfo = [NSJSONSerialization
                                  JSONObjectWithData:[urlStr dataUsingEncoding:NSUTF8StringEncoding]
                                  options:kNilOptions
                                  error:&jsonError];
        
        //check if there was error in parsing JSON input
        if (jsonError != nil)
        {
            NSLog(@"Error parsing JSON for the url %@",url);
            return NO;
        }
        
        //Get function name. It is a required input
        NSString *functionName = [callInfo objectForKey:@"functionname"];
        if (functionName == nil)
        {
            NSLog(@"Missing function name");
            return NO;
        }
        
        NSString *successCallback = [callInfo objectForKey:@"success"];
        NSString *errorCallback = [callInfo objectForKey:@"error"];
        NSArray *argsArray = [callInfo objectForKey:@"args"];
        
        [self callNativeFunction:functionName withArgs:argsArray onSuccess:successCallback onError:errorCallback];
        
        //Do not load this url in the WebView
        return NO;
        
    }
    
    return YES;
}

- (void) callNativeFunction:(NSString *) name withArgs:(NSArray *) args onSuccess:(NSString *) successCallback onError:(NSString *) errorCallback
{
    [self dummieFunction:name];
    
}

-(void) callErrorCallback:(NSString *) name withMessage:(NSString *) msg
{
    if (name != nil)
    {
        //call error handler
        
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        [resultDict setObject:msg forKey:@"error"];
        [self callJSFunction:name withArgs:resultDict];
    }
    else
    {
        NSLog(@"%@",msg);
    }
    
}

-(void) callSuccessCallback:(NSString *) name withRetValue:(id) retValue forFunction:(NSString *) funcName
{
    if (name != nil)
    {
        //call succes handler
        
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        [resultDict setObject:retValue forKey:@"result"];
        [self callJSFunction:name withArgs:resultDict];
    }
    else
    {
        NSLog(@"Result of function %@ = %@", funcName,retValue);
    }
    
}

-(void) callJSFunction:(NSString *) name withArgs:(NSMutableDictionary *) args
{
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from the response  : %@",[jsonError localizedDescription]);
        return;
    }
    
    //initWithBytes:length:encoding
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"jsonStr = %@", jsonStr);
    
    if (jsonStr == nil)
    {
        NSLog(@"jsonStr is null. count = %d", [args count]);
    }
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');",name,jsonStr]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dummieFunction:(NSString *) texto
{
    NSArray *array = [texto componentsSeparatedByString:@"_"];
    
    BOOL res = [array[0] isEqualToString:FACEBOOK_KEY];
    BOOL res2 = [array[0] isEqualToString:TWITTER_KEY];
    BOOL res3 = [array[0] isEqualToString:FINAL_MODULO];
    BOOL res4 = [array[0] isEqualToString:LINK_KEY];
    
    if(res)
    {
        [self CompartirFacebook : array];
    }
    if(res2)
    {
        [self CompartirTwitter : array];
    }
    if(res3)
    {   
        [self CompartirModal : array];
    }
    if(res4)
    {
        [self AbrirNavegador : array];
    }
}

- (void) showConfirmationAlert
{
    // A quick and dirty popup, displayed only once
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"AceptaCondicionesUso"])
    {
    
    NSString *tituloModal = @"";
    
     NSString *disclaimer = @"";
     NSString *aceptar = @"Acepto";
     NSString *cancelar = @"No Acepto";
    
    
    
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:tituloModal
                                                       message:disclaimer
                                                      delegate:self
                                             cancelButtonTitle:aceptar
                                             otherButtonTitles:cancelar,nil];
        
        alert.tag = 0;
        [alert show];
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 0)
    {
        if (buttonIndex == 0)
        {
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"AceptaCondicionesUso"];
        }
    
        if (buttonIndex == 1)
        {
            exit(0);
        }
    }
    if(alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            [self CompartirFacebook:NOMBRE_MODULO];
        }
        
        if (buttonIndex == 2)
        {
             [self CompartirTwitter:NOMBRE_MODULO];
        }
    }
}


-(void) CompartirFacebook:(NSArray *) array
{
    //FacebookViewController *controler = [[FacebookViewController alloc] initWithNibName:nil bundle:nil];
    //[self presentViewController:controler animated:YES completion:NULL];
    NSString *mensajeCompartir;
    
    if([array[1] isEqualToString:@"1"])
    {
        mensajeCompartir = @"";
    }
    else
    {
        mensajeCompartir = @"#SiJoven - ";
        mensajeCompartir = [mensajeCompartir stringByAppendingString:array[1]];
    }
    
    if([SLComposeViewController isAvailableForServiceType: SLServiceTypeFacebook])
    {
        // Facebook Service Type is Available
        
        SLComposeViewController *slVC = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeFacebook];
        SLComposeViewControllerCompletionHandler handler = ^(SLComposeViewControllerResult result)
        {
            if (result == SLComposeViewControllerResultCancelled)
            {
                NSLog(@"Cancelled");
                
            }
            else
            {
                NSLog(@"Done");
            }
            
            [slVC dismissViewControllerAnimated:YES completion:Nil];
        };
        slVC.completionHandler = handler;
        [slVC setInitialText:mensajeCompartir];
        [slVC addURL:[NSURL URLWithString:@""]];
        [slVC addImage:[UIImage imageNamed:@"www/ico.png"]];
        
        [self presentViewController:slVC animated:YES completion:Nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"SiJoven"];
        [alert setMessage:@"Para publicar en Facebook debes configurar primero tu cuenta en la configuración de tu dispositivo."];
        [alert setDelegate:self];
        [alert addButtonWithTitle:@"OK"];
        
        [alert show];
    }
}

-(void) CompartirTwitter:(NSArray *) array
{
    NSString *mensajeCompartir;
    
    if([array[1] isEqualToString:@"1"])
    {
        mensajeCompartir = @"";
    }
    else
    {
        mensajeCompartir = @"#SiJoven -  ";
        mensajeCompartir = [mensajeCompartir stringByAppendingString:array[1]];
    }
    
    
    if ([TWTweetComposeViewController canSendTweet]) // Check if twitter is setup and reachable
    {
        TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
        
        // set initial text
        [tweetViewController setInitialText:mensajeCompartir];
        
        // setup completion handler
        tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
            if(result == TWTweetComposeViewControllerResultDone) {
                // the user finished composing a tweet
            } else if(result == TWTweetComposeViewControllerResultCancelled) {
                // the user cancelled composing a tweet
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        
        // present view controller
            [self presentViewController:tweetViewController animated:YES completion:nil];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"SiJoven"];
        [alert setMessage:@"Para publicar en Twitter debes configurar primero tu cuenta en la configuración de tu dispositivo."];
        [alert setDelegate:self];
        [alert addButtonWithTitle:@"OK"];
        
        [alert show];
    }
}

-(void) CompartirModal:(NSArray *) array
{
    NOMBRE_MODULO = array;
    NSString * mensaje = [NSString stringWithFormat:@"%@.", array[1]];
    
        
    UIAlertView *myAlert1 = [[UIAlertView alloc]initWithTitle:@"Compartir Oferta\n\n"
                                                      message:mensaje
                                                     delegate:self
                                            cancelButtonTitle:@"Cancelar"
                                            otherButtonTitles:@"Facebook", @"Twitter", nil];
    
    myAlert1.tag = 1;
    [myAlert1 show];
}

-(void) AbrirNavegador:(NSArray *) array
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:array[1]]];
}

@end
