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

// Core
#import "Three20Core/Three20Core+Additions.h"

// UI
#import "Three20UI/TTTableCaptionItem.h"
#import "Three20UI/UIViewAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"
#import "Three20Style/UIFontAdditions.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ONMSSeverityItemCell

@synthesize severity = _severity;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier]) {

    self.titleLabel.font = TTSTYLEVAR(tableFont);
    self.titleLabel.textColor = TTSTYLEVAR(tableSubTextColor);
    self.titleLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.titleLabel.textAlignment = UITextAlignmentLeft;
    self.titleLabel.contentMode = UIViewContentModeTop;
    self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.backgroundColor = [UIColor clearColor];

    self.detailTextLabel.font = TTSTYLEVAR(font);
    self.detailTextLabel.textColor = TTSTYLEVAR(textColor);
    self.detailTextLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
    self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    self.timestampLabel.backgroundColor = [UIColor clearColor];
  }

  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_titleLabel);
  TT_RELEASE_SAFELY(_timestampLabel);
  TT_RELEASE_SAFELY(_severity);
  
  [super dealloc];
}

- (void)setSeverity:(NSString*)severity onLabel:(UILabel*)label {
  if (severity != nil && label != nil) {
    Severity* sev = [[Severity alloc] initWithSeverity:severity];
    TTDINFO(@"severity %@ found, using color %@", sev, [sev getTextColor]);
    label.textColor = [sev getTextColor];
    [sev release];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  ONMSSeverityItem* item = object;

  CGFloat width = tableView.width - kTableCellHPadding*2;

  CGSize detailTextSize = [item.text sizeWithFont:TTSTYLEVAR(tableFont)
                                constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                    lineBreakMode:UILineBreakModeWordWrap];

  CGSize textSize = [item.title sizeWithFont:TTSTYLEVAR(font)
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
  _titleLabel.text = nil;
  _timestampLabel.text = nil;
  _severity = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];
  
  TTDINFO(@"layoutSubviews");
  CGFloat width = self.contentView.width - kTableCellSmallMargin;
  CGFloat top = kTableCellSmallMargin;
  
  if (_titleLabel.text.length) {
    _titleLabel.frame = CGRectMake(kTableCellSmallMargin, top, width, _titleLabel.font.ttLineHeight);
    [self setSeverity:_severity onLabel:_titleLabel];
  } else {
    _titleLabel.frame = CGRectZero;
  }
  
  if (self.detailTextLabel.text.length) {
    [self.detailTextLabel sizeToFit];
    self.detailTextLabel.left = kTableCellHPadding;
    self.detailTextLabel.top = kTableCellVPadding + _titleLabel.height;
  } else {
    self.detailTextLabel.frame = CGRectZero;
  }
  
  if (_timestampLabel.text.length) {
    _timestampLabel.alpha = !self.showingDeleteConfirmation;
    [_timestampLabel sizeToFit];
    _timestampLabel.left = self.contentView.width - (_timestampLabel.width + kTableCellSmallMargin);
    _timestampLabel.top = _titleLabel.top;
    _titleLabel.width -= _timestampLabel.width + kTableCellSmallMargin*2;
  } else {
    _titleLabel.frame = CGRectZero;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
  [super didMoveToSuperview];
  
  if (self.superview) {
    _titleLabel.backgroundColor = self.backgroundColor;
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
    
    if (item) {
      if (item.title.length) {
        self.titleLabel.text = item.title;
      }
      if (item.text.length) {
        self.detailTextLabel.text = item.text;
      }
      if (item.timestamp) {
        self.timestampLabel.text = [item.timestamp formatShortTime];
      }

      self.severity = item.severity;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.highlightedTextColor = [UIColor whiteColor];
    _titleLabel.font = TTSTYLEVAR(tableFont);
    _titleLabel.contentMode = UIViewContentModeLeft;
    [self.contentView addSubview:_titleLabel];
  }
  return _titleLabel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)captionLabel {
  TTDINFO(@"captionLabel");
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
    [self.contentView addSubview:_timestampLabel];
  }
  return _timestampLabel;
}


@end
