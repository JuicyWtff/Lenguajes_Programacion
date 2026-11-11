import re
import shutil
import subprocess
from pathlib import Path

CARPETA = Path(__file__).resolve().parent
ARCHIVOS = ["main.pl", "puente.pl"]

PIEZA_RE = re.compile(r"pieza\((\w+),\s*(\w+),\s*(\d+),\s*(\d+)\)")
CASILLA_RE = re.compile(r"(\d+)\s*-\s*(\d+)")


class ErrorPuente(Exception):
    pass


def _buscar_swipl():
    ruta = shutil.which("swipl")
    if ruta:
        return ruta
    candidatos = [
        r"C:\Program Files\swipl\bin\swipl.exe",
        r"C:\Program Files (x86)\swipl\bin\swipl.exe",
    ]
    for c in candidatos:
        if Path(c).exists():
            return c
    raise ErrorPuente(
        "No se encontro SWI-Prolog. Instalalo y agregalo al PATH."
    )


def _consultar(meta):
    swipl = _buscar_swipl()
    comando = [swipl, "-q", "-g", meta, "-t", "halt"] + ARCHIVOS
    try:
        proceso = subprocess.run(
            comando,
            cwd=str(CARPETA),
            capture_output=True,
            text=True,
            timeout=20,
        )
    except subprocess.TimeoutExpired:
        raise ErrorPuente("La consulta a Prolog tardo demasiado.")

    salida = proceso.stdout.strip()
    if not salida:
        detalle = proceso.stderr.strip() or "sin salida"
        raise ErrorPuente("Prolog no respondio: " + detalle)
    return salida.splitlines()[-1]


def serializar(tablero):
    partes = [
        "pieza({},{},{},{})".format(color, tipo, col, fila)
        for (color, tipo, col, fila) in tablero
    ]
    return "[" + ",".join(partes) + "]"


def deserializar(texto):
    return [
        (color, tipo, int(col), int(fila))
        for (color, tipo, col, fila) in PIEZA_RE.findall(texto)
    ]


def _casillas(texto):
    return [(int(c), int(f)) for (c, f) in CASILLA_RE.findall(texto)]


def mover(tablero, color, origen, destino):
    meta = "c_mover({}, {}, {}-{}, {}-{})".format(
        serializar(tablero), color, origen[0], origen[1], destino[0], destino[1]
    )
    linea = _consultar(meta)

    if linea.startswith("ILEGAL|"):
        return {"legal": False, "motivo": linea.split("|", 1)[1]}

    if linea.startswith("LEGAL|"):
        _, resto = linea.split("|", 1)
        tablero_txt, estado, texto = resto.rsplit("|", 2)
        return {
            "legal": True,
            "tablero": deserializar(tablero_txt),
            "estado": estado,
            "texto_estado": texto,
        }

    raise ErrorPuente("Respuesta inesperada: " + linea)


def destinos(tablero, color, origen):
    meta = "c_destinos({}, {}, {}-{})".format(
        serializar(tablero), color, origen[0], origen[1]
    )
    linea = _consultar(meta)
    if not linea.startswith("DESTINOS|"):
        raise ErrorPuente("Respuesta inesperada: " + linea)
    return _casillas(linea.split("|", 1)[1])


def estado(tablero, color):
    meta = "c_estado({}, {})".format(serializar(tablero), color)
    linea = _consultar(meta)
    if not linea.startswith("ESTADO|"):
        raise ErrorPuente("Respuesta inesperada: " + linea)
    _, nombre, texto = linea.split("|", 2)
    return {"estado": nombre, "texto": texto}


def clavadas(tablero, color):
    meta = "c_clavadas({}, {})".format(serializar(tablero), color)
    linea = _consultar(meta)
    if not linea.startswith("CLAVADAS|"):
        raise ErrorPuente("Respuesta inesperada: " + linea)
    return _casillas(linea.split("|", 1)[1])


POSICIONES = {
    "Partida completa": [
        ("blanca", "torre", 1, 1), ("blanca", "caballo", 2, 1),
        ("blanca", "alfil", 3, 1), ("blanca", "dama", 4, 1),
        ("blanca", "rey", 5, 1), ("blanca", "alfil", 6, 1),
        ("blanca", "caballo", 7, 1), ("blanca", "torre", 8, 1),
        ("blanca", "peon", 1, 2), ("blanca", "peon", 2, 2),
        ("blanca", "peon", 3, 2), ("blanca", "peon", 4, 2),
        ("blanca", "peon", 5, 2), ("blanca", "peon", 6, 2),
        ("blanca", "peon", 7, 2), ("blanca", "peon", 8, 2),
        ("negra", "peon", 1, 7), ("negra", "peon", 2, 7),
        ("negra", "peon", 3, 7), ("negra", "peon", 4, 7),
        ("negra", "peon", 5, 7), ("negra", "peon", 6, 7),
        ("negra", "peon", 7, 7), ("negra", "peon", 8, 7),
        ("negra", "torre", 1, 8), ("negra", "caballo", 2, 8),
        ("negra", "alfil", 3, 8), ("negra", "dama", 4, 8),
        ("negra", "rey", 5, 8), ("negra", "alfil", 6, 8),
        ("negra", "caballo", 7, 8), ("negra", "torre", 8, 8),
    ],
    "Jaque mate": [
        ("blanca", "rey", 5, 1),
        ("negra", "torre", 1, 1),
        ("negra", "torre", 2, 2),
        ("negra", "rey", 7, 8),
    ],
    "Ahogado": [
        ("negra", "rey", 8, 8),
        ("blanca", "dama", 7, 6),
        ("blanca", "rey", 5, 1),
    ],
    "Clavada": [
        ("blanca", "rey", 5, 1),
        ("blanca", "caballo", 5, 2),
        ("negra", "torre", 5, 8),
        ("negra", "rey", 8, 8),
    ],
}