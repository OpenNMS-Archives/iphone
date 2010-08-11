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

#import "ONMSSeverityItemCell.h"
#import "ONMSSeverityItem.h"
#import "Severity.h"

#import "Three20Core/NSDateAdditions.h"

// UI
#import "Three20UI/TTTableCaptionItem.h"
#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/UITableViewAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ONMSSeverityItemCell

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier]) {
    self.detailTextLabel.font = TTSTYLEVAR(tableFont);
    self.detailTextLabel.contentMode = UIViewContentModeTop;
    self.detailTextLabel.textColor = TTSTYLEVAR(textColor);
    self.detailTextLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    self.detailTextLabel.backgroundColor = [UIColor clearColor];

    self.textLabel.font = TTSTYLEVAR(font);
    self.textLabel.textColor = TTSTYLEVAR(tableSubTextColor);
    self.textLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.textLabel.textAlignment = UITextAlignmentLeft;
    self.textLabel.contentMode = UIViewContentModeTop;
    self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.textLabel.numberOfLines = 0;
    self.textLabel.backgroundColor = [UIColor clearColor];
  }

  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_timestampLabel);

  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  TTTableCaptionItem* item = object;

  CGFloat accessorySize = 0.0;
  
  if (item.URL) {
    if (item.accessoryURL) {
      accessorySize = 20.0;
    } else {
      accessorySize = 20.0;
    }
  }
  
  CGFloat width = tableView.width - kTableCellHPadding*2 - [tableView tableCellMargin]*2 - accessorySize;

  CGSize detailTextSize = [item.text sizeWithFont:TTSTYLEVAR(tableFont)
                                constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                    lineBreakMode:UILineBreakModeTailTruncation];

  CGSize textSize = [item.caption sizeWithFont:TTSTYLEVAR(font)
                             constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                 lineBreakMode:UILineBreakModeWordWrap];

  return kTableCellVPadding*2 + detailTextSize.height + textSize.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [super prepareForReuse];
  _timestampLabel.text = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat maxWidth = self.contentView.width - kTableCellHPadding*2;
  if (!self.textLabel.text.length) {
    CGFloat titleHeight = self.textLabel.height + self.detailTextLabel.height;

    [self.detailTextLabel sizeToFit];
    self.detailTextLabel.width = maxWidth;
    self.detailTextLabel.top = floor(self.contentView.height/2 - titleHeight/2);
    self.detailTextLabel.left = self.detailTextLabel.top*2;

  } else {
    [self.detailTextLabel sizeToFit];
    self.detailTextLabel.left = kTableCellHPadding;
    self.detailTextLabel.top = kTableCellVPadding;

    CGSize captionSize =
    [self.textLabel.text sizeWithFont:self.textLabel.font
                    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                        lineBreakMode:self.textLabel.lineBreakMode];
    self.textLabel.frame = CGRectMake(kTableCellHPadding, self.detailTextLabel.bottom,
                                      captionSize.width, captionSize.height);

    if (_timestampLabel.text.length) {
      _timestampLabel.alpha = !self.showingDeleteConfirmation;
      [_timestampLabel sizeToFit];
      self.detailTextLabel.width = maxWidth - _timestampLabel.width;
      _timestampLabel.left = self.contentView.width - (_timestampLabel.width + kTableCellSmallMargin);
      _timestampLabel.top = self.detailTextLabel.top;
      _timestampLabel.backgroundColor = [UIColor clearColor];
    }
    
  }
}


/////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
  [super didMoveToSuperview];
  
  if (self.superview) {
    _timestampLabel.backgroundColor = self.backgroundColor;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];

    ONMSSeverityItem* item = object;
    self.textLabel.text = item.caption;
    self.detailTextLabel.text = item.text;
    self.timestampLabel.text = [item.timestamp formatShortTime];

    Severity* sev = [[Severity alloc] initWithSeverity:item.severity];
    self.detailTextLabel.textColor = [sev getTextColor];
    [sev release];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)captionLabel {
  return self.textLabel;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)timestampLabel {
  if (!_timestampLabel) {
    _timestampLabel = [[UILabel alloc] init];
    _timestampLabel.font = TTSTYLEVAR(tableTimestampFont);
    _timestampLabel.textColor = TTSTYLEVAR(timestampTextColor);
    _timestampLabel.highlightedTextColor = [UIColor whiteColor];
    _timestampLabel.contentMode = UIViewContentModeLeft;
    _timestampLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_timestampLabel];
  }
  return _timestampLabel;
}


@end
