//
//  ViewController.m
//  ImagePickerDemo
//
//  Created by Wangjianlong on 16/2/25.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "ViewController.h"
#import "IPickerViewController.h"
#import "IPAssetManager.h"

#import <Photos/Photos.h>

@interface ViewController ()<IPickerViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
/**sdf*/
@property (nonatomic, strong)NSArray *arr;

/**d*/
@property (nonatomic, strong)UIImageView *img1;
@property (nonatomic, strong)UIImageView *img2;
@property (nonatomic, strong)UIImageView *img3;
@property (nonatomic, strong)UIImageView *img4;

@end

@implementation ViewController
static UIViewController *vc;
- (void)viewDidLoad {
    [super viewDidLoad];
   
    _img1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 100, 100)];
    [self.view addSubview:_img1];
    _img2 = [[UIImageView alloc]initWithFrame:CGRectMake(130, 50, 100, 100)];
    [self.view addSubview:_img2];
    _img3 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 170, 100, 100)];
    [self.view addSubview:_img3];
    _img4 = [[UIImageView alloc]initWithFrame:CGRectMake(130, 170, 100, 100)];

    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(100, 64, 100, 100) collectionViewLayout:flow];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.dataSource = self;
    collectionView.delegate   = self;
//    [self.view addSubview:collectionView];
    
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:arc4random_uniform(255)/255.0];
    NSLog(@"cellForItemAtIndexPath%tu",indexPath.item);
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(100, 100);
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didEndDisplayingCell%tu",indexPath.item);

    
}

- (void)pickerVideo:(UIButton *)sender {
    IPickerViewController *ip = [IPickerViewController instanceWithDisplayStyle:IPickerViewControllerDisplayStyleVideo];
    ip.delegate = self;
    ip.maxCount = 9;
    ip.canTakeVideo = YES;
    [self.navigationController pushViewController:ip animated:YES];
}

- (void)popIPicker:(UIButton *)sender{
    IPickerViewController *ip = [IPickerViewController instanceWithDisplayStyle:IPickerViewControllerDisplayStyleImage];
    ip.delegate = self;
    ip.maxCount = 9;
    ip.canTakePhoto = YES;
    [self.navigationController pushViewController:ip animated:YES];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didFinishCaptureVideoUrl:(NSURL *)videourl videoDuration:(float)duration thumbailImage:(NSURL *)thumbailUrl{
    UIImage *thumbnailImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumbailUrl
                                                      ]];
    
    [_img2 setImage:thumbnailImage];
}

- (void)ipicker:(IPickerViewController *)ipicker didClickCancelOrCompleteBtn:(UIButton *)sender
{
    [ipicker.currentSelectAssets enumerateObjectsUsingBlock:^(IPAssetModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@--%@",obj.localIdentiy,obj.assetUrl.absoluteString);
        
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
