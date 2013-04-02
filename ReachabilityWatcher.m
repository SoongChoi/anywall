//
//  ReachabilityWatcher.m
//  PlayBook
//
//  Created by 전명곤 on 11. 12. 19..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReachabilityWatcher.h"
#import <arpa/inet.h> // For AF_INET, etc.
#import <ifaddrs.h> // For getifaddrs()
#import <net/if.h> // For IFF_LOOPBACK

@implementation UIDevice (ReachabilityCallback)

SCNetworkConnectionFlags	connectionFlags;
SCNetworkReachabilityRef	reachability;

#pragma mark Checking Connections
+ (void) pingReachabilityInternal
{
	if (!reachability)
	{
		BOOL				ignoresAdHocWiFi	= NO;
		struct sockaddr_in	ipAddress;
		
		bzero(&ipAddress, sizeof(ipAddress));
		
		ipAddress.sin_len			= sizeof(ipAddress);
		ipAddress.sin_family		= AF_INET;
		ipAddress.sin_addr.s_addr	= htonl(ignoresAdHocWiFi ? INADDR_ANY : IN_LINKLOCALNETNUM);
		
		reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr *)&ipAddress);
		
		CFRetain(reachability);
	}
	
	BOOL	didRetrieveFlags	= SCNetworkReachabilityGetFlags(reachability, &connectionFlags);
	
	if (!didRetrieveFlags)
	{
		NSLog(@"Error, Could not recover reachability flags");
	}
}

#pragma mark Monitoring reachability
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void * info)
{
	NSAutoreleasePool *	pool = [NSAutoreleasePool new];
	
	[(id)info performSelector:@selector(reachabilityChanged:)];
	
	[pool release];
}


+ (BOOL) scheduleReachabilityWatcher:(id)watcher
{
	if (![watcher conformsToProtocol:@protocol(ReachabilityWatcher)])
	{
		NSLog(@"Watcher doesn't conform to protocol.");
		return NO;
	}
	
	[self pingReachabilityInternal];
	
	SCNetworkReachabilityContext	context = {0, watcher, NULL, NULL, NULL};

	if (SCNetworkReachabilitySetCallback(reachability, ReachabilityCallback, &context))
	{
		if (!SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopCommonModes))
		{
			NSLog(@"Error Could not schedule reachability");
			
			SCNetworkReachabilitySetCallback(reachability, NULL, NULL);
			
			return NO;
		}
	}
	else
	{
		NSLog(@"Error Could not set reachability callback");
		return NO;
	}

	return YES;
}

+ (void) unscheduleReachabilityWatcher
{
	SCNetworkReachabilitySetCallback(reachability, NULL, NULL);
	
	if (SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopCommonModes))
	{
		NSLog(@"Unscheduled reachability");
	}
	else 
	{
		NSLog(@"Error Could not unschedule reachability");
	}
	
	CFRelease(reachability);
	reachability = nil;
}

+ (BOOL) networkAvailable
{
	[self pingReachabilityInternal];
	BOOL isReachable = ((connectionFlags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((connectionFlags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

+ (BOOL) activeWWAN
{
	if (![self networkAvailable]) return NO;
	return ((connectionFlags & kSCNetworkReachabilityFlagsIsWWAN) != 0);
}

+ (BOOL) activeWLAN
{
	return ([UIDevice localWiFiIPAddress] != nil);
}

+ (NSString *) localWiFiIPAddress
{
	BOOL					success = NO;
	struct ifaddrs *		addrs;
	const struct ifaddrs *	cursor;
	
	success = getifaddrs(&addrs) == 0;
	
	if (success)
	{
		cursor = addrs;
		
		while (cursor) 
		{
			if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) != 0)
			{
				NSString *	name = [NSString stringWithUTF8String:cursor->ifa_name];
				
				if ([name isEqualToString:@"en0"] == YES || [name isEqualToString:@"lo0"] == YES)
				{
					return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
				}
			}
			
			cursor = cursor->ifa_next;
		}
		
		freeifaddrs(addrs);
	}
		
	return nil;
}











@end

