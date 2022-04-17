![语言](https://img.shields.io/badge/语言-systemverilog_(IEEE1800_2005)-CAD09D.svg) ![仿真](https://img.shields.io/badge/仿真-iverilog-green.svg) ![部署](https://img.shields.io/badge/部署-quartus-blue.svg) ![部署](https://img.shields.io/badge/部署-vivado-FF1010.svg)

中文 | [English](#en)

Verilog SHA Family
===========================

使用 FPGA 计算 SHA1/SHA224/SHA256/SHA384/SHA512



# 代码文件一览

| 所在目录 | 文件名称 | 描述    | 备注   |
| :---: | :--- | :--- | :--- |
| RTL | sha1.sv | SHA1 计算器 | 可综合 |
| RTL | sha224.sv | SHA224 计算器 | 可综合 |
| RTL | sha256.sv | SHA256 计算器 | 可综合 |
| RTL | sha384.sv | SHA384 计算器 | 可综合 |
| RTL | sha512.sv | SHA512 计算器 | 可综合 |
| SIM | tb_sha1.sv | SHA1 仿真代码 | 读取SIM/test_data中的文件，发送给 SHA1 计算器 |
| SIM | tb_sha224.sv | SHA224 仿真代码 | 读取SIM/test_data中的文件，发送给 SHA224 计算器 |
| SIM | tb_sha256.sv | SHA256 仿真代码 | 读取SIM/test_data中的文件，发送给 SHA256 计算器 |
| SIM | tb_sha384.sv | SHA384 仿真代码 | 读取SIM/test_data中的文件，发送给 SHA384 计算器 |
| SIM | tb_sha512.sv | SHA512 仿真代码 | 读取SIM/test_data中的文件，发送给 SHA512 计算器 |



# 使用方法

这些不同的 SHA 计算器使用统一的，标准的 AXI-stream 接口来输入待计算的数据流。例如，你想分别计算字符串 '12' 和 '123' 的哈希值，则应按照如下波形图进行操作。

> 注意：字符 '1', '2', '3' 的 ASCII 码分别是 8'h31, 8'h32, 8'h33

| ![](./figures/wave.png) |
| :----: |
| **图1** : 波形图 |

注意：

* 模块会针对每个数据流计算一个 SHA 值。
* 每个数据流必须以 tlast=1 结尾，也就是说，在发送一个数据流的最后一个字节的同时要让 tlast=1 。
* tvalid=1 时，说明外界想输入一个字节给它，所以 tvalid=1 的同时 tdata 上要有有效数据。
* 虽然以上波形图中，数据流中的各个字节是连续输入的，但我们并不要求这样，你可以在输入数据流中加入气泡，也就是让 tvalid=0，此时相当于没有输入数据（空闲一个周期）。
* tready=0 时，说明模块还没有准备好接受一个字节。只有 tvalid 和 tready 同时 =1 时，tdata上的字节才能被接收，下周期才能发送下一个字节。
* 每当一个数据流输入完成后，也就是从 tlast=1 的下一周期开始，tready才会保持若干个周期=0。其余时候 tready=1。
* 每当一个数据流输入完成后，经过若干周期后，ovalid 会产生一周期的1，此时可以从 osha 中读出哈希值，同时可以从olen中读出数据长度。
* 不需要等到 ovalid=1 后再输入下一个数据流，只需要等到 tready=1 时，就能输入下一个数据流。
* tid 是允许用户自定义的数据流标识，用于将输入数据流和输出的哈希值对应起来，在输入数据流的第一个字节的同时，可以在 tid 输出一个标识，则该标识会在 oid 上与哈希值一同输出。



# 仿真

仿真相关的文件都在 SIM 目录中：

其中有 5 个仿真代码文件可以分别进行 SHA1, SHA224, SHA256, SHA384, SHA512 模块的仿真，它们会读取 SIM/test_data 中的文件，并将文件中的所有字节发送给 SHA 计算机，针对每个文件计算出 SHA 值。

使用 iverilog 进行仿真前，需要安装 iverilog ，见：[iverilog_usage](https://github.com/WangXuan95/WangXuan95/blob/main/iverilog_usage/iverilog_usage.md)

然后双击 .bat 文件来运行仿真。比如 tb_sha256_run_iverilog.bat 运行的是 SHA256 的仿真。仿真的过程中就会打印各文件的 SHA 值。仿真结束后，可以打开生成的波形文件 dump.vcd 来查看波形。



# 资源占用

下表展示了在 **Xilinx Artix-7 xc7a35ticsg324-1** 上的综合结果。

| 模块名称 | LUT占用量 | LUT百分比 | FF占用量 | LUT百分比 |
| :-----: | :-----:   | :-----:      | :-----: | :-----:      |
| **sha1**    | 759  | 3.7%  | 1820 | 4.4% |
| **sha224**  | 1284 | 6.2%  | 2149 | 5.2% |
| **sha256**  | 1284 | 6.2%  | 2149 | 5.2% |
| **sha384**  | 2350 | 11.3% | 3734 | 9.0% |
| **sha512**  | 2350 | 11.3% | 3734 | 9.0% |



<span id="en">Verilog SHA Family</span>
===========================

Calculate SHA1/SHA224/SHA256/SHA384/SHA512 using FPGA.



# Source File List

| Folder | File Name    | Discription        | remark                                                       |
| :----: | :----------- | :----------------- | :----------------------------------------------------------- |
|  RTL   | sha1.sv      | SHA1 Calculator    | Synthesizable                                                |
|  RTL   | sha224.sv    | SHA224 Calculator  | Synthesizable                                                |
|  RTL   | sha256.sv    | SHA256 Calculator  | Synthesizable                                                |
|  RTL   | sha384.sv    | SHA384 Calculator  | Synthesizable                                                |
|  RTL   | sha512.sv    | SHA512 Calculator  | Synthesizable                                                |
|  SIM   | tb_sha1.sv   | SHA1's Testbench   | Read files from [SIM/test_data](./SIM/test_data) , send to SHA1 Calculator. |
|  SIM   | tb_sha224.sv | SHA224's Testbench | Read files from [SIM/test_data](./SIM/test_data) , send to SHA224 Calculator. |
|  SIM   | tb_sha256.sv | SHA256's Testbench | Read files from [SIM/test_data](./SIM/test_data) , send to SHA256 Calculator. |
|  SIM   | tb_sha384.sv | SHA384's Testbench | Read files from [SIM/test_data](./SIM/test_data) , send to SHA384 Calculator. |
|  SIM   | tb_sha512.sv | SHA512's Testbench | Read files from [SIM/test_data](./SIM/test_data) , send to SHA512 Calculator. |



# Usage

These various SHA calculators use a unified, standard AXI-stream interface to input the data stream to be calculated. For example, if you want to calcuate the SHA value of the strings '12' and '123' respectively, you should do the following waveform diagram.

> Note: The ASCII codes of characters '1', '2', '3' are 8'h31, 8'h32, 8'h33 respectively

| ![](./figures/wave.png) |
| :---------------------: |
|    **图1** : 波形图     |

Notice:

* The module generates one SHA value for each data stream.
* Each data stream must end with `tlast=1`, that is, send the last byte of the data stream with `tlast=1` .
* `tvalid=1` means that the user wants to input a byte to it, so when `tvalid=1`, there must be valid data on `tdata` simutinously.
* Although each byte in the data stream is input continuously in the above waveform diagram, we do not require this. You can add bubbles to the input data stream, that is, let `tvalid=0`, which is equivalent to no input data at this time. (idle for one cycle).
* When `tready=0`, the module is not ready to accept a byte. Only when `tvalid=1` and `tready=1` at the same time, the byte on `tdata` can be accept.
* Whenever a data stream input is completed, that is, starting from the next cycle of `tlast=1`, `tready` will keep several cycles=0. The rest of the time `tready=1`.
* Whenever a data stream input is completed, after several cycles, `ovalid` will generate a cycle of 1. At this time, the SHA value can be read from `osha`, and the data length can be read from `olen`.
* No need to wait until `ovalid=1` to input the next data stream, just wait until `tready=1` to input the next data stream.
* `tid` is a user-defined data stream identifier, which is used to correspond the input data stream and the output hash value. While inputting the first byte of the data stream, an identifier can be output in `tid`, then the identifier Will be output on oid along with the SHA value.



# RTL Simulation

Simulation related files are in the [SIM](./SIM) directory:

There are 5 simulation code files for SHA1, SHA224, SHA256, SHA384, SHA512 module simulation respectively, they will read the files in [SIM/test_data](./SIM/test_data) and send all the bytes in the files to the SHA calculator, and calculates the SHA value for each file.

Before using iverilog for simulation, you need to install iverilog , see: [iverilog_usage](https://github.com/WangXuan95/WangXuan95/blob/main/iverilog_usage/iverilog_usage.md)

Then double-click the .bat file to run the simulation. For example, tb_sha256_run_iverilog.bat runs an simulation of SHA256. During the simulation, the SHA value of each file is printed. After the simulation, you can open the generated waveform file dump.vcd to view the waveform.



# Resource Usage

The table below shows the synthesize results on **Xilinx Artix-7 xc7a35ticsg324-1**.

|   Module   | LUT Usage | LUT % | FF Usage | LUT % |
| :--------: | :-------: | :---: | :------: | :---: |
|  **sha1**  |    759    | 3.7%  |   1820   | 4.4%  |
| **sha224** |   1284    | 6.2%  |   2149   | 5.2%  |
| **sha256** |   1284    | 6.2%  |   2149   | 5.2%  |
| **sha384** |   2350    | 11.3% |   3734   | 9.0%  |
| **sha512** |   2350    | 11.3% |   3734   | 9.0%  |
