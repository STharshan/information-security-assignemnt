<%@ page import="com.services.authentication.AuthenticationUtil" %>
<%
if (!AuthenticationUtil.isAuthenticated(request)) {
    // If the user is not authenticated, redirect to the login page
    response.sendRedirect("index.jsp"); // Replace "login.jsp" with your login page URL
}
%>
<%@ page import="com.services.database.*" %>
<%@ page import="java.sql.*" %>
<%@ include file="structure.jsp" %>


<%
DatabaseConnection dbConnection = new DatabaseConnection(); // Create a DatabaseConnection object
Connection connection = null;

if (request.getParameter("delete") != null) {
    String bookingId = request.getParameter("bookingId");

    try {
        connection = dbConnection.getConnection(); // Get a connection from DatabaseConnection
        PreparedStatement ps = connection.prepareStatement("DELETE FROM vehicle_service WHERE booking_id = ?");
        ps.setString(1, bookingId);
        ps.executeUpdate();

        response.sendRedirect("delete_registration.jsp?msg=success"); // Redirect back to the reservations page

    } catch (Exception e) {
        System.out.println(e);
        response.sendRedirect("delete_registration.jsp?msg=failure"); // Redirect back to the reservations page
    } finally {
        dbConnection.closeConnection(connection); // Close the connection in a finally block
    }
}

try {
    connection = dbConnection.getConnection(); // Get a connection from DatabaseConnection
    PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM vehicle_service WHERE username=? AND date >= ? ");
    String username = (String) request.getSession().getAttribute("username");
    preparedStatement.setString(1, username);
    preparedStatement.setDate(2, java.sql.Date.valueOf(java.time.LocalDate.now()));
    ResultSet resultSet = preparedStatement.executeQuery();

    if (resultSet.next()) {
%>
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f4f4f4;
        margin: 0;
        padding: 0;
    }

    h4 {
        color: #333;
    }

    table {
        width: 80%;
        margin: 20px auto;
        border-collapse: collapse;
        background-color: #fff;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        border-radius: 5px;
    }

    th, td {
        border: 1px solid #ddd;
        padding: 10px;
        text-align: left;
    }

    th {
        background-color: #333;
        color: #fff;
    }

    button {
        background-color: #d9534f;
        color: white;
        padding: 8px 12px;
        border: none;
        border-radius: 3px;
        cursor: pointer;
        font-size: 14px;
    }

    button:hover {
        background-color: #c9302c;
    }
</style>

    <table  border="1">
        <thead>
            <tr>
                <th>Booking ID</th>
                <th>Date</th>
                <th>Time</th>
                <th>Location</th>
                <th>Vehicle Number</th>
                <th>Mileage</th>
                <th>Message</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
        <%
        do {
        %>
        <tr>
            <td><%= resultSet.getString("booking_id") %></td>
            <td><%= resultSet.getString("date") %></td>
            <td><%= resultSet.getString("time") %></td>
            <td><%= resultSet.getString("location") %></td>
            <td><%= resultSet.getString("vehicle_no") %></td>
            <td><%= resultSet.getString("mileage") %></td>
            <td><%= resultSet.getString("message") %></td>
            <td>
                <form action="delete_registration.jsp" method="post">
                    <input type="hidden" name="bookingId" value="<%= resultSet.getString("booking_id") %>">
                    <button type="submit" name="delete">Delete</button>
                </form>
            </td>
        </tr>
        <%
        } while (resultSet.next());
        %>
        </tbody>
    </table>
<%
    } else {
%>
       <p style="color: white; text-align: center;">No Upcoming Reservations found.</p>
<%
    }
    resultSet.close();
    preparedStatement.close();
} catch (Exception e) {
    System.out.println(e);
} finally {
    dbConnection.closeConnection(connection); // Close the connection in a finally block
}
%>