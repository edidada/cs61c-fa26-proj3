# CS61CPU 实施与验收记录

依据官方 [Part A](https://cs61c.org/fa26/projects/proj3/part-a/) 与 [Part B](https://cs61c.org/fa26/projects/proj3/part-b/)，实现完整公开代码任务，包括两阶段流水线。校内身份、组队、个人反馈表、Gradescope 与私有评分未执行，不将公开测试等同于这些要求。

## 电路与接口

原锁定引脚位置、原自定义外观及外部接口保持；直接实例化经过原测试的模块，没有替换原 harness、参考数据或测试工具。

- ALU：加减、逻辑、低5位移位、signed slt、mul/mulh/mulhu及B直通；其余选择明确输出零。
- ImmGen：I/S/B/U/J，保持编码0/1/2/3/4，显式符号扩展和低位补零。
- RegFile：31个可写寄存器、恒零x0、RegWEn与索引共同使能写、双组合读及八个调试输出；上升沿提交。
- BrComp：有符号/无符号并列比较，由BrUn选择小于结果。
- Partial load/store：字节偏移、byte/half符号扩展（另支持无符号读）、word读写及lane掩码；MemRW=0时写掩码和写数据均为零。
- Control：14位ROM地址由opcode[6:0]、funct3、指令位30/25及BrEq/BrLt组成；16位控制字明确给出写使能、立即数、ALU、访存、写回和PC选择。无效opcode保持无副作用。BrUn从指令位13独立产生，避免比较器与ROM之间不确定值循环。
- CPU：完整算术/乘法/分支/访存/jal/jalr/lui/auipc，jalr清目标低位。普通下一PC取IF阶段PC+4；跳转目标与链接写回使用EX阶段PC。

## 流水线

IF/EX分别保存指令和对应PC。控制转移在EX解析；taken分支及全部jump将正在取的错误路径指令在进入指令寄存器前替换为addi x0,x0,0。未采取分支不刷新。首周期寄存器初始零指令不写寄存器/内存；相邻依赖指令在下一EX周期读取前一周期已提交的寄存器值。

单周期提交890977f7cf8c3c8ad550322a0fcbb613de8f1ab7的run43555974703已完成success：六模块26项、原15整机和自定义1轨迹通过，再进入Task10。最终电路为两阶段版本，按官方要求用--pipelined比较，不能再用非流水线轨迹验收。

## 可重现远端验证

工作流 .github/workflows/proj3.yml 调用 scripts/verify_proj3.sh，Java17运行官方Logisim与Venus。两工具来自starter指定fa24 Berkeley地址，固定SHA256：Logisim 8a963b4031c681f9945fb90f5a4c5506d6973dadb46844c44deca204258238df；Venus 69e48a8ffecb155d1227d171ae6888be0d3e103975d04b19762a08fc9463e1cc。

原run_test.py比较失败时可能仍exit0，所以每组均断言准确通过数：ALU6、ImmGen6、BrComp3、RegFile4、PartialLoad3、PartialStore4、整机15。另执行直接控制向量，并明确检查Passed: 1, Failed: 0。

自定义isa-boundaries.s覆盖要求的36类指令、连续依赖、INT_MIN/-1乘法高低位、负立即数、31/63移位量、x0、部分内存覆盖、有符号/无符号分支和jalr奇地址低位清零；错误路径包含可观察写入。原create_test.py使用官方Venus生成单周期/两阶段参考，最终按两阶段逐周期比较全部八个调试寄存器、PC和指令。完整日志、原/生成参考与实际轨迹、工具哈希及提交号作为工件保存。

最终提交/运行终态及逐文件哈希以langnote永久results.json登记为准。流水线当前仍须等待最终CI确认，不以历史单周期绿色代替。未声称超出上述指令集的完整RV32实现、时钟频率/物理时序或私有评分。

本地仅编辑、解析XML及读取源码，不编译或运行模拟器；没有新增Python源文件。Java仅作为官方工具运行时。
