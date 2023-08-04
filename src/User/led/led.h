#ifndef __LED_H
#define __LED_H

#ifdef __cplusplus
extern "C" {
#endif

#include "stm32f1xx.h"

#define USR_DEF_LED0_GPIOPORT     GPIOB    
#define USR_DEF_LED0_GPIOPIN      GPIO_PIN_5
#define USR_DEF_LED0_GPIO_RCC     __HAL_RCC_GPIOB_CLK_ENABLE()

#define LED0(a)	HAL_GPIO_WritePin(USR_DEF_LED0_GPIOPORT,USR_DEF_LED0_GPIOPIN,a)


void MX_GPIO_Init(void);

#ifdef __cplusplus
}
#endif


#endif

