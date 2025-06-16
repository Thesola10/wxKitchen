#ifndef __INET_H
#define __INET_H

#include <machine/endian.h>

#define htonl(x) __htonl(x)
#define ntohl(x) __ntohl(x)
#define htons(x) __htons(x)
#define ntohs(x) __ntohs(x)

#endif //__INET_H
