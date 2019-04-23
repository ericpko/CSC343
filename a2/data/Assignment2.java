import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
//import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try {
            connection = DriverManager.getConnection(url, username, password);
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        try {
            connection.close();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
        ArrayList<Integer> elections = new ArrayList<>();
        ArrayList<Integer> cabinets = new ArrayList<>();

        try {
            String query = "SELECT election_id, cabinet.id " +
                           "FROM parlgov.country, parlgov.cabinet " +
                           "WHERE cabinet.country_id = country.id " +
                           "AND country.name = ? " +
                           "ORDER BY start_Date DESC";

            PreparedStatement statement = connection.prepareStatement(query);
            statement.setString(1, countryName);

            ResultSet res = statement.executeQuery();

            while (res.next()) {
                int elec = res.getInt(1);
                int cab = res.getInt(2);

                // If the elections list doesn't contain this election, add it
                if (!elections.contains(elec)) {
                    elections.add(elec);
                }

                if (!cabinets.contains(cab)) {
                    cabinets.add(cab);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }

        return new ElectionCabinetResult(elections, cabinets);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!

        List<Integer> similarPoliticians = new ArrayList<Integer>();
    
        try {
            String query = "select concat(p1.description, p1.comment) as politician1, concat(p2.description, p2.comment) as politician2, p1.id, p2.id "+
             "from parlgov.politician_president p1, parlgov.politician_president p2 "+
             "where p1.id = ? and p1.id < p2.id ";

            PreparedStatement statement = connection.prepareStatement(query);
            statement.setInt(1, politicianName);

            ResultSet res = statement.executeQuery();

            while (res.next()) {
                String politician1 = res.getString(1);
                String politician2 = res.getString(2);
                Integer politician2id= Integer.valueOf(res.getInt(4));

                double score = similarity(politician1, politician2);

                //if similarity score if above the threshold add the second politician into the return set
                if(score > threshold){
                    similarPoliticians.add(politician2id);
                }

            }

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }

        return similarPoliticians;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.

        try {
            Assignment2 a2 = new Assignment2();
            a2.connectDB("jdbc:postgresql://localhost/a2", "erickoehli", "");

            System.out.println(a2.electionSequence("Canada").toString());
            // System.out.println(a2.findSimilarPoliticians(22, .1f).toString());

            a2.disconnectDB();

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

}
