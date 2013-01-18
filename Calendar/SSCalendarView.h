//
//  SSCalendarView.h
//  Calendar
//
//  Created by Shen Steven on 11/12/12.
//  Copyright (c) 2012 syshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSCalendarViewDelegate <NSObject>

- (void) dateDidSelected:(NSDate*) date;

@end

@protocol SSCalendarViewDatasource <NSObject>

@optional
- (NSArray *) highlightedDatesForCalendar;

@optional
- (NSArray *) highlightedDatesForCalendarMonth:(NSDate *)monthYear;

@end

@interface SSCalendarView : UIView

@property (nonatomic, assign) BOOL beginsWithSunday;

@property (nonatomic, strong) UIColor *headerBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *highlightedTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) id datasource;

- (id)initWithDateRangeSince:(NSDate*) startDate to:(NSDate*)endDate;
- (void) rotateToInterfaceOrientation:(UIInterfaceOrientation)orietantion;

@end
