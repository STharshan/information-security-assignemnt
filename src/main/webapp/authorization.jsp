<%@ page import="java.io.*, java.net.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.json.JSONObject" %>

<%
// Extract the authorization code from the request parameters
String authorizationCode = request.getParameter("code");
String sessionState = request.getParameter("session_state");
session.setAttribute("sessionState", sessionState); 

if (authorizationCode == null || authorizationCode.isEmpty()) {
    // Handle the case where the authorization code is missing
    out.println("Authorization code is missing.");
} else {
    // Define token endpoint and client credentials
    Properties props = new Properties();
    InputStream input = getServletContext().getResourceAsStream("/WEB-INF/authorization.properties");
    props.load(input);

    String clientId = props.getProperty("oauth.client_id");
    String clientSecret = props.getProperty("oauth.client_secret");
    String tokenEndpoint = props.getProperty("oauth.token_endpoint");
    String redirectUri = props.getProperty("oauth.redirect_uri");
    try {
        // Construct the request data for token exchange
        String requestData = "code=" + authorizationCode +
                "&grant_type=authorization_code" +
                "&client_id=" + clientId +
                "&client_secret=" + clientSecret +
                "&redirect_uri=" + URLEncoder.encode(redirectUri, "UTF-8");

        // Create a URL object for the token endpoint
        URL tokenUrl = new URL(tokenEndpoint);

        // Open a connection to the token endpoint
        HttpURLConnection tokenConnection = (HttpURLConnection) tokenUrl.openConnection();

        // Set the request method to POST
        tokenConnection.setRequestMethod("POST");

        // Enable input/output streams
        tokenConnection.setDoOutput(true);

        // Write the request data to the output stream
        try (DataOutputStream tokenOutputStream = new DataOutputStream(tokenConnection.getOutputStream())) {
            tokenOutputStream.writeBytes(requestData);
            tokenOutputStream.flush();
        }

        // Get the response code from the token endpoint
        int tokenResponseCode = tokenConnection.getResponseCode();

        // Read the response data from the token endpoint
        try (BufferedReader tokenReader = new BufferedReader(new InputStreamReader(tokenConnection.getInputStream()))) {
            String tokenInputLine;
            StringBuilder tokenResponse = new StringBuilder();

            while ((tokenInputLine = tokenReader.readLine()) != null) {
                tokenResponse.append(tokenInputLine);
            }

            // Handle the response data here
            String responseDataStr = tokenResponse.toString();

            // Parse the response data as JSON
            JSONObject jsonResponse = new JSONObject(responseDataStr);

            // Extract access_token and id_token
            String access_token = jsonResponse.getString("access_token");
            String id_token = jsonResponse.getString("id_token");

            // Store tokens in session attributes
            request.getSession().setAttribute("access_token", access_token);
            request.getSession().setAttribute("id_token", id_token);
            

            response.sendRedirect("home.jsp");
        }
    } catch (IOException e) {
        e.printStackTrace();
        // Handle the exception here, e.g., by displaying an error page.
    }
}
%>
