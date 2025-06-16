#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#ifdef __cplusplus
extern "C" {
#endif

int mkdir(const char *pathname, mode_t mode)
{
    return -1;
}

int rmdir(const char *pathname)
{
    return -1;
}

char *getcwd(char *buf, size_t size)
{
    if (!buf)
        return NULL;

    buf[0] = ':';
    buf[1] = 0;

    return buf;
}

int chdir(const char *path)
{
    return 0;
}

int access(const char *pathname, int mode)
{
    int result = open(pathname, O_RDWR);
    close(result);
    return result >= 0;
}

int creat(const char *pathname, mode_t mode)
{
    return open(pathname, O_CREAT, mode);
}

#ifdef __cplusplus
}
#endif
