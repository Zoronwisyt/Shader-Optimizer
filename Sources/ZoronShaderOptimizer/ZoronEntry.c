#include <stdio.h>

// Reference Swift entrypoint
extern void zoron_shader_opt_swift_entry(void);

// Auto-run when dylib is loaded into memory
__attribute__((constructor))
static void ZoronShaderOptimizerConstructor(void) {
    printf("[ZoronShaderOptimizer] Constructor fired! Initializing Metal shader optimization engine...\n");
    zoron_shader_opt_swift_entry();
}
