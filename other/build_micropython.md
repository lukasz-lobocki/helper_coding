# Build micropython with SPIRAM

![ESP](https://github.com/lukasz-lobocki/helper_coding/blob/main/other/Feather%20ESP32-S3%20SPIRAM.png)

Check [this](https://github.com/micropython/micropython/tree/master/ports/esp32) page.

## Toolset

```bash
sudo apt install build-essential git python3 python3-dev \
  python3-pip python3-setuptools python3-venv cmake
```

Usually already installed, maybe with the exception for `cmake`.

## Install the ESP-IDF

```bash
git clone -b v5.0.2 git@github.com:espressif/esp-idf.git
```

```bash
cd esp-idf
```

Check [here](https://github.com/micropython/micropython/tree/master/ports/esp32) if `v5.0.2` is still the proper one.

```bash
fish_greeting > /dev/null 2>&1 || ./install.sh
fish_greeting > /dev/null 2>&1 && ./install.fish
```

then

```bash
fish_greeting > /dev/null 2>&1 || source export.sh
fish_greeting > /dev/null 2>&1 && source export.fish
```

## Clone micropython source

```bash
git clone git@github.com:lukasz-lobocki/lobo_micropython \
  && cd lobo_micropython
```

```bash
git remote add upstream git@github.com:micropython/micropython.git
```

```bash
git checkout -b <dev-branch>
```

<details>
<summary>Using original micropython repo.</summary>

```bash
git clone git@github.com:micropython/micropython.git
```

## Update config for 4MB and 2MB SPIRAM (PSRAM)

Check [this](https://github.com/orgs/micropython/discussions/10156) page.

> It's only a straightforward change but it does necessitate compilation. In `ports/esp32/boards/GENERIC_S3_SPIRAM/sdkconfig.board` you need to make the following changes to: \
> \
> CONFIG_ESPTOOLPY_FLASHSIZE_4MB \
> CONFIG_ESPTOOLPY_FLASHSIZE_8MB \
> CONFIG_PARTITION_TABLE_CUSTOM_FILENAME

```text
CONFIG_FLASHMODE_QIO=y
CONFIG_ESPTOOLPY_FLASHFREQ_80M=y
CONFIG_ESPTOOLPY_FLASHSIZE_DETECT=y
CONFIG_ESPTOOLPY_AFTER_NORESET=y

CONFIG_SPIRAM_MEMTEST=

CONFIG_ESPTOOLPY_FLASHSIZE_4MB=y # This was unset
CONFIG_ESPTOOLPY_FLASHSIZE_8MB= # This was set
CONFIG_ESPTOOLPY_FLASHSIZE_16MB=
CONFIG_PARTITION_TABLE_CUSTOM=y
CONFIG_PARTITION_TABLE_CUSTOM_FILENAME="partitions.csv" # This pointed to 'partitions-8MiB.csv'
```

```bash
cd lobo_micropython
pushd ../espressif/esp-idf \
  && source export.sh \
  && popd
make -C mpy-cross \
  && make -C ports/esp32 submodules all BOARD=GENERIC_S3_SPIRAM
```

```bash
grep -E 'app_bin|target|project' \
  ports/esp32/build-GENERIC_S3_SPIRAM/project_description.json ; \
echo "" ; \
grep -E '^(CONFIG_ESPTOOLPY_FLASHSIZE|CONFIG_PARTITION_TABLE_CUSTOM)' \
  ports/esp32/build-GENERIC_S3_SPIRAM/sdkconfig
echo "" ; \
grep -E '^0x' ports/esp32/build-GENERIC_S3_SPIRAM/flash_args \
  | xargs -I@ \
  echo "esptool --chip esp32s3 --port /dev/ttyACM0 write_flash $(grep -E '^--' ports/esp32/build-GENERIC_S3_SPIRAM/flash_args) @"
```

```bash
esptool --port /dev/ttyACM0 --baud 460800 --chip esp32s3 \
  --before default_reset --after no_reset \
  write_flash --flash_size 4MB --flash_freq 80m \
  0x0 ports/esp32/build-GENERIC_S3_SPIRAM/firmware.bin
```

</details>

## Compilation

makes **all-in-one**.

```bash
cd lobo_micropython
```

```bash
git checkout ADAFRUIT_4M_2M_SPIRAM
```

```bash
pushd ../esp-idf \
  && source export.sh \
  && popd \
  && make -C mpy-cross \
  && make -C ports/esp32 submodules all BOARD=ADAFRUIT_4M_2M_SPIRAM
```

or, for _Fish_.

```bash
pushd ../esp-idf \
  && source export.fish \
  && popd \
  && make -C mpy-cross \
  && make -C ports/esp32 submodules all BOARD=ADAFRUIT_4M_2M_SPIRAM
```

<details>
<summary>Cleaning.</summary>

```bash
cd lobo_micropython
```

```bash
pushd ../esp-idf \
  && source export.sh \
  && popd \
  && make -C mpy-cross clean \
  && make -C ports/esp32 clean BOARD=ADAFRUIT_4M_2M_SPIRAM
```

</details>

## Output

See the result.

```bash
grep -E 'project_name|target|build_dir' \
  ports/esp32/build-ADAFRUIT_4M_2M_SPIRAM/project_description.json | sed -e 's/^[[:space:]]*//' ; \
echo "" ; \
grep -E '^(CONFIG_ESPTOOLPY_FLASHSIZE|CONFIG_PARTITION_TABLE_CUSTOM)' \
  ports/esp32/build-ADAFRUIT_4M_2M_SPIRAM/sdkconfig
echo "" ; \
grep -E '^0x' ports/esp32/build-ADAFRUIT_4M_2M_SPIRAM/flash_args \
  | xargs -I@ \
  echo "esptool --chip esp32s3 --port /dev/ttyACM0 write_flash $(grep -E '^--' ports/esp32/build-ADAFRUIT_4M_2M_SPIRAM/flash_args) @"
```

## Flashing

Erasing.

```bash
esptool --chip esp32s3 --port /dev/ttyACM0 --after no_reset \
  chip_id \
&& esptool --chip esp32s3 --port /dev/ttyACM0 --after no_reset \
  erase_flash
```

Flash **all-in-one**.

```bash
esptool --chip esp32s3 --port /dev/ttyACM0 --after no_reset \
  chip_id \
&& esptool --port /dev/ttyACM0 --baud 460800 --chip esp32s3 \
  --before default_reset --after no_reset \
  write_flash --flash_size 4MB --flash_freq 80m \
  0x0 ports/esp32/build-ADAFRUIT_4M_2M_SPIRAM/firmware.bin
```

<details>
<summary>Or use values from `flash_args` file above.</summary>

```bash
esptool --chip esp32s3 --port /dev/ttyACM0 write_flash 0x0 bootloader.bin
```

```bash
esptool --chip esp32s3 --port /dev/ttyACM0 write_flash 0x10000 micropython.bin
```

```bash
esptool --chip esp32s3 --port /dev/ttyACM0 write_flash 0x8000 partition-table.bin
```

</details>

## Workflow

Read [this](https://github.com/micropython/micropython/wiki/Micropython-Git-Development-Workflow) page.
