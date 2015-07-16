#import "LMRoundButton.h"
#import "LMUIColor+Extentions.h"

@implementation LMRoundButton

-(id)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.layer.cornerRadius = 5.0f;
    }
    
    return self;
}

@end

@implementation LMRoundBoundaryButton

-(id)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.layer.borderColor = [UIColor defaultThemeColor].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 5.0f;
    }
    
    return self;
}


@end
