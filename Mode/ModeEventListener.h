#import "AFNetworking.h"

#import "SRWebSocket.h"
#import "ModeData.h"

@interface MODEEventListener : NSObject<SRWebSocketDelegate>

@property (nonatomic, strong)SRWebSocket* websocket;
@property (nonatomic, strong)id <SRWebSocketDelegate> delegate;
@property (nonatomic, strong)NSURL* url;


@property (nonatomic, assign)int retryWait;
@property (nonatomic, assign)int fibCounter;
@property (readwrite, assign)BOOL autoReconnect;


typedef void (^didOpenBlock)();
typedef void (^didFailBlock)(NSError*);
typedef void (^didCloseBlock)(NSInteger, NSString *, BOOL);
typedef void (^didReceiveBlock)(MODEDeviceEvent*, NSError*);

@property (readwrite, copy)didOpenBlock didOpen;
@property (readwrite, copy)didFailBlock didFail;
@property (readwrite, copy)didCloseBlock didClose;
@property (nonatomic, copy)didReceiveBlock didReceive;

- (MODEEventListener*)initWithClientAuthentication:(MODEClientAuthentication*)clientAuthentication;
- (MODEEventListener*)startListenToEvents:(void(^)(MODEDeviceEvent*, NSError*))didReceive;

- (void)reconnect;

- (void)stopListenToEvent;


@end

