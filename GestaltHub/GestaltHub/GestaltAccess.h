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
#include <stdint.h>
#include <stdbool.h>
int64_t gestalthub_worse_query(NSString *path, NSString *group, bool alt_flags, bool create_dir);
void gestalthub_worse_query_release(int64_t handle);
