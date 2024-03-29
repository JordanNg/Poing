//
//  AADataLoader.m
//  Poing
//
//  Created by Kyle Oba on 12/14/13.
//  Copyright (c) 2013 AgencyAgency. All rights reserved.
//

#import "AAScheduleLoader.h"
#import "Bell+Create.h"
#import "Cycle+Create.h"
#import "Period+Create.h"
#import "SchoolDay+Create.h"
#import "BellCyclePeriod+Create.h"
#import <CoreData/CoreData.h>

#define BELL_ASSEMBLY_1 @"Assembly 1 Schedule"
#define BELL_ASSEMBLY_2 @"Assembly 2 Schedule"
#define BELL_ASSEMBLY_3 @"Assembly 3 Schedule"
#define BELL_BASIC @"Basic Schedule"
#define BELL_CHAPEL @"Chapel Schedule"
#define BELL_EXTENDED_1_1357 @"Extended 1 Schedule 1357"
#define BELL_EXTENDED_1_2468 @"Extended 1 Schedule 2468"
#define BELL_EXTENDED_2_7153 @"Extended 2 Schedule 7153"
#define BELL_EXTENDED_2_8264 @"Extended 2 Schedule 8264"
#define BELL_EXTENDED_3_3751 @"Extended 3 Schedule 3751"
#define BELL_EXTENDED_3_4862 @"Extended 3 Schedule 4862"
#define BELL_SPECIAL_CONVOCATION @"Special Convocation Schedule"
#define BELL_SPECIAL_FAIR_DAY @"Special Fair Day Schedule"
#define BELL_SPECIAL_MAY_DAY @"Special May Day Schedule"
#define BELL_VARSITY_ATHLETIC_ASSEMBLY @"VarietyAthletic Assembly Schedule"

#define CYCLE_1 @"1"
#define CYCLE_3 @"3"
#define CYCLE_7 @"7"

#define PERIOD_HOME_ROOM @"Home Room"
#define PERIOD_1 @"1"
#define PERIOD_2 @"2"
#define PERIOD_3 @"3"
#define PERIOD_4 @"4"
#define PERIOD_5 @"5"
#define PERIOD_6 @"6"
#define PERIOD_7 @"7"
#define PERIOD_8 @"8"
#define PERIOD_ASSEMBLY @"Assembly"
#define PERIOD_CHAPEL   @"Chapel"
#define PERIOD_LUNCH    @"Lunch"
#define PERIOD_MEETING  @"Meeting"

@implementation AAScheduleLoader

+ (void)loadScheduleDataWithContext:(NSManagedObjectContext *)context
{
    // Parse schedule:
    [self loadScheduleJSONIntoContext:context];
    
    // Test data load:
    [self verifyBellsCyclesPeriodsWithContext:context];
    
    // Load period times:
    [self loadBellCyclePeriodDataIntoContext:context];
}

+ (void)verifyBellsCyclesPeriodsWithContext:(NSManagedObjectContext *)context
{
    // Test and load bells:
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Bell"];
    NSError *error;
    NSArray *bells = [context executeFetchRequest:request error:&error];
    NSAssert(!error, @"error loading bell data");
    NSLog(@"Bells count: %i", [bells count]);
    
    // Test and load cycles:
    request = [NSFetchRequest fetchRequestWithEntityName:@"Cycle"];
    NSArray *cycles = [context executeFetchRequest:request error:&error];
    NSAssert(!error, @"error loading cycle data");
    NSLog(@"Cycles count: %i", [cycles count]);
    
    // Test and load periods:
    request = [NSFetchRequest fetchRequestWithEntityName:@"Period"];
    NSArray *periods = [context executeFetchRequest:request error:&error];
    NSAssert(!error, @"error loading period data");
    NSLog(@"Cycles count: %i", [periods count]);
}


#pragma mark - JSON Schedule Data Load

+ (void)loadScheduleJSONIntoContext:(NSManagedObjectContext *)context
{
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"schedule"
                                                         ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSArray *schedule = [NSJSONSerialization JSONObjectWithData:jsonData
                                              options:kNilOptions
                                                error:&error];
    if (!error) {
        for (NSDictionary *schoolDayInfo in schedule) {
            [SchoolDay schoolDayWithDayString:schoolDayInfo[@"day"]
                                     bellName:schoolDayInfo[@"title"]
                                    cycleName:[NSString stringWithFormat:@"%@", schoolDayInfo[@"cycle"]]
                       inManagedObjectContext:context];
        }
    } else {
        NSAssert(NO, @"Could not parse JSON schedule.");
    }
}


#pragma mark - Load Bell Cycle Period Data

+ (void)loadBellName:(NSString *)bellName
           cycleName:(NSString *)cycleName
             periods:(NSArray*)periods
               times:(NSArray *)times
intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (int i=0; i<[periods count]; i++) {
        [BellCyclePeriod bellCyclePeriodWithBellName:bellName
                                           cycleName:cycleName
                                          periodName:periods[i]
                                     startTimeString:times[i][@"start"]
                                       endTimeString:times[i][@"end"]
                              inManagedObjectContext:context];
    }
}

+ (void)loadBellCyclePeriodDataIntoContext:(NSManagedObjectContext *)context
{
    [self loadBasicPeriodDataIntoContext:context];
    [self loadChapelPeriodDataIntoContext:context];
}

+ (void)loadBasicPeriodDataIntoContext:(NSManagedObjectContext *)context
{
    NSString *bellType = BELL_BASIC;
    NSArray *periods = nil;
    
    // BASIC - CYCLE 1
    NSArray *times = @[@{@"start": @"07:40", @"end": @"07:45"},
                       @{@"start": @"07:50", @"end": @"08:34"},
                       @{@"start": @"08:39", @"end": @"09:23"},
                       @{@"start": @"09:28", @"end": @"10:12"},
                       @{@"start": @"10:17", @"end": @"11:01"},
                       @{@"start": @"11:06", @"end": @"11:50"},
                       @{@"start": @"11:50", @"end": @"12:33"},
                       @{@"start": @"12:38", @"end": @"13:22"},
                       @{@"start": @"13:27", @"end": @"14:11"},
                       @{@"start": @"14:16", @"end": @"15:00"}];
    periods = @[PERIOD_HOME_ROOM,
                PERIOD_1,
                PERIOD_2,
                PERIOD_3,
                PERIOD_4,
                PERIOD_5,
                PERIOD_LUNCH,
                PERIOD_6,
                PERIOD_7,
                PERIOD_8];
    [self loadBellName:bellType
             cycleName:CYCLE_1
               periods:periods
                 times:times intoManagedObjectContext:context];
    
    // BASIC - CYCLE 7
    periods = @[PERIOD_HOME_ROOM,
                PERIOD_7,
                PERIOD_8,
                PERIOD_1,
                PERIOD_2,
                PERIOD_5,
                PERIOD_LUNCH,
                PERIOD_6,    
                PERIOD_3,    
                PERIOD_4];
    [self loadBellName:bellType
             cycleName:CYCLE_7
               periods:periods
                 times:times intoManagedObjectContext:context];
    
    // BASIC - CYCLE 3
    periods = @[PERIOD_HOME_ROOM,
                PERIOD_3,
                PERIOD_4,
                PERIOD_7,
                PERIOD_8,
                PERIOD_5,
                PERIOD_LUNCH,
                PERIOD_6,    
                PERIOD_1,
                PERIOD_2];
    [self loadBellName:bellType
             cycleName:CYCLE_3
               periods:periods
                 times:times intoManagedObjectContext:context];
}

+ (void)loadChapelPeriodDataIntoContext:(NSManagedObjectContext *)context
{
    NSString *bellType = BELL_CHAPEL;
    NSArray *periods = nil;
    
    // CHAPEL - CYCLE 1
    NSArray *times = @[@{@"start": @"07:40", @"end": @"07:45"},
                       @{@"start": @"07:50", @"end": @"08:09"},
                       @{@"start": @"08:14", @"end": @"08:55"},
                       @{@"start": @"09:00", @"end": @"09:41"},
                       @{@"start": @"09:46", @"end": @"10:27"},
                       @{@"start": @"10:32", @"end": @"11:13"},
                       @{@"start": @"11:18", @"end": @"11:59"},
                       @{@"start": @"11:59", @"end": @"12:42"},
                       @{@"start": @"12:47", @"end": @"13:28"},
                       @{@"start": @"13:33", @"end": @"14:14"},
                       @{@"start": @"14:19", @"end": @"15:00"}];
    periods = @[PERIOD_HOME_ROOM,
                PERIOD_CHAPEL,
                PERIOD_1,
                PERIOD_2,
                PERIOD_3,
                PERIOD_4,
                PERIOD_5,
                PERIOD_LUNCH,
                PERIOD_6,
                PERIOD_7,
                PERIOD_8];
    [self loadBellName:bellType
             cycleName:CYCLE_1
               periods:periods
                 times:times intoManagedObjectContext:context];
    
    // CHAPEL - CYCLE 7
    periods = @[PERIOD_HOME_ROOM,
                PERIOD_CHAPEL,
                PERIOD_7,
                PERIOD_8,
                PERIOD_1,
                PERIOD_2,
                PERIOD_5,
                PERIOD_LUNCH,
                PERIOD_6,
                PERIOD_3,
                PERIOD_4];
    [self loadBellName:bellType
             cycleName:CYCLE_7
               periods:periods
                 times:times intoManagedObjectContext:context];
    
    // CHAPEL - CYCLE 3
    periods = @[PERIOD_HOME_ROOM,
                PERIOD_CHAPEL,
                PERIOD_3,
                PERIOD_4,
                PERIOD_7,
                PERIOD_8,
                PERIOD_5,
                PERIOD_LUNCH,
                PERIOD_6,
                PERIOD_1,
                PERIOD_2];
    [self loadBellName:bellType
             cycleName:CYCLE_3
               periods:periods
                 times:times intoManagedObjectContext:context];
}


@end
