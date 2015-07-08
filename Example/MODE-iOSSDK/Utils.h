void showAlert(NSError* err);

@interface NumericTextFieldDelegate : NSObject<UITextFieldDelegate>

@end

@interface PhoneNumberFieldDelegate : NSObject<UITextFieldDelegate>

- (id)initWithTextField:(UITextField*)textField;

@end

// These functions are for mixin to restrict UITextField only for numbers and phone numbers.
// You could make your subclasses derived from UITextField, but up to you.
NumericTextFieldDelegate* setupNumericTextField(UITextField* textField, NSString* name);
PhoneNumberFieldDelegate* setupPhoneNumberField(UITextField* textField);

void setupMessage(UILabel* message, NSString* text);
