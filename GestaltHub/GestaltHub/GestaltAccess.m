/*
 * Based on worse_query
 *
 * Copyright (C) 2026 Taj C (forcequit)
 *
 * This file has been modified and integrated into GestaltHub.
 *
 * Copyright (C) 2026 thanking157
 *
 * Licensed under the GNU General Public License v3.0.
 */
#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <xpc/xpc.h>
#include <sys/stat.h>
#import "GestaltAccess.h"

typedef void *(*query_create_fn)(void);
typedef void (*query_u64_fn)(void *, uint64_t);
typedef void (*query_identifiers_fn)(void *, xpc_object_t);
typedef void *(*query_result_fn)(void *);
typedef void (*query_free_fn)(void *);
typedef char *(*copy_token_fn)(void *);
typedef int64_t (*consume_fn)(const char *);
typedef int (*release_fn)(int64_t);

static void restore_caches(NSString *group) {
    NSFileManager *files = NSFileManager.defaultManager;
    NSURL *root = [files containerURLForSecurityApplicationGroupIdentifier:group];
    if (!root) return;
    NSURL *caches = [root URLByAppendingPathComponent:@"Library/Caches"];
    [files removeItemAtURL:caches error:nil];
    [files createDirectoryAtURL:caches withIntermediateDirectories:NO attributes:nil error:nil];
}

int64_t gestalthub_worse_query(NSString *target, NSString *group, bool alt_flags, bool create_dir) {
    if (!target.length || !group.length) return -1;
    if (!create_dir) { struct stat st; if (lstat(target.fileSystemRepresentation, &st) != 0) return -255; }
    NSFileManager *files = NSFileManager.defaultManager;
    NSURL *root = [files containerURLForSecurityApplicationGroupIdentifier:group];
    if (!root) return -1;
    NSString *caches = [[root URLByAppendingPathComponent:@"Library/Caches"] path];
    void *manager = dlopen("/usr/lib/system/libsystem_containermanager.dylib", RTLD_NOW | RTLD_LOCAL);
    if (!manager) return -2;
    query_create_fn create = (query_create_fn)dlsym(manager, "container_query_create");
    query_u64_fn set_class = (query_u64_fn)dlsym(manager, "container_query_set_class");
    query_identifiers_fn set_groups = (query_identifiers_fn)dlsym(manager, "container_query_set_group_identifiers");
    query_u64_fn set_flags = (query_u64_fn)dlsym(manager, "container_query_operation_set_flags");
    query_u64_fn set_part = (query_u64_fn)dlsym(manager, "container_query_operation_set_part");
    query_result_fn result_for_query = (query_result_fn)dlsym(manager, "container_query_get_single_result");
    query_free_fn free_query = (query_free_fn)dlsym(manager, "container_query_free");
    copy_token_fn copy_token = (copy_token_fn)dlsym(manager, "container_copy_sandbox_token");
    consume_fn consume = (consume_fn)dlsym(RTLD_DEFAULT, "sandbox_extension_consume");
    if (!create || !set_class || !set_groups || !set_flags || !set_part || !result_for_query || !free_query || !copy_token || !consume) { dlclose(manager); return -2; }
    void *query = create();
    if (!query) { dlclose(manager); return -3; }
    set_class(query, 7);
    xpc_object_t identifier = xpc_string_create(group.UTF8String);
    set_groups(query, identifier); set_part(query, 3);
    set_flags(query, alt_flags ? 0x0000000800000000ULL : 0x0000008000000000ULL);
    [files removeItemAtPath:caches error:nil];
    if (![files createSymbolicLinkAtPath:caches withDestinationPath:target error:nil]) { free_query(query); dlclose(manager); return -4; }
    void *result = result_for_query(query);
    if (!result) { free_query(query); dlclose(manager); restore_caches(group); return -5; }
    char *token = copy_token(result);
    if (!token) { free_query(query); dlclose(manager); restore_caches(group); return -6; }
    int64_t handle = consume(token);
    free_query(query); free(token); dlclose(manager); restore_caches(group);
    return handle;
}

void gestalthub_worse_query_release(int64_t handle) {
    if (handle < 0) return;
    release_fn release = (release_fn)dlsym(RTLD_DEFAULT, "sandbox_extension_release");
    if (release) release(handle);
}
