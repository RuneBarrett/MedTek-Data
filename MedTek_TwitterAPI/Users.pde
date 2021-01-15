ArrayList<String> processUsers() {
  println("\nCreating user requests..");
  //################ Request Settings
  String fields = "created_at,description,public_metrics,profile_image_url,location,url,pinned_tweet_id"; //Comma-separated request fields (NO spaces) - these fields appear in the response.
  id_string_lists = new ArrayList<String>();
  //requests = new ArrayList<String>();
  output = createWriter("data/userData.sql"); 
  String user_n;
  int count = 1;

  if ( db.connect() ) {
    String Q = "select distinct user from user"; //error tests - [not found error:  where user='BendixenPebe'][wierdly formatted description: where user = 'AndersKLund'][user suspended error: where user = 'GitteMadsen4']
    //String notFound = "";
    db.query(Q);
    println("\nQuery \"" + Q +"\" done after "+printTime());

    //Used for creating comma separated id lists such as "1234,2345,....,3456" with up to 100 id's in each (Twitter limit)
    int temp_id_list_length = 0; //For limiting to 100
    String temp_id_list = ""; //"1234,2345,....,3465" etc

    while (db.next() && count <= numRequests) {
      user_n = db.getString("user");
      temp_id_list += user_n +",";
      temp_id_list_length++;

      if (temp_id_list_length >= 100) {
        id_string_lists.add(
          temp_id_list.substring(
          0, temp_id_list.length()-1));
        temp_id_list="";
        temp_id_list_length = 0;
      }

      count++;
    }
    if (temp_id_list_length > 0) //Add remaining tweet id's to list if there are any
      id_string_lists.add(temp_id_list.substring(0, temp_id_list.length()-1));
    println("Data collected from query result and id lists created after "+printTime());
  }
  //#2
  ArrayList<String> requests = new ArrayList<String>();

  for (String s : id_string_lists) {
    //build request
    String request = endpoint+fields+"&usernames="+s;
    requests.add(request);
  }
  println("Number of requests created: "+requests.size()+ " in "+printTime()+"\n");

  return requests;
}
