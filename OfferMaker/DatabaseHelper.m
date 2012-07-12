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
    //Pripravimo array v katerega bomo zapisovali prebrane vrednosti stolpca
    NSMutableArray *columnItems = [[NSMutableArray alloc]initWithCapacity:columnLength];
    
    // Preberemo imena stolpcev
    for (int i = 0; i < columnLength; i++) {
        [columnItems addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt, i)]];
    }
    
    // Dodamo imena stolpcev v array
    [records addObject:[columnItems copy]];
    
    //Pregledamo vsako vrstico in stolpec v vrstici
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        // Počistimo array v katerega bomo zapisovali vrednosti stolpcev
        [columnItems removeAllObjects];
        for (int i = 0; i < columnLength; i++) {
            switch (sqlite3_column_type(stmt, i)) {
                case SQLITE_INTEGER:
                    [columnItems addObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, i)]];
                    break;
                case SQLITE_FLOAT:
                    [columnItems addObject:[NSNumber numberWithFloat:sqlite3_column_double(stmt, i)]];
                    break;
                case SQLITE_TEXT:
                    [columnItems addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i)]];
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
    
    // Pomagamo ARC-u da bo prej odstranil iz spomina??
    columnItems = nil;
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    
    return [records copy];
}
@end
