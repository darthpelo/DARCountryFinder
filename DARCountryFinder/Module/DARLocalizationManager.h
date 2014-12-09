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

/**
 *    Request user auth to use GEO position (> iOS 8)
 */
- (void)requestUserAuth;

/**
 *    Start updating user position
 */
- (void)startUserLocalization;

/**
 *    Stop updating user position
 */
- (void)stopUserLocalization;

/**
 *    Return last user position
 *
 *    @return CCLocation istance
 */
- (CLLocation *)getLastUserLocation;

/**
 *    Return a list with all nation names present in KML file
 *
 *    @return A NSArray with NSString
 */
- (NSArray *)getNationsList;

/**
 *    Using a specific position (lat, long) and reverse geocode functions return a block with NSDictionary with country name, country ISO code and address about the position.
 *
 *    @param location CLLocation of the user
 *    @param success  A block with a single parameter, a NSDictionary with address, country name and country code.
 *    @param failure  The failure block if geocode fails.
 */
- (void)reverseGeocode:(CLLocation *)location
               success:(void(^)(NSDictionary *info))success
               failure:(void(^)(NSError *error))failure;
/**
 *    Return geocode information (address, country and ISO country code) about user last know position
 *
 *    @param success A block with a single parameter, a NSDictionary with address, country name and country code.
 *    @param failure The failure block if geocode fails.
 */
- (void)reverseGeocode:(void(^)(NSDictionary *info))success
               failure:(void(^)(NSError *error))failure;
/**
 *    Return Country MKOverlay from KML file based on current user position (by reverse geocode) and country name
 *
 *    @param success A block with two parameters: the Country MKOverlay and the Country name
 *    @param failure The failure block if geocode fails.
 */
- (void)reverseGeocodeWithOverlay:(void (^)(id <MKOverlay> overlay, NSString *countryName))success
               failure:(void (^)(NSError *error))failure;

/**
 *    Return a specific Country MKOverlay respect a string (country name)
 *
 *    @param string  Country name
 *    @param success A block with the Country MKOverlay
 *    @param failure The failure block if geocode fails.
 */
- (void)getOverlayWithString:(NSString *)string
                     success:(void (^)(id <MKOverlay> overlay))success
failure:(void (^)(NSError *error))failure;

/**
 *    Center MKMapView respect a specific location
 *
 *    @param newLocat The specific location
 *    @param mapView  The MKMapView instance
 */
- (void)setupMapForLocation:(CLLocation*)newLocat mapView:(MKMapView *)mapView;

/**
 *    Center KMMapView respect last know user position
 *
 *    @param mapView The MKMapView instance
 */
- (void)setupMapForLocation:(MKMapView *)mapView;

/**
 *    Remove all annotations and overlays on the MKMapView, excepet user position, if present
 *
 *    @param mapView The MKMapView instance
 */
- (void)removeAllAnnotationExceptOfCurrentUser:(MKMapView *)mapView;

/**
 *    Find the KMLPlacemark object that owns this point and get the view from it.
 *
 *    @param point The MKAnnotation point
 *
 *    @return The KMLPlacemark object that owns the point
 */
- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point;

/**
 *    Find the KMLPlacemark object that owns this overlay and get the view from it.
 *
 *    @param overlay The MKOverlay overlay
 *
 *    @return The KMLPlacemark object that owns the overlay
 */
- (MKOverlayView *)viewForOverlay:(id <MKOverlay>)overlay;

@end
