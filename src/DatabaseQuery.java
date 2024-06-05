import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Scanner;

public class DatabaseQuery {

    private static final String URL = "jdbc:mysql://127.0.0.1:3306/ProyectoCMV";
    private static final String USER = "";
    private static final String PASSWORD = "";

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int option;

        do {
            System.out.println("Seleccione una opción:");
            System.out.println("1. Insertar un cine");
            System.out.println("2. Insertar una sala en un cine");
            System.out.println("3. Listar todos los cines con la información de sus salas");
            System.out.println("4. Devolver actores que solo figuran en una sola película");
            System.out.println("5. Listar las personas que han sido actores y directores");
            System.out.println("6. Listar los cines con la cantidad total de butacas totales");
            System.out.println("7. Consultas propias");
            System.out.println("0. Salir");
            System.out.print("> ");
            option = scanner.nextInt();
            scanner.nextLine();

            switch (option) {
                case 1:
                    insertarCine(scanner);
                    System.out.println("----------------------------------------------------");
                    break;
                case 2:
                    insertarSala(scanner);
                    System.out.println("----------------------------------------------------");
                    break;
                case 3:
                    listarCinesConSalas();
                    System.out.println("----------------------------------------------------");
                    break;
                case 4:
                    devolverActoresUnaSolaPelicula();
                    System.out.println("----------------------------------------------------");
                    break;
                case 5:
                    listarPersonasActoresYDirectores();
                    System.out.println("----------------------------------------------------");
                    break;
                case 6:
                    listarCinesConButacasTotales();
                    System.out.println("----------------------------------------------------");
                    break;
                case 7:
                    consultasPropias();
                    System.out.println("----------------------------------------------------");
                    break;
                case 0:
                    System.out.println("Saliendo...");
                    break;
                default:
                    System.out.println("Opcion no valida. Intente de nuevo.");
                    System.out.println("----------------------------------------------------");
            }
        } while (option != 0);

        scanner.close();
    }

    private static void insertarCine(Scanner scanner) {
        System.out.print("Ingrese el nombre del cine: ");
        String nombre = scanner.nextLine();
        System.out.print("Ingrese la direccion del cine: ");
        String direccion = scanner.nextLine();
        System.out.print("Ingrese el telefono del cine: ");
        String telefono = scanner.nextLine();

        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD);
            Statement statement = connection.createStatement()) {

            String sql = "INSERT INTO Cine (nombre, direccion, telefono) VALUES ('" + nombre + "', '" + direccion + "', '" + telefono + "')";
            statement.executeUpdate(sql);
            System.out.println("Cine insertado exitosamente.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static void insertarSala(Scanner scanner) {
        System.out.print("Ingrese el numero de la sala: ");
        int numero = scanner.nextInt();
        scanner.nextLine();
        System.out.print("Ingrese la cantidad de butacas: ");
        int butacas = scanner.nextInt();
        scanner.nextLine();
        System.out.print("Ingrese el nombre del cine: ");
        String nombreCine = scanner.nextLine();

        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD);
            Statement statement = connection.createStatement()) {

            String sql = "INSERT INTO Sala (numero, cantidad_butacas, nombre_cine) VALUES (" + numero + ", " + butacas + ", '" + nombreCine + "')";
            statement.executeUpdate(sql);
            System.out.println("Sala insertada exitosamente.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static void listarCinesConSalas() {
        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD);
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery(
                        "SELECT Cine.nombre AS cine_nombre, Cine.direccion, Cine.telefono, Sala.numero AS sala_numero, Sala.cantidad_butacas " +
                            "FROM Cine LEFT JOIN Sala ON Cine.nombre = Sala.nombre_cine")) {

            while (resultSet.next()) {
                String cineNombre = resultSet.getString("cine_nombre");
                String direccion = resultSet.getString("direccion");
                String telefono = resultSet.getString("telefono");
                int salaNumero = resultSet.getInt("sala_numero");
                int butacas = resultSet.getInt("cantidad_butacas");
                System.out.println("Cine: " + cineNombre + ", Direccion: " + direccion + ", Telefono: " + telefono + ", Sala: " + salaNumero + ", Butacas: " + butacas);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static void devolverActoresUnaSolaPelicula() {
        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD);
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery(
                        "SELECT nombre_protagonista " +
                            "FROM Protagonista " +
                            "JOIN Actuo ON Protagonista.nombre_protagonista = Actuo.nombre_p " +
                            "GROUP BY nombre_protagonista " +
                            "HAVING COUNT(Actuo.ident_pelicula) = 1")) {

            while (resultSet.next()) {
                String nombreProtagonista = resultSet.getString("nombre_protagonista");
                System.out.println("Protagonista: " + nombreProtagonista);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static void listarPersonasActoresYDirectores() {
        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD);
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery(
                        "SELECT DISTINCT Personal.nombre " +
                            "FROM Personal " +
                            "JOIN Director ON Personal.nombre = Director.nombre_director " +
                            "JOIN Protagonista ON Personal.nombre = Protagonista.nombre_protagonista")) {

            while (resultSet.next()) {
                String nombre = resultSet.getString("nombre");
                System.out.println("Nombre: " + nombre);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static void listarCinesConButacasTotales() {
        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD);
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery(
                        "SELECT Cine.nombre, SUM(Sala.cantidad_butacas) AS total_butacas " +
                            "FROM Cine " +
                            "JOIN Sala ON Cine.nombre = Sala.nombre_cine " +
                            "GROUP BY Cine.nombre")) {

            while (resultSet.next()) {
                String cineNombre = resultSet.getString("nombre");
                int totalButacas = resultSet.getInt("total_butacas");
                System.out.println("Cine: " + cineNombre + ", Butacas Totales: " + totalButacas);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static void consultasPropias() {
        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD);
            Statement statement = connection.createStatement()) {

            // consulta 1: peliculas dirigidas por mas de un director
            try (ResultSet resultSet = statement.executeQuery(
                    "SELECT Pelicula.titulo_distribucion " +
                            "FROM Pelicula " +
                            "JOIN Director ON Pelicula.nombre_d = Director.nombre_director " +
                            "GROUP BY Pelicula.id_pelicula " +
                            "HAVING COUNT(Director.nombre_director) > 1")) {

                System.out.println("Peliculas dirigidas por mas de un director:");
                while (resultSet.next()) {
                    String titulo = resultSet.getString("titulo_distribucion");
                    System.out.println("Titulo: " + titulo);
                }
            }

            // consulta 2: actores que han trabajado en mas de una pelicula dirigida por el mismo director
            try (ResultSet resultSet = statement.executeQuery(
                    "SELECT Personal.nombre " +
                            "FROM Personal " +
                            "JOIN Actuo ON Personal.nombre = Actuo.nombre_p " +
                            "JOIN Pelicula ON Actuo.ident_pelicula = Pelicula.id_pelicula " +
                            "JOIN Director ON Pelicula.nombre_d = Director.nombre_director " +
                            "GROUP BY Personal.nombre, Director.nombre_director " +
                            "HAVING COUNT(Actuo.ident_pelicula) > 1")) {

                System.out.println("Actores que han trabajado en mas de una pelicula dirigida por el mismo director:");
                while (resultSet.next()) {
                    String nombre = resultSet.getString("nombre");
                    System.out.println("Nombre: " + nombre);
                }
            }

            // consulta 3: directores que tambien han sido actores en sus propias peliculas
            try (ResultSet resultSet = statement.executeQuery(
                    "SELECT DISTINCT Personal.nombre " +
                            "FROM Personal " +
                            "JOIN Director ON Personal.nombre = Director.nombre_director " +
                            "JOIN Actuo ON Personal.nombre = Actuo.nombre_p " +
                            "JOIN Pelicula ON Actuo.ident_pelicula = Pelicula.id_pelicula " +
                            "WHERE Pelicula.nombre_d = Personal.nombre")) {

                System.out.println("Directores que tambien han sido actores en sus propias peliculas:");
                while (resultSet.next()) {
                    String nombre = resultSet.getString("nombre");
                    System.out.println("Nombre: " + nombre);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
