#import "ExamplePriorityQueue.h"
 
 
@implementation ExamplePriorityQueue
 
#pragma mark -
#pragma mark CFBinaryHeap functions for sorting the priority queue
 
static const void *ExampleObjectRetain(CFAllocatorRef allocator, const void *ptr) {
    ExampleObject *event = (ExampleObject *)ptr;
    return [event retain];
}
 
static void ExampleObjectRelease(CFAllocatorRef allocator, const void *ptr) {
    ExampleObject* event = (ExampleObject *) ptr;
    [event release];
}
 
static CFStringRef ExampleObjectCopyDescription(const void* ptr) {
    ExampleObject *event = (ExampleObject *) ptr;
    CFStringRef desc = (CFStringRef) [event description];
    return desc;
}
 
static CFComparisonResult ExampleObjectCompare(const void* ptr1, const void* ptr2, void* context) {
    ExampleObject *item1 = (ExampleObject *) ptr1;
    ExampleObject *item2 = (ExampleObject *) ptr2;
 
    // In this example, we're sorting by distance property of the object
    // Objects with smallest distance will be first in the queue
    if ([item1 distance] < [item2 distance]) {
        return kCFCompareLessThan;
    } else if ([item1 distance] == [item2 distance]) {
        return kCFCompareEqualTo;
    } else {
        return kCFCompareGreaterThan;
    }
}
 
#pragma mark -
#pragma mark NSObject methods
 
- (id)init {
    if ((self = [super init])) {
 
        CFBinaryHeapCallBacks callbacks;
        callbacks.version = 0;
 
        // Callbacks to the functions above
        callbacks.retain = ExampleObjectRetain;
        callbacks.release = ExampleObjectRelease;
        callbacks.copyDescription = ExampleObjectCopyDescription;
        callbacks.compare = ExampleObjectCompare;
 
        // Create the priority queue
        _heap = CFBinaryHeapCreate(kCFAllocatorDefault, 0, &callbacks, NULL);
    }
 
    return self;
}
 
- (void)dealloc {
    if (_heap) {
        CFRelease(_heap);
    }
 
    [super dealloc];
}
 
- (NSString *)description {
    return [NSString stringWithFormat:@"PriorityQueue = {%@}",
            (_heap ? [[self allObjects] description] : @"null")];
}
 
#pragma mark -
#pragma mark Queue methods
 
- (NSUInteger)count {
    return CFBinaryHeapGetCount(_heap);
}
 
- (NSArray *)allObjects {
    const void **arrayC = calloc(CFBinaryHeapGetCount(_heap), sizeof(void *));
    CFBinaryHeapGetValues(_heap, arrayC);
    NSArray *array = [NSArray arrayWithObjects:(id *)arrayC
                                         count:CFBinaryHeapGetCount(_heap)];
    free(arrayC);
    return array;
}
 
- (void)addObject:(ExampleObject *)object {
    CFBinaryHeapAddValue(_heap, object);
}
 
- (void)removeAllObjects {
    CFBinaryHeapRemoveAllValues(_heap);
}
 
- (ExampleObject *)nextObject {
    ExampleObject *obj = [self peekObject];
    CFBinaryHeapRemoveMinimumValue(_heap);
    return obj;
}
 
- (ExampleObject *)peekObject {
    return (ExampleObject *)CFBinaryHeapGetMinimum(_heap);
}
 
@end