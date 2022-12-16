def sucess_notify(Map tmap = [:]){
    def post = new URL("URL").openConnection();
    String body = '{ "channel": "#devops-tst","text": "Build Number: %s\\nJob Name: %s\\nURL: %s\\nResult: %s"}' //, "var": "%s"}'
    f_body = String.format("$body", "${tmap.nomerbilda}", "${tmap.jobname}", "${tmap.url}", "${tmap.result}")
    post.setRequestMethod("POST")
    post.setDoOutput(true)
    post.setRequestProperty("Content-Type", "application/json")
    post.setRequestProperty("X-Auth-Token", "TOKEN")
    post.setRequestProperty("X-User-Id", "USERID")
    post.getOutputStream().write(f_body.getBytes("UTF-8"));
    def postRC = post.getResponseCode();
    println("Result of HTTP POST Request is:" + postRC);
    if (postRC.equals(200)) {
        println(post.getInputStream().getText());
    }
}
def failure_notify(Map tmap = [:]){
    def post = new URL("URL").openConnection();
    String body = '{ "channel": "#name","text": "Build Number: %s\\nJob name: %s\\nURL: %s\\nFail message: %s"}' //, "var": "%s"}'
    f_body = String.format("$body", "${tmap.nomerbilda}", "${tmap.jobname}", "${tmap.url}", "${tmap.fail_msg}")
    post.setRequestMethod("POST")
    post.setDoOutput(true)
    post.setRequestProperty("Content-Type", "application/json")
    post.setRequestProperty("X-Auth-Token", "TOKEN")
    post.setRequestProperty("X-User-Id", "USERID")
    post.getOutputStream().write(f_body.getBytes("UTF-8"));
    def postRC = post.getResponseCode();
    println("Result of HTTP POST Request is:" + postRC);
    if (postRC.equals(200)) {
        println(post.getInputStream().getText());
    }
}


//test("123")
//success_build_notify(nomer: "123")

// { \"channel\": \"#devops-tst\",\"text\": \"test text\", \"var\": \"${info.BUILD_NUMBER}\"}

def call(String name){
    echo "Test value is: ${name}"
}



