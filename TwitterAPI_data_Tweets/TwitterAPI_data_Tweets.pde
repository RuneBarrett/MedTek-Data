import http.requests.*;
import de.bezier.data.sql.*;

PrintWriter output;
SQLite db;
ArrayList<String> id_string_lists;
String bearer;

//################ Settings
String endpoint = "https://api.twitter.com/2/tweets?ids=";
//Comma-separated request fields (NO spaces) - these fields appear in the response.
String e_fields = "attachments.media_keys";//"referenced_tweets.id,entities.mentions.username"; //expansion fields (mentioned/referenced/reply etc.)
String t_fields = "text,created_at,author_id,in_reply_to_user_id,attachments,public_metrics,entities"; //tweet fields
String u_fields = "name,description"; //user fields
String m_fields = "duration_ms,media_key,preview_image_url,public_metrics,type,url"; //media fields     


int numRequests = 1; //set to -1 to handle the full database
boolean useDelay = false;
int delayAmount = 2800;

public void setup() 
{
  size(400, 400);
  smooth();
  output = createWriter("tweetData.sql"); 
  db = new SQLite( this, "../tweets1.db" );
  long t_id;
  int count = 1; 
  id_string_lists = new ArrayList<String>();
  bearer = loadStrings("../secrets.txt")[0];

  if ( db.connect() ) {
    String Q = "select distinct id, user from tweet order by id"; //error tests - [not found error:  where user='BendixenPebe'][wierdly formatted description: where user = 'AndersKLund'][user suspended error: where user = 'GitteMadsen4']
    String notFound = "";
    db.query(Q);
    println();

    int temp_id_list_length = 0;
    String temp_id_list = "";

    //1. Collect needed data from database and separate into comma-separated string lists 
    while (db.next () && count <= numRequests || numRequests == -1) {
      if (useDelay) delay(delayAmount);
      t_id = db.getLong("id");
      temp_id_list += t_id +",";
      temp_id_list_length++;

      //println(temp_id_list, temp_id_list_length, temp_id_list.length());
      if (temp_id_list_length >= 100) {
        id_string_lists.add(temp_id_list.substring(0, temp_id_list.length()-1));
        temp_id_list="";
        temp_id_list_length = 0;
      }
      //if(count <130){count++; continue;} //skip until number # to run/debug from there

      count++;
    }
    if (temp_id_list_length > 0) //Add remaining tweet id's to list if there are any
      id_string_lists.add(temp_id_list.substring(0, temp_id_list.length()-1));

    //2. Build requests with 100 id's in each
    for (String s : id_string_lists) {
      println("Getting tweets with id's: "+s);
      //build request
      String request = endpoint+s;
      if (e_fields != "")
        request+= "&expansions="+e_fields;
      if (t_fields != "")
        request+="&tweet.fields="+t_fields;
      if (u_fields != "")
        request+="&user.fields="+u_fields;
      if (m_fields != "")
        request+="&media.fields="+m_fields;

      //send request
      //GetRequest get = sendTAPIRequest(endpoint+s+"&expansions=author_id&tweet.fields="+t_fields+"&user.fields="+u_fields);
      println("request: "+request);
      GetRequest get = sendTAPIRequest(request);
      println(get.getContent());
    }

    //println("Done in "+millis()+"ms"); //  /60+" seconds.");
    printTime();
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

void printTime() {
  println();
  int x = millis()/1000;
  //int m_seconds 
  int seconds = x % 60;
  x /= 60;
  int minutes = x % 60;
  x /= 60;
  int hours = x % 24;
  x /= 24;
  int days = x;

  String timeStr = "Done in ";
  if (days > 0) timeStr+=days+" days ";
  if (hours > 0) timeStr+=hours+" hours ";
  if (minutes > 0) timeStr+=minutes+" minutes and ";
  if (seconds > 0) timeStr+=seconds+" seconds.";

  //println("Done in", x, "days", hours, "hours", minutes, "minutes and", seconds, "seconds"  );
  println(timeStr);
}
