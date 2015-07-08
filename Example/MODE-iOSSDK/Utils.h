void showAlert(NSError* err);

@interface NumericTextFieldDelegate : NSObject<UITextFieldDelegate>

@end

@interface PhoneNumberFieldDelegate : NSObject<UITextFieldDelegate>

- (id)initWithTextField:(UITextField*)textField;

@end

NumericTextFieldDelegate* setupNumericTextField(UITextField* textField, NSString* name);
PhoneNumberFieldDelegate* setupPhoneNumberField(UITextField* textField);

void setupMessage(UILabel* message, NSString* text);
