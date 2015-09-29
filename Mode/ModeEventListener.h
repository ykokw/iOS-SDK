
#import <SocketRocket/SRWebSocket.h>
#import "ModeData.h"

@interface MODEEventListener : NSObject<SRWebSocketDelegate> {
    SRWebSocket* websocket;
    id <SRWebSocketDelegate> delegate;
    NSURL* url;
    int retryWait;
    int fibCounter;
}

/**
 *  If you want to disable auto-reconnect, set the flag @NO.
 *  The flag is set to @YES when initWithClientAuthentication is called.
 */
@property (readwrite, assign)BOOL autoReconnect;

typedef void (^didOpenBlock)();
typedef void (^didFailBlock)(NSError*);
typedef void (^didCloseBlock)(NSInteger, NSString *, BOOL);
typedef void (^didReceiveBlock)(MODEDeviceEvent*, NSError*);

/**
 *  Called when WebSocket connection is established.
 */
@property (readwrite, copy)didOpenBlock didOpen;

/**
 *  Called when WebSocket connection is failed. You can get NSError as the reason.
 */
@property (readwrite, copy)didFailBlock didFail;

/**
 *  Called when WebSocket connection is closed.
 */
@property (readwrite, copy)didCloseBlock didClose;

/**
 *  Called whenever message arrives from MODE cloud and can get MODEDeviceEvent.
 *  It is set by startListenToEvents
 */
@property (nonatomic, copy)didReceiveBlock didReceive;

/**
 *  Initializes MODEEventListner with USER_TOKEN.
 *
 *  @param clientAuthentication USER_TOKEN
 *
 *  @return
 */
- (MODEEventListener*)initWithClientAuthentication:(MODEClientAuthentication*)clientAuthentication;

/**
 *  Starts listening events from MODE cloud
 *
 *  @param didReceive Specify callback function to receive MODEDeviceEvent
 *
 *  @return
 */
- (MODEEventListener*)startListenToEvents:(void(^)(MODEDeviceEvent*, NSError*))didReceive;

/**
 *  Auto-reconnect is implemented and enabled when initWithClientAuthentication is called.
 *  But you need to proactively call reconnect function if you disable autoReconnect flag to @NO
 */
- (void)reconnect;

/**
 *  Stop listening to events and disconnect WebSocket connection.
 *  You need to call startListenToEvents again after you want to restart listening.
 */
- (void)stopListenToEvents;

@end

