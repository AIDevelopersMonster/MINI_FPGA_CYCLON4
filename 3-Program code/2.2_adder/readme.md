---

# 📘 **Full Adder — Полный однобитный сумматор**

### MINI_FPGA (Cyclone IV) — Базовые цифровые модули

Этот проект демонстрирует работу **полного однобитного сумматора** (Full Adder) на FPGA Cyclone IV.
Модуль принимает два однобитных операнда (**A**, **B**) и входной перенос (**Cin**), после чего формирует сумму (**S**) и выходной перенос (**Cout**).

Работа модуля отображается на светодиодах платы **MINI_FPGA (Cyclone IV)**.

---

# 🔧 **Структура проекта**

```
adder.v          — верхний уровень проекта (подключение к SW/LED)
Adder_module.v   — логика полного однобитного сумматора
```

---

# 🔬 **Логика полного сумматора**

Полный сумматор вычисляет:

### **Сумма:**

```
S = A ⊕ B ⊕ Cin
```

### **Перенос:**

```
Cout = (A & B) | (Cin & (A ⊕ B))
```

---

# 🧩 **Диаграмма работы Full Adder**

| A | B | Cin | S | Cout |
| - | - | --- | - | ---- |
| 0 | 0 | 0   | 0 | 0    |
| 0 | 0 | 1   | 1 | 0    |
| 0 | 1 | 0   | 1 | 0    |
| 0 | 1 | 1   | 0 | 1    |
| 1 | 0 | 0   | 1 | 0    |
| 1 | 0 | 1   | 0 | 1    |
| 1 | 1 | 0   | 0 | 1    |
| 1 | 1 | 1   | 1 | 1    |

---

# 📁 **Код проекта**

## **🔹 Верхний уровень: `adder.v`**

```verilog
module adder
(
    SW_In,
    LED_Out
);

    input  [2:0] SW_In;     // {Cin, A, B}
    output [1:0] LED_Out;   // {Cout, S}

    Adder_module U1
    (
        .a     ( SW_In[1]  ),
        .b     ( SW_In[0]  ),
        .c_in  ( SW_In[2]  ),

        .s     ( LED_Out[0] ),
        .c_out ( LED_Out[1] )
    );

endmodule
```

---

## **🔹 Логика сумматора: `Adder_module.v`**

```verilog
module Adder_module
(
    a,
    b,
    c_in,
    s,
    c_out
);

    input  wire a;
    input  wire b;
    input  wire c_in;

    output wire s;
    output wire c_out;

    assign s     = c_in ^ a ^ b;
    assign c_out = (a & b) | (c_in & (a ^ b));

endmodule
```

---

# 🛠 **Подключение к плате MINI_FPGA**

### **Переключатели SW_In:**

| SW  | Назначение            |
| --- | --------------------- |
| SW2 | Cin (входной перенос) |
| SW1 | A                     |
| SW0 | B                     |

### **Светодиоды LED_Out:**

| LED  | Значение       |
| ---- | -------------- |
| LED0 | S (сумма)      |
| LED1 | Cout (перенос) |

---

# 🎯 **Как протестировать**

1. Открыть проект в **Quartus Prime**
2. Подключить плату MINI_FPGA (Cyclone IV)
3. Прошить проект (`Programmer → Start`)
4. Изменять SW2–SW0
5. Наблюдать результат на LED0–LED1

---

# 🎓 **Что изучает студент**

✔ Логику полного сумматора
✔ Комбинационные схемы
✔ Передачу сигналов между модулями
✔ Работа с верхним уровнем проекта
✔ Применение XOR, AND, OR в вычислениях
✔ Фундамент цифровой логики, которая лежит в основе ALU

---

# 📎 **Ссылка на репозиторий**

[https://github.com/AIDevelopersMonster/MINI_FPGA_CYCLON4/](https://github.com/AIDevelopersMonster/MINI_FPGA_CYCLON4/)
# 📎 **Ссылка на плейлист FPGA**
[https://www.youtube.com/playlist?list=PLVoFIRfTAAI7-d_Yk6bNVnj4atUdMxvT5](https://www.youtube.com/playlist?list=PLVoFIRfTAAI7-d_Yk6bNVnj4atUdMxvT5)