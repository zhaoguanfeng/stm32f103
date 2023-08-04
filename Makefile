##########################################################################################################################
# version : 1.0
##########################################################################################################################

# ------------------------------------------------
# stm32f103c8t6 Makefile (based on gcc)
#
# ChangeLog :
# ------------------------------------------------

#######################################
# binaries
#######################################
PREFIX = arm-none-eabi-
# The gcc compiler bin path can be either defined in make command via GCC_PATH variable (> make GCC_PATH=xxx)
# either it can be added to the PATH environment variable.
ifdef GCC_PATH
CC = $(GCC_PATH)/$(PREFIX)gcc
AS = $(GCC_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
DP = $(GCC_PATH)/$(PREFIX)objdump
else
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
DP = $(PREFIX)objdump
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

TARGET = stm32f103$(c)
PRINT_INFO = @
# Build path
OBJ_DIR = obj
BIN_DIR = bin

######################################
# IF c = c8t , START_UP_FILE = startup_stm32f103xb.s ,LDSCRIPT = STM32F103C8Tx_FLASH.ld
# IF c = zet , START_UP_FILE = startup_stm32f103xe.s ,LDSCRIPT = STM32F103ZETx_FLASH.ld
######################################
c = c8t

ifeq ($(c),c8t)
	LDSCRIPT = STM32F103C8Tx_FLASH.ld
	START_UP_FILE := startup_stm32f103xb.s
	C_DEFS = -DSTM32F103xB
else ifeq ($(c),zet)
	LDSCRIPT = STM32F103ZETx_FLASH.ld
	START_UP_FILE := startup_stm32f103xe.s
	C_DEFS = -DSTM32F103xE
endif

C_DEFS +=  -DUSE_HAL_DRIVER 

######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization
OPT = -Og

######################################
# source
######################################
TOP :=./src

LDSCRIPT_PATH = $(TOP)/Link/$(LDSCRIPT)

SRCDIRS :=  \
$(TOP)/Hal/HAL_CFG \
$(TOP)/Hal/STM32F1xx_HAL_Driver/Src \
$(TOP)/Interrupt \
$(TOP)/System \
$(TOP)/User/main\
$(TOP)/User/led\
$(TOP)/User/uart

# C includes path
INCDIRS := \
$(TOP)/System/Include\
$(TOP)/Cmsis/Include\
$(TOP)/Hal/HAL_CFG \
$(TOP)/Hal/STM32F1xx_HAL_Driver/Inc \
$(TOP)/Hal/STM32F1xx_HAL_Driver/Legacy \
$(TOP)/Interrupt \
$(TOP)/System \
$(TOP)/User/main\
$(TOP)/User/led \
$(TOP)/User/uart


# AS includes
AS_INCLUDES = 
# C includes
C_INCLUDES := $(patsubst %,-I %,$(INCDIRS))

#找出所有.s文件放到SFILES中，.s文件是带路径的
SFILES := $(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.s))
SFILES += $(TOP)/Cmsis/startup_files/$(START_UP_FILE)
#找出所有.c文件放到SFILES中，.c文件是带路径的
CFILES := $(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.c))


#编译选项
#######################################
# # CFLAGS
#######################################
# cpu
CPU = -mcpu=cortex-m3

# fpu
# NONE for Cortex-M0/M0+/M3

# float-abi

# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# macros for gcc
# AS defines
AS_DEFS = 



# compile gcc flags
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif

# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

# libraries
LIBS = -lc -lm -lnosys 
LIBDIR = 
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT_PATH) $(LIBDIR) $(LIBS) -Wl,-Map=$(BIN_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# default action: build all
all: clean $(BIN_DIR)/$(TARGET).elf $(BIN_DIR)/$(TARGET).hex $(BIN_DIR)/$(TARGET).bin $(BIN_DIR)/$(TARGET).s


#######################################
# build the application
#######################################
# list of objects
#OBJECTS在希望得到 $(OBJ_DIR)/*.o 时，就会去执行 $(OBJ_DIR)/%.o: %.c 目标
OBJECTS = $(addprefix $(OBJ_DIR)/,$(notdir $(CFILES:.c=.o))) 
vpath %.c $(sort $(dir $(CFILES)))
# list of ASM program objects
OBJECTS += $(addprefix $(OBJ_DIR)/,$(notdir $(SFILES:.s=.o)))
vpath %.s $(sort $(dir $(SFILES)))

#.o文件全部放到output文件中
########################################################################################
# | 是管道的意思
$(OBJ_DIR)/%.o: %.c |$(OBJ_DIR) COMPILE_INFO
	$(PRINT_INFO) $(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(OBJ_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(OBJ_DIR)/%.o: %.s |$(OBJ_DIR)
	$(PRINT_INFO) $(AS) -c $(CFLAGS) $< -o $@

#编译结果全部放到bin文件中	
#加了%，就是将所有elf文件生成hex\bin，所以 $(BIN_DIR)/%.hex: $(BIN_DIR)/%.elf 看起来是一个目标，
#实际上它是很多个目标，所以不能在all的依赖中，直接填$(BIN_DIR)/%.hex，而是需要填写具体的名字
########################################################################################
$(BIN_DIR)/$(TARGET).elf: $(OBJECTS) |$(BIN_DIR)
	
	$(PRINT_INFO)$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BIN_DIR)/%.hex: $(BIN_DIR)/%.elf
	$(HEX) $< $@
	
$(BIN_DIR)/%.bin: $(BIN_DIR)/%.elf
	$(BIN) $< $@	

$(BIN_DIR)/%.s: $(BIN_DIR)/%.elf
	$(DP) -d $< >$@	
	
# arm-none-eabi-objdump.exe -d rtthread.elf >a.s	
	
#######################################
# make dir
#######################################

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)	
COMPILE_INFO:
	$(PRINT_INFO) echo "compiling......"
#######################################
# clean up
#######################################
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)
  
#######################################
# dependencies
#######################################
-include $(wildcard $(OBJ_DIR)/*.d)

# *** EOF ***