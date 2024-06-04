import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DatabaseQuery {
    // comando para compilar 
    // javac -cp libs/mysql-connector-java-8.0.26.jar src/DatabaseQuery.java

    // comando para ejecutar
    // java -cp src:libs/mysql-connector-java-8.0.26.jar DatabaseQuery
    private static final String URL = "jdbc:mysql://127.0.0.1:3306/ProyectoCMV";
    private static final String USER = "";
    private static final String PASSWORD = "";

    public static void main(String[] args) {
        Connection connection = null;
        Statement statement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(URL, USER, PASSWORD);

            statement = connection.createStatement();
            resultSet = statement.executeQuery("SELECT * FROM Personal");

            while (resultSet.next()) {

                String nombre = resultSet.getString("nombre");
                System.out.println("Nombre: " + nombre);
            }

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (resultSet != null) {
                    resultSet.close();
                }
                if (statement != null) {
                    statement.close();
                }
                if (connection != null) {
                    connection.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
