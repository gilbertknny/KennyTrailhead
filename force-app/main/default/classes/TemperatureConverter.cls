public class TemperatureConverter {
    // Takes a Fahrenheit temperature and returns the Celsius equivalent.
    public static decimal FahrenheitToCelcius(Decimal Fh){
        Decimal cs = (fh - 32) * 5/9;
        return cs.setScale(2);
    }
}