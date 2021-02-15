import http.requests.*;
import de.bezier.data.sql.*;
import static javax.swing.JOptionPane.*;

//DB & Output
SQLite db;
String db_path = "../tweets1.db";
String secrets_path ="../secrets.txt";
PrintWriter output;
PrintWriter output2;

//GUI Controls
boolean running = false;
float timer = 0;
float startTime;
String currentType = "";
//GUI Vars
Roller[] rollers;
String status = "Pick an endpoint";
String infoText = "Select a type below and click go";

//API Controls
int numRequests = 3000000; 
boolean runAll = true;
boolean useDelay = true;
int delayAmount = 3000;
String endpoint = "";

//API Vars
ArrayList<String> id_string_lists;
String bearer;
ArrayList<String> requests;
String tweetQuery = "select distinct id from tweet";
String userQuery = "select distinct user from user";

//debug
int progress = 0;
int progress_lim = 1;

//Other controls
boolean startRequestProcess, startUserProcess, processingRequests;// = false;
//boolean startUserProcess = false;


public void setup() 
{

  background(0);
  size(600, 400);
  setupRollers(); //moving int's used by GUI

  //output = createWriter(currentType+"_data.sql"); 
  //db = new SQLite( this, db_path);
  requests = new ArrayList<String>();
  bearer = loadStrings(secrets_path)[0];
  db = new SQLite( this, db_path);
}

public void draw() {
  //final String id = showInputDialog("Please enter new ID");
  gui_loop(); 

  //### Run the data generator after 'go' button is pressed
  //#Handle tweets
  if (startRequestProcess) {
    background(0);
    if (currentType == "tweet")
      requests = processTweets();
    else if (currentType == "user")
      requests = processUsers();
    progress = 0; //for progress bar
    progress_lim = requests.size(); //for progress bar
    startRequestProcess = false;
    infoText = requests.size()+" requests ready to be processed";
    //processingTweets = true; //flag to begin sending requests
    //return;
  }
  //Process a request each frame instead of in a loop so the processing draw loop can keep going
  if (processingRequests && requests.size() > 0) {
    GetRequest get = sendTAPIRequest(requests.get(0));
    println("Processed "+(progress_lim-requests.size()+1) +" requests in "+printTime()+". "+get.getContent().length());

    //Save json response for testing wo worrying about request limits
    //saveJSONObject(parseJSONObject(get.getContent()), "data/new"+(progress_lim-requests.size()+1)+".json");
    saveJSONObject(parseJSONObject(get.getContent()), "data/response"+".json");


    if (currentType.equals("user"))
      parseJSONandSavetoSQL_User(get);
    if (currentType.equals("tweet"))
      parseJSONandSavetoSQL_Tweet(get);


    requests.remove(0);
    if (useDelay)whileDelay(delayAmount);
    progress++;
  } else if (processingRequests) {//When requests is empty, complete process 
    processingRequests = false;
    running = false;
    status = "Success";
    infoText = "Done in "+printTime();
    output.flush(); // Writes the remaining data to the file
    output.close();
    if (currentType.equals("tweet")) {
      output2.flush(); // Writes the remaining data to the file
      output2.close();
    }
    background(0);
  }
  //#Handle users
  gui_loop();
}

void mousePressed() {
  if (bBut_over && requests.size() > 0) {
    processingRequests = true;
    startTime = millis();
  }
  if (!running) {
    //if(requests.size() > 0){}
    if (goBut_over) {
      println("Current type: "+currentType);
      if (currentType!= "tweet" && currentType != "user") {
        status = "Select Tweets or Users below first";
        return;
      }
      loadingScreen();
      running = true;
      startRequestProcess = true;
      startTime = millis();

      //requests = processTweets();
      //printArray(requests.size());
    }
    if (tBut_over) {
      status = "Ready";
      currentType = "tweet";
      endpoint = "https://api.twitter.com/2/tweets?ids=";
      infoText="Tweet query: \""+tweetQuery+"\"";
    }
    if (uBut_over) {
      status = "Ready";
      currentType = "user";
      endpoint = "https://api.twitter.com/2/users/by?user.fields=";
      infoText="User query: \""+userQuery+"\"";
    }
    if (dbBut_over)
      selectInput("Select a file to process:", "selectDB");
    if (sBut_over)
      selectInput("Select a file to process:", "selectSecret");
  }
}

void parseJSONandSavetoSQL_User(GetRequest get) {
  //Get the array containing users
  JSONArray user_objects = parseJSONObject(get.getContent()).getJSONArray("data");
  for (int i = 0; i < user_objects.size(); i++) {
    JSONObject user_obj = user_objects.getJSONObject(i);
    JSONObject u_metrics_obj = user_obj.getJSONObject("public_metrics");

    output.println("INSERT INTO user1 VALUES ("
      +"'"+user_obj.getString("username") +"', "
      //+u_metrics_obj.getInt("tweet_count")+", "
      +u_metrics_obj.getInt("following_count")+", "
      +u_metrics_obj.getInt("followers_count")+", "
      +u_metrics_obj.getInt("listed_count")+", "
      +"'"+user_obj.getString("url")+"',"
      +"'"+user_obj.getString("location")+"',"
      +"'"+user_obj.getString("created_at")+"',"
      +"'"+user_obj.getString("description").replaceAll("'", "''").replaceAll("\\r\\n|\\r|\\n", " ")+"',"
      +"'"+user_obj.getString("profile_image_url")+"');"
      );
  }
}

void parseJSONandSavetoSQL_Tweet(GetRequest get) {
  ////Get the array containing users
  //JSONArray tweet_objects = parseJSONObject(get.getContent()).getJSONArray("data");
  //JSONArray tweet_media_objects = parseJSONObject(get.getContent()).getJSONObject("includes").getJSONArray("media");

  //for (int i = 0; i < tweet_objects.size(); i++) {
  //  JSONObject tweet_obj = tweet_objects.getJSONObject(i);
  //  JSONObject t_metrics_obj = tweet_obj.getJSONObject("public_metrics");

  //  output.println("INSERT INTO Image VALUES ("
  //    //+"'"+user_obj.getString("username") +"', "

  //    );
  //}

  //Get the array containing users
  JSONArray tweet_objects = parseJSONObject(get.getContent()).getJSONArray("data");
  JSONArray tweet_media_objects;
  if (parseJSONObject(get.getContent()).getJSONObject("includes") != null)
    tweet_media_objects = parseJSONObject(get.getContent()).getJSONObject("includes").getJSONArray("media");
  else 
    tweet_media_objects = null;

  for (int i = 0; i < tweet_objects.size(); i++) {
    JSONObject tweet_obj = tweet_objects.getJSONObject(i);
    JSONObject t_metrics_obj = tweet_obj.getJSONObject("public_metrics");

    output.println("INSERT INTO tweet_metrics VALUES ("
      +"'"+tweet_obj.getString("id") +"', "
      +"'"+t_metrics_obj.getInt("like_count") +"', "
      +"'"+t_metrics_obj.getInt("reply_count") +"', "
      +"'"+t_metrics_obj.getInt("quote_count") +"', "
      +"'"+t_metrics_obj.getInt("retweet_count") +"'); "
      );

    JSONObject t_attachments_obj = tweet_obj.getJSONObject("attachments");
    if (t_attachments_obj != null && tweet_media_objects != null) {
      String media_key = (String)t_attachments_obj.getJSONArray("media_keys").get(0);//getString("media_keys");
      //println("tobj", media_key);
      //println(tweet_media_objects.getJSONObject(0).getString("media_key"));
      for (int j = 0; j < tweet_media_objects.size(); j++) {
        if (tweet_media_objects.getJSONObject(j).getString("media_key").equals(media_key))
          output2.println("INSERT INTO image VALUES ("
            +"'"+tweet_obj.getString("id")+"', "
            +"'"+tweet_media_objects.getJSONObject(j).getString("url")+"');");
      }
    }
  }
}
