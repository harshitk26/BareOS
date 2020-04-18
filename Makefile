ARMGNU ?= aarch64-linux-gnu
ARCH = arm64

CFLAGS = -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles # -mgeneral-regs-only
ASMOPS = -Iinclude 

ARCH_DIR = arch/$(ARCH)
BUILD_DIR = build
SRC_DIR = kernel

DRIVERS = $(SRC_DIR)/drivers
FS = $(SRC_DIR)/fs
MM = $(SRC_DIR)/mm
NET = $(SRC_DIR)/net

all : kernel8.img

clean :
	rm -rf $(BUILD_DIR) *.img 

$(BUILD_DIR)/%_c.o: $(SRC_DIR)/%.c
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

$(BUILD_DIR)/%_s.o: $(ARCH_DIR)/%.S
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(ASMOPS) -MMD -c $< -o $@

$(BUILD_DIR)/%_s.o: $(MM)/%.S
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(ASMOPS) -MMD -c $< -o $@


MAIN_FILES = $(wildcard $(SRC_DIR)/*.c)
ARCH_FILES = $(wildcard arch/$(ARCH)/*.S)
MM_FILES = $(wildcard $(MM)/*.S)

OBJ_FILES = $(MAIN_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(ARCH_FILES:$(ARCH_DIR)/%.S=$(BUILD_DIR)/%_s.o)
OBJ_FILES += $(MM_FILES:$(MM)/%.S=$(BUILD_DIR)/%_s.o)

DEP_FILES = $(OBJ_FILES:%.o=%.d)
-include $(DEP_FILES)

kernel8.img: arch/$(ARCH)/linker.ld $(OBJ_FILES)
	@echo "$(C_FILES)"
	$(ARMGNU)-ld -T arch/$(ARCH)/linker.ld -o $(BUILD_DIR)/kernel8.elf  $(OBJ_FILES)
	$(ARMGNU)-objcopy $(BUILD_DIR)/kernel8.elf -O binary kernel8.img
