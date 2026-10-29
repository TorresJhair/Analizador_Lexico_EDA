# Analizador léxico SQL

Implementación en C++17 de un analizador léxico para un subconjunto de
sentencias SQL `SELECT`.

## Estructura

- `include/`: modelo de tokens e interfaz del lexer.
- `src/`: reconocimiento léxico, nombres de tokens y programa principal.
- `tests/`: pruebas unitarias del lexer y del modelo de tokens.
- `examples/`: entradas SQL válidas y con errores.

## Arquitectura

El analizador es un módulo independiente del motor de base de datos: la clase
`Lexer` solo recibe un `std::string` y devuelve un `LexResult`, sin depender de
archivos ni de la consola.

```
Analizador_Lexico_EDA/
├── include/
│   ├── token.hpp        # Modelo de tokens (TokenType, Token)
│   └── lexer.hpp        # Interfaz del analizador (Lexer, LexResult, LexError)
├── src/
│   ├── token.cpp        # Nombres legibles de los tokens
│   ├── lexer.cpp        # Reconocedor léxico y tabla de palabras reservadas
│   └── main.cpp         # Lectura de archivo/stdin y salida por consola
├── tests/
│   ├── test_lexer.cpp   # Pruebas del reconocedor léxico
│   └── test_token.cpp   # Pruebas del modelo de tokens
├── examples/            # valida.sql, errores.sql
├── Makefile
└── README.md
```

| Componente | Dónde |
|---|---|
| Lectura de entrada | `main.cpp` |
| Modelo de tokens | `Token`, `TokenType` en `token.hpp` |
| Reconocedor léxico | `Lexer::tokenize()` y métodos `scan*` en `lexer.cpp` |
| Palabras reservadas | `keywords()` en `lexer.cpp` |
| Manejo de errores | `LexError` y `LexResult::errors` |
| Interfaz de salida | `LexResult` (hacia el parser) y tabla impresa por `main.cpp` |

Flujo: `entrada → main.cpp → Lexer::tokenize() → LexResult { tokens, errors }`.

## Compilación y pruebas

Se requiere `g++` con soporte para C++17 y `make`.

```bash
make
make test
```

La compilación usa las opciones `-Wall -Wextra -Wpedantic`.

## Ejecución

El programa puede leer un archivo:

```bash
./lexer examples/valida.sql
```

También puede recibir la consulta por la entrada estándar:

```bash
echo "SELECT nombre FROM estudiantes;" | ./lexer
```

La salida muestra el tipo, lexema, línea y columna de cada token. Los errores
léxicos se escriben en la salida de error y el análisis continúa cuando es
posible.

## Reglas principales

- Palabras reservadas: `SELECT`, `FROM`, `WHERE`, `AND` y `OR`, sin distinguir
  mayúsculas de minúsculas.
- Identificadores ASCII formados por letras, dígitos y guion bajo; no pueden
  comenzar con un dígito. Si una palabra contiene caracteres no ASCII, como
  `diñosáurio`, se reporta completa como error y ninguna de sus partes genera
  tokens.
- Literales enteros, decimales y cadenas entre comillas simples. En una cadena,
  `''` representa una comilla simple.
  comenzar con un dígito.
- Literales enteros, decimales y números en notación científica, con signo
  opcional (`-42`, `+3.14`, `1e5`, `-1e-10`). Las cadenas se escriben entre
  comillas simples y `''` representa una comilla simple dentro de ellas.
- Operadores `=`, `<>`, `!=`, `<`, `>`, `<=` y `>=`.
- Signos `,`, `;`, `*`, `(` y `)`.
- Posiciones de línea y columna con base 1, además de un token final `EOF`.

Los errores no se convierten en tokens válidos. Entre los casos reportados
están los caracteres no admitidos, las cadenas sin cerrar, `!` aislado y los
números mal formados como `12.` o `12abc`.

## Uso desde otro módulo

```cpp
#include "lexer.hpp"

sql::LexResult result = sql::Lexer("SELECT a FROM tabla;").tokenize();
if (result.ok()) {
    for (const auto& token : result.tokens) {
        // token.type, token.lexeme, token.line, token.column
    }
}
```

## Códigos de salida

- `0`: análisis completado sin errores léxicos.
- `1`: se encontraron errores léxicos.
- `2`: uso incorrecto o no se pudo abrir el archivo indicado.

Para eliminar los ejecutables generados:

```bash
make clean
```
