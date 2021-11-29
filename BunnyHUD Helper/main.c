/*
See LICENSE folder for licensing information.
*/

#if USE_SWIFT_HELPER
#include <dlfcn.h>
#else
#include "include/capi/cef_app_capi.h"
#endif

#include "include/wrapper/cef_library_loader.h"
#include "include/cef_sandbox_mac.h"
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>

// Entry point function for sub-processes.
int main(int argc, char* argv[]) {
    // Initialize the macOS sandbox for this helper process.
    void* sandboxContext = cef_sandbox_initialize(argc, argv);
    if (!sandboxContext) {
        return 1;
    }
    
    // Load the CEF framework library at runtime instead of linking directly
    // as required by the macOS sandbox implementation.
    const char* format = "%s/../../../Chromium Embedded Framework.framework/Chromium Embedded Framework";
    char* dirName = dirname(argv[0]);
    size_t bufSize = snprintf(NULL, 0, format, dirName) + 1;
    char* fwPath = (char*)malloc(bufSize);
    snprintf(fwPath, bufSize, format, dirName);
    
    int success = cef_load_library(fwPath);
    free(fwPath);

    if (!success) {
        cef_sandbox_destroy(sandboxContext);
        return 2;
    }
    
#if USE_SWIFT_HELPER
    void* lib = dlopen("SwiftHelper.framework/SwiftHelper", RTLD_LAZY);
    if (!lib) {
        cef_unload_library();
        cef_sandbox_destroy(sandboxContext);
        return 3;
    }
    
    int (*helperMain)(void) = dlsym(lib, "HelperMain");
    dlclose(lib);

    if (!helperMain) {
        cef_unload_library();
        cef_sandbox_destroy(sandboxContext);
        return 4;
    }

    int retval = helperMain();
#else
    // Provide CEF with command-line arguments.
    cef_main_args_t mainArgs = {.argc = argc, .argv = argv};
    
    // Execute the sub-process.
    int retval = cef_execute_process(&mainArgs, NULL, NULL);
#endif
    
    cef_unload_library();
    cef_sandbox_destroy(sandboxContext);
    
    return retval;
}

