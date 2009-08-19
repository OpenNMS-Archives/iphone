/*******************************************************************************
 * Copyright (c) 2009 Kåre Morstøl (NotTooBad Software).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    Kåre Morstøl (NotTooBad Software) - initial API and implementation
 *******************************************************************************/ 

#import "TextfieldCell.h"


@implementation TextfieldCell

//@synthesize configuration;

- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithValuelabelAndReuseIdentifier:reuseIdentifier]) {
		
		valuetextfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 11, 0, 25)];
		
		valuetextfield.textColor = valuelabel.textColor;
		valuetextfield.font = valuelabel.font;
		
		valuetextfield.clearsOnBeginEditing = NO;
		valuetextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
		valuetextfield.returnKeyType = UIReturnKeyDone;
		[valuetextfield setDelegate:self];
		
		[valuelabel removeFromSuperview];
		[self.contentView addSubview:valuetextfield];
		valueview = valuetextfield;
		
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
	[valuetextfield release];
}

// Without this, the title label disappears. I have no idea why.
- (void) setConfiguration:(NSDictionary *)config {
	[super setConfiguration:config];
	
	valuetextfield.placeholder = [configuration objectForKey:@"PlaceHolder"];
	valuetextfield.enablesReturnKeyAutomatically = [[configuration objectForKey:@"DontAllowEmptyText"] boolValue];

	id type = [configuration objectForKey:@"AutocapitalizationType"];
	if (type == nil) {
		valuetextfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
	} else {
		if ([type isEqual:@"Sentences"]) {
			valuetextfield.autocapitalizationType = UITextAutocapitalizationTypeSentences;
		} else if ([type isEqual:@"Words"]) {
			valuetextfield.autocapitalizationType = UITextAutocapitalizationTypeWords;
		} else if ([type isEqual:@"AllCharacters"]) {
			valuetextfield.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
		} else {
			valuetextfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
		}
	}

	type = [configuration objectForKey:@"AutocorrectionType"];
	if (type == nil) {
		valuetextfield.autocorrectionType = UITextAutocorrectionTypeDefault;
	} else {
		if ([type isEqual:@"No"]) {
			valuetextfield.autocorrectionType = UITextAutocorrectionTypeNo;
		} else if ([type isEqual:@"Yes"]) {
			valuetextfield.autocorrectionType = UITextAutocorrectionTypeYes;
		} else if ([type isEqual:@"Default"]) {
			valuetextfield.autocorrectionType = UITextAutocorrectionTypeDefault;
		}
	}

	type = [configuration objectForKey:@"KeyboardType"];
	if (type == nil) {
		valuetextfield.keyboardType = UIKeyboardTypeDefault;
	} else {
		if ([type isEqual:@"Alphabet"]) {
			valuetextfield.keyboardType = UIKeyboardTypeAlphabet;
		} else if ([type isEqual:@"ASCIICapable"]) {
			valuetextfield.keyboardType = UIKeyboardTypeASCIICapable;
		} else if ([type isEqual:@"EmailAddress"]) {
			valuetextfield.keyboardType = UIKeyboardTypeEmailAddress;
		} else if ([type isEqual:@"NamePhonePad"]) {
			valuetextfield.keyboardType = UIKeyboardTypeNamePhonePad;
		} else if ([type isEqual:@"NumberPad"]) {
			valuetextfield.keyboardType = UIKeyboardTypeNumberPad;
		} else if ([type isEqual:@"NumbersAndPunctuation"]) {
			valuetextfield.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
		} else if ([type isEqual:@"PhonePad"]) {
			valuetextfield.keyboardType = UIKeyboardTypePhonePad;
		} else if ([type isEqual:@"URL"]) {
			valuetextfield.keyboardType = UIKeyboardTypeURL;
		} else {
			valuetextfield.keyboardType = UIKeyboardTypeDefault;
		}
	}

	type = [configuration objectForKey:@"TextAlignment"];
	if (type == nil) {
		valuetextfield.textAlignment = UITextAlignmentLeft;
	} else {
		if ([type isEqual:@"Right"]) {
			valuetextfield.textAlignment = UITextAlignmentRight;
		} else if ([type isEqual:@"Center"]) {
			valuetextfield.textAlignment = UITextAlignmentCenter;
		} else {
			valuetextfield.textAlignment = UITextAlignmentLeft;
		}
	}

	valuetextfield.secureTextEntry = [[configuration objectForKey:@"IsSecure"] boolValue];
}

- (void) setValue:(NSObject *)newvalue {
	super.value = newvalue;
	valuetextfield.text = (NSString *) self.value;
}

#pragma mark Text Field Delegate Methods

- (void) textFieldDidBeginEditing:(UITextField *)textField {
	UITableView *tableview = (UITableView *) self.superview;
	tableview.scrollEnabled = FALSE;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
	UITableView *tableview = (UITableView *) self.superview;
	tableview.scrollEnabled = TRUE;
	
	super.value = textField.text = ([(NSNumber *)[configuration objectForKey:@"DontTrimText"] boolValue]) ? textField.text : [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if (range.location == 0 && [string isEqualToString:@" "] && ![(NSNumber *)[configuration objectForKey:@"AllowLeadingSpaces"] boolValue])
		// Avoid starting text with space
		return NO;
	else
		return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)theTextField {
	[theTextField resignFirstResponder]; //This closes the keyboard when you click done in the field.
	return YES;
}

@end
