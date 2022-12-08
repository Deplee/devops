properties([
    parameters([
        choice(
            name: "Test Param 1",
            choices: [
                "Test Param Choise 1",
                "Test Param Choise 2"
            ],
            description: ""
            ),
        string (
            name: "Test_String",
            defaultValue: "123",
            description: ""
        ),
        booleanParam(
            name: "Test Boolean",
            defaultValue: true,
            description: ""
        )
        ])
    ])
node ('Ubuntu Main'){
    stage("Test stage 1"){
            println("---->")
            println("Stage 1 is ok")
            println("---->")
        
    }
    stage("Test stage 2"){
           // if (params.Test_String == "456"){
            println("---->")
            println("Stage 2 is ok")
            println("---->")//}
        
    }
}