//
//  SSCalendarView.m
//  Calendar
//
//  Created by Shen Steven on 11/12/12.
//  Copyright (c) 2012 syshen. All rights reserved.
//

#import "SSCalendarView.h"

#pragma mark - Collection View Layouts

@interface SSCalendarLayout : UICollectionViewLayout

@property (nonatomic, assign) CGSize headerReferenceSize;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, strong) NSArray *sectionRects;
@property (nonatomic, assign) NSUInteger pageNumber;

@end

@implementation SSCalendarLayout

- (void) prepareLayout {
  
  [super prepareLayout];
  
  self.pageNumber = [self.collectionView numberOfSections];

  NSMutableArray *rects = [NSMutableArray array];
  for (int section = 0; section < self.pageNumber; section ++) {
    [rects addObject:[NSValue valueWithCGRect:(CGRect){ CGPointMake(self.collectionView.frame.size.width * section, 0), self.collectionView.frame.size } ]];
  }
  
  self.sectionRects = [NSArray arrayWithArray:rects];
  
}

- (CGSize) collectionViewContentSize {
  
  int pageNumber = [self.collectionView numberOfSections];
  
  return CGSizeMake(self.collectionView.frame.size.width * pageNumber, self.collectionView.frame.size.height);
  
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  
  return NO;

}

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
  
  __weak SSCalendarLayout *wSelf = self;
  NSMutableArray *filledAttributes = [NSMutableArray array];
  [self.sectionRects enumerateObjectsUsingBlock:^(NSValue *val, NSUInteger idx, BOOL *stop) {
    CGRect sectionRect = [val CGRectValue];
    
    if (CGRectIntersectsRect(sectionRect, rect)) {
      
      int cellNumber = [wSelf.collectionView numberOfItemsInSection:idx];
      
      for (int i = 0; i < cellNumber; i++) {
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:idx]];
        
        [filledAttributes addObject:attr];
        
      }
      
      // header
      [filledAttributes addObject: [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx]]];
      
    }
  }];
  
  return [NSArray arrayWithArray:filledAttributes];
  
}

- (UICollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

  attr.size = self.itemSize;
  CGFloat x = (indexPath.row % 7) * (attr.frame.size.width + 1) + ((indexPath.section) * self.collectionView.frame.size.width );
  CGFloat y =  (indexPath.row / 7) * (attr.frame.size.height + 1) + self.headerReferenceSize.height;
  attr.frame = (CGRect){ CGPointMake(x, y), attr.frame.size };

  return attr;
  
}

- (UICollectionViewLayoutAttributes *) layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
  
  UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
  
  attr.size = self.headerReferenceSize;
  CGFloat x = indexPath.section * self.collectionView.frame.size.width;
  CGFloat y = 0;
  attr.frame = (CGRect){ CGPointMake(x, y), self.collectionView.frame.size };
  return  attr;
  
}


- (CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {

  int closestPage = roundf(proposedContentOffset.x / self.collectionView.frame.size.width);
  if (closestPage < 0)
    closestPage = 0;
  
  return CGPointMake(closestPage * self.collectionView.frame.size.width, proposedContentOffset.y);

}

@end


@interface SSCalendarLineLayout : UICollectionViewFlowLayout

@end

@implementation SSCalendarLineLayout

- (id) init {
  
  self = [super init];
  if (self) {
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
  }
  return self;
  
}

- (CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
  
  int closestPage = roundf(proposedContentOffset.x / self.collectionView.frame.size.width);
  if (closestPage < 0)
    closestPage = 0;
  
  return CGPointMake(closestPage * self.collectionView.frame.size.width, proposedContentOffset.y);
  
}


@end

@interface SSCalendarDecoFlowLayout : UICollectionViewFlowLayout

@end
@implementation SSCalendarDecoFlowLayout

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {

  UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
  attr.frame = CGRectMake(0, self.headerReferenceSize.height, self.collectionViewContentSize.width, self.collectionViewContentSize.height - self.headerReferenceSize.height);
  return attr;

}

- (NSArray*) layoutAttributesForElementsInRect:(CGRect)rect {
  NSMutableArray *attrs = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
  
  UICollectionViewLayoutAttributes *decoAttr = [self layoutAttributesForDecorationViewOfKind:@"backgroundView" atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  [attrs addObject:decoAttr];
  
  return [NSArray arrayWithArray:attrs];
}
@end

@interface SSCalendarCoverFlowLayout : UICollectionViewFlowLayout

@end

@implementation SSCalendarCoverFlowLayout

- (id) init {
  
  self = [super init];
  if (self) {
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = -51.0f;
    self.minimumInteritemSpacing = 200;
    
    self.sectionInset = UIEdgeInsetsMake(0, 35, 0, 35);
  }
  
  return self;
  
}

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
  
  NSArray *array = [super layoutAttributesForElementsInRect:rect];
  for (UICollectionViewLayoutAttributes *attr in array) {
    if (attr.representedElementCategory == UICollectionElementCategoryCell) {
      if (CGRectIntersectsRect(rect, attr.frame)) {
        [self setAttributes:attr];
      }
    }
  }
  return array;
  
}

- (UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {

  UICollectionViewLayoutAttributes *attr = [super layoutAttributesForItemAtIndexPath:indexPath];
  [self setAttributes:attr];
  
  return attr;
}

#define ACTIVE_DISTANCE 100
#define TRANSLATE_DISTANCE 100
#define ZOOM_FACTOR 0.3
#define FLOW_OFFSET 40

- (void) setAttributes:(UICollectionViewLayoutAttributes*) attributes {
  
  CGRect visibleRect ;
  visibleRect.origin = self.collectionView.contentOffset;
  visibleRect.size = self.collectionView.bounds.size;
  
  CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
  CGFloat normalizedDistance = distance / ACTIVE_DISTANCE;
  BOOL isLeft = distance > 0;
  CATransform3D transform = CATransform3DIdentity;
  transform.m34 = -1/(4.6777 * self.itemSize.width);
  
  if (ABS(distance) < ACTIVE_DISTANCE)
  {
    if (ABS(distance) < TRANSLATE_DISTANCE)
    {
      transform = CATransform3DTranslate(CATransform3DIdentity, (isLeft? - FLOW_OFFSET : FLOW_OFFSET)*ABS(distance/TRANSLATE_DISTANCE), 0, (1 - ABS(normalizedDistance)) * 40000 + (isLeft? 200 : 0));

    }
    else
    {
      transform = CATransform3DTranslate(CATransform3DIdentity, (isLeft?  - FLOW_OFFSET : FLOW_OFFSET), 0, (1 - ABS(normalizedDistance)) * 40000 + (isLeft? 200 : 0));
    }
    transform.m34 = -1/(4.6777 * self.itemSize.width);
    CGFloat zoom = 1 + ZOOM_FACTOR*(1 - ABS(normalizedDistance)); 
    transform = CATransform3DRotate(transform, (isLeft? -1 : 1) * ABS(normalizedDistance) * 45 * M_PI / 180, 0, 1, 0);
    transform = CATransform3DScale(transform, zoom, zoom, 1);
    attributes.zIndex = 1;//ABS(ACTIVE_DISTANCE - ABS(distance)) + 1;
  }
  else
  {
    transform = CATransform3DTranslate(transform, isLeft? -FLOW_OFFSET : FLOW_OFFSET, 0, 0);
    transform = CATransform3DRotate(transform, (isLeft? -1 : 1) * 45 * M_PI / 180, 0, 1, 0);
    attributes.zIndex = 0;
  }
  attributes.transform3D = transform;

}

- (CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
  
  CGFloat offsetAdjustment = MAXFLOAT;
  CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
  
  CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
  NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
  
  for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
    if (layoutAttributes.representedElementCategory != UICollectionElementCategoryCell)
      continue; // skip headers
    
    CGFloat itemHorizontalCenter = layoutAttributes.center.x;
    if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
      offsetAdjustment = itemHorizontalCenter - horizontalCenter;
    }
  }
  return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);

}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  return YES;
}

@end

#pragma mark - Collection View Cell

@interface SSCalendarDayCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UIImage *backgroundImage;

@end

@implementation SSCalendarDayCell

- (id) initWithFrame:(CGRect)frame {
  
  self = [super initWithFrame:frame];
  if (self) {

    self.dayLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
    self.dayLabel.textAlignment = NSTextAlignmentCenter;
    self.dayLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.dayLabel];
  }
  return self;
  
}

@end

@interface SSCalendarHeaderView : UICollectionReusableView

@end

@implementation SSCalendarHeaderView


@end

@interface SSCalendarDecoView : UICollectionReusableView

@end

@implementation SSCalendarDecoView

- (id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  
  if (self) {
    self.backgroundColor = [UIColor clearColor];
  }
  
  return self;
}

- (void) drawRect:(CGRect)rect {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, [UIColor colorWithRed:193/255.0 green:193/255.0 blue:193/255.0 alpha:1].CGColor);
  
  CGFloat w = (rect.size.width - 8) / 7;
  for (int i = 0; i < 8; i++) {
    CGContextAddRect(context, CGRectMake(i * (w+1), 0, 1, rect.size.height));
  }
  
  for (int i = 0; i < 6; i++) {
    CGContextAddRect(context, CGRectMake(0, i * (w), rect.size.width, 1));
  }
  
  CGContextFillPath(context);

}

@end

@interface SSCalendarMonthView : UIView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) id datasource;

@property (nonatomic, strong) UIColor *headerBackgroundColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UICollectionView *calendarGrids;
@property (nonatomic, assign) NSUInteger firstDayInWeek;
@property (nonatomic, assign) BOOL beginsWithSunday;
@property (nonatomic, assign) CGSize itemSize;

@end

@implementation SSCalendarMonthView

- (id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.beginsWithSunday = YES;
    
    self.headerBackgroundColor = [UIColor whiteColor];
    self.textColor = [UIColor blackColor];
    
    int w = (int)(frame.size.width / 7);
    self.itemSize = CGSizeMake(w, w);
    
    SSCalendarDecoFlowLayout *flowlayout = [[SSCalendarDecoFlowLayout alloc] init];
    flowlayout.itemSize = self.itemSize;
    flowlayout.headerReferenceSize = CGSizeMake(self.frame.size.width, w);
    flowlayout.minimumInteritemSpacing = 0;
    flowlayout.minimumLineSpacing = 0;
    [flowlayout registerClass:[SSCalendarDecoView class] forDecorationViewOfKind:@"backgroundView"];

    CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.calendarGrids = [[UICollectionView alloc] initWithFrame:rect
                                            collectionViewLayout:flowlayout];
    self.calendarGrids.delegate = self;
    self.calendarGrids.dataSource = self;
    
    self.calendarGrids.alwaysBounceVertical = NO;
    self.calendarGrids.alwaysBounceHorizontal = NO;
    self.calendarGrids.bounces = NO;
    self.calendarGrids.allowsSelection = YES;
    self.calendarGrids.backgroundColor = [UIColor whiteColor];
    
    [self.calendarGrids registerClass:[SSCalendarDayCell class]
           forCellWithReuseIdentifier:@"CalendarDayCell"];
    [self.calendarGrids registerClass:[SSCalendarHeaderView class]
           forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                  withReuseIdentifier:@"calendarHeaderView"];
    
    [self addSubview:self.calendarGrids];
    
    
  }
  return self;

}

- (void) setDate:(NSDate *)date {
  
  _date = date;

  
  [self.calendarGrids reloadData];
  
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dcomp = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.date];
    dcomp.day = indexPath.row - self.firstDayInWeek + 1;
    
    return [cal dateFromComponents:dcomp];
}

- (NSInteger)numberOfCalendarItemsForIndexPath:(NSIndexPath *)indexPath {
    NSInteger items = 0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(highlightedDatesForCalendar)]) {
        
        NSArray *highlightedDates = [self.delegate performSelector:@selector(highlightedDatesForCalendar)];
        NSDate *dateForRow = [self dateForIndexPath:indexPath];
        
        NSDate *begin = dateForRow;
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&begin interval:NULL forDate:begin];
        NSDateComponents *oneDay = [[NSDateComponents alloc] init];
        [oneDay setDay:1];
        NSDate *end = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay toDate:begin options:0];
        
        NSArray *matches = [highlightedDates filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF >= %@) AND (SELF <= %@)", begin, end]];
        items = matches.count;
    }
    
    return items;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  
  return 1;
  
}


- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

  static NSDateFormatter *formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.dateFormat = @"YYYY / MMM";
  }
  
  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    
    SSCalendarHeaderView *weekdaysView = (SSCalendarHeaderView*)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"calendarHeaderView" forIndexPath:indexPath];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, {self.frame.size.width, self.itemSize.height/2}}];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *comps_since = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self.date];
    comps_since.month += indexPath.row;
    
    NSDate *date = [cal dateFromComponents:comps_since];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [formatter stringFromDate:date];
    label.backgroundColor = self.headerBackgroundColor;
    label.textColor = self.textColor;
    [weekdaysView addSubview:label];

    int start = 0;
    if (!self.beginsWithSunday)
      start = 1;
    
    for (int i = start; i < (7+start); i++) {
      
      UILabel *wday = [[UILabel alloc] initWithFrame:(CGRect){(CGPoint){self.itemSize.width * i, self.itemSize.height/2}, (CGSize){self.itemSize.width, self.itemSize.height/2}}];
      
      if (self.itemSize.width > 30) {
        wday.text = ([formatter shortWeekdaySymbols])[i];
        wday.font = [UIFont systemFontOfSize:12];
      } else {
        wday.text = ([formatter veryShortWeekdaySymbols])[i];
        wday.font = [UIFont systemFontOfSize:10];
      }
      
      wday.textAlignment = NSTextAlignmentCenter;
      wday.backgroundColor = self.headerBackgroundColor;
      wday.textColor = self.textColor;
      
      [weekdaysView addSubview:wday];
    }
    weekdaysView.backgroundColor = self.headerBackgroundColor;
    
    return weekdaysView;
    
  } 
  
  return nil;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  
  if(!self.date)
    return 0;
  
  NSCalendar *cal = [NSCalendar currentCalendar];
  
  NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:self.date];

  if (self.beginsWithSunday)
    self.firstDayInWeek = comps.weekday - 1;
  else
    self.firstDayInWeek = comps.weekday == 1 ? 6 : (comps.weekday - 2);
  
  NSRange days = [cal rangeOfUnit:NSDayCalendarUnit
                           inUnit:NSMonthCalendarUnit
                          forDate:self.date];
  
  return days.length + self.firstDayInWeek;
  
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  SSCalendarDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarDayCell" forIndexPath:indexPath];
  
  int row = indexPath.row;
  
  if (row < self.firstDayInWeek) {
    cell.dayLabel.text = @" ";
  } else {
    cell.dayLabel.text = [NSString stringWithFormat:@"%d", (row - self.firstDayInWeek + 1)];
  }
  cell.backgroundColor = self.backgroundColor;
  cell.dayLabel.textColor = self.textColor;
  
  if (cell.frame.size.width > 30)
    cell.dayLabel.font = [UIFont systemFontOfSize:14];
  else if (cell.frame.size.width >20)
    cell.dayLabel.font = [UIFont systemFontOfSize:12];
  else
    cell.dayLabel.font = [UIFont systemFontOfSize:10];
    
    NSInteger numCalendarItems = [self numberOfCalendarItemsForIndexPath:indexPath];
    if (numCalendarItems > 0) {
        // do something, e.g. add another label/image to the cell
    }
  
  return cell;
  
}


#pragma mark - UICollectionViewDelegate
- (void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

  NSDate *selectedDate = [self dateForIndexPath:indexPath];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(dateDidSelected:)]) {
    [self.delegate performSelector:@selector(dateDidSelected:) withObject:selectedDate];
  }
  
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  
  if([keyPath isEqualToString:@"delegate"]) {

    self.delegate = [change objectForKey:NSKeyValueChangeNewKey];
    
  } else if ([keyPath isEqualToString:@"datasource"]) {
    
    self.datasource = [change objectForKey:NSKeyValueChangeNewKey];
    
  }
}


@end

@interface SSCalendarMonthCell : UICollectionViewCell

@property (nonatomic, strong) SSCalendarMonthView *monthView;

@end

@implementation SSCalendarMonthCell

- (id) initWithFrame:(CGRect)frame {
  
  self = [super initWithFrame:frame];
  if (self) {
    
    CGRect newFrame = (CGRect){ CGPointZero, frame.size };
    self.monthView = [[SSCalendarMonthView alloc] initWithFrame:newFrame];
    [self.contentView addSubview:self.monthView];
    
  }
  return self;
  
}

@end

@interface SSCalendarView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UICollectionView *monthFlow;
@property (nonatomic, strong) NSDate *today;
@property (nonatomic, strong) NSDate *currentDisplayDate;
@property (nonatomic, strong) NSDate *sinceDate;
@property (nonatomic, strong) NSDate *endDate;

@end

@implementation SSCalendarView {
  NSString *cellIdentifier;
}

- (id)initWithFrame:(CGRect)frame
{
  
  self = [super initWithFrame:frame];
  if (self) {
    
    self.beginsWithSunday = NO;
    
    SSCalendarLineLayout *flowlayout = [[SSCalendarLineLayout alloc] init];
    cellIdentifier = @"SSCalendarMonthCell-line";
    
    CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
    flowlayout.itemSize = rect.size;

    self.monthFlow = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:flowlayout];
    self.monthFlow.delegate = self;
    self.monthFlow.dataSource = self;
    
    self.monthFlow.alwaysBounceHorizontal = NO;
    self.monthFlow.alwaysBounceVertical = NO;
    self.monthFlow.allowsMultipleSelection = NO;
    self.monthFlow.allowsSelection = NO;
    
    [self.monthFlow registerClass:[SSCalendarMonthCell class] forCellWithReuseIdentifier:@"SSCalendarMonthCell-line"];
    [self.monthFlow registerClass:[SSCalendarMonthCell class] forCellWithReuseIdentifier:@"SSCalendarMonthCell-coverflow"];

    NSUInteger numOfPages = [self.monthFlow numberOfItemsInSection:0];
    
    [self.monthFlow scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:numOfPages-1 inSection:0]
                           atScrollPosition:UICollectionViewScrollPositionRight
                                   animated:NO];
    
    [self addSubview:self.monthFlow];
    
  }
  
  return self;
  
}

- (void) rotateToInterfaceOrientation:(UIInterfaceOrientation)orietantion {
  CGFloat width = [[UIScreen mainScreen] bounds].size.width;
  CGFloat height = [[UIScreen mainScreen] bounds].size.height;

  
  if (UIInterfaceOrientationIsLandscape(orietantion)) {
    self.monthFlow.frame = CGRectMake(0, 0, height, width);
    
    SSCalendarLineLayout *layout = (SSCalendarLineLayout*) self.monthFlow.collectionViewLayout;
  
    SSCalendarCoverFlowLayout *newLayout = [[SSCalendarCoverFlowLayout alloc] init];
    layout.itemSize = newLayout.itemSize = (CGSize)CGSizeMake(220, 220);
    [layout invalidateLayout];
    cellIdentifier = @"SSCalendarMonthCell-coverflow";
  
    [self.monthFlow setCollectionViewLayout:newLayout animated:YES];
    
  } else {
    self.monthFlow.frame = CGRectMake(0, 0, width, height);
    
    SSCalendarCoverFlowLayout *layout = (SSCalendarCoverFlowLayout*) self.monthFlow.collectionViewLayout;
    
    SSCalendarLineLayout *newLayout = [[SSCalendarLineLayout alloc] init];
    layout.itemSize = newLayout.itemSize = self.monthFlow.frame.size;
    cellIdentifier = @"SSCalendarMonthCell-line";
  
    [layout invalidateLayout];
    
    [self.monthFlow setCollectionViewLayout:newLayout animated:YES];

  }
  
  [self.monthFlow reloadData];
  
}

- (id)initWithDateRangeSince:(NSDate*)startDate to:(NSDate*)endDate {
  
  self.sinceDate = startDate;
  self.endDate = endDate;
  self.today = [NSDate date];
  
  NSAssert((NSOrderedDescending == [endDate compare:startDate]), @"The ending date should be later then start of the date.");
  
  CGFloat width = [[UIScreen mainScreen] bounds].size.width;
  CGFloat height = [[UIScreen mainScreen] bounds].size.height;
  return [self initWithFrame:(CGRect){CGPointZero, (CGSize){width,height}}];
  
}

- (void) setBeginsWithSunday:(BOOL)beginsWithSunday {
  
  if (_beginsWithSunday != beginsWithSunday) {
    _beginsWithSunday = beginsWithSunday;
    [self.monthFlow.collectionViewLayout invalidateLayout];
  }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

  return 1;

}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

  if (!self.sinceDate || !self.endDate)
    return 0;
  
  NSCalendar *cal = [NSCalendar currentCalendar];
  
  NSDateComponents *comps_since = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self.sinceDate];
  NSDateComponents *comps_end = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self.endDate];
  
  NSUInteger total_month = 0;
  if (comps_end.year > comps_since.year)
    total_month = (comps_end.year - comps_since.year) * 12;
    
  total_month += comps_end.month - comps_since.month + 1;
  
  return total_month;

}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

  SSCalendarMonthCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                        forIndexPath:indexPath];
  

  NSCalendar *cal = [NSCalendar currentCalendar];

  NSDateComponents *comps_since = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self.sinceDate];
  comps_since.month += indexPath.row;
  
  cell.monthView.date = [cal dateFromComponents:comps_since];
  
  cell.monthView.calendarGrids.backgroundColor = self.backgroundColor;
  cell.monthView.headerBackgroundColor = self.headerBackgroundColor;
  cell.monthView.textColor = self.textColor;
  
  [self addObserver:cell.monthView forKeyPath:@"delegate"
            options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
            context:NULL];
  [self addObserver:cell.monthView forKeyPath:@"datasource"
            options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
            context:NULL];
  
  return cell;
  
}


#pragma mark - UICollectionViewDelegate
- (void) collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
  
  SSCalendarMonthCell *mCell = (SSCalendarMonthCell*)cell;
  [self removeObserver:mCell.monthView forKeyPath:@"delegate"];
  [self removeObserver:mCell.monthView forKeyPath:@"datasource"];
  
}


@end
