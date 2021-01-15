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

void selectDB(File f) {
  db_path = f.getAbsolutePath();
}

void selectSecret(File f) {
  secrets_path = f.getAbsolutePath();
}

void whileDelay(int time) {
  timer = millis()+time;
  while (timer-millis()>0) {
  }
}

String printTime() {
  //println();
  int x = (millis()-(int)startTime)/1000;
  //int m_seconds 
  int seconds = x % 60;
  x /= 60;
  int minutes = x % 60;
  x /= 60;
  int hours = x % 24;
  x /= 24;
  int days = x;

  String timeStr = ""; //Done in 
  if (days > 0) timeStr+=days+" days ";
  if (hours > 0) timeStr+=hours+" hours ";
  if (minutes > 0) timeStr+=minutes+" minutes and ";
  if (seconds > 0) timeStr+=seconds+" seconds.";

  //println(timeStr);
  return(timeStr);
}
