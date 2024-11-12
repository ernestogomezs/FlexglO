#include <FastLED.h>
#include <atomic>
#include <stdint.h>
#include <esp_err.h>
#include <esp_log.h>
#include <driver/adc.h>
#include <esp_adc/adc_continuous.h>
#include <esp_timer.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <BLE2901.h>

std::atomic<bool> wait_flag;         // Atomic boolean to trigger the wait task   
enum priority {low =1, high};         //Task priority enum (BLE but be higher than rest)
enum {EMG0 = 0, EMG1, EKG};           // Enum for easier indexing into data matrices

//LED defines and globals
#define LED_PIN1 38                   // Onboard Dev Board RGB
#define LED_PIN2 12                   // First WS2812B Bar
#define LED_PIN3 14                   // Second WS2812B Bar
#define LED_PIN4 13                   // WS2812B Circle
#define LED_ONBOARD 1                 // # of LEDs in the onboard RGB
#define BAR_LEDS 10                   // # of LEDs in the strips WS2812B 
#define CIRCLE_LEDS 12                // # of LEDs in the Circle WS2812B
#define NUM_PULSES 4                  // # of alternating start pulses
#define HEART_THRESH 2700             // Raw ADC value to register a heartbeat
#define MAX_JUICE 64                  // Length of a LED pulse showing the heartbeat (stickiness of the pulse)
#define HEART_WINDOW 4                // Number of samples used to determine heartrate
#define LOG2_HEART_WINDOW 2           // Log of the heart window for fast division

CRGB LEDs1[LED_ONBOARD];              // Array for the onboard RGB LED
CRGB LEDs2[BAR_LEDS];                 // Array for the first LED bar
CRGB LEDs3[BAR_LEDS];                 // Array for the second LED bar
CRGB LEDs4[CIRCLE_LEDS];              // Array for the second LED circle
int heart_juice;
uint64_t EKG_times[HEART_WINDOW];
uint16_t times_index;
uint16_t EKG_mean;
uint8_t colors[6] = {0, 191, 0, 0, 191, 0};
TaskHandle_t LED_task_handle = NULL;  //LED task handle
SemaphoreHandle_t LED_matrix_mtx;     // Mutex controlling access to the ADC_buffer

// ADC defines and globals
#define NUM_EXG_CHN 3                                   // Number of ADC channels for continuous reading
#define ADC_SIZE 4                                      // Size of default struct coming off ADC
#define MA_WINDOW 8                                     // MA window size
#define LOG2_MA_WINDOW 3                                // Bit size of MA window, for quick division
#define VREF_WINDOW 16                                  // Number of samples for initial VREF measure
#define LOG2_VREF_WINDOW 4                              // But size of VREF for quick division
#define BUFFER_SIZE ADC_SIZE * MA_WINDOW * NUM_EXG_CHN  // Total samples for all channels (8 samples per channel for 3 channels)
#define SAMPLE_FREQ_HZ 8000                              // Sampling frequency in Hz

uint16_t ADC_data[BUFFER_SIZE];                         // Buffer to hold raw ADC data after DMA transfer
uint16_t ADC_means[NUM_EXG_CHN];                        // MA result for the EXG channels
uint16_t ADC_midpoint;                                  // Midpoint used for ADC rectification
adc_continuous_handle_t continuous_ADC_handle;          // Aquiring ADC via DMA task handle
TaskHandle_t process_ADC_handle;                        // Processing ADC task handle
SemaphoreHandle_t ADC_buffer_mtx;                       // Mutex for access to the ADC buffer

//Wait defines and globals
#define FADE_TIME 16                                    // Fade length for the wait animation (you cannot just change this without making a new array in function)
#define ANIMA_TIME 64                                   // Refresh rate for the wait animations
TaskHandle_t process_wait_handle = NULL;                // Handle for the wait task
int bar_pos;                                            // Position of the chaser for the bar wait animations
int cir_pos;                                            // Position of the chaser for the circle wait animations
int direction;                                          // Direction of the chaser for the bar wait animations

//BLE defines and globals
#define STREAM_LEN 128                                  //Number of entries for both EMG data recordings
#define SERVICE_UUID              "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define FLEX_CHARACTERISTIC_UUID  "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define GLO_CHARACTERISTIC_UUID   "2ffa4a4d-581e-4c62-87b8-13884d8d9a5d"
TaskHandle_t process_BLE_handle = NULL;                 // Handle for the BLE task
BLEServer* pServer = nullptr;                           // BLE server attribute
BLEService* pService = nullptr;                         // BLE service attribute
bool connect_flag = false;                              // Flag set when the device connects to the client
bool recieve_flag = false;
BLE2901 *descriptor_flex = NULL;                        // Descriptor for the outward sending muscle data characteristic
BLE2901 *descriptor_glo = NULL;                         // Descriptor for the inward receiving color/logging characteristic
BLECharacteristic *flexCharacteristic = NULL;           // BLE outward muscle data characteristic
BLECharacteristic *gloCharacteristic = NULL;            // BLE inward color/logging characteristic
std::atomic<bool> pong_flag;                            // Atomic boolean record to one buffer and send over BLE to another buffer
enum {PING=0, PONG};                                    // Enum for more convienience working with ping pong buffer
struct data_unit{                                       // Unit of data for the ping pong buffer
  uint16_t EMG0;
  uint16_t EMG1;
  uint16_t BPM;
};
data_unit ping_pong_buffer[2] = {0};                    // Declaration of the ping pong buffer
uint16_t BLE_out_packet[3] = {0};                       // Actual BLE packet structure TODO: Probably could remove this and just use pingpong buffer
uint8_t BLE_in_packet[8] = {0};                         // Packet with 3 RGB colors and a 4th byte for the "start logging" bool


class MyServerCallbacks : public BLEServerCallbacks { // Callback class for handling connection and disconnection
  void onConnect(BLEServer *pServer) {
    connect_flag = true;
    pServer->getAdvertising()->stop();
  }

  void onDisconnect(BLEServer *pServer) {
    connect_flag = false;
    pServer->getAdvertising()->start();
  }
};

class MyCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    recieve_flag = true;
  }
};

// ADC callback function for when a conversion frame is complete
bool IRAM_ATTR adc_callback(adc_continuous_handle_t handle, const adc_continuous_evt_data_t *edata, void *user_data) {
  if (xSemaphoreTakeFromISR(ADC_buffer_mtx, NULL)) {     // Take the mutex before accessing ADC_data
    memcpy(ADC_data, edata->conv_frame_buffer, edata->size); // Copy the data into the global buffer
    xTaskNotifyGive(process_ADC_handle);       // Notify the ADC print task to process the data
    xSemaphoreGiveFromISR(ADC_buffer_mtx, NULL); // Release the mutex after copying
  }
  return false;  // Return false to indicate no higher priority task was woken
}

uint16_t rectify_ADC(uint16_t ADC_raw) { //Digitally rectifies values for the EMG coming from the ADC
  if (ADC_raw >= ADC_midpoint) {
    ADC_raw = ADC_raw - ADC_midpoint;
  } else {
    ADC_raw = ADC_midpoint - ADC_raw;
  }
  return ADC_raw;
}

void set_VREF_midpoint(){ //During ADC initialization takes a quick read of the VREF to use as rectification midpoint.
  ADC_midpoint = 0;
  for(uint16_t i = 0; i < VREF_WINDOW; i++){
    adc1_config_channel_atten((adc1_channel_t)ADC_CHANNEL_4, ADC_ATTEN_DB_11); //Set reading from 0-3.3V CHN4
    ADC_midpoint += uint16_t(adc1_get_raw((adc1_channel_t)ADC_CHANNEL_4));
  }
  ADC_midpoint = 2048;
  //MATT: TODO either set this or measure it for better accuracy!
  /*ADC_midpoint >>= LOG2_VREF_WINDOW;
  Serial.print("MP:");
  Serial.println(ADC_midpoint);
  */
}

void process_ADC(void *pvParameters) { // Process ADC Data Task
  while (true) {
    ulTaskNotifyTake(pdTRUE, portMAX_DELAY); // Wait to be released until DMA readies data
    if (xSemaphoreTake(ADC_buffer_mtx, portMAX_DELAY) == pdTRUE) { // Take the mutex before reading data off shared ADC_buffer
      uint32_t ADC_sums[NUM_EXG_CHN] = {0};
      for(uint8_t i = 0; i < NUM_EXG_CHN; i++){
        ADC_means[i] = 0;
      }
      for (uint32_t i = 0; i < BUFFER_SIZE / sizeof(uint16_t); i++) {
        adc_digi_output_data_t  entry = *(adc_digi_output_data_t *) &ADC_data[i]; //Process eatch entry from the DMA buffer
        switch (entry.type2.channel) {
          case ADC_CHANNEL_0:
            ADC_sums[EMG0] += entry.type2.data;
            break;
          case ADC_CHANNEL_1:
            ADC_sums[EMG1] += entry.type2.data;
            break;
          case ADC_CHANNEL_5:  // Channel 3 (GPIO pin 5)
            ADC_sums[EKG] += entry.type2.data;
            break;
          default:
            break;
        } 
      }
      // Calculate the averages and rectify for EMG
      ADC_means[EMG0] = rectify_ADC(ADC_sums[EMG0] >> LOG2_MA_WINDOW);
      ADC_means[EMG1] = rectify_ADC(ADC_sums[EMG1] >> LOG2_MA_WINDOW);
      //Record updated values to the pingpong
      if(pong_flag.load()){
        ping_pong_buffer[PING].EMG0 = ADC_means[EMG0];
        ping_pong_buffer[PING].EMG1 = ADC_means[EMG1];
      }else {
        ping_pong_buffer[PONG].EMG0 = ADC_means[EMG0];
        ping_pong_buffer[PONG].EMG1 = ADC_means[EMG1];
      }
      ADC_means[EKG]  = ADC_sums[EKG]  >> LOG2_MA_WINDOW;

      // Print the processed ADC values
      /*
      Serial.print("EMG0:");
      Serial.print(ADC_means[EMG0]);
      Serial.print(" | EMG1:");
      Serial.print(ADC_means[EMG1]);
      Serial.print(" | EKG:");
      Serial.println(ADC_means[EKG]);
      */

      xSemaphoreGive(ADC_buffer_mtx); // Release the mutex after processing
      xTaskNotifyGive(LED_task_handle); // Notify the LED task it may proceed
    }
  }
}

int judge_level(uint16_t measured){ // Determines LED bar levels from raw ADC readings
  const int thresholds[11] = {0, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1500}; //Array of pre-tested thresholds
  int level = -1; // Initialize the level to -1
  for (int i = 1; i < BAR_LEDS+1; i++) { // Loop through the thresholds to find the appropriate level
    if (measured < thresholds[i]) {
      level = i - 1; // Set the level just below the threshold
      return level;
    }
  }
  level = BAR_LEDS; // If measured exceeds all thresholds, set level to 9
  return level;
}

void set_bars(int EMG0_level, int EMG1_level){ //Sets the LED arrays for the bars
  for (int i = 0; i < BAR_LEDS; i++) { //Loop over all 10 LEDs, set level to green, do for both muscles
    if(i >= EMG0_level){
      LEDs2[i] = CRGB::Black;
    } else{
      LEDs2[i] = CRGB(colors[0], colors[1], colors[2]);
    }
  }
  for (int j = 0; j < BAR_LEDS; j++) {
    if(j >= EMG1_level){
      LEDs3[j] = CRGB::Black;
    } else{
      LEDs3[j] = CRGB(colors[3], colors[4], colors[5]);
    }
  }
}

void record_pulse(){
  EKG_times[times_index] = uint64_t(esp_timer_get_time());
  times_index++;
  if(times_index >= HEART_WINDOW){
    times_index = 0;
    uint32_t differences = 0;
    for(int i = 1; i < HEART_WINDOW; i++){
      //Serial.printf("Diff:%i\n", (EKG_times[i] - EKG_times[i-1]));
      differences += (EKG_times[i] - EKG_times[i-1]);
    }
    differences >>= LOG2_HEART_WINDOW;
    EKG_mean = 60000000/differences;
    //Update ping pong buffer correctly
    if(pong_flag.load()){
      ping_pong_buffer[PING].BPM = EKG_mean;
    } else{
      ping_pong_buffer[PONG].BPM = EKG_mean;
    }
    //Serial.println(60000000.0f/EKG_mean);
  }
} 

void set_circle(){ //Sets the LEDs for the heartbeat circle
  const uint8_t redIntensities[MAX_JUICE] = { // Precalculated array for red intensities 64 looks good and is fast enough for 1kHz
    //First Entry is Dummy Never Reached (Gaussian Model ;))
    0, 255, 254, 253, 252, 250, 247, 244, 237, 232, 227, 222, 216, 210, 204, 197,
    190, 183, 176, 169, 162, 154, 147, 139, 132, 125, 118, 111, 104, 98, 91, 85,
    79, 74, 68, 63, 58, 54, 49, 45, 41, 37, 34, 31, 28, 25, 23, 20,
    18, 16, 14, 13, 11, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 0
  };
  if (ADC_means[EKG] > HEART_THRESH) { // Check to see if the heart beat has registered
    if (heart_juice == 0) { // Make sure an ealier beat has not registered
      record_pulse();
      for (int k = 0; k < CIRCLE_LEDS; k++) { // Spike to white initially
        LEDs4[k] = CRGB::White; 
      }
      heart_juice = 1; // Start the pulse sequence
    }
  }
  if (heart_juice > 0) { // If heart juice is greater than zero we are displaying a registered beat
    for (int k = 0; k < CIRCLE_LEDS; k++) { // Walk the pre-computed pulse array
      LEDs4[k] = CRGB(redIntensities[heart_juice], 0, 0);
    }
    if (heart_juice < MAX_JUICE) { // Increment heart_juice until it reaches MAX_JUICE
      heart_juice++;
    } else {
      heart_juice = 0; // Reset heart_juice for the next pulse
      for (int k = 0; k < CIRCLE_LEDS; k++) {
        LEDs4[k] = CRGB::Black; // Turn off the LEDs
      }
    }
  } else { // If no pulse is detected and heart_juice is 0, turn off the LEDs   
    for (int k = 0; k < CIRCLE_LEDS; k++) {
      LEDs4[k] = CRGB::Black;
    }
  }
}

void process_LEDs(void *parameter) { //Sets the real-time LEDs to to muscle or heart levels
  while (1) {
    // Wait for notification from the ADC task
    ulTaskNotifyTake(pdTRUE, portMAX_DELAY);
    if(!wait_flag.load()){
      int levels[2] = {0,0}; //Levels for the LED bars
      levels[EMG0] = judge_level(ADC_means[EMG0]);
      levels[EMG1] = judge_level(ADC_means[EMG1]);
      //Serial.printf("Test: %i\n",ADC_means[EKG]);
      // Toggle the LED state when triggered by ADC task (applies to both strips)
      LEDs1[0] = CRGB(0, 255, 0);  // Blue with adjustable red for onboard LED
      //Set the bar LED levels
      set_bars(levels[EMG0], levels[EMG1]);
      set_circle();
      FastLED.show();
    }
  }
}

void startup_pulse(int num_pulse) { // Start-up pulse
  // Arrays for brightness levels (scaled by 1/3) and corresponding delay times for good looking pulse
  uint8_t brightnessLevels[] = {5, 10, 21, 32, 42, 53, 64, 64, 53, 42, 32, 21, 10, 5};
  uint8_t delayTimes[] = {112, 56, 28, 18, 14, 11, 9, 9, 11, 14, 18, 28, 56, 112}; 

  for (uint8_t i = 0; i < num_pulse; i++) { //Pulse given number of times
    for (uint8_t j = 0; j < sizeof(brightnessLevels) / sizeof(brightnessLevels[0]); j++) { //Walk the pulse arrays
      FastLED.setBrightness(brightnessLevels[j]); //Set brightness (globally)
      CRGB color = (i & 1)?CRGB(0x00, 0x27, 0x4C):CRGB(0xFF, 0xCB, 0x05); //#FFCB05 is Maize and #00274C is Michigan Blue, alternate even to odd
      LEDs1[0] = color;
      for (int k = 0; k < CIRCLE_LEDS; k++) { //Pulse both the LED bars and LED circle
        if(k < BAR_LEDS){
          LEDs2[k] = color;  // Copy the color to all LEDs in the second strip
          LEDs3[k] = color;  // Copy the color to all LEDs in the second strip
        }
        LEDs4[k] = color;  // Copy the color to all LEDs in the second strip
      }
      FastLED.show();
      delay(delayTimes[j]);  // Use the corresponding delay times
    }
    LEDs1[0] = CRGB::Black;  // Turn off both strips before the next iteration
    for (int k = 0; k < CIRCLE_LEDS; k++) {
      if(k < BAR_LEDS){
        LEDs2[k] = CRGB::Black;
        LEDs3[k] = CRGB::Black;
      }
      LEDs4[k] = CRGB::Black;
    }
    FastLED.show();
    delay(500);  // Wait 500 ms before the next pulse
  }

  // Reset LED brightness to 50 after the loop
  FastLED.setBrightness(75);
  FastLED.show();
}

void init_LEDs(){ //Initialize two LED strips and LED circle, possibly LED onboard for debugging
  FastLED.addLeds<WS2812B, LED_PIN1, GRB>(LEDs1, LED_ONBOARD);  // Onboard RGB
  FastLED.addLeds<WS2812B, LED_PIN2, GRB>(LEDs2, BAR_LEDS);     // First strip (10 LEDs)
  FastLED.addLeds<WS2812B, LED_PIN3, GRB>(LEDs3, BAR_LEDS);     // Second strip (10 LEDs)
  FastLED.addLeds<WS2812B, LED_PIN4, GRB>(LEDs4, CIRCLE_LEDS);  // LED circle (12 LEDs)
  FastLED.setBrightness(75);  // Initial brightness
  heart_juice = 0;
  for(uint8_t i = 0; i < HEART_WINDOW; i++){
    EKG_times[i] =0;
  }
  times_index = 0; 
  EKG_mean = 0.0;
  // Create the FreeRTOS task that will handle the LED toggling
  xTaskCreatePinnedToCore (process_LEDs, "Process LEDs", 2048, NULL, priority::low, &LED_task_handle, 1);
}

void init_ADC(){ //Initializes the ADC for correct operation
  esp_err_t ret; // Error catch
  set_VREF_midpoint();
  ADC_buffer_mtx = xSemaphoreCreateMutex(); //Initialize mutex to protect ADC buffer
  if (ADC_buffer_mtx == NULL) {
    Serial.println("Initialization of ADC mutex failed!");
    return;
  }
  adc_continuous_handle_cfg_t continuous_config = { // Initializr ADC continuous configuration
      .max_store_buf_size = BUFFER_SIZE * 2,  // Size in bytes (recommended to be 'twice the size')
      .conv_frame_size = BUFFER_SIZE,         // Frame size in bytes
      .flags = {
        .flush_pool = 1                       // Flush pool when full
    }
  };
  ret = adc_continuous_new_handle(&continuous_config, & continuous_ADC_handle);
  if (ret != ESP_OK) {
    Serial.println("Failed to create ADC handle");
    return;
  }

  adc_digi_pattern_config_t ADC_pattern[3] = {  { // Initialize pattern configurations for each ADC1 channel 0-3.3 for 12 bits @8kHz
      .atten = ADC_ATTEN_DB_11,
      .channel = ADC_CHANNEL_0,
      .unit = ADC_UNIT_1,
      .bit_width = ADC_WIDTH_BIT_12,
    },{
      .atten = ADC_ATTEN_DB_11,
      .channel = ADC_CHANNEL_1,
      .unit = ADC_UNIT_1,
      .bit_width = ADC_WIDTH_BIT_12,
    },{
      .atten = ADC_ATTEN_DB_11,
      .channel = ADC_CHANNEL_5,
      .unit = ADC_UNIT_1,
      .bit_width = ADC_WIDTH_BIT_12,
    }
  };
  adc_continuous_config_t adc_config = { //Initialize continuous ADC behavior
    .pattern_num = NUM_EXG_CHN,             // Number of ADC channels being used
    .adc_pattern = ADC_pattern,             // Pointer to individual channel behavior
    .sample_freq_hz = SAMPLE_FREQ_HZ,       // Sampling frequency in Hz
    .conv_mode = ADC_CONV_SINGLE_UNIT_1,    // Only using ADC1 not ADC2 
    .format = ADC_DIGI_OUTPUT_FORMAT_TYPE2  // Output format type (need type 2 to link byte to channel)
  };
  ret = adc_continuous_config(continuous_ADC_handle, &adc_config);
  if (ret != ESP_OK) {
    Serial.println("Failed to configure ADC");
    return;
  }

  // Create task to process ADC data once DMA fills buffer
  xTaskCreatePinnedToCore (process_ADC, "Process ADC", 2048, NULL, priority::low, &process_ADC_handle, 1);

  adc_continuous_evt_cbs_t cbs = { // Register the callback ISR to fire when DMA fills buffer
    .on_conv_done = adc_callback,  // Callback for when a conversion frame is complete
    .on_pool_ovf = NULL            // Optional: callback for pool overflow
  };
  adc_continuous_register_event_callbacks(continuous_ADC_handle, &cbs, NULL);

  ret = adc_continuous_start(continuous_ADC_handle); // Start the ADC continuous mode
  if (ret != ESP_OK) {
    Serial.println("Starting continuous ADC sampling failed!");
  }
}

void process_wait(void *pvParameters) {
  while(1) {  
    ulTaskNotifyTake(pdTRUE, portMAX_DELAY); //Wait until the BLE task tells us to wait
    wait_flag.store(true); //Enter waiting state
    while(wait_flag.load()){ //Wait until the wait_start clears (coming from the BLE task after connection)
      for(int i=0; i < BAR_LEDS; i++){ //Chaser animation for the LED bars
        if(i == bar_pos){
          LEDs2[i].setRGB(192, 192, 192);
          LEDs3[i].setRGB(192, 192, 192);
        }else if((bar_pos - 1 > -1) && (i == (bar_pos - 1))){
          LEDs2[i].setRGB(32, 32, 32);
          LEDs3[i].setRGB(32, 32, 32);
        }else if((bar_pos + 1 < BAR_LEDS) && (i == (bar_pos + 1))) {
          LEDs2[i].setRGB(32, 32, 32);
          LEDs3[i].setRGB(32, 32, 32);
        }else{
          LEDs2[i] = CRGB::Black;
          LEDs3[i] = CRGB::Black;
        }
      }
      if(bar_pos == 0){
        direction = 1;
      }else if (bar_pos == 9){
        direction = -1;
      }
      bar_pos+=direction;
      const uint8_t chaser[12] = {32, 192, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0};
      for (int i = 0; i < CIRCLE_LEDS; i++){ //Chaser animation for the circle LEDs
        int index = (i + cir_pos);
        if (index >= CIRCLE_LEDS) {
          index -= CIRCLE_LEDS;
        }
        LEDs4[index].setRGB(chaser[i], chaser[i], chaser[i]);
      }
      cir_pos++;
      if(cir_pos == CIRCLE_LEDS){
        cir_pos = 0;
      }
      FastLED.show();
      delay(ANIMA_TIME);
    }

    const uint8_t fader[FADE_TIME] = {191,187,176,159,138,115,92,71,53,37,25,16,10,6,3,0};
    for(uint8_t j = 0; j < FADE_TIME; j++){
      for(uint8_t k = 0; k < CIRCLE_LEDS; k++){
        if((k & 1) == 0){
          LEDs2[k].setRGB(fader[j], fader[j], fader[j]);
          LEDs3[k].setRGB(fader[j], fader[j], fader[j]);
          LEDs4[k].setRGB(fader[j], fader[j], fader[j]);
        }else{
          LEDs2[k] = CRGB::Black;
          LEDs3[k] = CRGB::Black;
          LEDs4[k] = CRGB::Black;
        }
      }
      FastLED.show();
      delay(FADE_TIME);
    }
  }
}

void init_wait(){
  //Wait task will be used by the BLE task until connection is made
  xTaskCreatePinnedToCore (process_wait, "Process Wait", 2048, NULL, priority::high, &process_wait_handle, 1);
  wait_flag.store(false);
  bar_pos = 0;
  cir_pos = 0;
  direction = 1;
}

void pack_data(){
  if(pong_flag){
    BLE_out_packet[0] = ping_pong_buffer[PONG].EMG0;
    BLE_out_packet[1] = ping_pong_buffer[PONG].EMG1;
    BLE_out_packet[2] = ping_pong_buffer[PONG].BPM;
  }else{
    BLE_out_packet[0] = ping_pong_buffer[PING].EMG0;
    BLE_out_packet[1] = ping_pong_buffer[PING].EMG1;
    BLE_out_packet[2] = ping_pong_buffer[PING].BPM;
  }
}

void unpack_data(){
  colors[0] = BLE_in_packet[0];
  colors[1] = BLE_in_packet[1];
  colors[2] = BLE_in_packet[2];
  colors[3] = BLE_in_packet[3];
  colors[4] = BLE_in_packet[4];
  colors[5] = BLE_in_packet[5];
  for(uint8_t i = 0; i < 3; i++){
    Serial.println(colors[i]);
  }
}

void process_BLE(void * parameter) {
  while (true) {
    pServer->getAdvertising()->start(); // Start BLE advertising
    //Serial.println("BLE Advertising Started");
    if (connect_flag) { // Check if connected
      wait_flag.store(false); // Break out of wait state
      if(recieve_flag == true){
        memcpy(BLE_in_packet, gloCharacteristic->getData(), 8);  
        unpack_data();
        recieve_flag = false;
      }else{
        //Serial.println("Client Connected!");
        pack_data(); // Pack data correctly
        flexCharacteristic->setValue((uint8_t*)BLE_out_packet, 6); //Set characteristic
        flexCharacteristic->notify(); //Notify client of the change
        pong_flag.exchange(!pong_flag.load()); //Toggle the pong pong buffer
      }
    } else {
      // If disconnected, start advertising again
      Serial.println("Client disconnected, restarting advert...");
      xTaskNotifyGive(process_wait_handle);
      pServer->getAdvertising()->start();
    }
    vTaskDelay(64 / portTICK_PERIOD_MS); // TODO: MATT Wait before processing again this was just fastest that we could do
  }
}

void init_BLE(){
  pong_flag.store(false);
  BLEDevice::init("Node 0"); // Create the BLE Device
  pServer = BLEDevice::createServer(); // Create the BLE Server
  pServer->setCallbacks(new MyServerCallbacks()); //Sets up the callback for the notification to get data bakc confirming data was sent
  pService = pServer->createService(SERVICE_UUID); // Create the BLE Service node identifier creates a struct
  flexCharacteristic = pService->createCharacteristic( // Create Flex BLE Characteristic
    FLEX_CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ    | 
    BLECharacteristic::PROPERTY_NOTIFY 
  );
  
  gloCharacteristic = pService->createCharacteristic( // Create Glo BLE Characteristic
    GLO_CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ    | 
    BLECharacteristic::PROPERTY_WRITE   | 
    BLECharacteristic::PROPERTY_NOTIFY 
  );

  flexCharacteristic->addDescriptor(new BLE2902()); // Creates BLE Descriptor 0x2902: Client Characteristic Configuration Descriptor (CCCD)
  descriptor_flex = new BLE2901(); // Adds also the Characteristic User Description - 0x2901 descriptor
  descriptor_flex->setDescription("From MSB-LSB: 2 bytes for left pec, 2 bytes for right pec, 1 byte for heart rate.");
  descriptor_flex->setAccessPermissions(ESP_GATT_PERM_READ);  // enforce read only - default is Read|Write
  flexCharacteristic->addDescriptor(descriptor_flex);

  gloCharacteristic->addDescriptor(new BLE2902()); // Creates BLE Descriptor 0x2902: Client Characteristic Configuration Descriptor (CCCD)
  descriptor_glo = new BLE2901(); // Adds also the Characteristic User Description - 0x2901 descriptor
  descriptor_glo->setDescription("From MSB-LSB: 5 bytes for color rgb data.");
  descriptor_glo->setAccessPermissions(ESP_GATT_PERM_WRITE);  // enforce read only - default is Read|Write
  gloCharacteristic->addDescriptor(descriptor_glo);
  gloCharacteristic->setCallbacks(new MyCallbacks());
  pService->start();
  xTaskCreatePinnedToCore(process_BLE, "Process BLE", 4048, NULL, priority::low, &process_BLE_handle, 0);
}

void setup() {
  Serial.begin(115200);
  init_LEDs();
  startup_pulse(NUM_PULSES);
  init_wait();
  init_BLE();
  init_ADC();
}

void loop() {
  // Tasking keeps this loop empty
}
