#!/usr/bin/env groovy

/* method GET */
try { 
    def get = new URL("http://localhost:8080").openConnection();
    def getRC = get.getResponseCode();
    println(getRC);
    if (getRC.equals(200)) {
        println(get.getInputStream().getText());
        }
        else if (getRC.equals(400|403)){
            println("Result of HTTP GET request is: " + getRC);
            } 
            else { 
                println ""
                }
}
catch (Exception ex) {
    println "[ERROR]. Exception detected"
    //exit 1
}

/* method POST */
def post = new URL("https://httpbin.org/post").openConnection();
def message = '{message:"test", info:"Kirill"}'
post.setRequestMethod("POST")
post.setDoOutput(true)
post.setRequestProperty("Content-Type", "application/json")
post.getOutputStream().write(message.getBytes("UTF-8"));
def postRC = post.getResponseCode();
println("Result of HTTP POST Request is:" + postRC);
if (postRC.equals(200)) {
    println(post.getInputStream().getText());
}
