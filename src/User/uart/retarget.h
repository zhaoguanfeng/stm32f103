#ifndef __RETARGET_H
#define __RETARGET_H

#ifdef __cplusplus
extern "C" {
#endif

#include "stm32f1xx.h"
#include <sys/stat.h>
#include <stdio.h>


void RetargetInit(UART_HandleTypeDef *huart);
int _isatty(int fd);
int _write(int fd, char *ptr, int len);
int _close(int fd);
int _lseek(int fd, int ptr, int dir);
int _read(int fd, char *ptr, int len);
int _fstat(int fd, struct stat *st);
int fputc(int ch, FILE *f);
int fgetc(FILE *f);


#ifdef __cplusplus
}
#endif

#endif
