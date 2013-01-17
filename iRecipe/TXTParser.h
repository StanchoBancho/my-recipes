//
//  TXTParser.h
//  iRecipe
//
//  Created by Stanimir Nikolov on 12/5/12.
//  Copyright (c) 2012 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXTParser : NSObject

+ (void)parseTextFile:(NSString*)file withCompletion:(void(^)(NSArray *result, NSError *error))completion;

@end
