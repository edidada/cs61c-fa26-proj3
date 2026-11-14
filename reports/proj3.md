# CS61CPU 实施与验收记录

官方要求：https://cs61c.org/fa26/projects/proj3/part-a/ 和 https://cs61c.org/fa26/projects/proj3/part-b/ 。

完整范围：ALU、32寄存器、五类立即数、完整控制逻辑、部分读写、单周期完整指令及Part B流水线。保留原锁定接口、原测试和禁止元件规则。原公开测试不是全覆盖，需补自定义指令、数据/控制相关与流水线刷新验证。

当前仅实现 branch_comp：并列有符号/无符号比较器，BrUn选择小于结果，等于结果与符号无关。原引脚位置及外部接口保持。独立Actions运行原三项分支比较测试；尚未验收整个Project3，也未实现其他模块/流水线。

本地仅编辑和XML解析，不编译或运行模拟器；Java仅作为官方Logisim运行时。校内身份、组队与Gradescope未执行。
