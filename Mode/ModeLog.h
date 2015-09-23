#ifndef ModeLog_h
#define ModeLog_h

#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)


#endif /* ModeLog_h */
