// Don't forget to import CoreFoundation
#import <CoreFoundation/CoreFoundation.h>
 
// Type of object that will be contained within priority queue
#import "ExampleObject.h"
 
 
@interface ExamplePriorityQueue : NSObject {
    @private
     // Heap itself
     CFBinaryHeapRef _heap;
}
 
// Returns number of items in the queue
- (NSUInteger)count;
 
// Returns all (sorted) objects in the queue
- (NSArray *)allObjects;
 
// Adds an object to the queue
- (void)addObject:(ExampleObject *)object;
 
// Removes all objects from the queue
- (void)removeAllObjects;
 
// Removes the "top-most" (as determined by the callback sort function) object from the queue
// and returns it
- (ExampleObject *)nextObject;
 
// Returns the "top-most" (as determined by the callback sort function) object from the queue
// without removing it from the queue
- (ExampleObject *)peekObject;
 
@end