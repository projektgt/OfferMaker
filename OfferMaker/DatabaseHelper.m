//
//  DatabaseHelper.m
//  OfferMaker
//
//  Created by Robert Povšič on 8. 07. 12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DatabaseHelper.h"

static sqlite3 *databaseInstance;

@implementation DatabaseHelper

@synthesize database;

-(sqlite3 *)database {
    if (databaseInstance == NULL) {
        sqlite3 *newDbConection;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Instabus.sqlite"];
        if (sqlite3_open([path UTF8String], &newDbConection) == SQLITE_OK){
            NSLog(@"Baza uspešno odprta");
            databaseInstance = newDbConection;
        } else {
            NSLog(@"Problem pri odpiranju baze");
            databaseInstance = NULL;
        }
    }
    
    return databaseInstance;
}

+ (NSArray *) query:(NSString *)text {
    NSMutableArray *records = [[NSMutableArray alloc]init];
    
    sqlite3 *db;
    sqlite3_stmt *stmt = nil;
    
    const char *sqlStatement = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Instabus.sqlite"];
    
    
    sqlite3_open([path UTF8String], &db);
    sqlite3_prepare_v2(db, sqlStatement, 1, &stmt, NULL);
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        //[records addObject:sqlite3_column_value(stmt, 0)];
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    
    return [records copy];
}
@end
