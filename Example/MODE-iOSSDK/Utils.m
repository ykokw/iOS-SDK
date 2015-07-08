#import <Foundation/Foundation.h>
#import "Utils.h"

void showAlert(NSError* err) {
    
    NSString* msg = err.userInfo[@"reason"];
    NSLog(@"Failed to call createUser: %@", err);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:err.domain
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

NumericTextFieldDelegate* setupNumericTextField(UITextField* numericField, NSString* name)
{
    [numericField setPlaceholder:name];
    numericField.keyboardType = UIKeyboardTypeNumberPad;
    NumericTextFieldDelegate* numericDelegate = [[NumericTextFieldDelegate alloc] init];
    numericField.delegate = numericDelegate;

    return numericDelegate;
}

PhoneNumberFieldDelegate* setupPhoneNumberField(UITextField* phoneNumberField)
{
    [phoneNumberField setPlaceholder:@"Phonenumber"];
    
    phoneNumberField.keyboardType = UIKeyboardTypeNumberPad;
    PhoneNumberFieldDelegate* phoneNumberDelegate = [[PhoneNumberFieldDelegate alloc] initWithTextField:phoneNumberField];
    phoneNumberField.delegate = phoneNumberDelegate;

    return phoneNumberDelegate;
}


@implementation NumericTextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0) || [string isEqualToString:@""];
}

@end

@interface PhoneNumberFieldDelegate ()

@property(strong, nonatomic)UITextField* phoneNumberField;
@property(assign, nonatomic) BOOL shouldAttemptFormat;

@end

@implementation PhoneNumberFieldDelegate


- (id)initWithTextField:(UITextField*)textField {
    self = [super init];
    if (self)
    {
        self.phoneNumberField = textField;
        [textField addTarget:self action:@selector(formatPhoneNumber) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // this is what the textField's string will be after changing the characters
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // flag that we should attempt to format the phone number ONLY if they are adding
    // characters, otherwise if they are deleting characters we simply want to allow
    // them to delete them and not format them
    _shouldAttemptFormat = resultString.length > self.phoneNumberField.text.length;
    
    return YES;
}

- (void)formatPhoneNumber {
    // this value is determined when textField shouldChangeCharactersInRange is called on a phone
    // number cell - if a user is deleting characters we don't want to try to format it, otherwise
    // using the current logic below certain deletions will have no effect
    if (!_shouldAttemptFormat) {
        return;
    }
    
    // here we are leveraging some of the objective-c NSString functions to help parse and modify
    // the phone number... first we strip anything that's not a number from the textfield, and then
    // depending on the current value we append formatting characters to make it pretty
    NSString *currentString = self.phoneNumberField.text;
    NSString *strippedValue = [currentString stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, currentString.length)];
    
    NSString *formattedString;
    if (strippedValue.length == 0) {
        formattedString = @"";
    }
    else if (strippedValue.length < 3) {
        formattedString = [NSString stringWithFormat:@"(%@", strippedValue];
    }
    else if (strippedValue.length == 3) {
        formattedString = [NSString stringWithFormat:@"(%@) ", strippedValue];
    }
    else if (strippedValue.length < 6) {
        formattedString = [NSString stringWithFormat:@"(%@) %@", [strippedValue substringToIndex:3], [strippedValue substringFromIndex:3]];
    }
    else if (strippedValue.length == 6) {
        formattedString = [NSString stringWithFormat:@"(%@) %@-", [strippedValue substringToIndex:3], [strippedValue substringFromIndex:3]];
    }
    else if (strippedValue.length <= 10) {
        formattedString = [NSString stringWithFormat:@"(%@) %@-%@", [strippedValue substringToIndex:3], [strippedValue substringWithRange:NSMakeRange(3, 3)], [strippedValue substringFromIndex:6]];
    }
    else if (strippedValue.length >= 11) {
        formattedString = [NSString stringWithFormat:@"(%@) %@-%@ x%@", [strippedValue substringToIndex:3], [strippedValue substringWithRange:NSMakeRange(3, 3)], [strippedValue substringWithRange:NSMakeRange(6, 4)], [strippedValue substringFromIndex:10]];
    }
    
    self.phoneNumberField.text = formattedString;
}

@end