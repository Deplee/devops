
//println "${BUILD_NUMBER}"
//println "${JENKINS_URL}"
//println "${BUILD_URL}"
//println "${JOB_URL}"
// println "${RUN_CHANGES_DISPLAY_URL}"
println "${JENKINS_HOME}"
println" ${JOB_NAME}"//

node ('Ubuntu Main') {
    stage("1"){
        writeFile file: "/home/izuna/j.txt", 
text: """
1kekwait
"""
println "${stageResult}"
    }
}



//println "${BUILD_NUMBER}"
// println "${JENKINS_URL}"
//println "${BUILD_URL}"
// println "${JOB_URL}"
// println "${RUN_CHANGES_DISPLAY_URL}"

node ('Ubuntu Main') {
 try{
    stage("st-1"){
        println("---------->")
        println("stage-1")
        println("---------->")
        sh """
            ls -la /home/izuna 
            """
        }
    stage("st-2"){
        println("---------->")
        println("stage-2")
        println("---------->")
        pwsh script: """
        write-host "`npwsh good`n"
        """
    }
    stage("Sucess-notify"){
        println("---------->")
        println("good notify")
        println("---------->")
    }
     }catch (Exception e) {
        stage("Err-notify")
        def getMsg = e.getMessage()
        def getCause = e.getCause()
        println("[Err]. Reason is ${getMsg}")
        //println ("Reason is: ${getMsg}" )//, cause is: ${getCause}")
    } 
} 
