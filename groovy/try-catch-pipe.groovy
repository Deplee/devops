
//println "${BUILD_NUMBER}"
// println "${JENKINS_URL}"
//println "${BUILD_URL}"
// println "${JOB_URL}"
// println "${RUN_CHANGES_DISPLAY_URL}"


node ('Ubuntu Main') {
 try{
    stage("st-1"){
        sh """
            ls -la /home/izuna 
            """
            }
    }catch (Exception e) {
        def getMsg = e.getMessage()
        def getCause = e.getCause()
        println ("Reason is: ${getMsg}" )//, cause is: ${getCause}")
    }

try {
    stage("st-2"){
        pwsh script: """
        kekwai.org
        """
    }
     }catch (Exception e) {
        def getMsg = e.getMessage()
        def getCause = e.getCause()
        println ("Reason is: ${getMsg}" )//, cause is: ${getCause}")
    } 
} 


