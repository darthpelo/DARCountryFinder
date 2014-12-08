//
//  DARLocalizationManager.m
//  DARCountryFinder
//
//  Created by Alessio Roberto on 06/12/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import "DARLocalizationManager.h"
#import "KMLParser.h"

@interface DARLocalizationManager ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastUserLocation;
@property (nonatomic, strong) CLPlacemark *actualUserPlacemark;
@property (nonatomic, strong) KMLParser *kmlParser;
@property (nonatomic, strong) NSArray *nationsList;
@end

@implementation DARLocalizationManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static DARLocalizationManager *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[DARLocalizationManager alloc] init]; });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"world-stripped"
                                                         ofType:@"kml"];
        
        NSURL *url = [NSURL fileURLWithPath:path];
        _kmlParser = [[KMLParser alloc] initWithURL:url];
        [self.kmlParser parseKML];
        
        _nationsList = [self.kmlParser placemarksName];
    }
    
    return self;
}

#pragma mark - Public methods

- (void)requestUserAuth
{
    if (!self.locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager.delegate = self;
    }
    
    // ask for "when in use" permission
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
#endif
}

- (void)startUserLocalization
{
    [self.locationManager startUpdatingLocation];
}

- (void)stopUserLocalization
{
    [self.locationManager stopUpdatingLocation];
}

- (CLLocation *)getLastUserLocation
{
    return self.lastUserLocation;
}

- (NSArray *)getNationsList
{
    return self.nationsList;
}

- (void)reverseGeocodeWithOverlay:(void (^)(id <MKOverlay>))success
                            failure:(void (^)(NSError *))failure
{
    __weak __typeof(self)weakSelf = self;
    
    [self reverseGeocode:self.lastUserLocation
                 success:^(NSDictionary *info) {
                     NSString *country = info[@"country"];
                     success([weakSelf.kmlParser overlayForString:country]);
                 } failure:^(NSError *error) {
                     failure(error);
                 }
     ];
}

- (void)reverseGeocode:(void (^)(NSDictionary *))success
               failure:(void (^)(NSError *))failure
{
    [self reverseGeocode:self.lastUserLocation
                 success:^(NSDictionary *info) {
                     success(info);
                 } failure:^(NSError *error) {
                     failure(error);
                 }
     ];
}

- (void)reverseGeocode:(CLLocation *)location
               success:(void(^)(NSDictionary *info))success
               failure:(void(^)(NSError *error))failure
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            failure(error);
        } else {
            self.actualUserPlacemark = [placemarks lastObject];
            
            if (self.actualUserPlacemark.addressDictionary && self.actualUserPlacemark.ISOcountryCode && self.actualUserPlacemark.country) {
                NSMutableDictionary *info = [NSMutableDictionary new];
                
                [info setObject:[NSString stringWithFormat:@"%@", ABCreateStringWithAddressDictionary(self.actualUserPlacemark.addressDictionary, NO)]
                         forKey:@"address"];
                [info setObject:self.actualUserPlacemark.ISOcountryCode forKey:@"countryCode"];
                [info setObject:self.actualUserPlacemark.country forKey:@"country"];
                
                success(info);
            } else
                failure([[NSError alloc] initWithDomain:@"No info" code:99 userInfo:nil]);

        }
    }];
}

- (void)getOverlayWithString:(NSString *)string
                     success:(void (^)(id <MKOverlay> overlay))success
                     failure:(void (^)(NSError *error))failure
{
    success([self.kmlParser overlayForString:string]);
}

- (void)setupMapForLocation:(MKMapView *)mapView
{
    [self setupMapForLocation:self.lastUserLocation mapView:mapView];
}

- (void)setupMapForLocation:(CLLocation*)newLocation
                    mapView:(MKMapView *)mapView
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.00725;
    span.longitudeDelta = 0.00725;
    CLLocationCoordinate2D location;
    location.latitude = newLocation.coordinate.latitude;
    location.longitude = newLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [mapView setRegion:region animated:YES];
}

-(void)removeAllAnnotationExceptOfCurrentUser:(MKMapView *)mapView
{
    NSMutableArray *annForRemove = [[NSMutableArray alloc] initWithArray:mapView.annotations];
    if ([mapView.annotations.lastObject isKindOfClass:[MKUserLocation class]]) {
        [annForRemove removeObject:mapView.annotations.lastObject];
    } else {
        for (id <MKAnnotation> annot_ in mapView.annotations)
        {
            if ([annot_ isKindOfClass:[MKUserLocation class]] ) {
                [annForRemove removeObject:annot_];
                break;
            }
        }
    }
    
    [mapView removeAnnotations:annForRemove];
}

#pragma mark - Private methods
#pragma mark CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    _lastUserLocation = locations[0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.alessioroberto.darcountryfinder.newlocation"
                                                        object:self
     ];
}

@end
