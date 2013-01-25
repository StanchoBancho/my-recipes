@interface ExampleObject : NSObject {
    @public
     NSString *name;
     NSUInteger distance;
}
 
@property (nonatomic, retain) NSString *name;
@property (nonatomic) NSUInteger distance;
 
+ (ExampleObject *)itemWithName:(NSString *)initName
                       distance:(NSUInteger)initDistance;
 
@end