import processing.serial.*;

Serial puerto;
int estadoE1 = 0, estadoE2 = 0;
int estadoL1 = 0, estadoL2 = 0;

void setup() {
  size(400, 300);
  
  // Inicialización de Puerto Serie
  printArray(Serial.list());
  if (Serial.list().length > 0) {
    // Si tu Arduino no está en el puerto 0, ajusta el índice del arreglo
    puerto = new Serial(this, Serial.list()[0], 9600);
    puerto.bufferUntil('\n'); // Esperar hasta el salto de línea para disparar el evento
  } else {
    println("ADVERTENCIA: No se detectaron puertos serie.");
  }
}

void draw() {
  background(245);
  textAlign(CENTER, CENTER);
  textSize(16);

  // --- SECTOR ENTRADAS ---
  fill(160, 190, 230); // Azul claro
  rect(40, 50, 100, 40);
  fill(0);
  text("Entradas", 90, 70);

  // Casillero E1 (Rectángulo)
  fill(estadoE1 == 1 ? color(0, 220, 0) : color(255));
  rect(180, 50, 50, 40);
  fill(0); text("E1", 205, 70);

  // Casillero E2 (Rectángulo)
  fill(estadoE2 == 1 ? color(0, 220, 0) : color(255));
  rect(260, 50, 50, 40);
  fill(0); text("E2", 285, 70);

  // --- SECTOR SALIDAS ---
  fill(240, 210, 190); // Salmón/Durazno
  rect(40, 150, 100, 40);
  fill(0);
  text("Salidas", 90, 170);

  // Casillero L1 (Círculo)
  fill(estadoL1 == 1 ? color(255, 50, 50) : color(255));
  ellipse(205, 170, 50, 50);
  fill(0); text("L1", 205, 170);

  // Casillero L2 (Círculo)
  fill(estadoL2 == 1 ? color(255, 50, 50) : color(255));
  ellipse(285, 170, 50, 50);
  fill(0); text("L2", 285, 170);
}

// Evento asíncrono que se dispara al recibir el '\n'
void serialEvent(Serial puerto) {
  String trama = puerto.readStringUntil('\n');
  if (trama != null) {
    trama = trim(trama); // Elimina espacios o saltos de línea residuales
    int[] valores = int(split(trama, ',')); // Divide la cadena usando las comas
    
    // Verificamos integridad de la trama
    if (valores.length == 4) {
      estadoE1 = valores[0];
      estadoE2 = valores[1];
      estadoL1 = valores[2];
      estadoL2 = valores[3];
    }
  }
}

void mousePressed() {
  if (puerto == null) return;
  
  // Cálculo de distancia euclidiana para detectar click dentro del círculo L1 (x=205, y=170, radio=25)
  if (dist(mouseX, mouseY, 205, 170) < 25) {
    puerto.write('T');
  }
  // Cálculo para L2 (x=285, y=170, radio=25)
  else if (dist(mouseX, mouseY, 285, 170) < 25) {
    puerto.write('Y');
  }
}
