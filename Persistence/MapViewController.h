//
//  MapViewController.h
//  Persistence
//
//  Created by Blayne Chong on 2016-02-06.
//  Copyright © 2016 Blayne Chong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "Location.h"
#import "ImagDisplayViewController.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) ImagDisplayViewController *imageDisplayVC;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSNumber *pinSelectedLatitude;
@property (strong, nonatomic) NSNumber *pinSelectedLongitude;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)deletePins:(id)sender;

@end
