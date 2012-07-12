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
            NSLog(@"Problem pri odpiranju baze");
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
    if ([databaseName isKindOfClass:[NSString class]] ) {
        dbName = databaseName;
    }
    return self;
}

- (NSArray *) rawQuery:(NSString *)text {
    NSMutableArray *records = [[NSMutableArray alloc]init];

    sqlite3_stmt *stmt = nil;
    
    const char *sqlStatement = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    //Odpiranje baze
    if (![ self openDatabaseConnection]) {
        NSLog(@"Ni povezave z bazo, prekinjam metodo!");
        return nil;
    }
    
    //Pripravimo SQL stavek
    sqlite3_prepare_v2(db, sqlStatement, 1, &stmt, NULL);
    
    int columnLength = sqlite3_column_count(stmt);
    
    //Pregledamo vsako vrstico in stolpec v vrstici
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableArray *columItems = [[NSMutableArray alloc]initWithCapacity:columnLength];
        for (int i = 0; i < columnLength; i++) {
            switch (sqlite3_column_type(stmt, i)) {
                case SQLITE_INTEGER:
                    [columItems addObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, i)]];
                    break;
                case SQLITE_FLOAT:
                    // TODO dodati v array
                    break;
                case SQLITE_TEXT:
                    // TODO dodati v array
                    break;
                case SQLITE_BLOB:
                    // TODO dodati v array
                    break;
                case SQLITE_NULL:
                    // TODO dodati v array
                    break;
                default:
                    NSLog(@"Vrnjena vrednost ne ustreza standardnim!");
                    break;
            }
        }
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    
    return [records copy];
}
@end
