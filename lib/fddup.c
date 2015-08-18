/*
	thanks to Stéphane Chazelas at
	http://unix.stackexchange.com/a/99041/89283
*/

#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int whichfd(const char *pathname)
{
  unsigned int fd;
  if (sscanf(pathname, "/dev/fd/%u", &fd) == 1)
    return fd;
  else
    return -1;
}

int open(const char *pathname, int flags, mode_t mode)
{
  static int (*orig)(const char *, int, mode_t) = 0;
  int fd = whichfd(pathname);
  if (fd >= 0)
    return dup(fd);
  else {
    if (!orig)
      orig = dlsym(RTLD_NEXT,"open");
    if (!orig) abort();
    return orig(pathname, flags, mode);
  }
}

FILE *fopen(const char *path, const char *mode)
{
  static FILE *(*orig)(const char *, const char *) = 0;
  int fd = whichfd(path);
  if (fd >= 0)
    return fdopen(dup(fd), mode);
  else {
    if (!orig)
      orig = dlsym(RTLD_NEXT,"fopen");
    if (!orig) abort();
    return orig(path, mode);
  }
}
