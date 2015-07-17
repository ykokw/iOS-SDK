#import "LMUIColor+Extentions.h"

@implementation UIColor (Extensions)

+ (UIColor*)defaultThemeColor
{
    return [UIColor colorWithRed:249.0/255.0 green:160.0/255.0 blue:117.0/255.0 alpha:1.0];
}

+ (UIColor*)defaultDisplayColor
{
    return [UIColor colorWithRed:240.0/255.0 green:110.0/255.0 blue:111.0/255.0 alpha:1.0];
}

+(UIColor*)bodyTextColor
{
    return [UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:1.0];
}


+(UIColor*)cellTextColor
{
    return [UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1.0];
}

+(UIColor*)subCellTextColor
{
    return [UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1.0];
}

@end
