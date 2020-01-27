#include <SPI.h>
#include <MPU9250.h>

MPU9250 mpu;

const int SS_n = 9;

void setup()
{
    //Serial.begin(115200);

    Wire.begin();
    SPI.begin();
    SPI.setDataMode(SPI_MODE0);
    SPI.setBitOrder(MSBFIRST);
    SPI.setClockDivider(SPI_CLOCK_DIV2);

    delay(2000);
    mpu.setup();
    mpu.calibrateAccelGyro();

    pinMode(SS_n, OUTPUT);
}

void loop()
{
    mpu.update();

    /*Serial.print(mpu.getRoll());
    Serial.print(" ");
    Serial.print(mpu.getPitch());
    Serial.print(" ");
    Serial.println(mpu.getYaw());*/

    int16_t roll = mpu.getPitch();
    int16_t pitch = mpu.getRoll();
    int16_t yaw = mpu.getYaw();

    /*Serial.print(roll);
    Serial.print(" ");
    Serial.print(pitch);
    Serial.print(" ");
    Serial.println(yaw);*/
        
    digitalWrite(SS_n, LOW);
    SPI.transfer16((int16_t)pitch);
    SPI.transfer16((int16_t)roll);
    SPI.transfer16((int16_t)yaw);
    /*SPI.transfer16((int16_t)0);
    SPI.transfer16((int16_t)0);
    SPI.transfer16((int16_t)10);*/
    digitalWrite(SS_n, HIGH);
}
