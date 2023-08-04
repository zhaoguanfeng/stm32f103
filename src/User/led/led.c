#include "led.h"

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* GPIO Ports Clock Enable */
  USR_DEF_LED0_GPIO_RCC;

  /*Configure GPIO pin : PA3 */
  GPIO_InitStruct.Pin = USR_DEF_LED0_GPIOPIN;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
  HAL_GPIO_Init(USR_DEF_LED0_GPIOPORT, &GPIO_InitStruct);

  HAL_GPIO_WritePin(USR_DEF_LED0_GPIOPORT, USR_DEF_LED0_GPIOPIN, GPIO_PIN_SET);
}

