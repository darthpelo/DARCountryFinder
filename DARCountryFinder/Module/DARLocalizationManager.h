//
//  DARLocalizationManager.h
//  DARCountryFinder
//
//  Created by Alessio Roberto on 06/12/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

@import Foundation;
@import CoreLocation;
@import AddressBookUI;
@import MapKit;

@interface DARLocalizationManager : NSObject <CLLocationManagerDelegate>

+ (instancetype)sharedInstance;

- (void)requestUserAuth;

- (void)startUserLocalization;

- (void)stopUserLocalization;

- (CLLocation *)getLastUserLocation;

- (NSArray *)getNationsList;

- (void)reverseGeocode:(CLLocation *)location
               success:(void(^)(NSDictionary *info))success
               failure:(void(^)(NSError *error))failure;

- (void)reverseGeocode:(void(^)(NSDictionary *info))success
               failure:(void(^)(NSError *error))failure;

- (void)reverseGeocodeWithOverlay:(void (^)(id <MKOverlay> overlay))success
               failure:(void (^)(NSError *error))failure;

- (void)getOverlayWithString:(NSString *)string
                     success:(void (^)(id <MKOverlay> overlay))success
failure:(void (^)(NSError *error))failure;

- (void)setupMapForLocation:(CLLocation*)newLocat mapView:(MKMapView *)mapView;

- (void)setupMapForLocation:(MKMapView *)mapView;

- (void)removeAllAnnotationExceptOfCurrentUser:(MKMapView *)mapView;

- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point;

- (MKOverlayView *)viewForOverlay:(id <MKOverlay>)overlay;

@end
