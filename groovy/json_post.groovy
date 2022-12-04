/*def baseUrl = new URL('https://httpbin.org/post')
def queryString = 'id=1&name=Test&job=sklad'
def connection = baseUrl.openConnection()
connection.with {
  doOutput = true
  requestMethod = 'POST'
  outputStream.withWriter { writer ->
    writer << queryString
  }
  println content.text
}*/
/* GET method */
try{
  def get = new URL("https://httpbin.org/get").openConnection();
  //def get = new URL("http://192.168.0.12:5001/?server=db&username=root").openConnection();
  def getRC = get.getResponseCode();
  println(getRC)
  println(get.getInputStream().getText());
  if (getRC.equals(200)){
    post()
  } else {
    println "[ERROR]. HTTP GET Request status is not 200."
  }
} catch (Exception ex) {
  println "[ERROR]. Exception from GET request."
}


 /* POST method */
  static void post(){
  try{
    def post = new URL ("https://httpbin.org/post").openConnection()
    def body = '{"name":"Test", "value": "5", "job": "tester", "phone": "1234567890"}'
    post.setRequestMethod("POST")
    post.setRequestProperty("Content-Type","application/json")
    post.setDoOutput(true)
    post.getOutputStream().write(body.getBytes("UTF-8"))
    def postRC = post.getResponseCode()
    //println(postRC)
    println(post.getInputStream().getText())
} catch(Exception ex){
  println "[ERROR.] Exception from POST request."
  }
}

/* post data */
