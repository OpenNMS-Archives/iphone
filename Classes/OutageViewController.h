#import <UIKit/UIKit.h>
#import "FuzzyDate.h"
#import "OpenNMSRestAgent.h"

@interface OutageViewController : UIViewController {
	IBOutlet UITableView* outageTable;
	NSArray* outages;
	OpenNMSRestAgent* agent;
	FuzzyDate* fuzzyDate;
}

- (IBAction) reload:(id) sender;

@end
