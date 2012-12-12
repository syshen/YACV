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

@end

@implementation SSViewController

- (void)viewDidLoad
{
  
  [super viewDidLoad];
  
  [[SSCalendarView appearance] setHeaderBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
  [[SSCalendarView appearance] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cal_background"]]];
  [[SSCalendarView appearance] setTextColor:[UIColor blackColor]];
  
  NSCalendar *cal = [NSCalendar currentCalendar];
  NSDateComponents *since = [[NSDateComponents alloc] init];
  since.year = 2005;
  since.month = 6;
  since.day = 12;
  NSDate *sinceDate = [cal dateFromComponents:since];
  
  NSDateComponents *to = [[NSDateComponents alloc] init];
  to.year = 2012;
  to.month = 12;
  to.day = 5;
  NSDate *toDate = [cal dateFromComponents:to];
  
  NSLog(@"%@", sinceDate);
  NSLog(@"%@", toDate);
  SSCalendarView *calendarView = [[SSCalendarView alloc] initWithDateRangeSince:sinceDate to:toDate];
  calendarView.delegate = self;
 // SSCalendarMonthView *calendarView = [[SSCalendarMonthView alloc] init];
 // calendarView.date = [NSDate date];
  [self.view addSubview:calendarView];
  
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
  return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotate {
  return NO;
}

@end
