//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "ONMSSeverityItem.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ONMSSeverityItem


@synthesize title     = _title;
@synthesize timestamp = _timestamp;
@synthesize severity  = _severity;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_title);
  TT_RELEASE_SAFELY(_timestamp);
  TT_RELEASE_SAFELY(_severity);
  
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCoding


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder*)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.title = [decoder decodeObjectForKey:@"title"];
    self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
    self.severity = [decoder decodeObjectForKey:@"severity"];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.title) {
    [encoder encodeObject:self.title forKey:@"title"];
  }
  if (self.timestamp) {
    [encoder encodeObject:self.timestamp forKey:@"timestamp"];
  }
  if (self.severity) {
    [encoder encodeObject:self.severity forKey:@"severity"];
  }
}


@end

