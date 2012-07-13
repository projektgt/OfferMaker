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

/**
 * Odpre povezavo z bazo
 */
-(BOOL)openDatabaseConnection {
    if (db == nil) {
        sqlite3 *newDbConection;
        
        NSString *dbFilename = [self getDatabaseFilename:dbName];
        NSString *path = [[NSBundle mainBundle] pathForResource:dbFilename ofType:@"sqlite"];
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
 * Preveri ali je ime baze v formatu name.sqlite ali name in vrne ime datoteke brez končnice
 */
-(NSString *)getDatabaseFilename:(NSString *) filename {
    NSRange range = [filename rangeOfString:@"."];
    if (range.location == NSNotFound) {
        return filename;
    }
    return [filename substringToIndex:range.location];
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
        
        //Pripravimo array v katerega bomo zapisovali prebrane vrednosti stolpca
        NSMutableDictionary *columnItems = [[NSMutableDictionary alloc]initWithCapacity:columnLength];
        
        // Dodamo imena stolpcev v array
        [records addObject:[columnItems copy]];

        for (int i = 0; i < columnLength; i++) {
            
            NSString *columnName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt, i)];
            
            switch (sqlite3_column_type(stmt, i)) {
                case SQLITE_INTEGER:
                    [columnItems setObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, i)] forKey:columnName];
                    NSLog(@"%@",[NSString stringWithFormat:@"%@ %i", columnName, sqlite3_column_int(stmt, i)]);
                    break;
                case SQLITE_FLOAT:
                    [columnItems setObject:[NSNumber numberWithFloat:sqlite3_column_double(stmt, i)] forKey:columnName];
                    NSLog(@"%@",[NSString stringWithFormat:@"%@ %d", columnName, sqlite3_column_double(stmt, i)]);
                    break;
                case SQLITE_TEXT:
                    [columnItems setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i)] forKey:columnName];
                    NSLog(@"%@",[NSString stringWithFormat:@"%@ %@", columnName, [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i)]]);
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
