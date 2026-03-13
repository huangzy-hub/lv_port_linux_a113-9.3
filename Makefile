#
# Makefile (LVGL v9 极简适配版)
#

CC = arm-linux-gnueabi-gcc
LVGL_DIR_NAME ?= lvgl
LVGL_DIR ?= ${shell pwd}
# 改动1：添加 v9 必需的 LV_CONF_INCLUDE_SIMPLE 宏
CFLAGS ?= -O3 -g0 -I$(LVGL_DIR)/ -DLV_CONF_INCLUDE_SIMPLE=1 -Wall -Wshadow -Wundef -Wmissing-prototypes -Wno-discarded-qualifiers -Wall -Wextra -Wno-unused-function -Wno-error=strict-prototypes -Wpointer-arith -fno-strict-aliasing -Wno-error=cpp -Wuninitialized -Wmaybe-uninitialized -Wno-unused-parameter -Wno-missing-field-initializers -Wtype-limits -Wsizeof-pointer-memaccess -Wno-format-nonliteral -Wno-cast-qual -Wunreachable-code -Wno-switch-default -Wreturn-type -Wmultichar -Wformat-security -Wno-ignored-qualifiers -Wno-error=pedantic -Wno-sign-compare -Wno-error=missing-prototypes -Wdouble-promotion -Wclobbered -Wdeprecated -Wempty-body -Wtype-limits  -Wstack-usage=2048 -Wno-unused-value -Wno-unused-parameter -Wno-missing-field-initializers -Wuninitialized -Wmaybe-uninitialized -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -Wtype-limits -Wsizeof-pointer-memaccess -Wno-format-nonliteral -Wpointer-arith -Wno-cast-qual -Wmissing-prototypes -Wunreachable-code -Wno-switch-default -Wreturn-type -Wmultichar -Wno-discarded-qualifiers -Wformat-security -Wno-ignored-qualifiers -Wno-sign-compare
LDFLAGS ?= -lm -static -Wl,--dynamic-linker=/lib/ld-linux.so.3

BUILT_DIR = built
BIN = $(BUILT_DIR)/demo

MYCODE = $(wildcard my_project/*.c)
MAINSRC = ./main.c $(MYCODE)

# 保留核心 lvgl.mk（自动编译 LVGL 核心代码）
include $(LVGL_DIR)/lvgl/lvgl.mk

# 改动2：删除 v8 专属的驱动/输入法 mk（v9 内置驱动，无需独立 mk）
# include $(LVGL_DIR)/lv_drivers/lv_drivers.mk
#include $(LVGL_DIR)/lv_chinese_ime/lv_chinese_ime.mk

# 改动3：手动添加 v9 内置驱动源码（替代 lv_drivers.mk）
#CSRCS += \
$(LVGL_DIR)/lvgl/src/drivers/display/fb/lv_linux_fbdev.c \
$(LVGL_DIR)/lvgl/src/drivers/evdev/lv_evdev.c

# 改动4：可选删除 v8 鼠标光标文件（开发板无需）
# CSRCS +=$(LVGL_DIR)/mouse_cursor_icon.c 

OBJEXT ?= .o
AOBJS = $(addprefix $(BUILT_DIR)/, $(ASRCS:.S=$(OBJEXT)))
COBJS = $(addprefix $(BUILT_DIR)/, $(CSRCS:.c=$(OBJEXT)))
MAINOBJ = $(addprefix $(BUILT_DIR)/, $(MAINSRC:.c=$(OBJEXT)))

SRCS = $(ASRCS) $(CSRCS) $(MAINSRC)
OBJS = $(AOBJS) $(COBJS)

all: default

$(BUILT_DIR)/%.o: %.c
	@mkdir -p $(BUILT_DIR)
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "CC $< -> $@"
    
default: $(AOBJS) $(COBJS) $(MAINOBJ)
	$(CC) -o $(BIN) $(MAINOBJ) $(AOBJS) $(COBJS) $(LDFLAGS)
	@echo "Link -> $(BIN)"

clean: 
	rm -rf $(BUILT_DIR)/*
	@echo "Clean $(BUILT_DIR) done"