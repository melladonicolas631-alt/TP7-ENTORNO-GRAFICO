// Definición de pines
const int pinE1 = 2;
const int pinE2 = 3;
const int pinL1 = 8;
const int pinL2 = 9;

// Variables de estado
bool estadoL1 = false;
bool estadoL2 = false;

// Registro para detección de flancos (Pull-up significa HIGH por defecto)
bool ultimoE1 = HIGH;
bool ultimoE2 = HIGH;

void setup() {
  Serial.begin(9600);
  pinMode(pinE1, INPUT_PULLUP);
  pinMode(pinE2, INPUT_PULLUP);
  pinMode(pinL1, OUTPUT);
  pinMode(pinL2, OUTPUT);
}

void loop() {
  // 1. Lectura de hardware físico
  bool actualE1 = digitalRead(pinE1);
  bool actualE2 = digitalRead(pinE2);

  // Detección de flanco de bajada (Botón recién presionado)
  if (ultimoE1 == HIGH && actualE1 == LOW) {
    estadoL1 = !estadoL1;               // Invierte el estado
    digitalWrite(pinL1, estadoL1);      // Aplica al hardware
  }
  if (ultimoE2 == HIGH && actualE2 == LOW) {
    estadoL2 = !estadoL2;
    digitalWrite(pinL2, estadoL2);
  }
  
  // Guardamos el estado para la próxima iteración
  ultimoE1 = actualE1;
  ultimoE2 = actualE2;

  // 2. Lectura de comandos desde Processing (Eventos de Mouse)
  if (Serial.available() > 0) {
    char comando = Serial.read();
    if (comando == 'T') {
      estadoL1 = !estadoL1;
      digitalWrite(pinL1, estadoL1);
    } else if (comando == 'Y') {
      estadoL2 = !estadoL2;
      digitalWrite(pinL2, estadoL2);
    }
  }

  // 3. Envío de Telemetría a Processing
  // Invertimos actualE1/E2 con "!" para que Processing reciba "1" cuando esté presionado
  Serial.print(!actualE1); Serial.print(",");
  Serial.print(!actualE2); Serial.print(",");
  Serial.print(estadoL1);  Serial.print(",");
  Serial.println(estadoL2);

  delay(30); // Pequeño retardo para estabilidad (Debounce por software)
}