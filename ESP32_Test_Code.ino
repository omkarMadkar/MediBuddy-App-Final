#include <Wire.h>
#include "MAX30105.h"
#include "heartRate.h"
#include "spo2_algorithm.h"
#include "BluetoothSerial.h"
#include <U8g2lib.h>

// OLED and Sensor initialization
U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, /* reset=*/ U8X8_PIN_NONE);
MAX30105 particleSensor;
BluetoothSerial SerialBT;

// Sensor and processing variables
int32_t heartRate = 0;
int8_t validHeartRate = 0;
int32_t spo2 = 0;
int8_t validSPO2 = 0;
uint32_t irValue = 0;
uint32_t irBuffer[100], redBuffer[100];

// Timing control variables
unsigned long lastBeatTime = 0;
unsigned long lastTransmission = 0;
unsigned long lastUIUpdate = 0;
unsigned long bootTime = 0;

// Finger detection buffer
const uint32_t FINGER_THRESHOLD = 50000;
const int DETECTION_SAMPLES = 10;
uint32_t fingerCheckBuffer[DETECTION_SAMPLES];
int fingerCheckIndex = 0;

// Heart rate smoothing
const byte RATE_ARRAY_SIZE = 4;
long rateArray[RATE_ARRAY_SIZE];
byte rateCounter = 0;
long rateSum = 0;

bool fingerDetected = false;
bool systemReady = false;

void setup() {
  Serial.begin(115200);
  bootTime = millis();

  u8g2.begin();
  
  // Make Bluetooth more discoverable
  SerialBT.begin("ESP32-Health-Pro", true); // true = discoverable
  Serial.println("Bluetooth Serial Started: ESP32-Health-Pro");
  Serial.println("Device is now discoverable!");

  Wire.begin(21, 22);

  if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) {
    displayError("Sensor Error", "Check Wiring");
    while (1) delay(1000);
  }

  particleSensor.setup();
  particleSensor.setPulseAmplitudeRed(0x0A);
  particleSensor.setPulseAmplitudeGreen(0);
  particleSensor.enableDIETEMPRDY();

  for (int i = 0; i < RATE_ARRAY_SIZE; i++) rateArray[i] = 0;
  for (int i = 0; i < DETECTION_SAMPLES; i++) fingerCheckBuffer[i] = 0;

  systemReady = true;
  Serial.println("System Ready - Waiting for Bluetooth connection...");
}

void loop() {
  // Check for Bluetooth connection
  if (SerialBT.hasClient()) {
    Serial.println("Bluetooth client connected!");
  } else {
    Serial.println("Waiting for Bluetooth connection...");
    delay(1000);
    return;
  }

  updateSensorData();
  checkFingerPresence();

  if (millis() - lastUIUpdate > 200) {
    updateDisplay();
    lastUIUpdate = millis();
  }

  if (fingerDetected && millis() - lastTransmission > 2000) {
    transmitData();
    lastTransmission = millis();
  }

  if (SerialBT.available()) {
    handleBluetoothCommands();
  }

  delay(20);
}

void updateSensorData() {
  irValue = particleSensor.getIR();

  if (fingerDetected && irValue > FINGER_THRESHOLD) {
    if (checkForBeat(irValue)) {
      long delta = millis() - lastBeatTime;
      lastBeatTime = millis();

      int bpm = 60 / (delta / 1000.0);

      if (bpm > 20 && bpm < 255) {
        rateArray[rateCounter % RATE_ARRAY_SIZE] = bpm;
        rateSum = 0;
        for (byte i = 0; i < RATE_ARRAY_SIZE; i++) {
          rateSum += rateArray[i];
        }
        heartRate = rateSum / RATE_ARRAY_SIZE;
        rateCounter++;
      }
    }

    static unsigned long lastSpO2Calc = 0;
    if (millis() - lastSpO2Calc > 3000) {
      calculateSpO2();
      lastSpO2Calc = millis();
    }
  } else {
    if (!fingerDetected) {
      heartRate = 0;
      spo2 = 0;
      validSPO2 = 0;
      validHeartRate = 0;
    }
  }

  particleSensor.nextSample();
}

void checkFingerPresence() {
  fingerCheckBuffer[fingerCheckIndex] = irValue;
  fingerCheckIndex = (fingerCheckIndex + 1) % DETECTION_SAMPLES;

  uint32_t average = 0;
  for (int i = 0; i < DETECTION_SAMPLES; i++) {
    average += fingerCheckBuffer[i];
  }
  average /= DETECTION_SAMPLES;

  bool previousFingerDetected = fingerDetected;
  fingerDetected = (average > FINGER_THRESHOLD);

  if (previousFingerDetected && !fingerDetected) {
    heartRate = 0;
    spo2 = 0;
    rateCounter = 0;
    rateSum = 0;
    for (int i = 0; i < RATE_ARRAY_SIZE; i++) rateArray[i] = 0;
  }
}

void calculateSpO2() {
  memset(irBuffer, 0, sizeof(irBuffer));
  memset(redBuffer, 0, sizeof(redBuffer));

  for (byte i = 0; i < 100; i++) {
    while (!particleSensor.available()) {
      particleSensor.check();
      delay(1);
    }
    redBuffer[i] = particleSensor.getRed();
    irBuffer[i] = particleSensor.getIR();
    particleSensor.nextSample();
  }

  maxim_heart_rate_and_oxygen_saturation(
    irBuffer, 100, redBuffer,
    &spo2, &validSPO2,
    &heartRate, &validHeartRate
  );

  if (!validSPO2 || spo2 <= 0 || spo2 > 100) {
    uint32_t redSum = 0, irSum = 0;
    for (int i = 0; i < 100; i++) {
      redSum += redBuffer[i];
      irSum += irBuffer[i];
    }
    if (irSum > 0) {
      float ratio = (float)redSum / irSum;
      if (ratio > 0.5 && ratio < 2.0) {
        spo2 = 110 - (25 * ratio);
        spo2 = constrain(spo2, 85, 100);
        validSPO2 = 1;
      }
    }
  }
}

void updateDisplay() {
  u8g2.clearBuffer();

  if (!systemReady) return;

  if (!fingerDetected) {
    displayWaitingScreen();
  } else {
    displayHealthData();
  }

  u8g2.sendBuffer();
}

void displayWaitingScreen() {
  u8g2.setFont(u8g2_font_helvR10_tr);
  String msg = "Place Finger on Sensor";
  int width = u8g2.getStrWidth(msg.c_str());
  u8g2.drawStr((128 - width) / 2, 32, msg.c_str());

  // Small pulsing heart animation
  static bool toggle = false;
  toggle = !toggle;
  if (toggle) {
    u8g2.setFont(u8g2_font_open_iconic_all_2x_t);
    u8g2.drawGlyph(56, 55, 0x0048); // heart icon
  }
}

void displayHealthData() {
  u8g2.setFont(u8g2_font_helvB12_tr);
  u8g2.drawStr(10, 15, "Health Monitor");

  // Draw separator line
  u8g2.drawLine(0, 20, 128, 20);

  // Heart Rate
  u8g2.setFont(u8g2_font_open_iconic_all_2x_t);
  u8g2.drawGlyph(5, 45, 0x0048); // Heart Icon
  u8g2.setFont(u8g2_font_helvB14_tr);
  String hrStr = (heartRate > 0) ? String(heartRate) + " BPM" : "---";
  u8g2.drawStr(35, 45, hrStr.c_str());

  // SpO2
  u8g2.setFont(u8g2_font_open_iconic_all_2x_t);
  u8g2.drawGlyph(5, 65, 0x004F); // O2 Icon (approximation)
  u8g2.setFont(u8g2_font_helvB14_tr);
  String spo2Str = (validSPO2 && spo2 > 70 && spo2 <= 100) ? String(spo2) + "%" : "---";
  u8g2.drawStr(35, 65, spo2Str.c_str());
}

void displayError(String title, String msg) {
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_helvB10_tr);
  int wTitle = u8g2.getStrWidth(title.c_str());
  int wMsg = u8g2.getStrWidth(msg.c_str());
  u8g2.drawStr((128 - wTitle)/2, 25, title.c_str());
  u8g2.drawStr((128 - wMsg)/2, 40, msg.c_str());
  u8g2.sendBuffer();
}

void transmitData() {
  if(!fingerDetected) return;

  String jsonData = "{";
  jsonData += "\"timestamp\":" + String(millis()) + ",";
  jsonData += "\"heartRate\":" + String(heartRate) + ",";
  jsonData += "\"spo2\":" + String(spo2) + ",";
  jsonData += "\"validHR\":" + String(validHeartRate) + ",";
  jsonData += "\"validSpO2\":" + String(validSpO2);
  jsonData += "}";

  SerialBT.println(jsonData);
  Serial.println("Sent: " + jsonData);
}

void handleBluetoothCommands() {
  String command = SerialBT.readStringUntil('\n');
  command.trim();
  command.toLowerCase();

  if (command == "status") sendDetailedStatus();
  else if (command == "reset") ESP.restart();
  else if (command == "info") sendSystemInfo();
}

void sendDetailedStatus() {
  String statusMsg = "{";
  statusMsg += "\"device\":\"ESP32-Health-Pro\",";
  statusMsg += "\"uptime\":" + String((millis() - bootTime) / 1000) + ",";
  statusMsg += "\"heartRate\":" + String(heartRate) + ",";
  statusMsg += "\"spo2\":" + String(spo2);
  statusMsg += "}";
  SerialBT.println(statusMsg);
}

void sendSystemInfo() {
  String infoMsg = "{";
  infoMsg += "\"chipModel\":\"" + String(ESP.getChipModel()) + "\",";
  infoMsg += "\"cpuFreq\":" + String(ESP.getCpuFreqMHz()) + ",";
  infoMsg += "\"freeHeap\":" + String(ESP.getFreeHeap());
  infoMsg += "}";
  SerialBT.println(infoMsg);
}