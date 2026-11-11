# TP7 - Entorno Gráfico: Control Concurrente de E/S

**Cátedra:** Informática II  
**Carrera:** Ingeniería Electrónica  
**Ciclo Lectivo:** 2026  
**Autor:** Nicolás Mellado  

## Introducción
Este repositorio contiene la resolución del Trabajo Práctico N.º 7. El proyecto implementa un sistema de control bidireccional y concurrente entre una interfaz gráfica de usuario (GUI) desarrollada en **Processing** y un microcontrolador **Arduino Uno**. 

El objetivo principal es mantener sincronizados los estados físicos de entradas (pulsadores) y salidas (LEDs) con su representación visual en la computadora. Para evitar desincronizaciones entre los clics del mouse y las pulsaciones físicas, se aplicó el principio de "Fuente Única de Verdad" (Single Source of Truth), donde el Arduino es el maestro absoluto del estado del hardware.

## Arquitectura del Proyecto

### 1. Hardware (Esquemático)
El circuito documentado en `esquematico.png` consta de:
*   **Entradas:** 2 Pulsadores conectados a los pines digitales 2 y 3. Utilizan lógica negativa aprovechando las resistencias internas `INPUT_PULLUP` del microcontrolador. Al presionarlos, el circuito se cierra hacia GND (estado `LOW`).
*   **Salidas:** 2 LEDs conectados a los pines digitales 8 y 9, con sus respectivas resistencias limitadoras de corriente de 220Ω conectadas al riel de masa (GND).

### 2. Firmware (Arduino - C++)
El archivo `firmware_tp7.ino` se encarga de:
*   Leer los pulsadores detectando **flancos de bajada** para realizar la conmutación de estado (evitando el parpadeo incontrolable por mantener apretado el botón).
*   Recibir comandos de la PC vía puerto Serie sin bloquear el ciclo principal.
*   Enviar telemetría constante a la PC mediante una trama estructurada en formato CSV (`estadoE1,estadoE2,estadoL1,estadoL2\n`).

### 3. Software (Processing - Java)
El archivo `interfaz_tp7.pde` actúa como cliente de telemetría y terminal de comandos:
*   Procesa la trama CSV enviada por el Arduino, separando los datos al detectar el salto de línea (`\n`), para colorear los componentes:
    *   **Entradas:** Rectángulos (E1, E2) - Verde al detectar pulsación física, Blanco en reposo.
    *   **Salidas:** Círculos (L1, L2) - Rojo al detectar LED encendido, Blanco en reposo.
*   Calcula la distancia euclidiana del puntero del mouse y envía comandos de texto (`'T'` para L1, `'Y'` para L2) por puerto Serie cuando el usuario hace clic dentro del área de los círculos.

## Protocolo de Comunicación Asíncrono
Se estableció una comunicación bidireccional a 9600 baudios:
*   **Uplink (Arduino a PC - Telemetría):** Envía strings del tipo `1,0,1,0\n` (Ejemplo: E1 presionado, E2 suelto, L1 encendido, L2 apagado). El carácter `\n` garantiza la integridad del paquete.
*   **Downlink (PC a Arduino - Comandos):** Caracteres individuales enviados por evento del mouse. El Arduino usa `Serial.available()` para atraparlos sin detener la lectura física.

## Instrucciones de Despliegue
1. Armar el circuito físico siguiendo la topología de `esquematico.png`.
2. Compilar y subir el archivo `firmware_tp7.ino` a la placa Arduino.
3. **Importante:** Cerrar el Monitor Serie del IDE de Arduino para liberar el puerto COM.
4. Abrir y ejecutar el script `interfaz_tp7.pde` en Processing. El programa se enlazará automáticamente al primer puerto COM disponible.