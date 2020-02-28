<!doctype html public "-//w3c/dtd HTML 4.0//en">
<html>
<head>
    <title>JDBC Table JSP</title>
    <style type="text/css">
        h2.heading {
            font: bolder 180% georgia, verdana, sans-serif;
            color: #f00;
        }
        td.header {
            font: 130% georgia, verdana, sans-serif;
            color: white;
            background-color: #449d48;
            padding: 5px;
            text-align: center;
        }
        td.cdata {
            font: normal 80% verdana, arial, sans-serif;
            background-color: lightgrey;
            border: 1px solid gray;
            padding-left: 10px;
        }
        h2.error {
            font: bolder 120% georgia, verdana, sans-serif;
            color: #15e;
        }
    </style>
</head>

<h2 class="heading">Using JSP to retrieve database data with JDBC</font></h2>
<%@ page import="java.io.*,java.sql.*,java.util.*, org.postgresql.*,javax.servlet.*,java.sql.*,javax.sql.*, java.text.SimpleDateFormat, java.sql.Date, java.text.DateFormat, java.text.ParseException"

%>
</head>
<H1>Results:</H1>

<%!
    public boolean isValidDate(String date){
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        dateFormat.setLenient(false);
        try {
            dateFormat.parse(date);
        }
        catch (ParseException e) {
            return false;
        }
        return true;
    }
%>
<%
    Connection conn;
    String jdbcDriver = "org.postgresql.Driver";
    String username = "shaikh";
    String passwd = "finishedthejob15";
    String sLo, sHi, cLo, cHi, dLo, dHi;
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
    java.util.Date dateLo, dateHi;
    PreparedStatement qry;
    boolean failed = false, rangeGood = false;

    try {
        Class.forName(jdbcDriver);
        conn = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/senators",
                username, passwd);

        // get the request parameters; if they are not present, they will come back null
        sLo = request.getParameter("lsnm");
        sHi = request.getParameter("hsnm");
        cLo = request.getParameter("lcnm");
        cHi = request.getParameter("hcnm");
        dLo = request.getParameter("ldate");
        dHi = request.getParameter("hdate");

        // initialize regEx for sLo and sHi
        String empty = "";
        String nonLetter = "[^a-zA-Z]";
//----
        /*sLo checks */
        // checks for all nulls
        if (sLo == null) {
            out.println("<h3>Low limit of the senator name range is missing.</h3>");
            failed = true;
        }
        // checks for empty spaces or white spaces
        else if (sLo.replace(" ","").equals("")) {
            out.println("<h3>Low limit of the senator name range is empty.</h3>");
            failed = true;
        }
        // checks for non-letter characters
        else if (sLo == nonLetter) {
            out.println("<h3>Low limit of the senator name range has non-letter characters.</h3>");
            failed = true;
        }
//----
        /*sHi checks */
        // checks for all nulls
        if (sHi == null) {
            out.println("<h3>High limit of the senator name range is missing.</h3>");
            failed = true;
        }
        // checks for empty spaces or white spaces
        else if (sHi.replace(" ","").equals("")) {
            out.println("<h3>High limit of the senator name range is empty.</h3>");
            failed = true;
        }
        // checks for non-letter characters
        else if (sHi == nonLetter) {
            out.println("<h3>High limit of the senator name range has non-letter characters.</h3>");
            failed = true;
        }
        // check for sHi < sLo
        else if(sHi.compareTo(sLo) < 0) {
            out.println("<h3>Empty senator name range.</h3>");
            failed = true;
        }
        // else no errors

        // initialize regEx for cLo and cHi
        String corpNameCheck = "^(([a-zA-Z])+[,.]?\\s(&\\s?)?)*[a-zA-Z]+[.]?$";
//----
        /*cLo checks*/
        // checks for all nulls
        if (cLo == null) {
            out.println("<h3>Low limit of the corporation name range is missing.</h3>");
            failed = true;
        }
        /* check if present, but the empty string or only white space or
         * has non-white space characters, but has leading or trailing white space
         */
        else if (!cLo.matches(corpNameCheck)) {
            out.println("<h3>Low limit of the corporation name range is wrong format.</h3>");
            failed = true;
        }
//----
        /*cHi checks*/
        // checks for all nulls
        if (cHi == null) {
            out.println("<h3>High limit of the corporation name range is missing.</h3>");
            failed = true;
        }
        /* check if present, but the empty string or only white space or
         * has non-white space characters, but has leading or trailing white space
         */
        else if (!cHi.matches(corpNameCheck)) {
            out.println("<h3>High limit of the corporation name range is wrong format.</h3>");
            failed = true;
        }
        // check for cHi < cLo
        else if(cHi.compareTo(cLo) < 0) {
            out.println("<h3>Empty corporation name range.</h3>");
            failed = true;
        }
        // else no errors

        // initialize regEx dLo and dHi
        String dateFormatCheck = "\\d{4}-\\d{1,2}-\\d{1,2}";
        boolean dLoValid = isValidDate(dLo);
        boolean dHiValid = isValidDate(dHi);
//----
        /* dLo checks*/
        // checks for all nulls
        if (dLo == null) {
            out.println("<h3>Low limit of the date range is missing.</h3>");
            failed = true;
        }
        // check for the correct format
        else if (!dLo.matches(dateFormatCheck) || dLo.matches(empty)) {
            out.println("<h3>Low limit of the date range is of the wrong format.</h3>");
            failed = true;
        }
        // check for the validity of data
        else if(!dLoValid) {
            out.println("<h3>Low limit of the date range is not a valid date.</h3>");
            failed = true;
        }
//----
        /*dHi checks*/
        // checks for all nulls
        if (dHi == null) {
            out.println("<h3>High limit of the date range is missing.</h3>");
            failed = true;
        }
        // check for the correct format
        else if (!dHi.matches(dateFormatCheck) || dHi.matches(empty)) {
            out.println("<h3>High limit of the date range is of the wrong format.</h3>");
            failed = true;
        }
        // check for the validity of data
        else if(!dHiValid) {
            out.println("<h3>High limit of the date range is not a valid date.</h3>");
            failed = true;
        }
        // check for dHi < dLo
        else {
            dateLo = df.parse(dLo);
            dateHi = df.parse(dHi);
            if(dateHi.compareTo(dateLo) < 0) {
                out.println("<h3>Empty date range.</h3>");
                failed = true;
            }
        }

        if(failed){
            out.println("<br/>\n");
            out.println("Missing or Invalid Parameters.<br/>\n");
            out.println("<br/>Click below to try another query:<br/>" );
            out.println("<a href=\"askQuery.html\">Parameter Entry Page</a><br/>\n" +
                    "</body></html>");
            return;
        }

        // if we got this far, we have strings for the parameters
        qry = conn.prepareStatement(

                // There is no SQL standard for formatting reals, so this gives more control
                " with "  +
                        " contribDates as (select z.cname, y.sname, z.amt as contribAmt " +
                        "                 from corporations x, senators y, contributes z " +
                        "                 where z.cname = x.cname and z.sname = y.sname " +
                        "                      and ? <= z.cdate and z.cdate <= ? " +
                        "                 order by z.cname) " +
                        " select distinct x.cname, y.sname, " +
                        "        (select coalesce(count(*), 0) " +
                        "         from contribDates z " +
                        "         where x.cname = z.cname and z.sname = y.sname) " +
                        "               as contribCount, " +
                        "        (select coalesce(sum(contribAmt), 0) " +
                        "         from contribDates z " +
                        "         where x.cname = z.cname and z.sname = y.sname) " +
                        "               as contribSum " +
                        "from corporations x, senators y " +
                        "where ? <= x.cname and x.cname <= ? and ? <= y.sname and y.sname <= ? " +
                        "group by x.cname, y.sname " +
                        "order by x.cname, y.sname");

        qry.setDate(1,java.sql.Date.valueOf(dLo));
        qry.setDate(2,java.sql.Date.valueOf(dHi));
        qry.setString(3,cLo);
        qry.setString(4,cHi);
        qry.setString(5,sLo);
        qry.setString(6,sHi);

        ResultSet rset = qry.executeQuery();
        ResultSetMetaData rsmd = rset.getMetaData();
        int numCols = rsmd.getColumnCount();
        int numRows = 0;
%>

<table class="mytable">
    <tr>
        <%
            for (int i = 1; i <= numCols; i++) {
        %>

        <td class="header"><%= rsmd.getColumnLabel(i) %></td>

        <%
            }
        %>

    </tr>

    <%
        while (rset.next()) {
            numRows++;
    %>
    <tr>
        <%
            for (int i = 1; i <= numCols; i++) {
        %>
        <td class="cdata"><%= rset.getString(i) %></td>
        <%
            }
        %>
    </tr>
    <%
            }
    %>
    <td>Specified Query Generated: <%= numRows %> Rows</td>
    <%
            conn.close();
        }
        catch (Exception e){
            out.println("Some error occurred.<br/>" );
            out.println(e.getMessage());
            out.println("<br/>Click below to try another query:<br/>" );
            out.println("<a href=\"askQuery.html\">Parameter Entry Page</a><br/>   " +
                    "</body></html>");
        }
    %>

</table>
<a href="askQuery.html"><br/>Try Different Parameters</a>
</body>
</html>