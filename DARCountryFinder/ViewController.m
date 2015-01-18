//
//  ViewController.m
//  DARCountryFinder
//
//  Created by Alessio Roberto on 06/12/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import "ViewController.h"

#import "DARNationsTableViewController.h"

#import "DARLocalizationManager.h"

#import "MBProgressHUD.h"

@interface ViewController ()
@property (assign, nonatomic) BOOL userPosition;
@property (strong, nonatomic) DARLocalizationManager *locMgr;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _locMgr = [DARLocalizationManager sharedInstance];
    
    /**
     *    User location auth (iOS 8)
     */
    [_locMgr requestUserAuth];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadMap)
                                                 name:@"com.alessioroberto.darcountryfinder.newlocation"
                                               object:nil
     ];
    
    self.userPosition = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (IBAction)buttonPressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

/**
 *    User can swith on/off automatic localization
 *
 */
- (IBAction)positionPressed:(id)sender {
    if (_userPosition == YES) {
        self.userPosition = NO;
        [self.locMgr stopUserLocalization];
    } else {
        self.userPosition = YES;
        [self.locMgr startUserLocalization];
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"toTableView"]) {
        DARNationsTableViewController *vc = (DARNationsTableViewController *)[segue destinationViewController];
        vc.nationsList = [self.locMgr getNationsList];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        __weak __typeof(self)weakSelf = self;
        
        vc.countrySelected = ^(NSString *country){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.locMgr stopUserLocalization];
            strongSelf.userPosition = NO;
            
            [_locMgr removeAllAnnotationExceptOfCurrentUser:strongSelf.mapView];
            
            dispatch_queue_t queue = dispatch_get_main_queue();
            /**
             *    Make mapView operations on main thread
             */
            dispatch_async(queue,^{
                [_locMgr getOverlayWithString:country
                                      success:^(id<MKOverlay> overlay) {
                                          // Add country's overlay on the map
                                          [strongSelf.mapView addOverlay:overlay];
                                          
                                          // Position the map so that overlay is visible on screen.
                                          strongSelf.mapView.visibleMapRect = [strongSelf.mapView mapRectThatFits:overlay.boundingMapRect];
                                          
                                          // Add annotation with country name in the callout
                                          MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                                          [annotation setCoordinate:strongSelf.mapView.centerCoordinate];
                                          [strongSelf.mapView addAnnotation:annotation];
                                          annotation.title = country;
                                          [strongSelf.mapView selectAnnotation:annotation animated:YES];
                                      } failure:nil
                 ];
            });
        };
    }
}

/**
 *    Each time GPS send different user position, overlay and annotation are removed and a new MKOverlay is neccesary.
 *    To get the correct MKOverlay I use reverse geocode functions, to know in which country user is.
 */
- (void)reloadMap
{
    // remove all annotations and overlays
    [_locMgr removeAllAnnotationExceptOfCurrentUser:self.mapView];
    
    __weak __typeof(self)weakSelf = self;
    
    [_locMgr reverseGeocodeWithOverlay:^(id<MKOverlay> overlay, NSString *countryName) {
        if (overlay) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            dispatch_queue_t queue = dispatch_get_main_queue();
            /**
             *    Make mapView operations on main thread
             */
            dispatch_async(queue,^{
                // Add country's overlay on the map
                [strongSelf.mapView addOverlay:overlay];
                
                // Position the map so that overlay is visible on screen.
                strongSelf.mapView.visibleMapRect = [strongSelf.mapView mapRectThatFits:overlay.boundingMapRect];
                
                // Add annotation with country name in the callout
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                [annotation setCoordinate:strongSelf.mapView.centerCoordinate];
                [strongSelf.mapView addAnnotation:annotation];
                annotation.title = countryName;
                [strongSelf.mapView selectAnnotation:annotation animated:YES];
            });
        }
    } failure:^(NSError *error) {
        NSLog(@"Error");
    }];
}

#pragma mark MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    return [_locMgr viewForOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return [_locMgr viewForAnnotation:annotation];
}

@end
