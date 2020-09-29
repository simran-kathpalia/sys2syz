# Sys2Syz <!-- omit in toc -->

## Overview <!-- omit in toc -->

Sys2Syz is a tool which automates the conversion of syscalls and other Ioctl calls to [syzkaller's](https://github.com/google/syzkaller) representation. This tool was created with a motive of increasing the syscall coverage for leveling up the support of syzkaller for NetBSD. Currently, the tool only supports grammar generation for NetBSD - we plan to add support for other operating systems soon.

## Table of Contents <!-- omit in toc -->

- [1. Reports](#1-reports)
- [2. Working](#2-working)
- [3. Installation](#3-installation)
  - [3.1. Dependencies](#31-dependencies)
  - [3.2. Build on Linux](#32-build-on-linux)
- [4. Usage](#4-usage)
- [5. Results](#5-results)
- [6. Features](#6-features)
- [7. TODO](#7-todo)

## 1. Reports

Below are the reports on the tool - written as a part of Google Summer of Code - 2020

- [Enhancing Syzkaller support for NetBSD - Part 1](https://blog.netbsd.org/tnf/entry/gsoc_reports_enhancing_syzkaller_support)
- [Enhancing Syzkaller support for NetBSD - Part 2](https://blog.netbsd.org/tnf/entry/gsoc_reports_enhancing_syzkaller_support1)

## 2. Working

Work flow of the tool -

<img src="sys2syz.png"
     alt="Sys2syz design"
     class="center"
     width="450" height="600"
     style="margin-left: 10px;
  margin-right: 10px;" />
     
The tool supports generation of syzkaller descriptions for NetBSD device driver's ioctl calls. Following steps are involved:

- Extraction of all ioctl commands of a given device driver along with their arguments from the header files. Ioctl commands in NetBSD can be identified with the help of some specific macros(`_IO`, `_IOR`, `_IOW`, `_IOWR`) - ([core/Extractor.py](https://github.com/ais2397/sys2syz/blob/gsoc-2020/core/Extractor.py)).
- Preprocessing of the device driver's files using compile_commands.json generated during the setup of tool using Bear - ([core/Bear.py](https://github.com/ais2397/sys2syz/blob/gsoc-2020/core/Bear.py))
- XML files are generated by running c2xml on preprocessed device files. This eases the process of fetching the information related to arguments of commands - ([core/C2xml.py](https://github.com/ais2397/sys2syz/blob/gsoc-2020/core/C2xml.py))
- Generates descriptions for the ioctl commands and their arguments (builtin-types, arrays, pointers, structures and unions) using the XML files - ([core/Description.py](https://github.com/ais2397/sys2syz/blob/gsoc-2020/core/Description.py))

## 3. Installation

Here are the installation instructions for Sys2syz

### 3.1. Dependencies

- [Bear](https://github.com/rizsotto/Bear) setup
- [NetBSD src](https://github.com/NetBSD/src) files

This is written for `python3`

Install the python dependencies using 

```shell
python3 -m pip install pybind11 lxml pylcs py_common_subseq
```

### 3.2. Build on Linux

- Clone the repo
 ```shell
 git clone https://github.com/ais2397/sys2syz.git
 cd sys2syz
 ```
- Run the setup script

**Note:** This step requires
- NetBSD toolchain. 
- Directory storing compiled modules should be cleaned before performing this step
 ```shell
 ./setup.sh -b <path_to_netbsd_src>
 ```
 
## 4. Usage

 To generate descriptions for a particular device driver(device_driver) run sys2syz.py:
```shell
python sys2syz.py -t <absolute_path_to_device_driver_source> -c compile_commands.json -v
```
This would generate a ```dev_<device_driver>.txt``` file in the ```out``` directory

## 5. Results

Example description file generated by sys2syz for i2c device- 
```txt
#Autogenerated by sys2syz
include <i2c_io.h>

resource fd_i2c[fd]

syz_open_dev$I2C(dev ptr[in, string["/dev/i2c"]], id intptr, flags flags[open_flags]) fd_i2c

ioctl$I2C_IOCTL_EXEC(fd fd_i2c, cmd const[I2C_IOCTL_EXEC], arg ptr[out, i2c_ioctl_exec])

i2c_ioctl_exec {
iie_op	flags[i2c_op_t_flags]
iie_addr	int16
iie_buflen	len[iie_buf, intptr]
iie_buf	buffer[out]
iie_cmdlen	len[iie_cmd, intptr]
iie_cmd	buffer[out]
}
```

## 6. Features

- Fetches ioctl calls of a particular device driver.
- Generates a file having syzkaller specific descriptions for fetched ioctl calls.

## 7. TODO

Features yet to be implemented:
- Generation of syzkaller descriptions for syscalls.
- Generation of descriptions for functions, passed as arguments to syscalls.
- Detection of flag type and extract values of flags
- Calculating Attributes for structs and unions

This tool is developed by Ayushi Sharma
