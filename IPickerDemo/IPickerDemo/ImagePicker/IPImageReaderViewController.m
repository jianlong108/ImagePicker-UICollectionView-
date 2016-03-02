//
//  IPImageReaderViewController.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPImageReaderViewController.h"
#import "IPZoomScrollView.h"
#import "IPImageModel.h"
#import "IPAlertView.h"

#define IS_Above_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define IOS7_STATUS_BAR_HEGHT (IS_Above_IOS7 ? 20.0f : 0.0f)

@interface IPImageReaderCell : UICollectionViewCell
/**伸缩图*/
@property (nonatomic, strong)IPZoomScrollView *zoomScroll;


@end

@implementation IPImageReaderCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        // Configure the cell
        self.backgroundColor = [UIColor blackColor];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _zoomScroll  = [[IPZoomScrollView alloc]init];
        _zoomScroll.frame = self.bounds;
        [self addSubview:_zoomScroll];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    _zoomScroll.frame = self.bounds;
}

@end


@interface IPImageReaderViewController ()<UICollectionViewDelegateFlowLayout>
/**图片数组*/
@property (nonatomic, strong)NSArray *dataArr;
/**第一次出现时,要滚动到指定位置*/
@property (nonatomic, assign)BOOL isFirst;

/**发生转屏时,要滚动到指定位置*/
@property (nonatomic, assign)BOOL isRoration;
/**需要跳转到指定位置*/
@property (nonatomic, assign)NSUInteger targetIndex;

/**左返回按钮*/
@property (nonatomic, weak)UIButton *leftButton;

/**右返回按钮*/
@property (nonatomic, weak)UIButton *rightButton;

/**头部视图*/
@property (nonatomic, weak)UIImageView *headerView;

/**当前位置*/
@property (nonatomic, assign)NSUInteger currentIndex;

/**旋屏前的位置*/
@property (nonatomic, assign)NSUInteger pageIndexBeforeRotation;

///**itemSize*/
//@property (nonatomic, assign)CGSize itemSize;


@end

@implementation IPImageReaderViewController

static NSString * const reuseIdentifier = @"Cell";
+ (instancetype)imageReaderViewControllerWithData:(NSArray<IPImageModel *> *)data TargetIndex:(NSUInteger)index{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    IPImageReaderViewController *vc = [[IPImageReaderViewController alloc]initWithCollectionViewLayout:flow];
    
    vc.dataArr = [NSArray arrayWithArray:data];
    vc.targetIndex = index;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[IPImageReaderCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self addHeaderView];
    
}
- (void)addHeaderView{
    
    //添加背景图
    UIImageView *headerView = [[UIImageView alloc]init];
    headerView.userInteractionEnabled = YES;
    headerView.image = [UIImage imageNamed:@"photobrowse_top"];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    [leftBtn setImage:[UIImage imageNamed:@"bar_btn_icon_returntext_white"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
    self.leftButton = leftBtn;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [rightBtn setImage:[UIImage imageNamed:@"img_icon_check"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"img_icon_check_p"] forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    self.rightButton = rightBtn;
    
    
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, IOS7_STATUS_BAR_HEGHT + 44);
    self.leftButton.frame = CGRectMake(10, IOS7_STATUS_BAR_HEGHT, 44, 44);
    self.rightButton.frame = CGRectMake(self.view.bounds.size.width - 54, IOS7_STATUS_BAR_HEGHT, 44, 44);
    
    NSUInteger maxIndex = self.dataArr.count - 1;
    NSUInteger minIndex = 0;
    if (self.targetIndex < minIndex) {
        self.targetIndex = minIndex;
    } else if (self.targetIndex > self.targetIndex) {
        self.targetIndex = maxIndex;
    }
    if (!self.isFirst) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.targetIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        self.isFirst = YES;
    }
    if (self.isRoration) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        self.isRoration = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    NSLog(@"IPImageReaderViewController---dealloc");
}
- (void)cancle{
    if (self.dismissBlock) {
        self.dismissBlock();
    }
  [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)selectBtn:(UIButton *)btn{
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        if (self.currentCount == self.maxCount) {
            [IPAlertView showAlertViewAt:self.view MaxCount:self.maxCount];
            btn.selected = NO;
            return;
        }
        self.currentCount ++;
    }else {
        self.currentCount --;
    }
    
    NSArray *arr = self.collectionView.indexPathsForVisibleItems;
    if (arr && arr.count > 0) {
        NSIndexPath *path = [arr firstObject];
        IPImageModel *model = self.dataArr[path.item];
        model.isSelect = btn.selected;
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickSelectBtnForReaderView:)]) {
            [self.delegate clickSelectBtnForReaderView:model];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Remember page index before rotation
    _pageIndexBeforeRotation = _currentIndex;
    
    
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Perform layout
    _currentIndex = _pageIndexBeforeRotation;
    self.isRoration = YES;
    
    IPImageModel *model = self.dataArr[_currentIndex];
    self.rightButton.selected = model.isSelect;
    
    [self.collectionView reloadData];
    
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    self.isRoration = NO;
    
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IPImageReaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    IPImageModel *model = [self.dataArr objectAtIndex:indexPath.item];
    cell.zoomScroll.imageModel = model;
   
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return self.view.bounds.size;
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(IPImageReaderCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [cell.zoomScroll prepareForReuse];
    
}
#pragma mark <UICollectionViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.isRoration) {
        return;
    }
    CGRect visibleBounds = scrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self.dataArr count] - 1) index = [self.dataArr count] - 1;
    NSUInteger previousCurrentPage = _currentIndex;
    _currentIndex = index;
    if (_currentIndex != previousCurrentPage) {
        IPImageModel *model = self.dataArr[_currentIndex];
        self.rightButton.selected = model.isSelect;
    }
    
}


@end
