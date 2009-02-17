#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__)

require 'osx/cocoa'
include OSX
require 'controller'
require 'commandline_parser'

OSX::require_framework('/System/Library/Frameworks/WebKit.framework')

OSX::NSApplication.sharedApplication # create NSApp object


class AppDelegate < NSObject
  def applicationDidFinishLaunching(aNotification)
    puts "#{aNotification.name} makes me say: Hello, world\n"
  end
end

app_delegate = AppDelegate.alloc.init
NSApp.setDelegate(app_delegate)

parser = CommandlineParser.instance
parser.parse_commandline

# use 1x1 size: when pagination is turned off, the view should grow to the 
# required size, if turned on, the view should use the page size. 
webView = WebView.alloc.initWithFrame_frameName_groupName(NSMakeRect(0,0,1,1), "myFrame", "myGroup");



# Disabled this code
#
#   window = NSWindow.alloc.initWithContentRect_styleMask_backing_defer(
#           NSMakeRect(0,0,1,1),
#           NSBorderlessWindowMask,
#           NSBackingStoreNonretained, false)
#   window.setContentView(webView)
#
#
# It seems that this workaround is no longer needed. It used to be required to 
# due to a bug in WebKit that introduced a dependency between Cocoa and the WindowServer.
# Acutually it should be possible to use Cocoa views without a running Window server.
#
# Still, wkpdf causes the warning to be printed at application startup:
#
#   _RegisterApplication(), FAILED TO establish the default connection 
#   to the WindowServer, _CGSDefaultConnection() is NULL
#
# and a warning about a NSRecursiveLock error when terminating the application
#
#   ruby[3818:613] *** -[NSRecursiveLock unlock]: lock 
#   (<NSRecursiveLock: 0x6982d0> '(null)') unlocked when not locked
#   *** Break on _NSLockError() to debug.
#
# However, despite of these error messages, wkpdf seems to work just fine, even 
# without a connection to the WindowServer. This opens the way to a non-interactive
# use of wkpdf, e.g., on a server.

controller = Controller.alloc.initWithWebView(webView)
webView.setFrameLoadDelegate(controller)

#OSX::NSApp.run


pool = NSAutoreleasePool.alloc.init

puts "wkpdf started\n"


theURL = NSURL.URLWithString(parser.source)

request = NSURLRequest.requestWithURL_cachePolicy_timeoutInterval(theURL,NSURLRequestReloadIgnoringCacheData,200.0) 
webView.mainFrame.loadRequest(request)

NSRunLoop.currentRunLoop.run

webView.release

pool.release
exit 0


__END__

CommandlineParser * parser = [CommandlineParser sharedInstance];
[parser parseWithArgumentNumber:argc andCommandline:argv];
[parser prettyprint];

[NSApplication sharedApplication];

// use 1x1 size: when pagination is turned off, the view should grow to the 
// required size, if turned on, the view should use the page size. 
WebView * webView = [[WebView alloc] initWithFrame:NSMakeRect(0,0,1,1)
                                         frameName:@"myFrame"
                                         groupName:@"myGroup"];

NSWindow * window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,1,1) 
                                                styleMask:NSBorderlessWindowMask 
                                                  backing:NSBackingStoreNonretained defer:NO];
[window setContentView:webView];

Controller * controller = [[Controller alloc] initWithWebView:webView]; 

[webView setFrameLoadDelegate: controller];
[webView setResourceLoadDelegate: controller];
NSString *appName = [NSString stringWithFormat: @"wkpdf/%@", [parser getVersionString]];
[webView setApplicationNameForUserAgent:appName];

WebPreferences * webPrefs = [WebPreferences standardPreferences];
[webPrefs setLoadsImagesAutomatically:YES];
[webPrefs setAllowsAnimatedImages:YES];
[webPrefs setAllowsAnimatedImageLooping:NO];
[webPrefs setJavaEnabled:NO];
[webPrefs setPlugInsEnabled:[parser enablePlugins]];
[webPrefs setJavaScriptEnabled:YES];
[webPrefs setJavaScriptCanOpenWindowsAutomatically:NO];
[webPrefs setShouldPrintBackgrounds:[parser printBackground]];
[webView setPreferences:webPrefs];
[webView setMaintainsBackForwardList:NO];

if ([parser stylesheetMedia] != nil)
[webView setMediaStyle:[parser stylesheetMedia]];
LOG_DEBUG(@"media style is: %@", [webView mediaStyle]);

NSURL * theURL = [parser source];  
NSURLRequest * request = [NSURLRequest requestWithURL:theURL 
                                          cachePolicy: [parser cachingPolicy]
                                      timeoutInterval: [parser timeout]];

// TODO: detect timeout and terminate if timeout occured

[[webView mainFrame] loadRequest:request];
[[NSRunLoop currentRunLoop] run];
  
[webView release];