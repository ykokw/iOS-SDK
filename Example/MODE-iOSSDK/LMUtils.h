@interface NumericTextFieldDelegate : NSObject<UITextFieldDelegate>

@end

@interface PhoneNumberFieldDelegate : NSObject<UITextFieldDelegate>

- (id)initWithTextField:(UITextField*)textField;

@end

@interface EmailFieldDelegate : NSObject<UITextFieldDelegate>

- (id)initWithTextField:(UITextField*)textField;

@end


// These functions are for mixin to restrict UITextField only for numbers and phone numbers.
// You could make your subclasses derived from UITextField.
NumericTextFieldDelegate *setupNumericTextField(UITextField *textField, NSString *name, NSString *iconName);
PhoneNumberFieldDelegate *setupPhoneNumberField(UITextField *textField);
EmailFieldDelegate *setupEmailField(UITextField *textField);
void setupPassowrdField(UITextField *textField);

void setupStandardTextField(UITextField *textField, NSString *name, NSString *iconName);

void setupMessage(UILabel *message, NSString *text, CGFloat fontSize);
void setupMessageWithColor(UILabel *message, NSString *text, UIColor *color, CGFloat fontSize);
void setupMessageWithColorAndAlign(UILabel *message, NSString *text, UIColor *color, CGFloat fontSize, NSTextAlignment align);

void setCellLabel(UILabel *cellTextLabel, NSString *text, UIColor *color, CGFloat fontSize);

NSString *formatPhonenumberFromString(NSString *phonenumber);

UILabel *setupTitle(NSString *title);

void showAlert(NSError *err);

void initiateAuth(int projectId, NSString *phoneNumber);

void setupKeyboardDismisser(UIViewController *viewController, SEL action);

NSArray *getTimezoneArray();


#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)