#!/bin/bash
gcc -Wall -fPIC -shared -o fddup.so lib/fddup.c -ldl
exit $?
