#include "uart.h"

UART_HandleTypeDef UartHandle;

void DEBUG_USART_Config(void)
{ 
	UartHandle.Instance          = DEBUG_USART;

	UartHandle.Init.BaudRate     = DEBUG_USART_BAUDRATE;
	UartHandle.Init.WordLength   = UART_WORDLENGTH_8B;
	UartHandle.Init.StopBits     = UART_STOPBITS_1;
	UartHandle.Init.Parity       = UART_PARITY_NONE;
	UartHandle.Init.HwFlowCtl    = UART_HWCONTROL_NONE;
	UartHandle.Init.Mode         = UART_MODE_TX_RX;

	HAL_UART_Init(&UartHandle);

//  __HAL_UART_ENABLE_IT(&UartHandle,UART_IT_RXNE);  
}

void HAL_UART_MspInit(UART_HandleTypeDef *huart)
{  
	GPIO_InitTypeDef  GPIO_InitStruct;

	DEBUG_USART_CLK_ENABLE();

	DEBUG_USART_RX_GPIO_CLK_ENABLE();
	DEBUG_USART_TX_GPIO_CLK_ENABLE();

	/**USART1 GPIO Configuration    
	PA9     ------> USART1_TX
	PA10    ------> USART1_RX 
	*/
	GPIO_InitStruct.Pin = DEBUG_USART_TX_PIN;
	GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
	GPIO_InitStruct.Pull = GPIO_PULLUP;
	GPIO_InitStruct.Speed =  GPIO_SPEED_FREQ_HIGH;
	HAL_GPIO_Init(DEBUG_USART_TX_GPIO_PORT, &GPIO_InitStruct);

	GPIO_InitStruct.Pin = DEBUG_USART_RX_PIN;
	GPIO_InitStruct.Mode=GPIO_MODE_AF_INPUT;		
	HAL_GPIO_Init(DEBUG_USART_RX_GPIO_PORT, &GPIO_InitStruct); 

//  HAL_NVIC_SetPriority(DEBUG_USART_IRQ ,0,1);	
//  HAL_NVIC_EnableIRQ(DEBUG_USART_IRQ );		      
}


void Usart_SendString(uint8_t *str)
{
	uint32_t k=0;
	do 
	{
		HAL_UART_Transmit(&UartHandle,(uint8_t *)(str + k) ,1,1000);
		k++;
	} while(*(str + k)!='\0');
  
}
