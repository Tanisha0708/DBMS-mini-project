package project;
import java.sql.*;
import java.util.Scanner;

public class dbms {

    // Database credentials
    private static final String URL = "jdbc:mysql://localhost:3306/mini";
    private static final String USER = "root";
    private static final String PASSWORD = "root";

    public static void main(String[] args) {
        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD)) {
            System.out.println("Database connected!");

            Scanner scanner = new Scanner(System.in);
            int choice;

            while (true) {
                System.out.println("\nSelect an option:");
                System.out.println("1. Insert User");
                System.out.println("2. Update User");
                System.out.println("3. Delete User");
                System.out.println("4. Display Users");
                System.out.println("5. Exit");
                System.out.print("Choice: ");
                choice = scanner.nextInt();
                scanner.nextLine();  // Consume newline character

                switch (choice) {
                    case 1:
                        insertUser(connection, scanner);
                        break;
                    case 2:
                        updateUser(connection, scanner);
                        break;
                    case 3:
                        deleteUser(connection, scanner);
                        break;
                    case 4:
                        displayUsers(connection);
                        break;
                    case 5:
                        System.out.println("Exiting...");
                        return;
                    default:
                        System.out.println("Invalid choice! Please try again.");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Method to insert a new user
    private static void insertUser(Connection connection, Scanner scanner) {
        try {
            System.out.print("Enter Username: ");
            String username = scanner.nextLine();
            System.out.print("Enter Bio: ");
            String bio = scanner.nextLine();
            System.out.print("Enter Email: ");
            String email = scanner.nextLine();

            String insertSQL = "INSERT INTO Users (username, bio, email) VALUES (?, ?, ?)";
            try (PreparedStatement preparedStatement = connection.prepareStatement(insertSQL)) {
                preparedStatement.setString(1, username);
                preparedStatement.setString(2, bio);
                preparedStatement.setString(3, email);

                int rowsInserted = preparedStatement.executeUpdate();
                System.out.println(rowsInserted + " row(s) inserted.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Method to update a user's email
    private static void updateUser(Connection connection, Scanner scanner) {
        try {
            System.out.print("Enter User ID to update: ");
            int userId = scanner.nextInt();
            scanner.nextLine();  // Consume newline character
            System.out.print("Enter new Email: ");
            String newEmail = scanner.nextLine();

            String updateSQL = "UPDATE Users SET email = ? WHERE user_id = ?";
            try (PreparedStatement preparedStatement = connection.prepareStatement(updateSQL)) {
                preparedStatement.setString(1, newEmail);
                preparedStatement.setInt(2, userId);

                int rowsUpdated = preparedStatement.executeUpdate();
                System.out.println(rowsUpdated + " row(s) updated.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Method to delete a user by ID (with cascading delete for related rows in follows table)
    private static void deleteUser(Connection connection, Scanner scanner) {
        try {
            System.out.print("Enter User ID to delete: ");
            int userId = scanner.nextInt();

            // First delete the rows in 'follows' table where the user_id is involved
            String deleteFollowsSQL = "DELETE FROM follows WHERE followee_id = ? OR follower_id = ?";
            try (PreparedStatement preparedStatement = connection.prepareStatement(deleteFollowsSQL)) {
                preparedStatement.setInt(1, userId);
                preparedStatement.setInt(2, userId);
                int rowsDeletedFromFollows = preparedStatement.executeUpdate();
                System.out.println("Deleted " + rowsDeletedFromFollows + " related rows from 'follows' table.");
            }

            // Now delete the user from 'Users' table
            String deleteUserSQL = "DELETE FROM Users WHERE user_id = ?";
            try (PreparedStatement preparedStatement = connection.prepareStatement(deleteUserSQL)) {
                preparedStatement.setInt(1, userId);
                int rowsDeletedFromUsers = preparedStatement.executeUpdate();
                System.out.println(rowsDeletedFromUsers + " row(s) deleted from 'Users' table.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Method to display all users
    private static void displayUsers(Connection connection) {
        try {
            String selectSQL = "SELECT * FROM Users";
            try (Statement statement = connection.createStatement();
                 ResultSet resultSet = statement.executeQuery(selectSQL)) {

                while (resultSet.next()) {
                    int userId = resultSet.getInt("user_id");
                    String username = resultSet.getString("username");
                    String bio = resultSet.getString("bio");
                    String email = resultSet.getString("email");
                    System.out.println("ID: " + userId + ", Username: " + username + ", Bio: " + bio + ", Email: " + email);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
