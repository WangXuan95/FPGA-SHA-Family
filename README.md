![test](https://img.shields.io/badge/test-passing-green.svg)
![docs](https://img.shields.io/badge/docs-passing-green.svg)
![platform](https://img.shields.io/badge/platform-Quartus|Vivado-blue.svg)

Verilog SHA Family
===========================

FPGA implementation of SHA1/SHA224/SHA256/SHA384/SHA512

使用 FPGA 计算 SHA1/SHA224/SHA256/SHA384/SHA512

# 文件

| 文件名称 | 描述    | 备注   |
| :---: | :--- | :--- |
| [**sha1.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/sha1.sv) | SHA1 计算器 | 可综合，独立模块，不调用其它模块 |
| [**sha224.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/sha224.sv) | SHA224 计算器 | 可综合，独立模块，不调用其它模块 |
| [**sha256.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/sha256.sv) | SHA256 计算器 | 可综合，独立模块，不调用其它模块 |
| [**sha384.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/sha384.sv) | SHA384 计算器 | 可综合，独立模块，不调用其它模块 |
| [**sha512.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/sha512.sv) | SHA512 计算器 | 可综合，独立模块，不调用其它模块 |
| [**tb_sha1.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/tb_sha1.sv) | SHA1 仿真顶层 | 读取指定的文件，发送给 SHA1 计算器 |
| [**tb_sha224.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/tb_sha224.sv) | SHA224 仿真顶层 | 读取指定的文件，发送给 SHA224 计算器 |
| [**tb_sha256.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/tb_sha256.sv) | SHA256 仿真顶层 | 读取指定的文件，发送给 SHA256 计算器 |
| [**tb_sha384.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/tb_sha384.sv) | SHA384 仿真顶层 | 读取指定的文件，发送给 SHA384 计算器 |
| [**tb_sha512.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/tb_sha512.sv) | SHA512 仿真顶层 | 读取指定的文件，发送给 SHA512 计算器 |

# 使用方法

这些模块使用统一的，标准的 AXI-stream 接口来输入待计算的数据流。例如，你想分别计算数据流 '12' 和 '123' 的哈希值，则应按照如下波形图进行操作。

其中，字符'1','2','3'的ASCII码分别是8'h31,8'h32,8'h33

| ![输入图](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/images/wave.png) |
| :----: |
| **图1** : 波形图 |

**注意**：
* 每个数据流以 tlast=1 结尾，每个数据流会产生一个 SHA 哈希值。
* 虽然该波形图中，每个数据流的各个字节是连续输入的，但我们并不要求这样，你可以在输入数据中加入气泡，气泡的 tvalid=0。
* tready=0 时，说明模块还没有准备好接受一个字节。只有 tvalid 和 tready 同时 =1 时，tdata上的信号才能被接收。
* 每当一个数据流输入完成后，也就是从 tlast=1 的下一周期开始，tready会保持若干个周期=0。其余时候 tready=1。
* 每当一个数据流输入完成后，经过若干周期后，ovalid 产生一周期的1，此时可以从osha中读出哈希值，同时可以从olen中读出数据长度。
* 不需要等到 ovalid=1 后再输入下一个数据流，只需要等到 tready=1 时，就能输入下一个数据流。
* tid 是允许用户自定义的数据流标识，用于将输入数据流和输出的哈希值对应起来，在输入数据流的第一个字节的同时，可以在 tid 输出一个标识，则该标识会在 oid 上与哈希值一同输出。

# 仿真

[RTL目录](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL) 里提供的5个仿真的顶层文件可以分别进行 SHA1, SHA224, SHA256, SHA384, SHA512 模块的仿真，它们能从你的文件系统中读取若干文件，并将其内容发送给 SHA 模块，针对每个文件计算出哈希值。

在进行仿真前，请从仿真文件的第82行开始，将待计算哈希值的文件的路径填入$fopen()中。注意，push_file 函数的第一个参数是你希望给这个数据流的标识（也就是tid的值），第二个参数是文件指针（也就是$fopen()的返回值）。

# 资源占用

下表展示了在 **Xilinx Artix-7 xc7a35ticsg324-1** 上的综合结果。

| 模块名称 | LUT占用量 | LUT百分比 | FF占用量 | LUT百分比 |
| :-----: | :-----:   | :-----:      | :-----: | :-----:      |
| **sha1**    | 759  | 3.7%  | 1820 | 4.4% |
| **sha224**  | 1284 | 6.2%  | 2149 | 5.2% |
| **sha256**  | 1284 | 6.2%  | 2149 | 5.2% |
| **sha384**  | 2350 | 11.3% | 3734 | 9.0% |
| **sha512**  | 2350 | 11.3% | 3734 | 9.0% |
