JSONObject get = loadJSONObject("../data/new1.json");
PrintWriter output = createWriter("testing.sql");
PrintWriter output2 = createWriter("testing2.sql");

//Get the array containing users
JSONArray tweet_objects = get.getJSONArray("data");
JSONArray tweet_media_objects = get.getJSONObject("includes").getJSONArray("media");

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
  if (t_attachments_obj != null) {
    String media_key = (String)t_attachments_obj.getJSONArray("media_keys").get(0);//getString("media_keys");
    println("tobj", media_key);
    println(tweet_media_objects.getJSONObject(0).getString("media_key"));
    for (int j = 0; j < tweet_media_objects.size(); j++) {
      if (tweet_media_objects.getJSONObject(j).getString("media_key").equals(media_key))
        output2.println("INSERT INTO image VALUES ("
          +"'"+tweet_obj.getString("id")+"', "
          +"'"+tweet_media_objects.getJSONObject(j).getString("url")+"');");
    }
  }
}
output.flush(); // Writes the remaining data to the file
output.close();
output2.flush(); // Writes the remaining data to the file
output2.close();
println("done");
