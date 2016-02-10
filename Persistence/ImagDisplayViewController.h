//
//  ImagDisplayViewController.h
//  Persistence
//
//  Created by Blayne Chong on 2016-02-06.
//  Copyright © 2016 Blayne Chong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ImagDisplayViewController : UIViewController <MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property CLLocationCoordinate2D pinPressedCoordinates;
@property (strong, nonatomic) NSMutableArray *flickrImageResults;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *refreshDeleteButton;

- (IBAction)refreshDeletePressed:(id)sender;

@end
