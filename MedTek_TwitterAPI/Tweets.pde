/*
* Creates and returns a list of requests using the given list of id's and the Twitter API
 */
ArrayList<String> processTweets() {
  println("\nCreating tweet requests..");
  //################ Request Settings
  String e_fields = "attachments.media_keys&media.fields=preview_image_url,url";//"attachments.media_keys,referenced_tweets.id,author_id";//"attachments.media_keys";//"referenced_tweets.id,entities.mentions.username"; //expansion fields (mentioned/referenced/reply etc.)
  String t_fields = "public_metrics";//"entities, media"; //tweet fields
  String u_fields = "";//"name,description"; //user fields
  String m_fields = "public_metrics";//"duration_ms,height,media_key,preview_image_url,public_metrics,type,url,width";//"duration_ms,media_key,preview_image_url,public_metrics,type,url"; //media fields  
  
  output = createWriter("data/tweet_metrics.sql");
  output2 = createWriter("data/tweet_img.sql");

  //setup
  id_string_lists = new ArrayList<String>();
  //db = new SQLite( this, db_path);
  long t_id;
  int count = 1;

  //Generate requests
  if ( db.connect() ) {
    String Q = tweetQuery;//"select distinct id from tweet order by id";
    //String notFound = "";
    db.query(Q);
    println("\nQuery \"" + Q +"\" done after "+printTime());

    //Used for creating comma separated id lists such as "1234,2345,....,3456" with up to 100 id's in each (Twitter limit)
    int temp_id_list_length = 0; //For limiting to 100
    String temp_id_list = ""; //"1234,2345,....,3465" etc

    //#1. Collect needed data from database and separate into comma-separated string lists 
    while (db.next () && count <= numRequests) {
      //if(count <130){count++; continue;} //uncomment to skip until number # to run/debug from there
      t_id = db.getLong("id");
      temp_id_list += t_id +",";
      temp_id_list_length++;

      //println(temp_id_list, temp_id_list_length, temp_id_list.length());
      if (temp_id_list_length >= 100) {
        id_string_lists.add(temp_id_list.substring(0, temp_id_list.length()-1));
        temp_id_list="";
        temp_id_list_length = 0;
      }

      count++;
    }
    if (temp_id_list_length > 0) //Add remaining tweet id's to list if there are any
      id_string_lists.add(temp_id_list.substring(0, temp_id_list.length()-1));
    println("Data collected from query result and id lists created after "+printTime());
  }

  //2. Build requests for each of the id string lists
  ArrayList<String> requests = new ArrayList<String>();
  int counter = 0;
  for (String s : id_string_lists) {
    //println("Getting tweets with id's: "+s);
    //build request
    String request = endpoint+s;
    if (e_fields != "")
      request+= "&expansions="+e_fields;
    if (t_fields != "")
      request+="&tweet.fields="+t_fields;
    //if (u_fields != "")
    //  request+="&user.fields="+u_fields;
    //if (m_fields != "")
    //  request+="&expansions=attachments.media_keys&media.fields="+m_fields;
    //request+="&tweet_mode=extended";
    //request+= "&tweet.fields=created_at&expansions=author_id,attachments.media_keys&media.fields=media_key,type,url&user.fields=profile_image_url";
    requests.add(request);
    //send request
    //GetRequest get = sendTAPIRequest(endpoint+s+"&expansions=author_id&tweet.fields="+t_fields+"&user.fields="+u_fields);
    println("request "+counter+": "+request);
    //GetRequest get = sendTAPIRequest(request);
    //println(get.getContent());
    counter++;
  }
  println("Number of requests created: "+requests.size()+ " in "+printTime()+"\n");
  return requests;
}
