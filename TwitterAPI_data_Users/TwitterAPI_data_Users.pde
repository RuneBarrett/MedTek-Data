import http.requests.*;
import de.bezier.data.sql.*;

PrintWriter output;
SQLite db;
String bearer;

//################ Settings
String endpoint = "https://api.twitter.com/2/users/by?user.fields=";
String fields = "created_at,description,public_metrics,profile_image_url,location,url,pinned_tweet_id"; //Comma-separated request fields (NO spaces) - these fields appear in the response.

int numRequests = 3; //set to -1 to handle the full database
boolean useDelay = false;
int delayAmount = 2800;

public void setup() 
{
  size(400, 400);
  smooth();
  output = createWriter("userData.sql"); 
  db = new SQLite( this, "../tweets1.db" );
  bearer = loadStrings("../secrets.txt")[0];
  String user;
  int count = 1;

  if ( db.connect() ) {
    String Q = "select distinct user from user"; //error tests - [not found error:  where user='BendixenPebe'][wierdly formatted description: where user = 'AndersKLund'][user suspended error: where user = 'GitteMadsen4']
    String notFound = "";
    db.query(Q);
    println();

    while (db.next () && count <= numRequests || numRequests == -1) {
      if (useDelay) delay(delayAmount);
      user = db.getString("user");

      //if(count <130){count++; continue;} //skip until number # to run/debug from there

      //User the TwitterAPI to gather data from the username
      GetRequest get = sendTAPIRequest(endpoint+fields+"&usernames="+user);

      //Make sure the user was found/not suspended, handle other errors
      if (get.getContent().indexOf("Could not find user with usernames")>0 || get.getContent().indexOf("User has been suspended")>0) { 
        notFound += user+", ";
        println("The username ["+user+"] does not exist\n");
        //println("\nERROR RESPONSE: "+get.getContent()+"\n");
        count++;
        continue;
      } else if (get.getContent().indexOf("errors")>0) {
        println("\nERROR RESPONSE: "+get.getContent()+"\n");
      }

      //Split the incoming jsondata into processing JSONObjects 
      JSONArray response = parseJSONObject(get.getContent()).getJSONArray("data");
      //JSONArray response = loadJSONObject("testResponse.json").getJSONArray("data");
      JSONObject data = response.getJSONObject(0);
      JSONObject data_metrics = data.getJSONObject("public_metrics");
      printUser(data, data_metrics, count);

      //Add a user line to the generated SQL file
      output.println("INSERT INTO user1 VALUES ("
        +"'"+data.getString("username") +"', "
        +data_metrics.getInt("tweet_count")+", "
        +data_metrics.getInt("following_count")+", "
        +data_metrics.getInt("followers_count")+", "
        +data_metrics.getInt("listed_count")+", "
        +"'"+data.getString("url")+"',"
        +"'"+data.getString("location")+"',"
        +"'"+data.getString("created_at")+"',"
        +"'"+data.getString("description").replaceAll("'", "''").replaceAll("\\r\\n|\\r|\\n", " ")+"',"
        +"'"+data.getString("profile_image_url")+"');"
        );

      count++;
    }

    println("Done in "+millis()+"ms"); //  /60+" seconds.");
    if (notFound != "") println("Not existing: "+ notFound +"\n");
    output.flush(); // Writes the remaining data to the file
    output.close();
  }
}
// ################## HANDLERS
GetRequest sendTAPIRequest(String url) {
  GetRequest get = new GetRequest(url);
  get.addHeader("authorization", "Bearer "+bearer);
  get.send();
  return get;
}

// ################## HELPERS
void printUser(JSONObject data, JSONObject data_metrics, int count) {
  print("User "+ count + ": ");
  //Metrics
  print("Tweets "+ data_metrics.getInt("tweet_count") +", ");
  print("followers "+ data_metrics.getInt("followers_count") +", ");
  print("following "+ data_metrics.getInt("following_count") +", ");
  print("listed "+ data_metrics.getInt("listed_count") +", ");

  //Userdata
  println();
  print("ID: " + data.getString("id") + ", ");
  print("Name: " + data.getString("username") + ", ");
  print("User name: " + data.getString("username") + ", ");
  print("Website: " + data.getString("url") + ", ");
  print("ProfileImg: " + data.getString("profile_image_url") + ", ");
  print("Location: " + data.getString("location") + ", ");
  print("Created at: " + data.getString("created_at") + ", ");
  print("Description: " + data.getString("description").replaceAll("\\r\\n|\\r|\\n", " "));

  println("\n");
}
