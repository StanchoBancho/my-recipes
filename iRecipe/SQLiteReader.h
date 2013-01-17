//
//  SQLiteReader.h
//  iRecipe
//
//  Created by Stanimir Nikolov on 12/5/12.
//  Copyright (c) 2012 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SQLiteReader : NSObject

- (NSMutableArray*)readDBWithQuery:(NSString*)sqlStatement;
- (BOOL)executeSQLStatement:(NSString*)query;

@end
