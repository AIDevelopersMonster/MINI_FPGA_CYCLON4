
# 2.1 — Логические элементы (Gate Module)

### Проект: **MINI_FPGA (Cyclone IV)**

В этом упражнении создаётся набор логических элементов на FPGA Cyclone IV.
Проект принимает два входных сигнала с переключателей и выводит результаты **шести** логических операций на светодиоды платы.

Этот урок является частью обучающей серии по FPGA и Quartus для платы **MINI_FPGA на базе Cyclone IV EP4CE6**.

---

## 📌 Цели задания

* Научиться создавать иерархический проект в Quartus.
* Освоить передачу сигналов между верхним модулем и внутренним модулем.
* Реализовать базовые логические операции (AND, OR, XOR, NAND, NOR, XNOR).
* Наблюдать результаты операций на светодиодах платы.

---

## 📁 Структура проекта

```
/project/
│
├── gate.v          — верхний уровень (top-level)
├── Gate_module.v   — модуль логики (шесть операций)
└── README.md        — описание (этот файл)
```

---

## 🔧 Аппаратные сигналы

* **Входы:**
  `SW_In[1:0]` — два переключателя SW0 и SW1 на плате.

* **Выходы:**
  `LED_Out[5:0]` — светодиоды LED0–LED5.

Каждый светодиод отображает результат одной логической операции.

---

## 🧠 Таблица соответствий логических операций

| LED  | Gate_Out[x] | Операция | Обозначение       | Логика                        |
| ---- | ----------- | -------- | ----------------- | ----------------------------- |
| LED0 | 0           | AND      | И                 | 1, если оба входа = 1         |
| LED1 | 1           | NAND     | И-НЕ              | инверсия AND                  |
| LED2 | 2           | OR       | ИЛИ               | 1, если хотя бы один вход = 1 |
| LED3 | 3           | NOR      | ИЛИ-НЕ            | инверсия OR                   |
| LED4 | 4           | XOR      | исключающее ИЛИ   | 1, если входы разные          |
| LED5 | 5           | XNOR     | исключающ. ИЛИ-НЕ | 1, если входы равны           |

---

## 📘 Верхний модуль (`gate.v`)

```verilog
module gate
(
    SW_In,
    LED_Out
);

    input  [1:0] SW_In;
    output [5:0] LED_Out;

    Gate_module U1
    (
        .Gate_In ( SW_In  ),
        .Gate_Out( LED_Out )
    );

endmodule
```

---

## 📘 Логический модуль (`Gate_module.v`)

```verilog
module Gate_module
(
    Gate_In, 
    Gate_Out
);

    input  [1:0] Gate_In;
    output reg [5:0] Gate_Out;

    always @ (Gate_In[0] or Gate_In[1]) 
    begin 
        Gate_Out[0] = Gate_In[0] &  Gate_In[1];  // AND
        Gate_Out[1] = ~(Gate_In[0] & Gate_In[1]); // NAND
        Gate_Out[2] = Gate_In[0] |  Gate_In[1];  // OR
        Gate_Out[3] = ~(Gate_In[0] | Gate_In[1]); // NOR
        Gate_Out[4] = Gate_In[0] ^  Gate_In[1];  // XOR
        Gate_Out[5] = Gate_In[0] ~^ Gate_In[1];  // XNOR
    end

endmodule
```

---

## 🧪 Проверка работы

1. Скомпилируйте проект в Quartus.
2. Назначьте выводы:

   * `SW_In[0]` → SW0
   * `SW_In[1]` → SW1
   * `LED_Out[0..5]` → LED0..LED5
3. Загрузите прошивку в FPGA.
4. Переключайте SW0 и SW1 и наблюдайте, как изменяются светодиоды.

---

## 📝 Ожидаемые результаты

Пример:
Если входы = `SW_In = 01`, то получаем:

```
AND   = 0
NAND  = 1
OR    = 1
NOR   = 0
XOR   = 1
XNOR  = 0
```

То есть светодиоды LED0–LED5 будут:
`0 1 1 0 1 0`

---

## 📎 Репозиторий проекта

🔗 GitHub:
[https://github.com/AIDevelopersMonster/MINI_FPGA_CYCLON4/](https://github.com/AIDevelopersMonster/MINI_FPGA_CYCLON4/)

