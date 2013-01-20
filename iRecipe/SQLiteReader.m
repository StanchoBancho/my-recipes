//
//  SQLiteReader.m
//  iRecipe
//
//  Created by Stanimir Nikolov on 12/5/12.
//  Copyright (c) 2012 Stanimir Nikolov. All rights reserved.
//

#import "SQLiteReader.h"


@interface SQLiteReader ()

@property (nonatomic, assign) sqlite3 *database;

@end

@implementation SQLiteReader

@synthesize database;

- (BOOL)openDataBaseWithName:(NSString*)dbName {
    NSString* databaseName = dbName;
    NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDir = [documentPaths objectAtIndex:0];
    NSString* databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    
    return sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK;
}

- (NSMutableArray*)readDBWithQuery:(NSString*)sqlStatement {
    NSMutableArray* result = [[NSMutableArray alloc] init];
    NSLog(@"%@",sqlStatement);
    
    if([self openDataBaseWithName:kDBName]) {
        const char *newSqlStatement = [sqlStatement cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, newSqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSMutableArray* newRow = [[NSMutableArray alloc] init];
                for(int i = 0; i < sqlite3_column_count(compiledStatement);i++) {
                    id newEntry = nil;
                    char *value = (char *)sqlite3_column_text(compiledStatement, i);
                    if(value) {
                        newEntry = [NSString stringWithUTF8String:value];
                    } else {
                        newEntry = [NSString stringWithFormat:@""];
                    }
                    [newRow addObject:newEntry];
                }
                [result addObject:newRow];
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return result;
}

- (BOOL)executeSQLStatement:(NSString*)query {
    BOOL result = [self openDataBaseWithName:kDBName];
    if(result) {
        const char *newSqlStatement = [query cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, newSqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            sqlite3_step(compiledStatement);
        } else {
            result = NO;
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    
    return result;
}

@end