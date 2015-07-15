#import "LMUIColor+Extentions.h"
#import "LMUtils.h"
#import "MODEApp.h"

#define TEXTFIELD_HEIGHT 48

/**
 * This is very basic alert function.
 * You should rewrite the error to get more user friendly.
 */
void showAlert(NSError* err)
{
    NSString* msg = err.userInfo[@"reason"];
    NSLog(@"Failed to call API: %@", err);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:err.domain
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

void setTextFieldHeight(UITextField* textField)
{
    CGRect rect = textField.frame;
    rect.size.height = TEXTFIELD_HEIGHT;
    textField.frame = rect;
}

void setupTextFieldWithLeftIcon(UITextField* textField, NSString* iconName)
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    imageView.frame = CGRectMake(10,0,16,16);
    
    UIView* objLeftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,26,16)];
    [objLeftView addSubview:imageView];
    
    [textField setLeftViewMode:UITextFieldViewModeAlways];
    textField.leftView = objLeftView;
    setTextFieldHeight(textField);
}

void setupStandardTextField(UITextField* textField, NSString* name, NSString* iconName)
{
    [textField setPlaceholder:name];
    setupTextFieldWithLeftIcon(textField, iconName);
    setTextFieldHeight(textField);
}

NumericTextFieldDelegate* setupNumericTextField(UITextField* numericField, NSString* name, NSString* iconName)
{
    [numericField setPlaceholder:name];
    
    setupTextFieldWithLeftIcon(numericField, iconName);
    
    numericField.keyboardType = UIKeyboardTypeNumberPad;
    NumericTextFieldDelegate* numericDelegate = [[NumericTextFieldDelegate alloc] init];
    numericField.delegate = numericDelegate;
    
    setTextFieldHeight(numericField);

    return numericDelegate;
}

PhoneNumberFieldDelegate* setupPhoneNumberField(UITextField* phoneNumberField)
{
    [phoneNumberField setPlaceholder:@"Phonenumber"];
    
    setupTextFieldWithLeftIcon(phoneNumberField, @"Phone.png");
    
    phoneNumberField.keyboardType = UIKeyboardTypeNumberPad;
    PhoneNumberFieldDelegate* phoneNumberDelegate = [[PhoneNumberFieldDelegate alloc] initWithTextField:phoneNumberField];
    phoneNumberField.delegate = phoneNumberDelegate;
 
    setTextFieldHeight(phoneNumberField);
    
    return phoneNumberDelegate;
}

void setupMessage(UILabel* message, NSString* text)
{
    return setupMessageWithColor(message, text, [UIColor bodyTextColor]);
}

void setupMessageWithColor(UILabel* message, NSString* text, UIColor* color)
{
    message.adjustsFontSizeToFitWidth = NO;
    message.lineBreakMode = NSLineBreakByWordWrapping;
    message.numberOfLines = 0;
    message.textAlignment = NSTextAlignmentCenter;
    message.textColor = color;
    message.text = text;
}

UILabel* setupTitle(NSString* title)
{
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

@interface NSString (Extensions)

-(NSString*)subString:(int)start end:(int)end;

@end

@implementation NSString (Extensions)

-(NSString *)subString:(int)start end:(int)end
{
    return [self substringWithRange:NSMakeRange(start, end-start)];
}

@end

// It assumes only US phonenumber.
NSString* formatPhonenumberFromString(NSString* phonenumber)
{
    return [NSString stringWithFormat:@"(%@) %@-%@", [phonenumber subString:2 end:5], [phonenumber subString:5 end:8], [phonenumber subString:8 end:12]];
}

@implementation NumericTextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0) || [string isEqualToString:@""];
}

@end


@interface PhoneNumberFieldDelegate ()

@property(strong, nonatomic)UITextField* phoneNumberField;
@property(assign, nonatomic) BOOL shouldAttemptFormat;

@end

@implementation PhoneNumberFieldDelegate


- (id)initWithTextField:(UITextField*)textField
{
    self = [super init];
    if (self)
    {
        self.phoneNumberField = textField;
        [textField addTarget:self action:@selector(handleFormatPhoneNumber) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    _shouldAttemptFormat = resultString.length > self.phoneNumberField.text.length;
    
    return YES;
}

- (void)handleFormatPhoneNumber
{
     if (!_shouldAttemptFormat) {
        return;
    }
    
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
    else {
        formattedString = [NSString stringWithFormat:@"(%@) %@-%@", [strippedValue substringToIndex:3], [strippedValue substringWithRange:NSMakeRange(3, 3)], [strippedValue substringWithRange:NSMakeRange(6, 4)]];
    }
    
    self.phoneNumberField.text = formattedString;
}

@end

void initiateAuth(int projectId, NSString* phoneNumber)
{
    [MODEAppAPI initiateAuthenticationWithSMS:projectId phoneNumber:phoneNumber
        completion:^(MODESMSMessageReceipt *receipt, NSError *err) {
            if (err != nil) {
                showAlert(err);
            } else {
                NSLog(@"Reinitiated auth token: %@", receipt);
            }
        }];
}
