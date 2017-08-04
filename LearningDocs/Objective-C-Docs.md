Objective-C-Docs.md

```

Objective-C
Classes
Class header (MyClassName.h)
#import "AnyHeaderFile.h"

@interface MyClassName : SuperClassName
// define public properties
// define public methods
@end
Class implementation (MyClassName.m)
#import "MyClassName.h"

@interface MyClassName ()
// define private properties
// define private methods
@end

@implementation MyClassName {
// define private instance variables
}

// implement methods

@end
Variables
Declaring variables
type myVariableName;
Variable types
int 
1, 2, 500, 10000 

float, double 
1.5, 3.14, 578.234 

BOOL 
YES, NO 

ClassName * 
NSString *, NSArray *, ... 

id 
Hold reference to any object (no need to add *)

Properties
Defining properties
@property (attribute1, attribute2, ...) type myPropertyName;
Automatically defines a private instance variable

type _myPropertyName;
Automatically creates a getter and setter

- (type)myPropertyName;
- (void)setMyPropertyName:(type)name;
Using _myPropertyName uses the private instance variable directly. 
Using self.myPropertyName uses the getter and setter.

Property attributes
strong 
Adds reference to keep object alive 

weak 
Object can disapear, become nil 

assign 
Normal assign, no reference 

copy 
Make copy on assign 

nonatomic 
Make not threadsafe, increase performance 

readwrite 
Create getter & setter (default) 

readonly 
Create just getter

Methods
Defining methods
- (type)doIt;
- (type)doItWithA:(type)a;
- (type)doItWithA:(type)a andB:(type)b;
Implementing methods
- (type)doIt {
    // do something
    return ReturnValue;
}

- (type)doItWithA:(type)a {
    // do something with a
    return ReturnValue;
}

- (type)doItWithA:(type)a andB:(type)b {
    // do something with a and b
    return ReturnValue;
}
Constants
File specific constants
  static const double name = value;
  static NSString * const name = value;
External constants
  // .h
  extern const double name;
  // .m
  const double name = value;

  // .h
  extern NSString * const name;
  // .m
  NSString * const name = value;
Usage
Creating objects
ClassName *myObject = [[ClassName alloc] init];
Using properties
// setting value
[myObject setMyPropertyName:a]; // or
myObject.myPropertyName = a;

// getting value
a = [myObject myPropertyName]; // or
a = myObject.myPropertyName;
Calling methods
[myObject doIt];
[myObject doItWithA:a];
[myObject doItWithA:a andB:b];
Example
Custom initializer
- (id)initWithParam:(type)param {
    if ((self = [super init])) {
        _myPropertyName = param;
    }
    return self;
}
NSString
NSString *personOne = @"Ray";
NSString *personTwo = @"Shawn";
NSString *combinedString = [NSString stringWithFormat:@"%@: Hello, %@!", personOne, personTwo];
NSLog(@"%@", combinedString);
NSString *tipString = @"24.99";
float tipFloat = [tipString floatValue];
NSArray
NSMutableArray *array = [@[person1, person2] mutableCopy];
[array addObject:@"Waldo"];
for (NSString *person in array) {
    NSLog(@"Person: %@", person);
}
NSString *waldo = array[2];

```

