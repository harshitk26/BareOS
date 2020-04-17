ARMGNU ?= aarch64-linux-gnu

CFLAGS = -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles # -mgeneral-regs-only
ASMOPS = -Iinclude 

BUILD_DIR = build
FS = fs
NET = net
DRIVERS = drivers
MM = mm
ARCH = arm64
SRC_DIR = kernel
all : kernel8.img

clean :
	rm -rf $(BUILD_DIR) *.img 

$(BUILD_DIR)/%_c.o: $(SRC_DIR)/%.c
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

$(BUILD_DIR)/%_s.o: arch/$(ARCH)/%.S
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(ASMOPS) -MMD -c $< -o $@

$(BUILD_DIR)/%_s.o: $(MM)/%.S
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(ASMOPS) -MMD -c $< -o $@


C_FILES = $(wildcard $(SRC_DIR)/*.c)
BOOT_FILES = $(wildcard arch/$(ARCH)/*.S)
MM_FILES = $(wildcard $(MM)/*.S)

OBJ_FILES = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(BOOT_FILES:arch/$(ARCH)/%.S=$(BUILD_DIR)/%_s.o)
OBJ_FILES += $(MM_FILES:$(MM)/%.S=$(BUILD_DIR)/%_s.o)

DEP_FILES = $(OBJ_FILES:%.o=%.d)
-include $(DEP_FILES)

kernel8.img: arch/$(ARCH)/linker.ld $(OBJ_FILES)
	@echo "$(C_FILES)"
	$(ARMGNU)-ld -T arch/$(ARCH)/linker.ld -o $(BUILD_DIR)/kernel8.elf  $(OBJ_FILES)
	$(ARMGNU)-objcopy $(BUILD_DIR)/kernel8.elf -O binary kernel8.img
