//
//  SSViewController.m
//  Calendar
//
//  Created by Shen Steven on 11/12/12.
//  Copyright (c) 2012 syshen. All rights reserved.
//

#import "SSViewController.h"
#import "SSCalendarView.h"

@interface SSViewController () <SSCalendarViewDelegate, SSCalendarViewDatasource>

@property (nonatomic, strong) SSCalendarView *calendarView;

@end

@implementation SSViewController

- (void)viewDidLoad
{
  
  [super viewDidLoad];
  
  [[SSCalendarView appearance] setHeaderBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
  [[SSCalendarView appearance] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cal_background"]]];
  [[SSCalendarView appearance] setTextColor:[UIColor blackColor]];
  self.view.backgroundColor = [UIColor blackColor];
  NSCalendar *cal = [NSCalendar currentCalendar];
  NSDateComponents *since = [[NSDateComponents alloc] init];
  since.year = 2013;
  since.month = 1;
  since.day = 1;
  NSDate *sinceDate = [cal dateFromComponents:since];
  
  NSDateComponents *to = [[NSDateComponents alloc] init];
  to.year = 2013;
  to.month = 12;
  to.day = 1;
  NSDate *toDate = [cal dateFromComponents:to];
  
  self.calendarView = [[SSCalendarView alloc] initWithDateRangeSince:sinceDate to:toDate];
  self.calendarView.delegate = self;
 // SSCalendarMonthView *calendarView = [[SSCalendarMonthView alloc] init];
 // calendarView.date = [NSDate date];
  [self.view addSubview:self.calendarView];
  
}

- (void) dateDidSelected:(NSDate *)date {
  
  NSLog(@"date selected: %@", date);
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger) supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

- (BOOL) shouldAutorotate {
  return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  
  [self.calendarView rotateToInterfaceOrientation:toInterfaceOrientation];
  
}


@end
