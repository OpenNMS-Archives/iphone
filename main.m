//
//  main.m
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

int main(int argc, char *argv[]) {
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
  [pool release];
  return retVal;
}
