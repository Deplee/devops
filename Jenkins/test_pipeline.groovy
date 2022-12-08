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
            name: "Test String",
            defaultValue: "",
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
            println("---->")
            println("Stage 2 is ok")
            println("---->")
        
    }
}