<%@ page import="com.services.authentication.AuthenticationUtil" %>
<%
if (!AuthenticationUtil.isAuthenticated(request)) {
    // If the user is not authenticated, redirect to the login page
    response.sendRedirect("index.jsp"); // Replace "login.jsp" with your login page URL
}
%>
<%@page import="com.services.database.DatabaseConnection"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@include file="structure.jsp"%>



<%
try {
    String username = (String) request.getSession().getAttribute("username");
    DatabaseConnection dbConnection = new DatabaseConnection();
    Connection connection = dbConnection.getConnection();
    PreparedStatement ps = connection.prepareStatement("SELECT * FROM vehicle_service WHERE username=?");
    ps.setString(1, username);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
%>
<style>
    body {
        font-family: Arial;
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
    
</style>

<table>
    <thead>
        <tr>
            <th>Booking ID</th>
            <th>Date</th>
            <th>Time</th>
            <th>Location</th>
            <th>Vehicle Number</th>
            <th>Mileage</th>
            <th>Message</th>
            
        </tr>
    </thead>
    <tbody>
        <%
        do {
        %>
        <tr>
            <td><%= rs.getString(1) %></td>
            <td><%= rs.getString(2) %></td>
            <td><%= rs.getString(3) %></td>
            <td><%= rs.getString(4) %></td>
            <td><%= rs.getString(5) %></td>
            <td><%= rs.getString(6) %></td>
            <td><%= rs.getString(7) %></td>
        </tr>
        <%
        } while (rs.next());
        %>
    </tbody>
</table>
<%
    } else {
%>
<p style="color: white; text-align: center;">No reservations found.</p>

<%
    }
    rs.close(); // Close the ResultSet.
    dbConnection.closeConnection(connection); // Close the database connection.
} catch (Exception e) {
    // Handle exceptions here, e.g., display an error message or log the exception.
    e.printStackTrace();
}
%>
