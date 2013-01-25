#import "ExampleObject.h"
 
 
@implementation ExampleObject
 
@synthesize name;
@synthesize distance;
 
+ (ExampleObject *)itemWithName:(NSString *)initName
                       distance:(NSUInteger)initDistance {
 
    ExampleObject *item = [[[ExampleObject alloc] init] autorelease];
    item.name = initName;
    item.distance = initDistance;
 
    return item;
}
 
// This method is not required
- (NSString *)description {
 
    return [NSString stringWithFormat:
            @"ExampleObject = {\n"
            "\tname = %@\n"
            "\tdistance = %d\n"
            "}",
 
            [name description],
            distance];
}
 
@end