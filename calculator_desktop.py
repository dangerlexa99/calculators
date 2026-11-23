"""Десктопный калькулятор на Python (tkinter). Запуск: python calculator_desktop.py"""
import tkinter as tk

KEYS = [
    ["C", "±", "%", "÷"],
    ["7", "8", "9", "×"],
    ["4", "5", "6", "−"],
    ["1", "2", "3", "+"],
    ["⌫", "0", ".", "="],
]


def fmt(n):
    if n != n or n in (float("inf"), float("-inf")):
        return "Ошибка"
    return f"{n:.12g}"


def calc(a, op, b):
    if op == "+": return a + b
    if op == "−": return a - b
    if op == "×": return a * b
    if op == "÷": return float("nan") if b == 0 else a / b
    return b


class Calculator(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Калькулятор")
        self.resizable(False, False)
        self.configure(bg="#1b222b", padx=12, pady=12)
        self.cur, self.acc, self.op, self.fresh = "0", None, None, True

        self.tape = tk.Label(self, anchor="e", fg="#8793a3", bg="#1b222b", font=("Segoe UI", 11))
        self.tape.grid(row=0, column=0, columnspan=4, sticky="ew")
        self.screen = tk.Label(self, text="0", anchor="e", fg="#eef2f6", bg="#1b222b",
                               font=("Segoe UI", 30), width=12)
        self.screen.grid(row=1, column=0, columnspan=4, sticky="ew", pady=(0, 8))

        for r, row in enumerate(KEYS, start=2):
            for c, k in enumerate(row):
                bg = "#d9822b" if k == "=" else "#4a7fb0" if k in "÷×−+" else "#252e39"
                tk.Button(self, text=k, width=5, height=2, font=("Segoe UI", 14), fg="#fff",
                          bg=bg, activebackground=bg, relief="flat", bd=0,
                          command=lambda k=k: self.press(k)).grid(row=r, column=c, padx=3, pady=3)

        keymap = {"*": "×", "/": "÷", "-": "−", "Return": "=", "Escape": "C", "BackSpace": "⌫", ",": "."}
        self.bind("<Key>", lambda e: self.press(keymap.get(e.keysym, keymap.get(e.char, e.char))))

    def press(self, k):
        if self.cur == "Ошибка" and k != "C":
            return
        if k.isdigit() and len(k) == 1:
            self.cur = k if self.fresh or self.cur == "0" else self.cur + k
            self.fresh = False
        elif k == ".":
            if self.fresh:
                self.cur, self.fresh = "0.", False
            elif "." not in self.cur:
                self.cur += "."
        elif k == "C":
            self.cur, self.acc, self.op, self.fresh = "0", None, None, True
        elif k == "⌫":
            self.cur = self.cur[:-1] if len(self.cur) > 1 and not self.fresh else "0"
            if self.cur == "-":
                self.cur = "0"
        elif k == "±":
            if self.cur != "0":
                self.cur = self.cur[1:] if self.cur.startswith("-") else "-" + self.cur
        elif k == "%":
            self.cur, self.fresh = fmt(float(self.cur) / 100), True
        elif k == "=":
            if self.op and self.acc is not None:
                self.cur = fmt(calc(self.acc, self.op, float(self.cur)))
                self.acc, self.op, self.fresh = None, None, True
        elif k in "÷×−+":
            if self.op and self.acc is not None and not self.fresh:
                self.cur = fmt(calc(self.acc, self.op, float(self.cur)))
            if self.cur == "Ошибка":
                return self.render()
            self.acc, self.op, self.fresh = float(self.cur), k, True
        self.render()

    def render(self):
        self.screen.config(text=self.cur)
        self.tape.config(text=f"{fmt(self.acc)} {self.op}" if self.op and self.acc is not None else "")


if __name__ == "__main__":
    Calculator().mainloop()
