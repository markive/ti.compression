/**
 * Ti.Compression Module
 * Copyright (c) 2010-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiCompressionModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiCompressionModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"c129f5f7-ace8-4cca-be47-b226f8b29f78";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.compression";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[self fireEvent:@"lowmemory"];
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Helper Methods

-(NSString*)getNormalizedPath:(NSString*)source
{
	// NOTE: File paths may contain URL prefix as of release 1.7 of the SDK
	if ([source hasPrefix:@"file:/"]) {
		NSURL* url = [NSURL URLWithString:source];
		return [url path];
	}
	
	// NOTE: Here is where you can perform any other processing needed to
	// convert the source path. For example, if you need to handle
	// tilde, then add the call to stringByExpandingTildeInPath
	
	return source;
}

-(NSArray*)getNormalizedPaths:(NSArray*)source
{
    // NOTE: File paths may contain URL prefix as of release 1.7 of the SDK
    NSMutableArray *sourceUpdate = [source mutableCopy];
	NSUInteger count = [source count];
    for (NSUInteger i = 0; i < count; i++) {
        // do something with object
		NSString *fileName = [source objectAtIndex: i];
        NSLog(@"[INFO] file [%@]", fileName);
        if ([fileName hasPrefix:@"file:/"]) {
            NSURL* url = [NSURL URLWithString:fileName];
            NSLog(@"[INFO] url [%@]", [url path]);
            sourceUpdate[i] = [url path];
        }
    }
    
    return [NSArray arrayWithArray:sourceUpdate];
}

#pragma mark Public APIs

-(id)unzip:(id)args
{
	// unzip API requires 3 parameters:
	//   location:string - folder location to unzip the files
	//   filename:string - path to the zip file

	enum unzipArgs {
		kUnzipArgLocation  = 0,
		kUnzipArgFileName  = 1,
		kUnzipArgOverwrite = 2,
		kUnzipArgCount
	};	
	
	// Validate arguments
	ENSURE_ARG_COUNT(args, kUnzipArgCount);

	NSString* msg = @"";
	
	// Get and validate the folder location
	NSString* folderLocationIn = [args objectAtIndex:kUnzipArgLocation];
	NSString* folderLocation = [self getNormalizedPath:folderLocationIn];
	if (folderLocation == nil) {
		msg = [NSString stringWithFormat:@"Invalid folder location [%@]", folderLocationIn];
		NSLog(@"[ERROR] %@", msg);
		return msg;
	}
	
	// Get and validate the zip file name
	NSString* zipFileNameIn = [args objectAtIndex:kUnzipArgFileName];
	NSString* zipFileName = [self getNormalizedPath:zipFileNameIn];
	if (zipFileName == nil) {
		msg = [NSString stringWithFormat:@"Invalid archive file name [%@]", zipFileNameIn];
		NSLog(@"[ERROR] %@", msg);
		return msg;
	}
	
	BOOL overWrite = [TiUtils boolValue:[args objectAtIndex:kUnzipArgOverwrite] def:NO];
	
    BOOL success = [SSZipArchive unzipFileAtPath:zipFileName
                                   toDestination:folderLocation
                              preserveAttributes:YES
                                       overwrite:overWrite
                                  nestedZipLevel:0
                                        password:nil
                                           error:nil
                                        delegate:nil
                                 progressHandler:nil
                               completionHandler:nil];
    

		if (success) {
			msg = @"success";
			NSLog(@"[INFO] Archive file [%@] successfully extracted", zipFileName);
		} 
		else {
			msg = [NSString stringWithFormat:@"Failed to extract archive file [%@], may be password protected", zipFileName];
			NSLog(@"[ERROR] %@", msg);
		}
		
	return msg;
}

// Define the interval at which the autorelease pool will be drained. This value can be tuned to accommodate
// optimal memory usage. If memory needs to be released more frequently then set to a lower value; less 
// frequently then set to a higher value;
static const int kAutoReleaseInterval = 100;

// Create a zip file
-(id)zip:(id)args
{ 
	// zip API requires 2 parameters:
	//   filename:string - path to the zip file to create
	//   filearray:string - array of file paths to add to the zip

	enum zipArgs {
		kZipArgFileName  = 0,
		kZipArgFileArray = 1,
		kZipArgCount
	};
	
	// Validate arguments
	ENSURE_ARG_COUNT(args, kZipArgCount);

	NSString* msg = @"";
	
	// Get and validate the zip file name
	NSArray* zipFileArrayIn = [args objectAtIndex:kZipArgFileArray];
	NSArray* zipFileArray = [self getNormalizedPaths:zipFileArrayIn];
	if (zipFileArray == nil) {
		msg = [NSString stringWithFormat:@"Invalid archive file name [%@]", zipFileArrayIn];
		NSLog(@"[ERROR] %@", msg);
		return msg;
	}
    
    // Get and validate the zip file name
   NSString* _directoryPath = [args objectAtIndex:kZipArgFileName];
    NSString* directoryPath = [self getNormalizedPath:_directoryPath];
    if (directoryPath == nil) {
        msg = [NSString stringWithFormat:@"Invalid archive file name [%@]", directoryPath];
        NSLog(@"[ERROR] %@", msg);
        return msg;
    }
	
	
    BOOL success = [SSZipArchive createZipFileAtPath:directoryPath
                             withFilesAtPaths:zipFileArray];
    
    if (success) {
        NSLog(@"[INFO] Archive file created", directoryPath);
        msg = @"success";
        
    } else {
        msg = [NSString stringWithFormat:@"Unable to create archive file [%@]", directoryPath];
        NSLog(@"[ERROR] %@", msg);
    }
    
	return msg;
}

@end
