//
//  DatabaseHelper.m
//  OfferMaker
//
//  Created by Robert Povšič on 8. 07. 12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DatabaseHelper.h"

@implementation DatabaseHelper {
    sqlite3 *db;
    NSString *dbName;
}

-(BOOL)openDatabaseConnection {
    if (db == nil) {
        sqlite3 *newDbConection;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:dbName];
        if (sqlite3_open([path UTF8String], &newDbConection) == SQLITE_OK){
            NSLog(@"Baza uspešno odprta");
            db = newDbConection;
            return YES;
        } else {
            NSString *errorString = [NSString stringWithCString:sqlite3_errmsg(db) encoding:NSUTF8StringEncoding];
            NSLog(@"Povezava z bazo ni uspela: %@", errorString);
            db = nil;
            return NO;
        }
    }
    return YES;
}

/**
 * Designated initializer
 */
- (id) initWithDatabaseName:(NSString *)databaseName {
    self = [super init];
    dbName = databaseName;
    return self;
}

- (NSArray *) rawQuery:(NSString *)text {
    NSMutableArray *records = [[NSMutableArray alloc]init];

    sqlite3_stmt *stmt = nil;
    
    //Odpiranje baze
    if (![ self openDatabaseConnection]) {
        return nil;
    }
    
    //Pripravimo SQL stavek
    if (sqlite3_prepare_v2(db, [text UTF8String], -1, &stmt, NULL) == SQLITE_ERROR) {
        NSString *errorString = [NSString stringWithCString:sqlite3_errmsg(db) encoding:NSUTF8StringEncoding];
		NSLog(@"Napaka pri sqlite3_prepare_v2(): %@", errorString);
        return nil;
    }
    
    //Pregledamo vsako vrstico in stolpec v vrstici
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        int columnLength = sqlite3_column_count(stmt);
        NSLog(@"columnLength = %i", columnLength);
        
        //Pripravimo array v katerega bomo zapisovali prebrane vrednosti stolpca
        NSMutableDictionary *columnItems = [[NSMutableDictionary alloc]initWithCapacity:columnLength];
        
        // Dodamo imena stolpcev v array
        [records addObject:[columnItems copy]];
        NSLog(@"step");
        for (int i = 0; i < columnLength; i++) {
            NSLog(@"SQLite column count %i", i);
            
            NSString *columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt, i)];
            
            switch (sqlite3_column_type(stmt, i)) {
                case SQLITE_INTEGER:
                    [columnItems setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, i)] forKey:columnName];
                    break;
                case SQLITE_FLOAT:
                    [columnItems setObject:[NSNumber numberWithFloat:sqlite3_column_double(stmt, i)] forKey:columnName];
                    break;
                case SQLITE_TEXT:
                    [columnItems setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i)] forKey:columnName];
                    break;
                case SQLITE_BLOB:
                    // TODO ugotoviti kako dodati BLOB
                    break;
                case SQLITE_NULL:
                    // TODO dodati v array
                    break;
                default:
                    NSLog(@"Vrnjena vrednost ne ustreza standardnim!");
                    break;
            }
        }
        // Dodamo immutable kopijo vrednosti stolpcev v array
        [records addObject:[columnItems copy]];
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    
    return [records copy];
}
@end
