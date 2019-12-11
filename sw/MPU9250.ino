#include <SPI.h>
#include "MPU9250/MPU9250.h"

MPU9250 mpu;

const int SS_n = 10;

void setup()
{
    pinMode(SS_n, OUTPUT);
    Serial.begin(115200);

    Wire.begin();
    SPI.begin();
    SPI.setDataMode(SPI_MODE0);
    SPI.setBitOrder(MSBFIRST);
    SPI.setClockDivider(SPI_CLOCK_DIV2);

    delay(2000);
    mpu.setup();
    mpu.calibrateAccelGyro();
}

void loop()
{
    mpu.update();

    /*Serial.print(mpu.getRoll());
    Serial.print(" ");
    Serial.print(mpu.getPitch());
    Serial.print(" ");
    Serial.println(mpu.getYaw());

    int16_t roll = mpu.getRoll()*16;
    int16_t pitch = mpu.getPitch()*16;
    int16_t yaw = mpu.getYaw()*16;

    Serial.print(roll);
    Serial.print(" ");
    Serial.print(pitch);
    Serial.print(" ");
    Serial.println(yaw);*/
    
    digitalWrite(SS_n, LOW);
    SPI.transfer16((int16_t)(mpu.getRoll()*16));
    SPI.transfer16((int16_t)(mpu.getPitch()*16));
    SPI.transfer16((int16_t)(mpu.getYaw()*16));
    digitalWrite(SS_n, HIGH);
}
