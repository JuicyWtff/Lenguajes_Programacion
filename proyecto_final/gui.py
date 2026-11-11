import tkinter as tk
from tkinter import ttk

import puente

LADO = 68
MARGEN = 28
TABLERO = LADO * 8

CLARO = "#efe4cf"
OSCURO = "#9a7b5a"
SELECCION = "#f2e36a"
DESTINO = "#8fc98f"
CLAVADA = "#e09a9a"
BORDE = "#4a3a2a"

GLIFOS = {
    ("blanca", "rey"): "♔", ("blanca", "dama"): "♕",
    ("blanca", "torre"): "♖", ("blanca", "alfil"): "♗",
    ("blanca", "caballo"): "♘", ("blanca", "peon"): "♙",
    ("negra", "rey"): "♚", ("negra", "dama"): "♛",
    ("negra", "torre"): "♜", ("negra", "alfil"): "♝",
    ("negra", "caballo"): "♞", ("negra", "peon"): "♟",
}

LETRAS = "abcdefgh"


def nombre(casilla):
    col, fila = casilla
    return LETRAS[col - 1] + str(fila)


class Aplicacion:
    def __init__(self, raiz):
        self.raiz = raiz
        raiz.title("JaqueLogico - arbitro de ajedrez en Prolog")
        raiz.resizable(False, False)

        self.tablero = list(puente.POSICIONES["Clavada"])
        self.turno = "blanca"
        self.seleccion = None
        self.destinos = []
        self.clavadas = []

        marco = ttk.Frame(raiz, padding=10)
        marco.grid(row=0, column=0)

        superior = ttk.Frame(marco)
        superior.grid(row=0, column=0, sticky="w", pady=(0, 8))

        ttk.Label(superior, text="Posicion:").grid(row=0, column=0, padx=(0, 6))
        self.combo = ttk.Combobox(
            superior,
            values=list(puente.POSICIONES.keys()),
            state="readonly",
            width=18,
        )
        self.combo.set("Clavada")
        self.combo.grid(row=0, column=1, padx=(0, 10))
        self.combo.bind("<<ComboboxSelected>>", self.cargar_posicion)

        ttk.Button(superior, text="Cambiar turno", command=self.cambiar_turno)\
            .grid(row=0, column=2, padx=(0, 10))
        ttk.Button(superior, text="Marcar clavadas", command=self.marcar_clavadas)\
            .grid(row=0, column=3)

        self.lienzo = tk.Canvas(
            marco,
            width=TABLERO + MARGEN * 2,
            height=TABLERO + MARGEN * 2,
            highlightthickness=0,
        )
        self.lienzo.grid(row=1, column=0)
        self.lienzo.bind("<Button-1>", self.clic)

        self.etiqueta = ttk.Label(marco, text="", font=("Segoe UI", 11, "bold"))
        self.etiqueta.grid(row=2, column=0, sticky="w", pady=(8, 4))

        self.registro = tk.Text(marco, width=56, height=9, wrap="word")
        self.registro.grid(row=3, column=0, sticky="we")
        self.registro.configure(state="disabled")

        self.dibujar()
        self.anotar("Sistema listo. Haz clic en una pieza para ver sus jugadas legales.")
        self.actualizar_estado()

    def anotar(self, texto):
        self.registro.configure(state="normal")
        self.registro.insert("end", texto + "\n")
        self.registro.see("end")
        self.registro.configure(state="disabled")

    def pieza_en(self, casilla):
        col, fila = casilla
        for pieza in self.tablero:
            if pieza[2] == col and pieza[3] == fila:
                return pieza
        return None

    def dibujar(self):
        self.lienzo.delete("all")
        for col in range(1, 9):
            for fila in range(1, 9):
                x1 = MARGEN + (col - 1) * LADO
                y1 = MARGEN + (8 - fila) * LADO
                casilla = (col, fila)

                color = CLARO if (col + fila) % 2 == 0 else OSCURO
                if casilla == self.seleccion:
                    color = SELECCION
                elif casilla in self.destinos:
                    color = DESTINO
                elif casilla in self.clavadas:
                    color = CLAVADA

                self.lienzo.create_rectangle(
                    x1, y1, x1 + LADO, y1 + LADO, fill=color, outline=""
                )

                pieza = self.pieza_en(casilla)
                if pieza:
                    glifo = GLIFOS[(pieza[0], pieza[1])]
                    self.lienzo.create_text(
                        x1 + LADO / 2,
                        y1 + LADO / 2,
                        text=glifo,
                        font=("Segoe UI Symbol", 36),
                        fill="#111111",
                    )

        self.lienzo.create_rectangle(
            MARGEN, MARGEN, MARGEN + TABLERO, MARGEN + TABLERO,
            outline=BORDE, width=2,
        )

        for col in range(1, 9):
            x = MARGEN + (col - 1) * LADO + LADO / 2
            for y in (MARGEN - 12, MARGEN + TABLERO + 12):
                self.lienzo.create_text(
                    x, y, text=LETRAS[col - 1], font=("Segoe UI", 10)
                )
        for fila in range(1, 9):
            y = MARGEN + (8 - fila) * LADO + LADO / 2
            for x in (MARGEN - 12, MARGEN + TABLERO + 12):
                self.lienzo.create_text(
                    x, y, text=str(fila), font=("Segoe UI", 10)
                )

    def casilla_desde(self, x, y):
        col = int((x - MARGEN) // LADO) + 1
        fila = 8 - int((y - MARGEN) // LADO)
        if 1 <= col <= 8 and 1 <= fila <= 8:
            return (col, fila)
        return None

    def clic(self, evento):
        casilla = self.casilla_desde(evento.x, evento.y)
        if casilla is None:
            return

        if self.seleccion is None:
            self.seleccionar(casilla)
            return

        if casilla == self.seleccion:
            self.limpiar_seleccion()
            return

        pieza = self.pieza_en(casilla)
        if pieza and pieza[0] == self.turno:
            self.seleccionar(casilla)
            return

        self.intentar(self.seleccion, casilla)

    def seleccionar(self, casilla):
        pieza = self.pieza_en(casilla)
        if pieza is None:
            self.anotar("No hay ninguna pieza en {}.".format(nombre(casilla)))
            return
        if pieza[0] != self.turno:
            self.anotar(
                "La pieza en {} es {} y el turno es de {}.".format(
                    nombre(casilla), pieza[0], self.turno
                )
            )
            return

        self.seleccion = casilla
        self.clavadas = []
        try:
            self.destinos = puente.destinos(self.tablero, self.turno, casilla)
        except puente.ErrorPuente as error:
            self.destinos = []
            self.anotar("Error: {}".format(error))

        if self.destinos:
            lista = ", ".join(nombre(d) for d in sorted(self.destinos))
            self.anotar(
                "{} en {}: puede ir a {}".format(
                    pieza[1], nombre(casilla), lista
                )
            )
        else:
            self.anotar(
                "{} en {}: no tiene ninguna jugada legal.".format(
                    pieza[1], nombre(casilla)
                )
            )
        self.dibujar()

    def limpiar_seleccion(self):
        self.seleccion = None
        self.destinos = []
        self.dibujar()

    def intentar(self, origen, destino):
        try:
            resultado = puente.mover(self.tablero, self.turno, origen, destino)
        except puente.ErrorPuente as error:
            self.anotar("Error: {}".format(error))
            return

        etiqueta = "{}-{}".format(nombre(origen), nombre(destino))

        if not resultado["legal"]:
            self.anotar("ILEGAL {}: {}".format(etiqueta, resultado["motivo"]))
            return

        self.tablero = resultado["tablero"]
        self.anotar("LEGAL {}".format(etiqueta))
        if resultado["estado"] != "normal":
            self.anotar(">>> " + resultado["texto_estado"])

        self.turno = "negra" if self.turno == "blanca" else "blanca"
        self.seleccion = None
        self.destinos = []
        self.clavadas = []
        self.dibujar()
        self.actualizar_estado()

    def cambiar_turno(self):
        self.turno = "negra" if self.turno == "blanca" else "blanca"
        self.limpiar_seleccion()
        self.actualizar_estado()
        self.anotar("Turno cambiado manualmente a {}.".format(self.turno))

    def marcar_clavadas(self):
        try:
            self.clavadas = puente.clavadas(self.tablero, self.turno)
        except puente.ErrorPuente as error:
            self.anotar("Error: {}".format(error))
            return

        if self.clavadas:
            lista = ", ".join(nombre(c) for c in self.clavadas)
            self.anotar("Piezas clavadas de {}: {}".format(self.turno, lista))
        else:
            self.anotar("No hay piezas clavadas de {}.".format(self.turno))
        self.seleccion = None
        self.destinos = []
        self.dibujar()

    def cargar_posicion(self, _evento=None):
        clave = self.combo.get()
        self.tablero = list(puente.POSICIONES[clave])
        self.turno = "blanca"
        self.seleccion = None
        self.destinos = []
        self.clavadas = []
        self.dibujar()
        self.anotar("--- Posicion cargada: {} ---".format(clave))
        self.actualizar_estado()

    def actualizar_estado(self):
        try:
            info = puente.estado(self.tablero, self.turno)
        except puente.ErrorPuente as error:
            self.etiqueta.configure(text="Error: {}".format(error))
            return

        self.etiqueta.configure(
            text="Turno: {}   |   {}".format(self.turno, info["texto"])
        )
        if info["estado"] in ("jaque_mate", "ahogado"):
            self.anotar(">>> " + info["texto"])


def main():
    raiz = tk.Tk()
    Aplicacion(raiz)
    raiz.mainloop()


if __name__ == "__main__":
    main()