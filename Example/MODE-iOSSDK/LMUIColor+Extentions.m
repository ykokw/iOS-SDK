#import "LMUIColor+Extentions.h"

@implementation UIColor (Extensions)

+ (UIColor *)defaultThemeColor
{
    return [UIColor colorWithRed:253.0/255.0 green:178.0/255.0 blue:109.0/255.0 alpha:1.0];
}

+ (UIColor *)defaultThemeColorWithAlpha:(double) alpha
{
    return [UIColor colorWithRed:253.0/255.0 green:178.0/255.0 blue:109.0/255.0 alpha:alpha];
}

+ (UIColor *)defaultDisplayColor
{
    return [UIColor colorWithRed:234.0/255.0 green:91.0/255.0 blue:97.0/255.0 alpha:1.0];
}

+ (UIColor *)bodyTextColor
{
    return [UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:1.0];
}

+ (UIColor *)cellTextColor
{
    return [UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1.0];
}

+ (UIColor *)subCellTextColor
{
    return [UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1.0];
}

@end
