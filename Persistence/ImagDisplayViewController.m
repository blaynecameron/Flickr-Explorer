//
//  ImagDisplayViewController.m
//  Persistence
//
//  Created by Blayne Chong on 2016-02-06.
//  Copyright © 2016 Blayne Chong. All rights reserved.
//

#import "ImagDisplayViewController.h"

@interface ImagDisplayViewController ()

@end

@implementation ImagDisplayViewController

#pragma mark - View Events

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getDataFromFlickr];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void) viewWillAppear:(BOOL)animated {
    [self setupMapView];
}

#pragma mark - Get Request

- (void)getDataFromFlickr {
    NSString *flickrURL = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=0d1f4732f76deefaacc0664293235d08&accuracy=16&content_type=1&lat=%f&lon=%f&extras=url_m&per_page=100&page=1&format=json&nojsoncallback=1",self.pinPressedCoordinates.latitude, self.pinPressedCoordinates.longitude];
    
    // get request to retrieve json with image URLs
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:flickrURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // sorts through JSON
        NSDictionary *response = [responseObject objectForKey:@"photos"];
        self.flickrImageResults = [[NSMutableArray alloc] initWithArray:[response objectForKey:@"photo"]];
        
        [self shuffleFlickrArrayAndRefreshCollectionView];
        // [self.collectionView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

#pragma mark - Map View

-(void) setupMapView {
    CLLocationCoordinate2D pinCoordinates = {.latitude = self.pinPressedCoordinates.latitude, .longitude = self.pinPressedCoordinates.longitude};
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pinCoordinates, 2000, 2000);
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = pinCoordinates;
    
    [self.mapView setRegion:region animated:YES];
    [self.mapView addAnnotation:pin];
}


#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.flickrImageResults count] > 21) {
        return 21;
    } else {
        return [self.flickrImageResults count];
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *image = [self.flickrImageResults objectAtIndex:indexPath.row];
    
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];
    
    // gets the images from the URL and populates the collection view
    NSString *string = [NSString stringWithFormat:@"%@", [image objectForKey:@"url_m"]];
    [cellImageView setImageWithURL:[NSURL URLWithString:string]];
    
    return cell;
}

#pragma mark - Collection View Cell Size & Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect screenRectangle = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRectangle.size.width;
    
    // set collection view cell size so that three pictures fit per row
    return CGSizeMake(screenWidth/3, screenWidth/3);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 3.0;
}

#pragma mark - Shuffle NSarray

// Shuffles our array so that we can provide users with random unique photos
- (void)shuffleFlickrArrayAndRefreshCollectionView {
    NSUInteger count = [self.flickrImageResults count];
    if (count < 1) return;
    
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self.flickrImageResults exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    
    [self.collectionView reloadData];
}

#pragma mark - Actions

- (IBAction)refreshDeletePressed:(id)sender {
    [self shuffleFlickrArrayAndRefreshCollectionView];
}
@end
