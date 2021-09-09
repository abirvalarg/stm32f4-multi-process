SRC=$(wildcard src/*.s)
OBJ=$(SRC:src/%.s=obj/%.o)

flash: firmware.bin
	st-flash --connect-under-reset write $< 0x08000000

dump: firmware
	arm-none-eabi-objdump -D $<

firmware.bin: firmware
	arm-none-eabi-objcopy -O binary $< $@

firmware: $(OBJ)
	arm-none-eabi-ld -nostdlib --gc-sections -T link.ld -o $@ $^

obj/%.o: src/%.s
	mkdir -p obj
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb -g -c -o $@ $<

.PHONY: flash
