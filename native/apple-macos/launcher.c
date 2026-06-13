#include <errno.h>
#include <libgen.h>
#include <limits.h>
#include <mach-o/dyld.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char** argv)
{
    char executable_path[PATH_MAX];
    char runtime_path[PATH_MAX];
    uint32_t executable_path_size = sizeof(executable_path);
    char** runtime_argv;
    char* executable_dir;
    int input_index;
    int output_index;

    if (_NSGetExecutablePath(executable_path, &executable_path_size) != 0) {
        fprintf(stderr, "aivectra launcher: executable path is too long\n");
        return 126;
    }
    executable_dir = dirname(executable_path);
    if (snprintf(runtime_path, sizeof(runtime_path), "%s/ailang-runtime", executable_dir) >=
        (int)sizeof(runtime_path)) {
        fprintf(stderr, "aivectra launcher: runtime path is too long\n");
        return 126;
    }

    runtime_argv = calloc((size_t)argc + 1U, sizeof(char*));
    if (runtime_argv == NULL) {
        fprintf(stderr, "aivectra launcher: unable to allocate runtime arguments\n");
        return 126;
    }
    runtime_argv[0] = runtime_path;
    output_index = 1;
    input_index = 1;
    while (input_index < argc) {
        if (strncmp(argv[input_index], "-psn_", 5U) != 0) {
            runtime_argv[output_index++] = argv[input_index];
        }
        input_index += 1;
    }

    if (setenv("AILANG_DISABLE_RUN_TOOL_DISPATCH", "1", 1) != 0) {
        fprintf(stderr, "aivectra launcher: unable to configure runtime dispatch: %s\n", strerror(errno));
        free(runtime_argv);
        return 126;
    }

    execv(runtime_path, runtime_argv);
    fprintf(stderr, "aivectra launcher: unable to start runtime: %s\n", strerror(errno));
    free(runtime_argv);
    return 126;
}
