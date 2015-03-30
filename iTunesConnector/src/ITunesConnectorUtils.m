//
//  ITunesConnectorUtils.m
//  iTunesConnector
//
//  Created by Fernando Canon on 29/03/15.
//  Copyright (c) 2015 Fernando Canon. All rights reserved.
//

#import "ITunesConnectorUtils.h"

#import "NSFileHandle+Print.h"


static NSString *CommandLineEquivalentForTaskArchGenericTask(NSTask *task);



NSDictionary *LaunchTaskAndCaptureOutput(NSTask *task, NSString *description)
{
    NSPipe *stdoutPipe = [NSPipe pipe];
    __block NSFileHandle *stdoutHandle = [stdoutPipe fileHandleForReading];
    
    NSPipe *stderrPipe = [NSPipe pipe];
    NSFileHandle *stderrHandle = [stderrPipe fileHandleForReading];
    
    [task setStandardOutput:stdoutPipe];
    [task setStandardError:stderrPipe];
    
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    
        // Instead of using `-[Options showCommands]`, we look directly at the process
        // arguments.  This has two advantages: 1) we can start logging commands even
        // before Options gets parsed/initialized, and 2) we don't have to add extra
        // plumbing so that the `Options` instance gets passed into this function.
        if ([arguments containsObject:@"-showTasks"] ||
            [arguments containsObject:@"--showTasks"]) {
    
            NSMutableString *buffer = [NSMutableString string];
            [buffer appendFormat:@"\n================================================================================\n"];
            [buffer appendFormat:@"LAUNCHING TASK (%@):\n\n", description];
            [buffer appendFormat:@"%@",CommandLineEquivalentForTaskArchGenericTask(task)];
            [buffer appendFormat:@"================================================================================\n"];
            fprintf(stderr, "%s", [buffer UTF8String]);
            fflush(stderr);
        }
    

    [task launch];
    
    [task waitUntilExit];
    
    NSString *outPut = ProcessDataFromStoutPut(stdoutHandle);
    NSString *errorOut =  ProcessDataFromStoutPut(stderrHandle);
    
    return @{@"stdout":outPut,@"stderror":errorOut};
}




NSString *ProcessDataFromStoutPut(NSFileHandle *stOut) {
    
    NSData *outputData = [stOut readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    return outputString;
}


static NSString *QuotedStringIfNeeded(NSString *str) {
    if ([str rangeOfString:@" "].length > 0) {
        return (NSString *)[NSString stringWithFormat:@"\"%@\"", str];
    } else {
        return str;
    }
}


static NSString *CommandLineEquivalentForTaskArchGenericTask(NSTask *task) {
    
    NSMutableString *buffer = [NSMutableString string];
    
    [[task environment] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *val, BOOL *stop){
        [buffer appendFormat:@"  %@=%@ \\\n", key, QuotedStringIfNeeded(val)];
    }];
    
    NSCAssert(task.launchPath != nil, @"Should have a launchPath");
    [buffer appendFormat:@"  %@", QuotedStringIfNeeded(task.launchPath)];
    
    if (task.arguments.count > 0) {
        [buffer appendFormat:@" \\\n"];
        
        for (NSUInteger i = 0; i < task.arguments.count; i++) {
            if (i == (task.arguments.count - 1)) {
                [buffer appendFormat:@"    %@", QuotedStringIfNeeded(task.arguments[i])];
            } else {
                [buffer appendFormat:@"    %@ \\\n", QuotedStringIfNeeded(task.arguments[i])];
            }
        }
    }
    
    return buffer;
}

NSString *XcodeDeveloperDirPath(void) {
    
    NSTask * xcodePathTask = [[NSTask alloc] init];
    [xcodePathTask setLaunchPath:@"/usr/bin/xcode-select"];
    [xcodePathTask setArguments:@[@"--print-path"]];
    
    NSDictionary *output = LaunchTaskAndCaptureOutput(xcodePathTask,
                                                      @"finding Xcode path via xcode-select --print-path");
    NSString *path = output[@"stdout"];
    path = [path stringByTrimmingCharactersInSet:
            [NSCharacterSet newlineCharacterSet]];
    
    
    return [path stringByDeletingLastPathComponent];
}


