//
//  OutageDataSource.h
//  OpenNMS
//
//  Created by Benjamin Reed on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OutageListModel;
@class OutageModel;

@interface OutageListDataSource : TTListDataSource {
	OutageListModel* _outageListModel;
}

@end
