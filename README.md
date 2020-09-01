
Verilog SHA Family
===========================
FPGA implementation of SHA256/SHA224
使用 FPGA 计算 SHA256/SHA224

# 文件

| 文件名称 | 描述    | 备注   |
| :---: | :---: | :--- |
| [**sha256.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/sha256.sv) | SHA256 计算器 | 可综合，独立模块，不调用其它模块 |
| [**tb_sha256.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/tb_sha256.sv) | SHA256 仿真顶层 | 读取若干个指定的文件（请从81行开始修改，以指定需要输入的文件），发送给 sha256计算器 |
| [**sha224.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/sha224.sv) | SHA224 计算器 | 可综合，独立模块，不调用其它模块 |
| [**tb_sha224.sv**](https://github.com/WangXuan95/Verilog-SHA-Family/blob/master/RTL/tb_sha224.sv) | SHA224 仿真顶层 | 读取若干个指定的文件（请从81行开始修改，以指定需要输入的文件），发送给 sha224计算器 |
| 待实现 | SHA1   计算器 |  - |
| 待实现 | SHA512 计算器 |  - |
| 待实现 | SHA384 计算器 |  - |

# 使用方法

这些模块使用统一的，标准的 AXI-stream 接口来输入待计算的数据流。例如，你想分别计算数据流 '12' 和 '123' 的哈希值，则应按照如下波形图进行操作。（8'h31,8'h32,8'h33 分别是字符'1','2','3' 的ASCII码。

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
