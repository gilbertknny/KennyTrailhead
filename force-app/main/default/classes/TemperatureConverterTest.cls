@isTest
public class TemperatureConverterTest {
    @isTest static void testWarmp(){
        Decimal celsius = TemperatureConverter.FahrenheitToCelcius(70);
        System.assertEquals(21.11,celsius);
    }
    
    @isTest static void testFreezingPoint(){
        Decimal celsius = TemperatureConverter.FahrenheitToCelcius(32);
        System.assertEquals(32,celsius);
        
    }
    
    @isTest static void testBoillingPoint(){
        Decimal celcius = TemperatureConverter.FahrenheitToCelcius(212);
        System.assertEquals(100,celcius,'Boilling temperature is not expected.');
    }
    
    @isTest static void testNegativeTemp(){
        Decimal celcius = TemperatureConverter.FahrenheitToCelcius(-10);
        System.assertEquals(-28.33,celcius);
    }

}