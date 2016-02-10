//
//  MapViewController.m
//  Persistence
//
//  Created by Blayne Chong on 2016-02-06.
//  Copyright © 2016 Blayne Chong. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

BOOL delete;

@implementation MapViewController

#pragma mark - View Events

- (void)viewDidLoad {
    [super viewDidLoad];
    // gets the managed object context from app delegate
    self.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    [self instantiateMapViewAndLocationManager];
    [self addLongPressGestureToMapView];
}

- (void)viewWillAppear:(BOOL)animated {
    // sets bool value for delete button
    delete = NO;
    
    [self setSavedPinsOnMap];
}

#pragma mark - View Setup

- (void)instantiateMapViewAndLocationManager {
    self.mapView.delegate = self;
    
    // initiate instance of CLLocationManager and sets location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)addLongPressGestureToMapView {
    // Add a long press gesture which adds pins to the MapView
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    [self.mapView addGestureRecognizer:longPress];
}

#pragma mark - Actions

// Adds and saves pins to map
- (void)handleLongPress: (UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    // gets the coordinates from the area pressed
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = touchCoordinate;
    
    // Adds and saves pin to core data
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    Location *locationRecord = [[Location alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    
    locationRecord.latitude = @(pin.coordinate.latitude);
    locationRecord.longitude = @(pin.coordinate.longitude);
    
    [self saveChanges];
    [self.mapView addAnnotation:pin];
}

- (IBAction)deletePins:(id)sender {
    if (delete == NO) {
        delete = YES;
        [self.deleteButton setTitle:@"Cancel"];
    } else {
        delete = NO;
        [self.deleteButton setTitle:@"Delete"];
    }
}

#pragma mark - CLLocation Delegates

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Did fail with error: %@", error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // gets the users current location
    self.currentLocation = [locations lastObject];
    double currentLatitude = self.currentLocation.coordinate.latitude;
    double currentLongitude =  self.currentLocation.coordinate.longitude;
    [self.locationManager stopUpdatingLocation];
    
    // zooms into location on the map
    CLLocationCoordinate2D userLocation = {.latitude = currentLatitude, .longitude = currentLongitude};
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation, 6000, 6000);
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - Map View Delegates

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    self.pinSelectedLatitude = [NSNumber numberWithDouble:view.annotation.coordinate.latitude];
    self.pinSelectedLongitude = [NSNumber numberWithDouble:view.annotation.coordinate.longitude];
    
    if (delete == NO) {
        [self.mapView deselectAnnotation:view.annotation animated:NO];
        [self performSegueWithIdentifier:@"displayImages" sender:self];
    } else {
        // if BOOL delete is YES then it will delete selected pin
        
        NSFetchRequest *fetchRequest = [self performFetchRequest];
        
        // instantiate predicates with values of the coordinates of the pins
        NSPredicate *predicateLatitude = [NSPredicate predicateWithFormat:@"latitude=%lf", [self.pinSelectedLatitude doubleValue]];
        NSPredicate *predicateLongitude = [NSPredicate predicateWithFormat:@"longitude=%lf", [self.pinSelectedLongitude doubleValue]];
        
        [fetchRequest setPredicate:predicateLatitude];
        [fetchRequest setPredicate:predicateLongitude];
        
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        // runs through data and finds lat and long matching the pins coordinates and deletes them
        for (NSManagedObject *obj in fetchedObjects) {
            [self.managedObjectContext deleteObject:obj];
        }
        
        [self saveChanges];
        [self.mapView removeAnnotation:view.annotation];
    }
}

#pragma mark - Core Data

// Fetch request to retrieve data
- (NSFetchRequest *)performFetchRequest {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    return fetchRequest;
}

// Call save
- (void) saveChanges {
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

// Fetches pins from core data and populates the map
- (void)setSavedPinsOnMap {
    NSError *error = nil;
    NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:[self performFetchRequest] error:&error];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        // for loop that iterates through the fetch request results and places pins at there locations
        for (int fetchResultCounter = 0; fetchResultCounter < [fetchResult count]; fetchResultCounter++) {
            Location *locationRecord = (Location *)[fetchResult objectAtIndex:fetchResultCounter];
            
            // gets coordinates from managed object
            CLLocationCoordinate2D coordinates = {.latitude = [locationRecord.latitude doubleValue], .longitude = [locationRecord.longitude doubleValue]};
            MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
            pin.coordinate = coordinates;
            [self.mapView addAnnotation:pin];
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"displayImages"]) {
        self.imageDisplayVC = (ImagDisplayViewController *)segue.destinationViewController;
        CLLocationCoordinate2D pinSelectedCoordinates = {.latitude = [self.pinSelectedLatitude doubleValue], .longitude = [self.pinSelectedLongitude doubleValue]};
        self.imageDisplayVC.pinPressedCoordinates = pinSelectedCoordinates;
    }
}


@end
