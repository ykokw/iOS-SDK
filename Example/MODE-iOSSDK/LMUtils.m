#import "LMUIColor+Extentions.h"
#import "LMMessages.h"
#import "LMUtils.h"
#import "MODEApp.h"

#define TEXTFIELD_HEIGHT 48

/**
  *This is very basic alert function.
  *You should rewrite the error to get more user friendly.
 */
void showAlert(NSError *err)
{
    NSString *msg = err.userInfo[@"reason"];
    
    if ([msg  isEqual: @"INVALID_APP_ID"]) {
        msg = [msg stringByAppendingString:MESSAGE_EMAIL_LOGIN];
    }
    
    DLog(@"Failed to call API: %@", err);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:err.domain
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

void setTextFieldHeight(UITextField *textField)
{
    CGRect rect = textField.frame;
    rect.size.height = TEXTFIELD_HEIGHT;
    textField.frame = rect;
    
    [textField setReturnKeyType:UIReturnKeyDone];
}

void setupTextFieldWithLeftIcon(UITextField *textField, NSString *iconName)
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    
    imageView.frame = CGRectMake(14,0, imageView.frame.size.width, imageView.frame.size.height);
    
    UIView *objLeftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,34,16)];
    [objLeftView addSubview:imageView];
    
    [textField setLeftViewMode:UITextFieldViewModeAlways];
    textField.leftView = objLeftView;
    setTextFieldHeight(textField);
}

void setupStandardTextField(UITextField *textField, NSString *name, NSString *iconName)
{
    [textField setPlaceholder:name];
    setupTextFieldWithLeftIcon(textField, iconName);
    setTextFieldHeight(textField);
}

NumericTextFieldDelegate *setupNumericTextField(UITextField *numericField, NSString *name, NSString *iconName)
{
    [numericField setPlaceholder:name];
    
    setupTextFieldWithLeftIcon(numericField, iconName);
    
    numericField.keyboardType = UIKeyboardTypeNumberPad;
    NumericTextFieldDelegate *numericDelegate = [[NumericTextFieldDelegate alloc] init];
    numericField.delegate = numericDelegate;
    
    setTextFieldHeight(numericField);

    return numericDelegate;
}

PhoneNumberFieldDelegate *setupPhoneNumberField(UITextField *phoneNumberField)
{
    [phoneNumberField setPlaceholder:@"Phone number"];
    
    setupTextFieldWithLeftIcon(phoneNumberField, @"Phone.png");
    
    phoneNumberField.keyboardType = UIKeyboardTypePhonePad;
    PhoneNumberFieldDelegate *phoneNumberDelegate = [[PhoneNumberFieldDelegate alloc] initWithTextField:phoneNumberField];
    phoneNumberField.delegate = phoneNumberDelegate;
 
    setTextFieldHeight(phoneNumberField);
    
    return phoneNumberDelegate;
}

EmailFieldDelegate *setupEmailField(UITextField *emailField)
{
    [emailField setPlaceholder:@"Email"];
    
    setupTextFieldWithLeftIcon(emailField, @"Email.png");
    
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    EmailFieldDelegate *emailDelegate = [[EmailFieldDelegate alloc] initWithTextField:emailField];
    emailField.delegate = emailDelegate;
    
    setTextFieldHeight(emailField);
    
    return emailDelegate;
}

void setupPassowrdField(UITextField *passwordField) {
    [passwordField setPlaceholder:@"Password"];
    
    setupTextFieldWithLeftIcon(passwordField, @"Authentication.png");
    
    passwordField.secureTextEntry = YES;
    passwordField.keyboardType = UIKeyboardTypeDefault;
    setTextFieldHeight(passwordField);
}

void setupMessage(UILabel *message, NSString *text, CGFloat fontSize)
{
    return setupMessageWithColor(message, text, [UIColor bodyTextColor], fontSize);
}

void setupMessageWithColor(UILabel *message, NSString *text, UIColor *color, CGFloat fontSize)
{
    setupMessageWithColorAndAlign(message, text, color, fontSize, NSTextAlignmentCenter);
}

void setupMessageWithColorAndAlign(UILabel *message, NSString *text, UIColor *color, CGFloat fontSize, NSTextAlignment align)
{
    UIFont *font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:fontSize];
    
    // Multiline line spacing is always 11px.
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing: 11];
    
    NSDictionary *attributes = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    [message setAttributedText: attributedString];
    
    // You have to set ohter properties after calling setAttributedText.
    message.adjustsFontSizeToFitWidth = NO;
    message.lineBreakMode = NSLineBreakByWordWrapping;
    message.numberOfLines = 0;
    message.textAlignment = align;
    message.textColor = color;
}

void setCellLabel(UILabel *label, NSString *text, UIColor *color, CGFloat fontSize)
{
    [label setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:fontSize]];
    label.text = text;
    label.adjustsFontSizeToFitWidth = NO;
    label.numberOfLines = 1;
    label.textColor = color;
}

UILabel *setupTitle(NSString *title)
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
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
NSString *formatPhonenumberFromString(NSString *phonenumber)
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


@interface EmailFieldDelegate ()

@property(strong, nonatomic)UITextField *emailField;

@end

@implementation EmailFieldDelegate


- (id)initWithTextField:(UITextField*)textField
{
    self = [super init];
    if (self) {
        self.emailField = textField;
    }
    return self;
}

@end


@interface PhoneNumberFieldDelegate ()

@property(strong, nonatomic)UITextField *phoneNumberField;
@property(assign, nonatomic) BOOL shouldAttemptFormat;

@end

@implementation PhoneNumberFieldDelegate


- (id)initWithTextField:(UITextField*)textField
{
    self = [super init];
    if (self) {
        self.phoneNumberField = textField;
        //[textField addTarget:self action:@selector(handleFormatPhoneNumber) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _phoneNumberField.text = @"+1";
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

void initiateAuth(int projectId, NSString *phoneNumber)
{
    [MODEAppAPI initiateAuthenticationWithSMS:projectId phoneNumber:phoneNumber
        completion:^(MODESMSMessageReceipt *receipt, NSError *err) {
            if (err != nil) {
                showAlert(err);
            } else {
                DLog(@"Reinitiated auth token: %@", receipt);
            }
        }];
}


void setupKeyboardDismisser(UIViewController *viewController, SEL action)
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:viewController
                                   action:action];
    
    [viewController.view addGestureRecognizer:tap];
}

NSArray* getTimezoneArray() {
    NSArray* timezones = @[@"Etc/GMT+12",
                           @"Etc/GMT+11",
                           @"Pacific/Apia",
                           @"Pacific/Midway",
                           @"Pacific/Niue",
                           @"Pacific/Pago_Pago",
                           @"America/Adak",
                           @"Etc/GMT+10",
                           @"HST",
                           @"Pacific/Fakaofo",
                           @"Pacific/Honolulu",
                           @"Pacific/Johnston",
                           @"Pacific/Rarotonga",
                           @"Pacific/Tahiti",
                           @"Pacific/Marquesas",
                           @"America/Anchorage",
                           @"America/Juneau",
                           @"America/Nome",
                           @"America/Yakutat",
                           @"Etc/GMT+9",
                           @"Pacific/Gambier",
                           @"America/Dawson",
                           @"America/Los_Angeles",
                           @"America/Santa_Isabel",
                           @"America/Tijuana",
                           @"America/Vancouver",
                           @"America/Whitehorse",
                           @"Etc/GMT+8",
                           @"PST8PDT",
                           @"Pacific/Pitcairn",
                           @"America/Boise",
                           @"America/Cambridge_Bay",
                           @"America/Chihuahua",
                           @"America/Dawson_Creek",
                           @"America/Denver",
                           @"America/Edmonton",
                           @"America/Hermosillo",
                           @"America/Inuvik",
                           @"America/Mazatlan",
                           @"America/Ojinaga",
                           @"America/Phoenix",
                           @"America/Yellowknife",
                           @"Etc/GMT+7",
                           @"MST",
                           @"MST7MDT",
                           @"America/Bahia_Banderas",
                           @"America/Belize",
                           @"America/Cancun",
                           @"America/Chicago",
                           @"America/Costa_Rica",
                           @"America/El_Salvador",
                           @"America/Guatemala",
                           @"America/Indiana/Knox",
                           @"America/Indiana/Tell_City",
                           @"America/Managua",
                           @"America/Matamoros",
                           @"America/Menominee",
                           @"America/Merida",
                           @"America/Mexico_City",
                           @"America/Monterrey",
                           @"America/North_Dakota/Center",
                           @"America/North_Dakota/New_Salem",
                           @"America/Rainy_River",
                           @"America/Rankin_Inlet",
                           @"America/Regina",
                           @"America/Swift_Current",
                           @"America/Tegucigalpa",
                           @"America/Winnipeg",
                           @"CST6CDT",
                           @"Etc/GMT+6",
                           @"Pacific/Easter",
                           @"Pacific/Galapagos",
                           @"America/Atikokan",
                           @"America/Bogota",
                           @"America/Cayman",
                           @"America/Detroit",
                           @"America/Grand_Turk",
                           @"America/Guayaquil",
                           @"America/Havana",
                           @"America/Indiana/Indianapolis",
                           @"America/Indiana/Marengo",
                           @"America/Indiana/Petersburg",
                           @"America/Indiana/Vevay",
                           @"America/Indiana/Vincennes",
                           @"America/Indiana/Winamac",
                           @"America/Iqaluit",
                           @"America/Jamaica",
                           @"America/Kentucky/Louisville",
                           @"America/Kentucky/Monticello",
                           @"America/Lima",
                           @"America/Montreal",
                           @"America/Nassau",
                           @"America/New_York",
                           @"America/Nipigon",
                           @"America/Panama",
                           @"America/Pangnirtung",
                           @"America/Port-au-Prince",
                           @"America/Resolute",
                           @"America/Thunder_Bay",
                           @"America/Toronto",
                           @"EST",
                           @"EST5EDT",
                           @"Etc/GMT+5",
                           @"America/Caracas",
                           @"America/Anguilla",
                           @"America/Antigua",
                           @"America/Argentina/San_Luis",
                           @"America/Aruba",
                           @"America/Asuncion",
                           @"America/Barbados",
                           @"America/Blanc-Sablon",
                           @"America/Boa_Vista",
                           @"America/Campo_Grande",
                           @"America/Cuiaba",
                           @"America/Curacao",
                           @"America/Dominica",
                           @"America/Eirunepe",
                           @"America/Glace_Bay",
                           @"America/Goose_Bay",
                           @"America/Grenada",
                           @"America/Guadeloupe",
                           @"America/Guyana",
                           @"America/Halifax",
                           @"America/La_Paz",
                           @"America/Manaus",
                           @"America/Martinique",
                           @"America/Moncton",
                           @"America/Montserrat",
                           @"America/Port_of_Spain",
                           @"America/Porto_Velho",
                           @"America/Puerto_Rico",
                           @"America/Rio_Branco",
                           @"America/Santiago",
                           @"America/Santo_Domingo",
                           @"America/St_Kitts",
                           @"America/St_Lucia",
                           @"America/St_Thomas",
                           @"America/St_Vincent",
                           @"America/Thule",
                           @"America/Tortola",
                           @"Antarctica/Palmer",
                           @"Atlantic/Bermuda",
                           @"Atlantic/Stanley",
                           @"Etc/GMT+4",
                           @"America/St_Johns",
                           @"America/Araguaina",
                           @"America/Argentina/Buenos_Aires",
                           @"America/Argentina/Catamarca",
                           @"America/Argentina/Cordoba",
                           @"America/Argentina/Jujuy",
                           @"America/Argentina/La_Rioja",
                           @"America/Argentina/Mendoza",
                           @"America/Argentina/Rio_Gallegos",
                           @"America/Argentina/Salta",
                           @"America/Argentina/San_Juan",
                           @"America/Argentina/Tucuman",
                           @"America/Argentina/Ushuaia",
                           @"America/Bahia",
                           @"America/Belem",
                           @"America/Cayenne",
                           @"America/Fortaleza",
                           @"America/Godthab",
                           @"America/Maceio",
                           @"America/Miquelon",
                           @"America/Montevideo",
                           @"America/Paramaribo",
                           @"America/Recife",
                           @"America/Santarem",
                           @"America/Sao_Paulo",
                           @"Antarctica/Rothera",
                           @"Etc/GMT+3",
                           @"America/Noronha",
                           @"Atlantic/South_Georgia",
                           @"Etc/GMT+2",
                           @"America/Scoresbysund",
                           @"Atlantic/Azores",
                           @"Atlantic/Cape_Verde",
                           @"Etc/GMT+1",
                           @"Africa/Abidjan",
                           @"Africa/Accra",
                           @"Africa/Bamako",
                           @"Africa/Banjul",
                           @"Africa/Bissau",
                           @"Africa/Casablanca",
                           @"Africa/Conakry",
                           @"Africa/Dakar",
                           @"Africa/El_Aaiun",
                           @"Africa/Freetown",
                           @"Africa/Lome",
                           @"Africa/Monrovia",
                           @"Africa/Nouakchott",
                           @"Africa/Ouagadougou",
                           @"Africa/Sao_Tome",
                           @"America/Danmarkshavn",
                           @"Atlantic/Canary",
                           @"Atlantic/Faroe",
                           @"Atlantic/Madeira",
                           @"Atlantic/Reykjavik",
                           @"Atlantic/St_Helena",
                           @"Etc/GMT",
                           @"Etc/UCT",
                           @"Etc/UTC",
                           @"Europe/Dublin",
                           @"Europe/Lisbon",
                           @"Europe/London",
                           @"UTC",
                           @"WET",
                           @"Africa/Algiers",
                           @"Africa/Bangui",
                           @"Africa/Brazzaville",
                           @"Africa/Ceuta",
                           @"Africa/Douala",
                           @"Africa/Kinshasa",
                           @"Africa/Lagos",
                           @"Africa/Libreville",
                           @"Africa/Luanda",
                           @"Africa/Malabo",
                           @"Africa/Ndjamena",
                           @"Africa/Niamey",
                           @"Africa/Porto-Novo",
                           @"Africa/Tunis",
                           @"Africa/Windhoek",
                           @"CET",
                           @"Etc/GMT-1",
                           @"Europe/Amsterdam",
                           @"Europe/Andorra",
                           @"Europe/Belgrade",
                           @"Europe/Berlin",
                           @"Europe/Brussels",
                           @"Europe/Budapest",
                           @"Europe/Copenhagen",
                           @"Europe/Gibraltar",
                           @"Europe/Luxembourg",
                           @"Europe/Madrid",
                           @"Europe/Malta",
                           @"Europe/Monaco",
                           @"Europe/Oslo",
                           @"Europe/Paris",
                           @"Europe/Prague",
                           @"Europe/Rome",
                           @"Europe/Stockholm",
                           @"Europe/Tirane",
                           @"Europe/Vaduz",
                           @"Europe/Vienna",
                           @"Europe/Warsaw",
                           @"Europe/Zurich",
                           @"MET",
                           @"Africa/Blantyre",
                           @"Africa/Bujumbura",
                           @"Africa/Cairo",
                           @"Africa/Gaborone",
                           @"Africa/Harare",
                           @"Africa/Johannesburg",
                           @"Africa/Kigali",
                           @"Africa/Lubumbashi",
                           @"Africa/Lusaka",
                           @"Africa/Maputo",
                           @"Africa/Maseru",
                           @"Africa/Mbabane",
                           @"Africa/Tripoli",
                           @"Asia/Amman",
                           @"Asia/Beirut",
                           @"Asia/Damascus",
                           @"Asia/Gaza",
                           @"Asia/Jerusalem",
                           @"Asia/Nicosia",
                           @"EET",
                           @"Etc/GMT-2",
                           @"Europe/Athens",
                           @"Europe/Bucharest",
                           @"Europe/Chisinau",
                           @"Europe/Helsinki",
                           @"Europe/Istanbul",
                           @"Europe/Kaliningrad",
                           @"Europe/Kiev",
                           @"Europe/Minsk",
                           @"Europe/Riga",
                           @"Europe/Simferopol",
                           @"Europe/Sofia",
                           @"Europe/Tallinn",
                           @"Europe/Uzhgorod",
                           @"Europe/Vilnius",
                           @"Europe/Zaporozhye",
                           @"Africa/Addis_Ababa",
                           @"Africa/Asmara",
                           @"Africa/Dar_es_Salaam",
                           @"Africa/Djibouti",
                           @"Africa/Kampala",
                           @"Africa/Khartoum",
                           @"Africa/Mogadishu",
                           @"Africa/Nairobi",
                           @"Antarctica/Syowa",
                           @"Asia/Aden",
                           @"Asia/Baghdad",
                           @"Asia/Bahrain",
                           @"Asia/Kuwait",
                           @"Asia/Qatar",
                           @"Asia/Riyadh",
                           @"Etc/GMT-3",
                           @"Europe/Moscow",
                           @"Europe/Samara",
                           @"Europe/Volgograd",
                           @"Indian/Antananarivo",
                           @"Indian/Comoro",
                           @"Indian/Mayotte",
                           @"Asia/Tehran",
                           @"Asia/Baku",
                           @"Asia/Dubai",
                           @"Asia/Muscat",
                           @"Asia/Tbilisi",
                           @"Asia/Yerevan",
                           @"Etc/GMT-4",
                           @"Indian/Mahe",
                           @"Indian/Mauritius",
                           @"Indian/Reunion",
                           @"Asia/Kabul",
                           @"Antarctica/Mawson",
                           @"Asia/Aqtau",
                           @"Asia/Aqtobe",
                           @"Asia/Ashgabat",
                           @"Asia/Dushanbe",
                           @"Asia/Karachi",
                           @"Asia/Oral",
                           @"Asia/Samarkand",
                           @"Asia/Tashkent",
                           @"Asia/Yekaterinburg",
                           @"Etc/GMT-5",
                           @"Indian/Kerguelen",
                           @"Indian/Maldives",
                           @"Asia/Colombo",
                           @"Asia/Kolkata",
                           @"Asia/Kathmandu",
                           @"Antarctica/Vostok",
                           @"Asia/Almaty",
                           @"Asia/Bishkek",
                           @"Asia/Dhaka",
                           @"Asia/Novokuznetsk",
                           @"Asia/Novosibirsk",
                           @"Asia/Omsk",
                           @"Asia/Qyzylorda",
                           @"Asia/Thimphu",
                           @"Etc/GMT-6",
                           @"Indian/Chagos",
                           @"Asia/Rangoon",
                           @"Indian/Cocos",
                           @"Antarctica/Davis",
                           @"Asia/Bangkok",
                           @"Asia/Ho_Chi_Minh",
                           @"Asia/Hovd",
                           @"Asia/Jakarta",
                           @"Asia/Krasnoyarsk",
                           @"Asia/Phnom_Penh",
                           @"Asia/Pontianak",
                           @"Asia/Vientiane",
                           @"Etc/GMT-7",
                           @"Indian/Christmas",
                           @"Antarctica/Casey",
                           @"Asia/Brunei",
                           @"Asia/Choibalsan",
                           @"Asia/Chongqing",
                           @"Asia/Harbin",
                           @"Asia/Hong_Kong",
                           @"Asia/Irkutsk",
                           @"Asia/Kashgar",
                           @"Asia/Kuala_Lumpur",
                           @"Asia/Kuching",
                           @"Asia/Macau",
                           @"Asia/Makassar",
                           @"Asia/Manila",
                           @"Asia/Shanghai",
                           @"Asia/Singapore",
                           @"Asia/Taipei",
                           @"Asia/Ulaanbaatar",
                           @"Asia/Urumqi",
                           @"Australia/Perth",
                           @"Etc/GMT-8",
                           @"Australia/Eucla",
                           @"Asia/Dili",
                           @"Asia/Jayapura",
                           @"Asia/Pyongyang",
                           @"Asia/Seoul",
                           @"Asia/Tokyo",
                           @"Asia/Yakutsk",
                           @"Etc/GMT-9",
                           @"Pacific/Palau",
                           @"Australia/Adelaide",
                           @"Australia/Broken_Hill",
                           @"Australia/Darwin",
                           @"Antarctica/DumontDUrville",
                           @"Asia/Sakhalin",
                           @"Asia/Vladivostok",
                           @"Australia/Brisbane",
                           @"Australia/Currie",
                           @"Australia/Hobart",
                           @"Australia/Lindeman",
                           @"Australia/Melbourne",
                           @"Australia/Sydney",
                           @"Etc/GMT-10",
                           @"Pacific/Chuuk",
                           @"Pacific/Guam",
                           @"Pacific/Port_Moresby",
                           @"Pacific/Saipan",
                           @"Australia/Lord_Howe",
                           @"Antarctica/Macquarie",
                           @"Asia/Anadyr",
                           @"Asia/Kamchatka",
                           @"Asia/Magadan",
                           @"Etc/GMT-11",
                           @"Pacific/Efate",
                           @"Pacific/Guadalcanal",
                           @"Pacific/Kosrae",
                           @"Pacific/Noumea",
                           @"Pacific/Pohnpei",
                           @"Pacific/Norfolk",
                           @"Antarctica/McMurdo",
                           @"Etc/GMT-12",
                           @"Pacific/Auckland",
                           @"Pacific/Fiji",
                           @"Pacific/Funafuti",
                           @"Pacific/Kwajalein",
                           @"Pacific/Majuro",
                           @"Pacific/Nauru",
                           @"Pacific/Tarawa",
                           @"Pacific/Wake",
                           @"Pacific/Wallis",
                           @"Pacific/Chatham",
                           @"Etc/GMT-13",
                           @"Pacific/Enderbury",
                           @"Pacific/Tongatapu",
                           @"Etc/GMT-14",
                           @"Pacific/Kiritimati"
                           ];
    return timezones;
}
