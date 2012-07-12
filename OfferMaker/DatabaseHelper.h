//
//  DatabaseHelper.h
//  OfferMaker
//
//  Created by Robert Povšič on 8. 07. 12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DatabaseHelper : NSObject

- (id) initWithDatabaseName:(NSString *) databaseName;

- (NSArray *) rawQuery:(NSString *)text;

@end
