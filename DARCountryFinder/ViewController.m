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
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[DARLocalizationManager sharedInstance] requestUserAuth];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadMap)
                                                 name:@"com.alessioroberto.darcountryfinder.newlocation"
                                               object:nil
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (IBAction)buttonPressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"toTableView"]) {
        DARNationsTableViewController *vc = (DARNationsTableViewController *)[segue destinationViewController];
        vc.nationsList = [[DARLocalizationManager sharedInstance] getNationsList];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        __weak __typeof(self)weakSelf = self;
        vc.countrySelected = ^(NSString *country){
            [[DARLocalizationManager sharedInstance] stopUserLocalization];
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            dispatch_queue_t queue = dispatch_get_main_queue();
            
            dispatch_async(queue,^{
                [[DARLocalizationManager sharedInstance] getOverlayWithString:country
                                                                      success:^(id<MKOverlay> overlay) {
                                                                          [strongSelf.mapView addOverlay:overlay];
                                                                          // Position the map so that all overlays and annotations are visible on screen.
                                                                          strongSelf.mapView.visibleMapRect = [strongSelf.mapView mapRectThatFits:overlay.boundingMapRect];
                                                                      } failure:nil
                 ];
            });
        };
    }
}


- (void)reloadMap
{
    // remove all annotations and overlays
//    NSMutableArray *annotations = @[].mutableCopy;
//    [self.mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
//     {
//         id<MKAnnotation> annotation = (id<MKAnnotation>)obj;
//         
//         if (![annotation isKindOfClass:[MKUserLocation class]]) {
//             [annotations addObject:annotation];
//         }
//     }];
//    [self.mapView removeAnnotations:annotations];
//    [self.mapView removeOverlays:self.mapView.overlays];
    
//    [[DARLocalizationManager sharedInstance] setupMapForLocation:self.mapView];
    
    DARLocalizationManager *loc = [DARLocalizationManager sharedInstance];
    
    __weak __typeof(self)weakSelf = self;
    [loc reverseGeocodeWithOverlay:^(id<MKOverlay> overlay) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_queue_t queue = dispatch_get_main_queue();
        
        dispatch_async(queue,^{
            [strongSelf.mapView addOverlay:overlay];
            // Position the map so that all overlays and annotations are visible on screen.
            strongSelf.mapView.visibleMapRect = [strongSelf.mapView mapRectThatFits:overlay.boundingMapRect];
        });
    } failure:^(NSError *error) {
        NSLog(@"Error");
    }];
}

#pragma mark MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    return [[DARLocalizationManager sharedInstance] viewForOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return [[DARLocalizationManager sharedInstance] viewForAnnotation:annotation];
}

@end
